import 'package:elzsi/Utils/colors.dart';
// import 'package:elzsi/Utils/common.dart';
import 'package:elzsi/Utils/horizontalspace.dart';
import 'package:elzsi/utils/navigations.dart';
import 'package:elzsi/Utils/verticalspace.dart';
import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';

class LeaderAgentUnitsScreen extends StatefulWidget {
  const LeaderAgentUnitsScreen({super.key, required this.agentUnitsList});

  final List agentUnitsList;

  @override
  State<LeaderAgentUnitsScreen> createState() => _LeaderAgentUnitsScreenState();
}

class _LeaderAgentUnitsScreenState extends State<LeaderAgentUnitsScreen> {
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
                'Units',
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
        child: widget.agentUnitsList.isEmpty
            ? const Center(
                child: Text('No agent units'),
              )
            : SingleChildScrollView(
                child: Column(
                  children: [
                    const VerticalSpace(height: 15),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: widget.agentUnitsList.length,
                      itemBuilder: (context, index) => Container(
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.only(bottom: 15),
                        decoration: BoxDecoration(
                          color: inputBg,
                          borderRadius: BorderRadius.circular(7),
                          border: Border.all(color: inputBorder, width: 2),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: screenWidth * 0.7,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Unit : ${widget.agentUnitsList[index]?['unit_no'] ?? ''}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  // const VerticalSpace(height: 5),
                                  // Text(
                                  //   'Customer Name :  ${widget.agentUnitsList[index]?['is_sold_to']?['name'] ?? ''}',
                                  //   style: const TextStyle(fontSize: 12),
                                  // ),
                                  // const VerticalSpace(height: 5),
                                  // Text(
                                  //   'Customer Mobile Number : ${widget.agentUnitsList[index]?['is_sold_to']?['mobile'] ?? ''}',
                                  //   overflow: TextOverflow.clip,
                                  //   style: const TextStyle(fontSize: 12),
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
                                          text: widget.agentUnitsList[index]
                                                  ?['is_status'] ??
                                              '-',
                                          style: const TextStyle(
                                              color: Colors.blue,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // IconButton(
                            //   onPressed: widget.agentUnitsList[index]
                            //                   ?['is_sold_to']?['mobile'] ==
                            //               null ||
                            //           widget.agentUnitsList[index]['is_sold_to']
                            //                   ['mobile']
                            //               .toString()
                            //               .isEmpty
                            //       ? () {
                            //           Common()
                            //               .showToast('No mobile number found');
                            //         }
                            //       : () {
                            //           launchUrl(
                            //             Uri(
                            //               scheme: 'tel',
                            //               path: widget.agentUnitsList[index]
                            //                   ['is_sold_to']['mobile'],
                            //             ),
                            //           );
                            //         },
                            //   icon: Image.asset(
                            //     'assets/images/phone.png',
                            //     height: 30,
                            //   ),
                            // ),
                          ],
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
