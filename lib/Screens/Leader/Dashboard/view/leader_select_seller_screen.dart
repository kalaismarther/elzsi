import 'package:cached_network_image/cached_network_image.dart';
import 'package:elzsi/Api/api_call.dart';
import 'package:elzsi/Database/database_helper.dart';
import 'package:elzsi/Utils/button_loader.dart';
import 'package:elzsi/Utils/colors.dart';
import 'package:elzsi/Utils/common.dart';
import 'package:elzsi/Utils/horizontalspace.dart';
import 'package:elzsi/Utils/loader.dart';
import 'package:elzsi/utils/navigations.dart';
import 'package:elzsi/Utils/verticalspace.dart';
import 'package:elzsi/Utils/waiting_shimmer.dart';
import 'package:elzsi/Widgets/sellers.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

class LeaderSelectSellerScreen extends StatefulWidget {
  const LeaderSelectSellerScreen({super.key});

  @override
  State<LeaderSelectSellerScreen> createState() =>
      _LeaderSelectSellerScreenState();
}

class _LeaderSelectSellerScreenState extends State<LeaderSelectSellerScreen> {
  late Future _getRequests;
  //CONTROLLERS
  final _selectSellerController = TextEditingController();
  final _scrollController = ScrollController();

  //FOR SELECTED SELLER
  Map? selectedSeller;

  //FOR LOADER
  bool isLoading = false;
  bool requestLoader = false;
  bool paginationLoader = false;

  List sellerList = [];

  int? pageNo;

  void _sendRequest() async {
    final userInfo = await DatabaseHelper().initDb();

    try {
      setState(() {
        requestLoader = true;
      });
      var data = {
        "user_id": userInfo.userId,
        "seller_id": selectedSeller!['id']
      };
      if (!context.mounted) {
        return;
      }
      final result = await Api().requestSeller(data, userInfo.token, context);

      if (result['status'].toString() == '1') {
        setState(() {
          requestLoader = false;
          isLoading = true;
        });
        Common().showToast(result['message']);
        _selectSellerController.clear();
        sellerList.clear();
        _getRequestedList();
      } else {
        setState(() {
          requestLoader = false;
        });
        Common().showToast(result['message']);
      }
    } catch (e) {
      setState(() {
        requestLoader = false;
      });
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Something Went Wrong')));
    }
  }

  Future<void> _getRequestedList() async {
    setState(() {
      pageNo = sellerList.length;
    });
    final userInfo = await DatabaseHelper().initDb();

    var data = {"user_id": userInfo.userId, "page_no": sellerList.length};

    if (!context.mounted) {
      return;
    }
    final result = await Api().getRequest(data, userInfo.token, context);

    if (result['status'].toString() == '1') {
      setState(() {
        sellerList.addAll(result?['data'] ?? []);
        isLoading = false;
        paginationLoader = false;
      });
    } else if (result['status'].toString() == '3') {
      throw Exception('Device changed');
    } else {
      setState(() {
        paginationLoader = false;
      });
    }
  }

  String changeDateFormat(String dateWithTime) {
    if (dateWithTime.isEmpty) {
      return '';
    }
    DateTime inputDateTime = DateTime.parse(dateWithTime);
    String formattedDate = DateFormat('dd MMM, yyyy').format(inputDateTime);
    return formattedDate;
  }

