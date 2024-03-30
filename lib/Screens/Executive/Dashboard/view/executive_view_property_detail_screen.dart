import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:elzsi/Api/api_call.dart';
import 'package:elzsi/Database/database_helper.dart';
import 'package:elzsi/Screens/Executive/Dashboard/view/executive_edit_entry_screen.dart';
import 'package:elzsi/Screens/Executive/Dashboard/view/executive_entries_screen.dart';
import 'package:elzsi/Screens/Executive/Dashboard/view/executive_units_screen.dart';
import 'package:elzsi/Screens/Executive/Dashboard/view/executive_new_entry_screen.dart';
// import 'package:elzsi/Utils/button_loader.dart';
import 'package:elzsi/Utils/colors.dart';
import 'package:elzsi/Utils/common.dart';
// import 'package:elzsi/Utils/common.dart';
// import 'package:elzsi/Utils/horizontalspace.dart';
import 'package:elzsi/Utils/navigations.dart';
import 'package:elzsi/Utils/verticalspace.dart';
// import 'package:elzsi/Widgets/units.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
// import 'package:url_launcher/url_launcher.dart';

class ExecutiveViewPropertyDetailScreen extends StatefulWidget {
  const ExecutiveViewPropertyDetailScreen(
      {super.key, required this.projectNo, required this.reloadHomeContent});

  final int projectNo;
  final Function() reloadHomeContent;

  @override
  State<ExecutiveViewPropertyDetailScreen> createState() =>
      _ExecutiveViewPropertyDetailScreenState();
}

