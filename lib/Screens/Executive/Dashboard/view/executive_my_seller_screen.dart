import 'package:cached_network_image/cached_network_image.dart';
import 'package:elzsi/Api/api_call.dart';
import 'package:elzsi/Database/database_helper.dart';
import 'package:elzsi/Screens/Executive/Dashboard/view/executive_view_details_screen.dart';
import 'package:elzsi/Utils/colors.dart';
import 'package:elzsi/Utils/horizontalspace.dart';
import 'package:elzsi/Utils/loader.dart';
import 'package:elzsi/utils/navigations.dart';
import 'package:elzsi/Utils/verticalspace.dart';
import 'package:elzsi/Utils/waiting_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ExecutiveMySellerScreen extends StatefulWidget {
  const ExecutiveMySellerScreen({super.key});

  @override
  State<ExecutiveMySellerScreen> createState() =>
      _ExecutiveMySellerScreenState();
}

class _ExecutiveMySellerScreenState extends State<ExecutiveMySellerScreen> {
  @override
  void initState() {
    _getLinkedSellers = _getMySellers();
    _scrollController.addListener(() {
      if (_scrollController.position.maxScrollExtent ==
          _scrollController.offset) {
        if (pageNo != null && pageNo != mySellers.length) {
          setState(() {
            paginationLoader = true;
          });
          _getMySellers();
        }
      }
    });
    super.initState();
  }

  //FUTURE
  late Future _getLinkedSellers;

  //CONTROLLERS
  final _scrollController = ScrollController();

  //FOR LOADER
  bool paginationLoader = false;

  //FOR PAGINATION
  int? pageNo;

  //LIST FOR STORING LINKED SELLERS
  List mySellers = [];

  //FUNCTION FOR GETTING LINKED SELLERS LIST
  Future<void> _getMySellers() async {
    setState(() {
      pageNo = mySellers.length;
    });
    final userInfo = await DatabaseHelper().initDb();
    var data = {"user_id": userInfo.userId, "page_no": mySellers.length};

    print(data);

    print(userInfo.token);

    if (!context.mounted) {
      return;
    }

    final result = await Api().getLinkedSellers(data, userInfo.token, context);

    if (result['status'].toString() == '1') {
      setState(() {
        mySellers.addAll(result['data']);
        paginationLoader = false;
      });
      print(mySellers);
    } else if (result['status'].toString() == '3') {
      throw Exception('Device changed');
    } else {
      setState(() {
        paginationLoader = false;
      });
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
                'My Sellers',
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
          future: _getLinkedSellers,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Column(
                children: [
                  VerticalSpace(height: 15),
                  WaitingShimmer(count: 3, height: 68),
                ],
              );
            } else if (snapshot.hasError) {
              return const Center(child: Text('Failed to fetch data'));
            } else {
              return mySellers.isEmpty
                  ? const Center(
                      child: Text(
                        'No linked sellers found',
                        style: TextStyle(color: Colors.grey, fontSize: 11),
                      ),
                    )
                  : SingleChildScrollView(
                      controller: _scrollController,
                      child: Column(
                        children: [
                          const VerticalSpace(height: 15),
                          ListView.builder(
                            shrinkWrap: true,
                            itemCount: mySellers.length,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) => InkWell(
                              onTap: () {
                                Nav().push(
                                  context,
                                  ExecutiveViewDetailsScreen(
                                    data: mySellers[index],
                                  ),
                                );
                              },
                              child: Container(
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
                                      horizontal: 10, vertical: 0),
                                  leading: mySellers[index]
                                                  ['is_business_logo'] ==
                                              null ||
                                          mySellers[index]['is_business_logo']
                                              .trim()
                                              .isEmpty
                                      ? const Icon(
                                          Icons.image_not_supported_rounded,
                                          size: 35,
                                        )
                                      : SizedBox(
                                          height: 45,
                                          width: 45,
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(6),
                                            child: CachedNetworkImage(
                                              imageUrl: mySellers[index]
                                                  ['is_profile_image'],
                                              placeholder: (context, url) =>
                                                  Shimmer.fromColors(
                                                baseColor:
                                                    const Color(0xFFE2E2E2),
                                                highlightColor:
                                                    Colors.grey.shade50,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: const Color.fromARGB(
                                                        169, 226, 226, 226),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            13),
                                                  ),
                                                ),
                                              ),
                                              imageBuilder:
                                                  (context, imageProvider) =>
                                                      Container(
                                                decoration: BoxDecoration(
                                                    image: DecorationImage(
                                                        image: imageProvider,
                                                        fit: BoxFit.cover)),
                                              ),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      const Icon(Icons
                                                          .image_not_supported),
                                            ),
                                          ),
                                        ),
                                  title: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        mySellers[index]?['business_name'] ??
                                            '',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14),
                                      ),
                                      const VerticalSpace(height: 3.5),
                                      Text(
                                        mySellers[index]?['business_address'] ??
                                            '',
                                        style: TextStyle(
                                            color: fontLightGrey, fontSize: 11),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          paginationLoader
                              ? const Padding(
                                  padding: EdgeInsets.only(top: 5),
                                  child: Loader(),
                                )
                              : const VerticalSpace(height: 0)
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
