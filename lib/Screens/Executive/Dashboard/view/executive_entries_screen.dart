import 'package:elzsi/Screens/Executive/Dashboard/view/executive_edit_entry_screen.dart';
import 'package:elzsi/Utils/colors.dart';
import 'package:elzsi/Utils/common.dart';
import 'package:elzsi/Utils/horizontalspace.dart';
import 'package:elzsi/utils/navigations.dart';
import 'package:elzsi/Utils/verticalspace.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class ExecutiveEntriesScreen extends StatefulWidget {
  const ExecutiveEntriesScreen(
      {super.key,
      required this.propertyDetail,
      required this.agentEntriesList,
      required this.onBack});

  final Map propertyDetail;
  final List agentEntriesList;
  final Function() onBack;

  @override
  State<ExecutiveEntriesScreen> createState() => _ExecutiveEntriesScreenState();
}

class _ExecutiveEntriesScreenState extends State<ExecutiveEntriesScreen> {
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
              const HorizontalSpace(width: 9),
              Image.asset(
                'assets/images/prev.png',
                height: 17,
              ),
              const HorizontalSpace(width: 15),
              const Text(
                'Entries',
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
        child: widget.agentEntriesList.isEmpty
            ? const Center(
                child: Text('No agent entries'),
              )
            : SingleChildScrollView(
                child: Column(
                  children: [
                    const VerticalSpace(height: 15),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: widget.agentEntriesList.length,
                      itemBuilder: (context, index) => InkWell(
                        onTap: () {
                          print(widget.agentEntriesList[index]);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          margin: const EdgeInsets.only(bottom: 15),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: inputBg,
                            borderRadius: BorderRadius.circular(7),
                            border: Border.all(color: inputBorder, width: 2),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: screenWidth * 0.68,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Customer Name : ${widget.agentEntriesList[index]?['name'] ?? ''}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    const VerticalSpace(height: 5),
                                    Text(
                                      'Customer Mobile Number : ${widget.agentEntriesList[index]?['mobile'] ?? ''}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    const VerticalSpace(height: 5),
                                    if (widget.agentEntriesList[index]
                                                ?['unit_no'] !=
                                            null &&
                                        widget.agentEntriesList[index]
                                                ?['unit_id'] !=
                                            0) ...[
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'Unit no : ${widget.agentEntriesList[index]?['unit_no'] ?? ''} - ',
                                            style:
                                                const TextStyle(fontSize: 12),
                                          ),
                                          Text(
                                            widget.agentEntriesList[index]
                                                    ?['unit_status'] ??
                                                '',
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: widget.agentEntriesList[
                                                                index]
                                                                ?['unit_status']
                                                            ?.toString() ==
                                                        'AVAILABLE'
                                                    ? Colors.red
                                                    : widget.agentEntriesList[
                                                                    index]?[
                                                                    'unit_status']
                                                                ?.toString() ==
                                                            'BOOKED'
                                                        ? Colors.blue
                                                        : widget.agentEntriesList[
                                                                        index]?[
                                                                        'unit_status']
                                                                    ?.toString() ==
                                                                'SOLD OUT'
                                                            ? Colors.green
                                                            : Colors.black),
                                          ),
                                        ],
                                      ),
                                      const VerticalSpace(height: 5),
                                      Text(
                                        'Block name: ${widget.agentEntriesList[index]?['block_name'] ?? ''}',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      const VerticalSpace(height: 5),
                                      Text(
                                        'Phase name: ${widget.agentEntriesList[index]?['phases'] ?? ''}',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      const VerticalSpace(height: 5),
                                    ],
                                    Text(
                                      'Call / Visit : ${widget.agentEntriesList[index]?['is_sourceby'] ?? ''}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    const VerticalSpace(height: 5),
                                    Text(
                                      'Comments : ${widget.agentEntriesList[index]?['agent_remind_comments'] ?? ''}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    const VerticalSpace(height: 5),
                                    Text(
                                      'Entry Date : ${_formatDate1(widget.agentEntriesList[index]?['enquired_at'] ?? '')}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    const VerticalSpace(height: 5),
                                    Text(
                                      'Reminder Date : ${_formatDate(widget.agentEntriesList[index]?['agent_remind_date'] ?? '')}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    const VerticalSpace(height: 5),
                                    Text(
                                      'Status : ${widget.agentEntriesList[index]?['status'] ?? ''}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    const VerticalSpace(height: 5),
                                    // Text(
                                    //   'Source : ${widget.agentEntriesList[index]?['enquiry_by'] ?? ''}',
                                    //   style: const TextStyle(fontSize: 12),
                                    // ),
                                    // const VerticalSpace(height: 5),
                                  ],
                                ),
                              ),
                              Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      _goToCorrespondingApp(
                                          'tel',
                                          widget.agentEntriesList[index]
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
                                          widget.agentEntriesList[index]
                                                  ?['mobile'] ??
                                              '');
                                    },
                                    icon: Image.asset(
                                      'assets/images/whatsapp.png',
                                      height: 28,
                                    ),
                                  ),
                                  widget.agentEntriesList[index]?['unit_no'] ==
                                              null ||
                                          widget.agentEntriesList[index]
                                                  ?['unit_id'] ==
                                              0 ||
                                          widget.agentEntriesList[index]
                                                      ?['unit_status']
                                                  .toString()
                                                  .trim() ==
                                              'REQUESTED' ||
                                          widget.agentEntriesList[index]
                                                      ?['unit_status']
                                                  .toString()
                                                  .trim() ==
                                              'AVAILABLE'
                                      ? IconButton(
                                          onPressed: () {
                                            Nav().replace(
                                                context,
                                                ExecutiveEditEntryScreen(
                                                    previousEntryDetail:
                                                        widget.agentEntriesList[
                                                                index] ??
                                                            {},
                                                    propertyDetail:
                                                        widget.propertyDetail,
                                                    onBack: () {
                                                      widget.onBack();
                                                    }));
                                          },
                                          icon: Image.asset(
                                            'assets/images/edit.png',
                                            height: 28,
                                          ),
                                        )
                                      : const VerticalSpace(height: 0),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    const VerticalSpace(height: 15),
                  ],
                ),
              ),
      ),
    );
  }
}