class _ExecutiveViewPropertyDetailScreenState
    extends State<ExecutiveViewPropertyDetailScreen> {
  @override
  void initState() {
    _propertyDetail = _getPropertyDetail();
    super.initState();
  }

  //FUTURE
  late Future _propertyDetail;

  //CONTROLLERS
  // final _unitController = TextEditingController();

  //FOR STORING ENTIRE PROPERTY DETAIL
  Map? thisPropertyDetail;

  //LIST FOR STORING UNITS OF THE PROPERTY
  List? units;

  //LIST FOR STORING AGENT UNITS(STATUS etc...)
  List? agentUnits;

  //LIST FOR STORING PREVIOUS ENTRIES
  List? agentEntries;

  //LIST FOR STORING NEW ENTRY
  List newEntry = [];

  //THIS IS FOR UPDATING STATE AFTER SELECTING UNIT
  Map? selectedUnit;

  //FOR LOADER
  bool isSaving = false;

  //FOR FORMATTING DATE
  String _formatDate(String date) {
    if (date.isEmpty || date == '') {
      return '';
    }
    try {
      DateTime inputDate = DateTime.parse(date);
      String formattedDate = DateFormat('dd-MM-yyyy').format(inputDate);
      return formattedDate;
    } catch (e) {
      return '';
    }
  }

  String _formatDate1(String date) {
    if (date.isEmpty || date == '') {
      return '';
    }
    try {
      DateTime inputDate = DateFormat("dd MMM, yyyy").parse(date);
      String formattedDate = DateFormat('dd-MM-yyyy').format(inputDate);
      return formattedDate;
    } catch (e) {
      return '';
    }
  }

  //FUNCTION FOR GETTING PROPERTY DETAIL
  Future<void> _getPropertyDetail() async {
    final userInfo = await DatabaseHelper().initDb();
    var data = {"user_id": userInfo.userId, "project_id": widget.projectNo};
    print(data);
    print(userInfo.token);

    if (!context.mounted) {
      return;
    }

    try {
      final result =
          await Api().getLinkedProjectDetails(data, userInfo.token, context);

      if (result['status'].toString() == '1') {
        setState(() {
          // mySellers.addAll(result['data']);
          thisPropertyDetail = result?['data'] ?? {};
          units = result?['data']?['projectunits'] ?? [];
          agentUnits = result?['data']?['agentunits'] ?? [];
          agentEntries = result?['data']?['agententries'] ?? [];
        });
      } else if (result['status'].toString() == '3') {
        throw Exception('Device changed');
      }
    } catch (e) {
      throw Exception('Something went wrong');
    }
  }

  //FUNCTION FOR EXITING FROM THIS SCREEN
  // void _goBack() {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text(
  //         'Save new entry',
  //         style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  //       ),
  //       content: const Text(
  //         'Entry detail won\'t be saved if you are not save the detail',
  //         style: TextStyle(fontSize: 12),
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () {
  //             Nav().pop(context);
  //             Nav().pop(context);
  //           },
  //           child: const Text('Don\'t save'),
  //         ),
  //         ElevatedButton(
  //           style: ElevatedButton.styleFrom(
  //             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
  //           ),
  //           onPressed: () {
  //             Nav().pop(context);
  //           },
  //           child: const Text('OK'),
  //         )
  //       ],
  //     ),
  //   );
  // }

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

  //FUNCTION
  // void _saveUnitEntry() async {
  //   if (selectedUnit == null || _unitController.text.isEmpty) {
  //     Common().showToast('Select unit');
  //   } else if (newEntry.isEmpty) {
  //     Common().showToast('No new entries found');
  //   } else {
  //     try {
  //       setState(() {
  //         isSaving = true;
  //       });
  //       final userInfo = await DatabaseHelper().initDb();

  //       var data = {
  //         "user_id": userInfo.userId,
  //         "project_id": widget.projectNo,
  //         "unit_id": selectedUnit!['id'],
  //         "customer_name": newEntry[0]['customer_name'],
  //         "contact_number": newEntry[0]['contact_number'],
  //         "call_visit": newEntry[0]['call_visit'],
  //         "comments": newEntry[0]['comments'],
  //         "reminder_date": newEntry[0]['reminder_date']
  //       };

  //       if (!context.mounted) {
  //         return;
  //       }
  //       final result =
  //           await Api().projectUnitEntry(data, userInfo.token, context);

  //       if (result['status'].toString() == '1') {
  //         setState(() {
  //           isSaving = false;
  //         });
  //         Common().showToast(result['message']);
  //         newEntry.clear();
  //         _unitController.clear();
  //         _getPropertyDetail();
  //       } else {
  //         setState(() {
  //           isSaving = false;
  //         });
  //         Common().showToast(result['message']);
  //       }
  //     } catch (e) {
  //       if (!context.mounted) {
  //         return;
  //       }
  //       setState(() {
  //         isSaving = false;
  //       });
  //       ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(content: Text('Something Went Wrong')));
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        widget.reloadHomeContent();
      },
      child: Scaffold(
        backgroundColor: primaryColor,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            onPressed: () {
              Nav().pop(context);
              // widget.reloadHomeContent();
            },
            icon: Image.asset(
              'assets/images/prev.png',
              height: 17,
            ),
          ),
          title: const Text(
            'View Details',
            style: TextStyle(color: Colors.white, fontSize: 17.5),
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
                              imageBuilder: (context, imageProvider) =>
                                  Container(
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                thisPropertyDetail?['project_name'] ?? '',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                            ),
                            const VerticalSpace(height: 5),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                thisPropertyDetail?['location'] ?? '',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                            const VerticalSpace(height: 5),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                'Total units : ${thisPropertyDetail?['no_of_units'] ?? ''}',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                            const VerticalSpace(height: 5),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                'Builder Name : ${thisPropertyDetail?['is_builder_name'] ?? ''}',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                            const VerticalSpace(height: 7),
                          ],
                        ),
                      ),
                      const VerticalSpace(height: 15),
                      // const Text(
                      //   'Select Unit',
                      //   style: TextStyle(
                      //       fontWeight: FontWeight.bold, fontSize: 16),
                      // ),
                      // const VerticalSpace(height: 7),
                      // Row(
                      //   children: [
                      //     Expanded(
                      //       child: TextFormField(
                      //         controller: _unitController,
                      //         readOnly: true,
                      //         onTap: () {
                      //           showModalBottomSheet(
                      //             backgroundColor: Colors.white,
                      //             context: context,
                      //             builder: (context) => Units(
                      //               projectUnits: units!,
                      //               onSelect: (unit) {
                      //                 setState(() {
                      //                   selectedUnit = unit;
                      //                   _unitController.text =
                      //                       unit['unit_no'] == null ||
                      //                               unit['unit_no']
                      //                                   .toString()
                      //                                   .isEmpty
                      //                           ? ''
                      //                           : unit['unit_no'].toString();
                      //                 });
                      //               },
                      //             ),
                      //           );
                      //         },
                      //         decoration: InputDecoration(
                      //           hintText: 'Select Unit',
                      //           suffixIcon: Padding(
                      //             padding: const EdgeInsets.all(20.0),
                      //             child: Image.asset(
                      //               'assets/images/down.png',
                      //               height: 8.5,
                      //             ),
                      //           ),
                      //         ),
                      //         style: const TextStyle(fontSize: 15),
                      //       ),
                      //     ),
                      //     const HorizontalSpace(width: 10),
                      //     ElevatedButton(
                      //       style: ElevatedButton.styleFrom(
                      //         padding: const EdgeInsets.symmetric(
                      //             vertical: 12, horizontal: 10),
                      //       ),
                      //       onPressed: isSaving ? () {} : _saveUnitEntry,
                      //       child: isSaving
                      //           ? const ButtonLoader()
                      //           : const Text('SAVE'),
                      //     )
                      //   ],
                      // ),
                      // const VerticalSpace(height: 20),
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
                                TextButton(
                                  onPressed: () {
                                    Nav().push(
                                      context,
                                      ExecutiveUnitsScreen(
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
                            // const VerticalSpace(height: 7),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: inputBg,
                                borderRadius: BorderRadius.circular(7),
                                border:
                                    Border.all(color: inputBorder, width: 2),
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
                                                style: const TextStyle(
                                                    fontSize: 12),
                                              ),
                                              const VerticalSpace(height: 5),
                                              // Text(
                                              //   'Customer Name :  ${agentUnits?[agentUnits!.length - 1]['is_sold_to']?['name'] ?? ''}',
                                              //   style: const TextStyle(
                                              //       fontSize: 12),
                                              // ),
                                              // const VerticalSpace(height: 5),
                                              // Text(
                                              //   'Customer Mobile Number : ${agentUnits?[agentUnits!.length - 1]?['is_sold_to']?['mobile'] ?? ''}',
                                              //   overflow: TextOverflow.clip,
                                              //   style: const TextStyle(
                                              //       fontSize: 12),
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
                                                                  1]
                                                              ?['is_status'] ??
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
                                        //   onPressed: agentUnits![agentUnits!
                                        //                           .length -
                                        //                       1]?['is_sold_to']
                                        //                   ?['mobile'] ==
                                        //               null ||
                                        //           agentUnits![agentUnits!
                                        //                           .length -
                                        //                       1]['is_sold_to']
                                        //                   ['mobile']
                                        //               .toString()
                                        //               .isEmpty
                                        //       ? () {
                                        //           Common().showToast(
                                        //               'No mobile number found');
                                        //         }
                                        //       : () {
                                        //         launchUrl(Uri(
                                        //               scheme: 'tel',
                                        //               path: agentUnits![
                                        //                       agentUnits!
                                        //                               .length -
                                        //                           1]['is_sold_to']
                                        //                   ['mobile']));
                                        //         },
                                        //   icon: Image.asset(
                                        //     'assets/images/phone.png',
                                        //     height: 30,
                                        //   ),
                                        // ),
                                      ],
                                    ),
                            ),
                            const VerticalSpace(height: 20),
                          ],
                        ),

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
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Nav().push(
                                      context,
                                      ExecutiveEntriesScreen(
                                          propertyDetail: thisPropertyDetail!,
                                          agentEntriesList: agentEntries ?? [],
                                          onBack: _getPropertyDetail),
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
                            // const VerticalSpace(height: 7),
                            Container(
                              padding: const EdgeInsets.all(10),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: inputBg,
                                borderRadius: BorderRadius.circular(7),
                                border:
                                    Border.all(color: inputBorder, width: 2),
                              ),
                              child: agentEntries == null ||
                                      agentEntries!.isEmpty
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
                                                style: const TextStyle(
                                                    fontSize: 12),
                                              ),
                                              const VerticalSpace(height: 5),
                                              Text(
                                                'Customer Mobile Number : ${agentEntries?[0]?['mobile'] ?? ''}',
                                                style: const TextStyle(
                                                    fontSize: 12),
                                              ),
                                              const VerticalSpace(height: 5),
                                              if (agentEntries?[0]
                                                          ?['unit_id'] !=
                                                      null &&
                                                  agentEntries?[0]
                                                          ?['unit_id'] !=
                                                      0) ...[
                                                Row(
                                                  children: [
                                                    Text(
                                                      'Unit no: ${agentEntries?[0]?['unit_no'] ?? ''} - ',
                                                      style: const TextStyle(
                                                          fontSize: 12),
                                                    ),
                                                    Text(
                                                      agentEntries?[0]?[
                                                              'unit_status'] ??
                                                          '',
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          color: agentEntries?[
                                                                              0]
                                                                          ?[
                                                                          'unit_status']
                                                                      ?.toString() ==
                                                                  'AVAILABLE'
                                                              ? Colors.red
                                                              : agentEntries?[0]
                                                                              ?[
                                                                              'unit_status']
                                                                          ?.toString() ==
                                                                      'BOOKED'
                                                                  ? Colors.blue
                                                                  : agentEntries?[0]?['unit_status']?.toString() ==
                                                                          'SOLD OUT'
                                                                      ? Colors
                                                                          .green
                                                                      : Colors
                                                                          .black),
                                                    ),
                                                  ],
                                                ),
                                                const VerticalSpace(height: 5),
                                                Text(
                                                  'Block name: ${agentEntries?[0]?['block_name'] ?? ''}',
                                                  style: const TextStyle(
                                                      fontSize: 12),
                                                ),
                                                const VerticalSpace(height: 5),
                                                Text(
                                                  'Phase name: ${agentEntries?[0]?['phases'] ?? ''}',
                                                  style: const TextStyle(
                                                      fontSize: 12),
                                                ),
                                                const VerticalSpace(height: 5),
                                              ],
                                              Text(
                                                'Call / Visit : ${agentEntries?[0]?['is_sourceby'] ?? ''}',
                                                style: const TextStyle(
                                                    fontSize: 12),
                                              ),
                                              const VerticalSpace(height: 5),
                                              Text(
                                                'Comments : ${agentEntries?[0]?['agent_remind_comments'] ?? ''}',
                                                style: const TextStyle(
                                                    fontSize: 12),
                                              ),
                                              const VerticalSpace(height: 5),
                                              Text(
                                                'Entry Date : ${_formatDate1(agentEntries?[0]?['enquired_at'] ?? '')}',
                                                style: const TextStyle(
                                                    fontSize: 12),
                                              ),
                                              const VerticalSpace(height: 5),
                                              Text(
                                                'Reminder Date : ${_formatDate(agentEntries?[0]?['agent_remind_date'] ?? '')}',
                                                style: const TextStyle(
                                                    fontSize: 12),
                                              ),
                                              const VerticalSpace(height: 5),
                                              Text(
                                                'Status : ${agentEntries?[0]?['status'] ?? ''}',
                                                style: const TextStyle(
                                                    fontSize: 12),
                                              ),
                                              const VerticalSpace(height: 5),
                                              // Text(
                                              //   'Source : ${agentEntries?[0]?['enquiry_by'] ?? ''}',
                                              //   style: const TextStyle(
                                              //       fontSize: 12),
                                              // ),
                                              // const VerticalSpace(height: 5),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          children: [
                                            IconButton(
                                              onPressed: () {
                                                _goToCorrespondingApp(
                                                    'tel',
                                                    agentEntries?[0]
                                                            ?['mobile'] ??
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
                                                    agentEntries?[0]
                                                            ?['mobile'] ??
                                                        '');
                                              },
                                              icon: Image.asset(
                                                'assets/images/whatsapp.png',
                                                height: 28,
                                              ),
                                            ),
                                            agentEntries?[0]?['unit_id'] ==
                                                        null ||
                                                    agentEntries?[0]
                                                            ?['unit_id'] ==
                                                        0 ||
                                                    agentEntries?[0]
                                                                ?['unit_status']
                                                            .toString()
                                                            .trim() ==
                                                        'REQUESTED' ||
                                                    agentEntries?[0]
                                                                ?['unit_status']
                                                            .toString()
                                                            .trim() ==
                                                        'AVAILABLE'
                                                ? IconButton(
                                                    onPressed: () {
                                                      Nav().push(
                                                          context,
                                                          ExecutiveEditEntryScreen(
                                                            previousEntryDetail:
                                                                agentEntries?[
                                                                        0] ??
                                                                    {},
                                                            propertyDetail:
                                                                thisPropertyDetail!,
                                                            onBack:
                                                                _getPropertyDetail,
                                                          ));
                                                      // agentEntries?.clear();

                                                      // _getPropertyDetail();
                                                    },
                                                    icon: Image.asset(
                                                      'assets/images/edit.png',
                                                      height: 28,
                                                    ),
                                                  )
                                                : const VerticalSpace(
                                                    height: 0),
                                          ],
                                        )
                                      ],
                                    ),
                            ),
                          ],
                        ),
                      const VerticalSpace(height: 20),
                      // if (newEntry.isNotEmpty)
                      //   Column(
                      //     crossAxisAlignment: CrossAxisAlignment.start,
                      //     children: [
                      //       const Text(
                      //         'New Entry',
                      //         style: TextStyle(
                      //             fontWeight: FontWeight.bold, fontSize: 16),
                      //       ),
                      //       const VerticalSpace(height: 7),
                      //       Container(
                      //         padding: const EdgeInsets.all(10),
                      //         width: double.infinity,
                      //         decoration: BoxDecoration(
                      //           color: inputBg,
                      //           borderRadius: BorderRadius.circular(7),
                      //           border:
                      //               Border.all(color: inputBorder, width: 2),
                      //         ),
                      //         child: Column(
                      //           crossAxisAlignment: CrossAxisAlignment.start,
                      //           children: [
                      //             Text(
                      //               'Customer Name : ${newEntry[0]['customer_name']}',
                      //               style: const TextStyle(fontSize: 12),
                      //             ),
                      //             const VerticalSpace(height: 5),
                      //             Text(
                      //               'Customer Mobile Number : ${newEntry[0]['contact_number']}',
                      //               style: const TextStyle(fontSize: 12),
                      //             ),
                      //             const VerticalSpace(height: 5),
                      //             Text(
                      //               'Call / Vist : ${newEntry[0]['call_visit'] == 1 ? 'Call' : 'Direct Visit'}',
                      //               style: const TextStyle(fontSize: 12),
                      //             ),
                      //             const VerticalSpace(height: 5),
                      //             Text(
                      //               'Comments : ${newEntry[0]['comments']}',
                      //               style: const TextStyle(fontSize: 12),
                      //             ),
                      //             const VerticalSpace(height: 5),
                      //             Text(
                      //               'Reminder Date : ${_formatDate(newEntry[0]['reminder_date'])}',
                      //               style: const TextStyle(fontSize: 12),
                      //             ),
                      //             const VerticalSpace(height: 5),
                      //           ],
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      const VerticalSpace(height: 40),
                    ],
                  ),
                );
              }
            },
          ),
        ),
        bottomNavigationBar: Container(
          padding: Platform.isIOS
              ? const EdgeInsets.only(top: 15, left: 15, right: 15, bottom: 35)
              : const EdgeInsets.all(15),
          color: Colors.white,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: thisPropertyDetail == null
                ? () {}
                : () async {
                    // Nav().push(
                    //     context,
                    //     ExecutiveNewEntryScreen(
                    //       previousEntryDetail: newEntry.isNotEmpty
                    //           ? newEntry[0]
                    //           : agentEntries != null && agentEntries!.isNotEmpty
                    //               ? agentEntries![agentEntries!.length - 1]
                    //               : {},
                    //       onNewEntry: (entry) {
                    //         setState(() {
                    //           newEntry.clear();
                    //           newEntry.add(entry);
                    //         });
                    //       },
                    //     ));

                    await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ExecutiveNewEntryScreen(
                                  propertyDetail: thisPropertyDetail ?? {},
                                  onBack: _getPropertyDetail,
                                )));
                    // agentEntries?.clear();
                    _getPropertyDetail();
                  },
            child: const Text(
              'NEW ENTRY',
              style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.8),
            ),
          ),
        ),
      ),
    );
  }
}