  @override
  void initState() {
    _getRequests = _getRequestedList();
    _scrollController.addListener(() {
      if (_scrollController.position.maxScrollExtent ==
          _scrollController.offset) {
        if (pageNo != null && pageNo != sellerList.length) {
          setState(() {
            paginationLoader = true;
          });
          _getRequestedList();
        }
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        // widget.reloadHomeContent();
      },
      child: Scaffold(
        backgroundColor: primaryColor,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () {
              Nav().pop(context);
              // widget.reloadHomeContent();
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
                  'Select Seller',
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
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const VerticalSpace(height: 15),
                const Text(
                  'Select Seller',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                const VerticalSpace(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _selectSellerController,
                        readOnly: true,
                        onTap: () {
                          showModalBottomSheet(
                              context: context,
                              builder: (context) => Sellers(
                                    onSelect: (seller) {
                                      setState(() {
                                        selectedSeller = seller;
                                        _selectSellerController.text =
                                            selectedSeller!['business_name'];
                                      });
                                    },
                                  ));
                        },
                        decoration: InputDecoration(
                          hintText: 'Select seller',
                          suffixIcon: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Image.asset(
                              'assets/images/down.png',
                              height: 8.5,
                            ),
                          ),
                        ),
                        style: const TextStyle(fontSize: 15),
                      ),

                      // DropdownButtonHideUnderline(
                      //   child: ButtonTheme(
                      //     alignedDropdown: true,
                      //     child: DropdownButtonFormField(
                      //       isExpanded: true,
                      //       icon: Image.asset(
                      //         'assets/images/down.png',
                      //         height: 9,
                      //       ),
                      //       items: const [
                      //         DropdownMenuItem(
                      //             value: 'one', child: Text('Option 1')),
                      //         DropdownMenuItem(
                      //             value: 'two', child: Text('Option 2'))
                      //       ],
                      //       onChanged: (v) {},
                      //     ),
                      //   ),
                      // ),
                    ),
                    const HorizontalSpace(width: 10),
                    SizedBox(
                      width: screenWidth * 0.33,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              vertical: 14.5, horizontal: 20),
                        ),
                        onPressed: selectedSeller == null
                            ? () {
                                Common().showToast('Please select seller');
                              }
                            : requestLoader
                                ? () {}
                                : _sendRequest,
                        child: requestLoader
                            ? const ButtonLoader()
                            : const Text(
                                'SEND REQUEST',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 11),
                              ),
                      ),
                    )
                  ],
                ),
                const VerticalSpace(height: 20),
                FutureBuilder(
                  future: _getRequests,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const WaitingShimmer(count: 3, height: 68);
                    } else if (snapshot.hasError) {
                      return const Center(child: Text('Failed to fetch data'));
                    } else {
                      return isLoading
                          ? const WaitingShimmer(count: 3, height: 68)
                          : sellerList.isEmpty
                              ? const Center(
                                  child: Text(
                                    'No requests found',
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 11),
                                  ),
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: sellerList.length,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) => Container(
                                    margin: const EdgeInsets.only(bottom: 15),
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 5),
                                    decoration: BoxDecoration(
                                      color: inputBg,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: inputBorder),
                                    ),
                                    child: ListTile(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 0),
                                      leading: sellerList[index]['is_seller']
                                                      ['is_business_logo'] ==
                                                  null ||
                                              sellerList[index]['is_seller']
                                                      ['is_business_logo']
                                                  .trim()
                                                  .isEmpty
                                          ? const Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 10),
                                              child: Icon(
                                                Icons
                                                    .image_not_supported_rounded,
                                                size: 35,
                                              ),
                                            )
                                          : SizedBox(
                                              height: 55,
                                              width: 55,
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                child: CachedNetworkImage(
                                                  imageUrl: sellerList[index]
                                                          ['is_seller']
                                                      ['is_business_logo'],
                                                  placeholder: (context, url) =>
                                                      Shimmer.fromColors(
                                                    baseColor:
                                                        const Color(0xFFE2E2E2),
                                                    highlightColor:
                                                        Colors.grey.shade50,
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color: const Color
                                                            .fromARGB(
                                                            169, 226, 226, 226),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(13),
                                                      ),
                                                    ),
                                                  ),
                                                  imageBuilder: (context,
                                                          imageProvider) =>
                                                      Container(
                                                    height: 35,
                                                    width: 35,
                                                    decoration: BoxDecoration(
                                                      image: DecorationImage(
                                                          image: imageProvider,
                                                          fit: BoxFit.cover),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                      title: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            sellerList[index]?['is_seller']
                                                    ?['business_name'] ??
                                                '',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13),
                                          ),
                                          const VerticalSpace(height: 3.5),
                                          Text(
                                            changeDateFormat(sellerList[index]
                                                    ?['status_date'] ??
                                                ''),
                                            style: TextStyle(
                                                color: fontLightGrey,
                                                fontSize: 11),
                                          ),
                                        ],
                                      ),
                                      trailing: Container(
                                        width: 90,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.5, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: sellerList[index]['status'] ==
                                                  "APPROVED"
                                              ? Colors.green
                                              : sellerList[index]['status'] ==
                                                      "REJECTED"
                                                  ? Colors.red
                                                  : Colors.amber,
                                          borderRadius:
                                              BorderRadius.circular(3.5),
                                        ),
                                        child: Text(
                                          sellerList[index]?['status'] ?? '',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 11.5),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                    }
                  },
                ),
                paginationLoader
                    ? const Padding(
                        padding: EdgeInsets.only(top: 5),
                        child: Loader(),
                      )
                    : const VerticalSpace(height: 0)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
