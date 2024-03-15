import 'package:cached_network_image/cached_network_image.dart';
import 'package:elzsi/Api/api_call.dart';
import 'package:elzsi/Database/database_helper.dart';
import 'package:elzsi/Utils/button_loader.dart';
import 'package:elzsi/Utils/common.dart';
import 'package:elzsi/Utils/horizontalspace.dart';
import 'package:elzsi/Utils/loader.dart';
import 'package:elzsi/Utils/verticalspace.dart';
import 'package:elzsi/Utils/waiting_shimmer.dart';
import 'package:elzsi/Widgets/sellers.dart';
import 'package:elzsi/utils/colors.dart';
import 'package:elzsi/utils/navigations.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';

class ExecutiveSelectSellerScreen extends StatefulWidget {
  const ExecutiveSelectSellerScreen({super.key});

  @override
  State<ExecutiveSelectSellerScreen> createState() =>
      _ExecutiveSelectSellerScreenState();
}

class _ExecutiveSelectSellerScreenState
    extends State<ExecutiveSelectSellerScreen> {
  @override
  void initState() {
    _getRequests = _getRequestedList();
    _scrollController.addListener(() {
      if (_scrollController.position.maxScrollExtent ==
          _scrollController.offset) {
        if (pageNo != null && pageNo != requestedSellerList.length) {
          setState(() {
            paginationLoader = true;
          });
          _getRequestedList();
        }
      }
    });
    super.initState();
  }

  //FUTURE
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

  //LIST FOR STORING SELLERS WHOM WE ARE REQUESTED
  List requestedSellerList = [];

  //FOR PAGINATION
  int? pageNo;

  //FUNCTION FOR GETTING REQUESTED SELLERS LIST
  Future<void> _getRequestedList() async {
    setState(() {
      pageNo = requestedSellerList.length;
    });
    final userInfo = await DatabaseHelper().initDb();

    var data = {
      "user_id": userInfo.userId,
      "page_no": requestedSellerList.length
    };

    if (!context.mounted) {
      return;
    }
    final result = await Api().getRequest(data, userInfo.token, context);

    if (result['status'].toString() == '1') {
      setState(() {
        requestedSellerList.addAll(result['data']);
        isLoading = false;
        paginationLoader = false;
      });
    } else if (result['status'].toString() == '3') {
      throw Exception('Device changed');
    } else {
      setState(() {
        isLoading = false;
        paginationLoader = false;
      });
    }
  }

  //FUNCTION FOR CHANGING DATE FORMAT
  String changeDateFormat(String dateWithTime) {
    DateTime inputDateTime = DateTime.parse(dateWithTime);
    String formattedDate = DateFormat('dd MMM, yyyy').format(inputDateTime);
    return formattedDate;
  }

  //FUNCTION FOR SENDING REQUEST TO SELLER
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
        requestedSellerList.clear();
        _getRequestedList();
      } else if (result['status'].toString() == '3') {
        throw Exception('Device changed');
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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
          controller: _scrollController,
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
                  ),
                  const HorizontalSpace(width: 10),
                  SizedBox(
                    width: screenWidth * 0.34,
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
                                  fontWeight: FontWeight.bold, fontSize: 10.5),
                            ),
                    ),
                  ),
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
                        : requestedSellerList.isEmpty
                            ? const Center(
                                child: Text(
                                  'No requests found',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 11),
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                itemCount: requestedSellerList.length,
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
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 0),
                                    leading: requestedSellerList[index]
                                                        ['is_seller']
                                                    ['is_business_logo'] ==
                                                null ||
                                            requestedSellerList[index]
                                                        ['is_seller']
                                                    ['is_business_logo']
                                                .trim()
                                                .isEmpty
                                        ? const Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 10),
                                            child: Icon(
                                              Icons.image_not_supported_rounded,
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
                                                imageUrl:
                                                    requestedSellerList[index]
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
                                                      color:
                                                          const Color.fromARGB(
                                                              169,
                                                              226,
                                                              226,
                                                              226),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              13),
                                                    ),
                                                  ),
                                                ),
                                                imageBuilder:
                                                    (context, imageProvider) =>
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
                                          requestedSellerList[index]
                                              ['is_seller']['business_name'],
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13),
                                        ),
                                        const VerticalSpace(height: 3.5),
                                        Text(
                                          changeDateFormat(
                                              requestedSellerList[index]
                                                  ['status_date']),
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
                                        color: requestedSellerList[index]
                                                    ['status'] ==
                                                "APPROVED"
                                            ? Colors.green
                                            : requestedSellerList[index]
                                                        ['status'] ==
                                                    "REJECTED"
                                                ? Colors.red
                                                : Colors.amber,
                                        borderRadius:
                                            BorderRadius.circular(3.5),
                                      ),
                                      child: Text(
                                        requestedSellerList[index]['status'],
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
    );
  }
}
