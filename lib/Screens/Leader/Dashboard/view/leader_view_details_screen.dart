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

class LeaderViewDetailsScreen extends StatefulWidget {
  const LeaderViewDetailsScreen({super.key, required this.data});

  final Map data;

  @override
  State<LeaderViewDetailsScreen> createState() =>
      _LeaderViewDetailsScreenState();
}

class _LeaderViewDetailsScreenState extends State<LeaderViewDetailsScreen> {
  late Future _linkedSellerProjects;
  //CONTROLLERS
  final _scrollController = ScrollController();

  //FOR LOADER

  bool paginationLoader = false;

  //FOR PAGINATION
  int? pageNo;
  List linkedSellerProjects = [];

  @override
  void initState() {
    _linkedSellerProjects = _getLinkedSellerProjects();
    _scrollController.addListener(() {
      if (_scrollController.position.maxScrollExtent ==
          _scrollController.offset) {
        if (pageNo != null && pageNo != linkedSellerProjects.length) {
          setState(() {
            paginationLoader = true;
          });
          _getLinkedSellerProjects();
        }
      }
    });
    super.initState();
  }

  Future<void> _getLinkedSellerProjects() async {
    setState(() {
      pageNo = linkedSellerProjects.length;
    });
    final userInfo = await DatabaseHelper().initDb();
    var data = {
      "user_id": userInfo.userId,
      "seller_id": widget.data['id'],
      "page_no": linkedSellerProjects.length
    };
    print(data);
    if (!context.mounted) {
      return;
    }

    final result =
        await Api().getLinkedSellerProjects(data, userInfo.token, context);
    print(result);

    if (result['status'].toString() == '1') {
      setState(() {
        linkedSellerProjects.addAll(result?['data']?['projects'] ?? []);
      });
    } else if (result['status'].toString() == '3') {
      throw Exception('Device changed');
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
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const VerticalSpace(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: inputBg,
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(color: inputBorder, width: 2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    widget.data['is_business_logo'] == null ||
                            widget.data['is_business_logo'].trim().isEmpty
                        ? const Center(
                            child: Icon(
                              Icons.image_not_supported_rounded,
                              size: 35,
                            ),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(7),
                            child: CachedNetworkImage(
                              imageUrl: widget.data['is_profile_image'],
                              placeholder: (context, url) => SizedBox(
                                height: 175,
                                width: double.infinity,
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
                              imageBuilder: (context, imageProvider) =>
                                  Container(
                                height: 175,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: imageProvider, fit: BoxFit.cover),
                                ),
                              ),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.image_not_supported),
                            ),
                          ),
                    const VerticalSpace(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        widget.data['business_name'] ?? '',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                    const VerticalSpace(height: 4),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        widget.data['business_address'] ?? '',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                    const VerticalSpace(height: 7),
                  ],
                ),
              ),
              const VerticalSpace(height: 15),
              const Text(
                'Property List',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              const VerticalSpace(height: 15),
              // PropertiesList(
              //   properties: propertiesList,
              //   moveTo: 'detail1',
              // ),
              FutureBuilder(
                future: _linkedSellerProjects,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const WaitingShimmer(count: 2, height: 105);
                  } else if (snapshot.hasError) {
                    return const Center(child: Text('Failed to fetch data'));
                  } else {
                    return linkedSellerProjects.isEmpty
                        ? const Center(
                            child: Text(
                              'No properties found',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 11),
                            ),
                          )
                        : ListView.builder(
                            itemCount: linkedSellerProjects.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) => InkWell(
                              onTap: () {
                                Nav().push(
                                    context,
                                    LeaderViewPropertyDetailScreen(
                                      projectNo: linkedSellerProjects[index]
                                          ['id'],
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
                                    // Image.network(
                                    //   propertiesList[index]['is_project_image'],
                                    //   height: 80,
                                    // ),
                                    CachedNetworkImage(
                                      imageUrl: linkedSellerProjects[index]
                                          ['is_project_image'],
                                      imageBuilder: (context, imageProvider) =>
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
                                      placeholder: (context, url) => Container(
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
                                          linkedSellerProjects[index]
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
                                            linkedSellerProjects[index]
                                                    ?['location'] ??
                                                '',
                                            overflow: TextOverflow.ellipsis,
                                            style:
                                                const TextStyle(fontSize: 12.5),
                                          ),
                                        ),
                                        const VerticalSpace(height: 6),
                                        Text(
                                          'Total Units : ${linkedSellerProjects[index]?['no_of_units'] ?? ''}',
                                          style:
                                              const TextStyle(fontSize: 12.5),
                                        ),
                                      ],
                                    )
                                  ],
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
                  : const VerticalSpace(height: 0),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
