import 'package:cached_network_image/cached_network_image.dart';
import 'package:elzsi/Api/api_call.dart';
import 'package:elzsi/Database/database_helper.dart';
import 'package:elzsi/Screens/Leader/Dashboard/view/leader_view_property_detail_screen.dart';
import 'package:elzsi/Utils/colors.dart';
import 'package:elzsi/Utils/horizontalspace.dart';
import 'package:elzsi/Utils/loader.dart';
import 'package:elzsi/utils/navigations.dart';
import 'package:elzsi/Utils/verticalspace.dart';
import 'package:elzsi/Utils/waiting_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class LeaderPropertiesScreen extends StatefulWidget {
  const LeaderPropertiesScreen({super.key, required this.reloadHomeContent});

  final Function() reloadHomeContent;
  @override
  State<LeaderPropertiesScreen> createState() => _LeaderPropertiesScreenState();
}

class _LeaderPropertiesScreenState extends State<LeaderPropertiesScreen> {
  late Future _linkedProjectsList;
  //CONTROLLERS
  final _scrollController = ScrollController();

  //FOR LOADER
  bool paginationLoader = false;

  //FOR PAGINTION
  int? pageNo;

  List propertiesList = [];

  Future<void> _getPropertyList() async {
    setState(() {
      pageNo = propertiesList.length;
    });
    final userInfo = await DatabaseHelper().initDb();
    var data = {"user_id": userInfo.userId, "page_no": propertiesList.length};

    if (!context.mounted) {
      return;
    }
    try {
      final result =
          await Api().getLinkedProjects(data, userInfo.token, context);

      if (result['status'].toString() == '1') {
        setState(() {
          propertiesList.addAll(result['data']);
        });
        print(propertiesList[0]);
      } else {}
    } catch (e) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Something Went Wrong')));
    }
  }

  @override
  void initState() {
    _linkedProjectsList = _getPropertyList();
    _scrollController.addListener(() {
      if (_scrollController.position.maxScrollExtent ==
          _scrollController.offset) {
        if (pageNo != null && pageNo != propertiesList.length) {
          setState(() {
            paginationLoader = true;
          });
          _getPropertyList();
        }
      }
    });
    super.initState();
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
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        widget.reloadHomeContent();
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
              widget.reloadHomeContent();
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
                  'Properties',
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
            future: _linkedProjectsList,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Column(
                  children: [
                    VerticalSpace(height: 15),
                    WaitingShimmer(count: 2, height: 105),
                  ],
                );
              } else if (snapshot.hasError) {
                return const Center(child: Text('Failed to fetch data'));
              } else {
                return propertiesList.isEmpty
                    ? const Center(
                        child: Text(
                          'No properties found',
                          style: TextStyle(color: Colors.grey, fontSize: 11),
                        ),
                      )
                    : SingleChildScrollView(
                        controller: _scrollController,
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 15,
                            ),
                            ListView.builder(
                              itemCount: propertiesList.length,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) => InkWell(
                                onTap: () {
                                  Nav().push(
                                      context,
                                      LeaderViewPropertyDetailScreen(
                                        projectNo: propertiesList[index]['id'],
                                        reloadHomeContent: () {},
                                      ));
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 15),
                                  padding: const EdgeInsets.all(8.5),
                                  decoration: BoxDecoration(
                                    color: inputBg,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: inputBorder),
                                  ),
                                  child: Row(
                                    children: [
                                      CachedNetworkImage(
                                        imageUrl: propertiesList[index]
                                                ?['is_project_image'] ??
                                            '',
                                        imageBuilder:
                                            (context, imageProvider) =>
                                                Container(
                                          height: 80,
                                          width: 80,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            image: DecorationImage(
                                              image: imageProvider,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        placeholder: (context, url) =>
                                            Container(
                                          height: 80,
                                          width: 80,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                          child: Shimmer.fromColors(
                                            baseColor: const Color(0xFFE2E2E2),
                                            highlightColor: Colors.grey.shade50,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: const Color.fromARGB(
                                                    169, 226, 226, 226),
                                                borderRadius:
                                                    BorderRadius.circular(13),
                                              ),
                                            ),
                                          ),
                                        ),
                                        errorWidget: (context, url, error) =>
                                            const Icon(Icons.error),
                                      ),
                                      const HorizontalSpace(width: 17.5),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            propertiesList[index]
                                                    ?['project_name'] ??
                                                '',
                                            style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          const VerticalSpace(height: 6),
                                          SizedBox(
                                            width: screenWidth * 0.6,
                                            child: Text(
                                              propertiesList[index]
                                                      ?['location'] ??
                                                  '',
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  fontSize: 12.5),
                                            ),
                                          ),
                                          const VerticalSpace(height: 6),
                                          Text(
                                            'Total Units : ${propertiesList[index]?['no_of_units'] ?? ''}',
                                            style:
                                                const TextStyle(fontSize: 12.5),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            paginationLoader
                                ? const Padding(
                                    padding: EdgeInsets.only(top: 5),
                                    child: Loader(),
                                  )
                                : const VerticalSpace(height: 0),
                            const SizedBox(
                              height: 10,
                            ),
                          ],
                        ),
                      );
              }
            },
          ),
        ),
      ),
    );
  }
}
