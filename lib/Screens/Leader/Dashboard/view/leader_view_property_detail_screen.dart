import 'package:cached_network_image/cached_network_image.dart';
import 'package:elzsi/Api/api_call.dart';
import 'package:elzsi/Database/database_helper.dart';
import 'package:elzsi/Screens/Leader/Dashboard/view/leader_agent_entries_screen.dart';
import 'package:elzsi/Screens/Leader/Dashboard/view/leader_agent_units_screen.dart';
import 'package:elzsi/Utils/colors.dart';
import 'package:elzsi/Utils/common.dart';
import 'package:elzsi/Utils/horizontalspace.dart';
import 'package:elzsi/utils/navigations.dart';
import 'package:elzsi/Utils/verticalspace.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
// import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class LeaderViewPropertyDetailScreen extends StatefulWidget {
  const LeaderViewPropertyDetailScreen({super.key, required this.projectNo});

  final int projectNo;

  @override
  State<LeaderViewPropertyDetailScreen> createState() =>
      _LeaderViewPropertyDetailScreenState();
}

class _LeaderViewPropertyDetailScreenState
    extends State<LeaderViewPropertyDetailScreen> {
  late Future _propertyDetail;

  Map? thisPropertyDetail;
  List? authorizedPersons;

  List? units;
  List? agentUnits;
  List? agentEntries;

  // //FOR FORMATTING DATE
  // String _formatDate(String date) {
  //   DateTime inputDate = DateTime.parse(date);
  //   String formattedDate = DateFormat('dd-MM-yyyy').format(inputDate);
  //   return formattedDate;
  // }

  @override
  void initState() {
    _propertyDetail = _getPropertyDetail();
    super.initState();
  }

  Future<void> _getPropertyDetail() async {
    final userInfo = await DatabaseHelper().initDb();
    var data = {"user_id": userInfo.userId, "project_id": widget.projectNo};

    if (!context.mounted) {
      return;
    }

    final result =
        await Api().getLinkedProjectDetails(data, userInfo.token, context);

    if (result['status'].toString() == '1') {
      setState(() {
        // mySellers.addAll(result['data']);
        thisPropertyDetail = result['data'];
        authorizedPersons = result['data']['is_authorized_persons'];
        units = result['data']['projectunits'];
        agentUnits = result['data']['agentunits'];
        agentEntries = result['data']['agententries'];
      });
    } else if (result['status'].toString() == '3') {
      throw Exception('Device changed');
    }
  }

  //FOR FORMATTING DATE
  String _formatDate(String date) {
    if (date.isEmpty || date == '') {
      return '';
    }
    DateTime inputDate = DateTime.parse(date);
    String formattedDate = DateFormat('dd-MM-yyyy').format(inputDate);
    return formattedDate;
  }

  String _formatDate1(String date) {
    if (date.isEmpty || date == '') {
      return '';
    }
    DateTime inputDate = DateFormat("dd MMM, yyyy").parse(date);
    String formattedDate = DateFormat('dd-MM-yyyy').format(inputDate);
    return formattedDate;
  }

  Future _goToCorrespondingApp(String? type, String data) async {
    if (data.isEmpty || data == '') {
      return;
    }
    try {
      if (type == 'tel') {
        launchUrl(Uri(scheme: type, path: data));
      } else if (type == 'whatsapp') {
        launchUrlString('http://wa.me//+91$data');
      }
    } catch (e) {
      Common().showToast('Failed to launch');
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () {
            Nav().pop(context);
          },
          child: Row(
            children: [
              const HorizontalSpace(width: 7),
              Image.asset(
                'assets/images/prev.png',
                height: 15,
              ),
              const HorizontalSpace(width: 15),
              const Text(
                'View Details',
                style: TextStyle(color: Colors.white, fontSize: 17.5),
              ),
            ],
          ),
        ),
      ),
      body: Container(
        height: screenHeight,
        width: screenWidth,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(13),
            topRight: Radius.circular(13),
          ),
        ),
        child: FutureBuilder(
          future: _propertyDetail,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return SpinKitCircle(
                color: primaryColor,
              );
            } else if (snapshot.hasError) {
              return const Center(child: Text('Failed to fetch data'));
            } else {
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const VerticalSpace(height: 10),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: inputBg,
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(color: inputBorder, width: 2),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CachedNetworkImage(
                            imageUrl: thisPropertyDetail!['is_project_image'],
                            imageBuilder: (context, imageProvider) => Container(
                              height: 175,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image: imageProvider,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            placeholder: (context, url) => Container(
                              height: 175,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8)),
                              child: Shimmer.fromColors(
                                baseColor: const Color(0xFFE2E2E2),
                                highlightColor: Colors.grey.shade50,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(
                                        169, 226, 226, 226),
                                    borderRadius: BorderRadius.circular(13),
                                  ),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                          ),
                          const VerticalSpace(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              thisPropertyDetail!['project_name'],
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                          ),
                          const VerticalSpace(height: 5),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              thisPropertyDetail!['location'],
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                          const VerticalSpace(height: 5),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              'Total units : ${thisPropertyDetail!['no_of_units']}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                          const VerticalSpace(height: 5),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              'Builder Name : ${thisPropertyDetail?['is_builder_name'] ?? ''}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                          const VerticalSpace(height: 7),
                        ],
                      ),
                    ),
                    const VerticalSpace(height: 25),
                    if (authorizedPersons != null &&
                        authorizedPersons!.isNotEmpty)
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: authorizedPersons!.length,
                        itemBuilder: (context, index) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          margin: const EdgeInsets.only(bottom: 7),
                          decoration: BoxDecoration(
                            color: inputBg,
                            borderRadius: BorderRadius.circular(7),
                            border: Border.all(color: inputBorder, width: 2),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Executive Name  :  ${authorizedPersons![index]?['agent_name'] ?? ''}',
                                style: const TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.bold),
                              ),
                              IconButton(
                                onPressed: authorizedPersons![index]
                                                ['agent_mobile'] ==
                                            null ||
                                        authorizedPersons![index]
                                                ['agent_mobile']
                                            .toString()
                                            .isEmpty
                                    ? () {
                                        Common().showToast(
                                            'No mobile number found');
                                      }
                                    : () {
                                        launchUrl(
                                          Uri(
                                              scheme: 'tel',
                                              path:
                                                  '${authorizedPersons?[index]?['agent_mobile'] ?? ''}'),
                                        );
                                      },
                                icon: Image.asset(
                                  'assets/images/phone.png',
                                  height: 26,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    const VerticalSpace(height: 13),
                    if (agentUnits != null && agentUnits!.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Status : ',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16),
                              ),
                              InkWell(
                                onTap: () {
                                  Nav().push(
                                    context,
                                    LeaderAgentUnitsScreen(
                                      agentUnitsList:
                                          agentUnits?.reversed.toList() ?? [],
                                    ),
                                  );
                                },
                                child: Text(
                                  'See All',
                                  style: TextStyle(
                                      color: primaryColor, fontSize: 12),
                                ),
                              )
                            ],
                          ),
                          const VerticalSpace(height: 7),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: inputBg,
                              borderRadius: BorderRadius.circular(7),
                              border: Border.all(color: inputBorder, width: 2),
                            ),
                            child: agentUnits![agentUnits!.length - 1]
                                        ['unit_status'] ==
                                    null
                                ? const Center(
                                    child: Text(
                                      'No status found',
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 11),
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(
                                        width: screenWidth * 0.7,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Unit : ${agentUnits?[agentUnits!.length - 1]?['unit_no'] ?? ''}',
                                              style:
                                                  const TextStyle(fontSize: 12),
                                            ),
                                            // const VerticalSpace(height: 5),
                                            // Text(
                                            //   'Customer Name :  ${agentUnits?[agentUnits!.length - 1]['is_sold_to']?['name'] ?? ''}',
                                            //   style:
                                            //       const TextStyle(fontSize: 12),
                                            // ),
                                            // const VerticalSpace(height: 5),
                                            // Text(
                                            //   'Customer Mobile Number : ${agentUnits?[agentUnits!.length - 1]?['is_sold_to']?['mobile'] ?? ''}',
                                            //   overflow: TextOverflow.clip,
                                            //   style:
                                            //       const TextStyle(fontSize: 12),
                                            // ),
                                            const VerticalSpace(height: 5),
                                            RichText(
                                              text: TextSpan(
                                                children: [
                                                  const TextSpan(
                                                    text: 'Status : ',
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 14),
                                                  ),
                                                  TextSpan(
                                                    text: agentUnits?[agentUnits!
                                                                .length -
                                                            1]?['is_status'] ??
                                                        '-',
                                                    style: const TextStyle(
                                                        color: Colors.blue,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 14),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // IconButton(
                                      //   onPressed:
                                      //       agentUnits![agentUnits!.length - 1]
                                      //                           ?['is_sold_to']
                                      //                       ?['mobile'] ==
                                      //                   null ||
                                      //               agentUnits![agentUnits!
                                      //                               .length -
                                      //                           1]['is_sold_to']
                                      //                       ['mobile']
                                      //                   .toString()
                                      //                   .isEmpty
                                      //           ? () {
                                      //               Common().showToast(
                                      //                   'No mobile number found');
                                      //             }
                                      //           : () {
                                      //               launchUrl(Uri(
                                      //                   scheme: 'tel',
                                      //                   path: agentUnits![agentUnits!
                                      //                               .length -
                                      //                           1]['is_sold_to']
                                      //                       ['mobile']));
                                      //             },
                                      //   icon: Image.asset(
                                      //     'assets/images/phone.png',
                                      //     height: 30,
                                      //   ),
                                      // ),
                                    ],
                                  ),
                          ),
                        ],
                      ),
                    const VerticalSpace(height: 20),
                    if (agentEntries != null && agentEntries!.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Entry',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              InkWell(
                                onTap: () {
                                  Nav().push(
                                      context,
                                      LeaderAgentEntriesScreen(
                                          agentEntriesList:
                                              agentEntries ?? []));
                                },
                                child: Text(
                                  'See All',
                                  style: TextStyle(
                                      color: primaryColor, fontSize: 12),
                                ),
                              )
                            ],
                          ),
                          const VerticalSpace(height: 7),
                          Container(
                            padding: const EdgeInsets.all(10),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: inputBg,
                              borderRadius: BorderRadius.circular(7),
                              border: Border.all(color: inputBorder, width: 2),
                            ),
                            child: agentEntries == null || agentEntries!.isEmpty
                                ? const Center(
                                    child: Text(
                                      'No previous entries',
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 11),
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: screenWidth * 0.7,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Customer Name : ${agentEntries?[0]?['name'] ?? ''}',
                                              style:
                                                  const TextStyle(fontSize: 12),
                                            ),
                                            const VerticalSpace(height: 5),
                                            Text(
                                              'Customer Mobile Number : ${agentEntries?[0]?['mobile'] ?? ''}',
                                              style:
                                                  const TextStyle(fontSize: 12),
                                            ),
                                            const VerticalSpace(height: 5),
                                            Text(
                                              'Unit no: ${agentEntries?[0]?['unit_no'] ?? ''}',
                                              style:
                                                  const TextStyle(fontSize: 12),
                                            ),
                                            const VerticalSpace(height: 5),
                                            Text(
                                              'Block name: ${agentEntries?[0]?['block_name'] ?? ''}',
                                              style:
                                                  const TextStyle(fontSize: 12),
                                            ),
                                            const VerticalSpace(height: 5),
                                            Text(
                                              'Phase name: ${agentEntries?[0]?['phases'] ?? ''}',
                                              style:
                                                  const TextStyle(fontSize: 12),
                                            ),
                                            const VerticalSpace(height: 5),
                                            Text(
                                              'Call / Vist : ${agentEntries?[0]?['is_sourceby'] ?? ''}',
                                              style:
                                                  const TextStyle(fontSize: 12),
                                            ),
                                            const VerticalSpace(height: 5),
                                            Text(
                                              'Comments : ${agentEntries?[0]?['agent_remind_comments'] ?? ''}',
                                              style:
                                                  const TextStyle(fontSize: 12),
                                            ),
                                            const VerticalSpace(height: 5),
                                            Text(
                                              'Entry Date : ${_formatDate1(agentEntries?[0]?['enquired_at'] ?? '')}',
                                              style:
                                                  const TextStyle(fontSize: 12),
                                            ),
                                            const VerticalSpace(height: 5),
                                            Text(
                                              'Reminder Date : ${_formatDate(agentEntries?[0]?['agent_remind_date'] ?? '')}',
                                              style:
                                                  const TextStyle(fontSize: 12),
                                            ),
                                            const VerticalSpace(height: 5),
                                            Text(
                                              'Status : ${agentEntries?[0]?['status'] ?? ''}',
                                              style:
                                                  const TextStyle(fontSize: 12),
                                            ),
                                            const VerticalSpace(height: 5),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        children: [
                                          IconButton(
                                            onPressed: () {
                                              _goToCorrespondingApp(
                                                  'tel',
                                                  agentEntries?[0]?['mobile'] ??
                                                      '');
                                            },
                                            icon: Image.asset(
                                              'assets/images/phone.png',
                                              height: 28,
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: () {
                                              _goToCorrespondingApp(
                                                  'whatsapp',
                                                  agentEntries?[0]?['mobile'] ??
                                                      '');
                                            },
                                            icon: Image.asset(
                                              'assets/images/whatsapp.png',
                                              height: 28,
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                          ),
                        ],
                      ),
                    const VerticalSpace(height: 20),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
