import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:elzsi/Api/api_call.dart';
import 'package:elzsi/Database/database_helper.dart';
import 'package:elzsi/Screens/Ownership/help_and_support_screen.dart';
import 'package:elzsi/Screens/Ownership/terms_and_conditions_screen.dart';
import 'package:elzsi/Screens/Executive/Dashboard/executive_notification_screen.dart';
import 'package:elzsi/Screens/Executive/Dashboard/view/executive_my_profile_screen.dart';
import 'package:elzsi/Screens/Executive/Dashboard/view/executive_my_seller_screen.dart';
import 'package:elzsi/Screens/Executive/Dashboard/view/executive_properties_screen.dart';
import 'package:elzsi/Screens/Executive/Dashboard/view/executive_select_seller_screen.dart';
import 'package:elzsi/Screens/Executive/Dashboard/view/executive_view_property_detail_screen.dart';
import 'package:elzsi/Utils/common.dart';
import 'package:elzsi/Utils/horizontalspace.dart';
import 'package:elzsi/Utils/loader.dart';
import 'package:elzsi/Utils/waiting_shimmer.dart';
import 'package:elzsi/utils/colors.dart';
import 'package:elzsi/utils/navigations.dart';
import 'package:elzsi/utils/verticalspace.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';
// import 'package:new_version_plus/new_version_plus.dart';
// import 'package:url_launcher/url_launcher_string.dart';

class ExecutiveHomeScreen extends StatefulWidget {
  const ExecutiveHomeScreen({super.key});

  @override
  State<ExecutiveHomeScreen> createState() => _ExecutiveHomeScreenState();
}

class _ExecutiveHomeScreenState extends State<ExecutiveHomeScreen> {
  late Future _home;

  //CONTROLLERS
  final _scrollController = ScrollController();

  //FOR LOADER
  bool isLoading = false;
  bool paginationLoader = false;

  //FOR PAGINATION
  int? pageNo;

  List recentProperties = [];

  @override
  void initState() {
    _home = _homeContent();
    // _checkUpdate();
    _scrollController.addListener(() {
      if (_scrollController.position.maxScrollExtent ==
          _scrollController.offset) {
        if (pageNo != null && pageNo != recentProperties.length) {
          setState(() {
            paginationLoader = true;
          });
          _homeContent();
        }
      }
    });
    super.initState();
  }

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Map> homeGrid = [
    {
      "image": "assets/images/select-seller.png",
      "title": "Select Seller",
    },
    {
      "image": "assets/images/my-seller.png",
      "title": "My sellers",
    },
    {
      "image": "assets/images/properties.png",
      "title": "Properties",
    },
    {
      "image": "assets/images/profile.png",
      "title": "Profile",
    },
  ];

  // Future<void> _checkUpdate() async {
  //   final newVersion = NewVersionPlus(
  //       androidId: 'com.smart.elzsimanager', iOSId: 'com.smart.elzsimanager');
  //   final status = await newVersion.getVersionStatus();

  //   print(status);

  //   try {
  //     if (status != null) {
  //       if (status.canUpdate) {
  //         showDialog(
  //             barrierDismissible: false,
  //             context: context,
  //             builder: (context) => PopScope(
  //                   canPop: false,
  //                   child: AlertDialog(
  //                     title: Row(
  //                       children: [
  //                         Platform.isIOS
  //                             ? Image.asset(
  //                                 'assets/images/appstore.png',
  //                                 height: 26,
  //                               )
  //                             : Image.asset(
  //                                 'assets/images/playstore.png',
  //                                 height: 26,
  //                               ),
  //                         const HorizontalSpace(width: 10),
  //                         const Text(
  //                           'Update Available',
  //                           style: TextStyle(
  //                               fontSize: 16,
  //                               fontWeight: FontWeight.bold,
  //                               letterSpacing: 1),
  //                         ),
  //                       ],
  //                     ),
  //                     content: Platform.isIOS
  //                         ? const Text(
  //                             'New version of Elzsi Task Manager is now available on App Store. Please update it')
  //                         : const Text(
  //                             'New version of Elzsi Task Manager is now available on Play Store. Please update it'),
  //                     actions: [
  //                       ElevatedButton(
  //                         style: ElevatedButton.styleFrom(
  //                             padding:
  //                                 const EdgeInsets.symmetric(horizontal: 10)),
  //                         onPressed: () {
  //                           try {
  //                             if (Platform.isIOS) {
  //                               Nav().pop(context);
  //                               Common()
  //                                   .showToast('Will launch soon on App Store');
  //                             } else {
  //                               launchUrlString(
  //                                   'https://play.google.com/store/apps/details?id=com.smart.elzsimanager');
  //                             }
  //                           } catch (e) {
  //                             Common().showToast('Failed to launch');
  //                           }
  //                         },
  //                         child: const Text('Update'),
  //                       ),
  //                     ],
  //                   ),
  //                 ));
  //       }
  //     }
  //   } catch (e) {
  //     Common().showToast('Failed to get update');
  //   }
  // }

  Future<void> _homeContent() async {
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    setState(() {
      pageNo = recentProperties.length;
    });
    final userInfo = await DatabaseHelper().initDb();
    if (!context.mounted) {
      return;
    }

    var data = {"user_id": userInfo.userId, "page_no": recentProperties.length};
    print(data);

    final result = await Api().homeContent(data, userInfo.token, context);

    if (result?['status'].toString() == '1') {
      setState(() {
        recentProperties.addAll(result?['data']?['projects'] ?? []);
        isLoading = false;
        paginationLoader = false;
      });
    } else if (result?['status'].toString() == '3') {
      throw Exception('Device changed');
    } else {
      isLoading = false;
      throw Exception('Failed to load recent properties');
    }
  }

  //FOR RELOADING HOME CONTENT
  void _reload() {
    setState(() {
      recentProperties.clear();
      isLoading = true;
    });
    _homeContent();
  }

  //LOGOUT
  Future<void> _logout() async {
    final userInfo = await DatabaseHelper().initDb();
    if (!context.mounted) {
      return;
    }

    var data = {
      "user_id": userInfo.userId,
      "fcm_token": userInfo.fcmToken,
      "device_id": userInfo.deviceId,
      "device_type": Platform.isAndroid ? "ANDROID" : "IOS"
    };

    try {
      final result = await Api().homeContent(data, userInfo.token, context);

      if (result['status'].toString() == '1') {
        if (!context.mounted) {
          return;
        }
        Common().logout(context);
      } else if (result['status'].toString() == '3') {
        throw Exception('Device changed');
      } else {
        if (!context.mounted) {
          return;
        }
        Nav().pop(context);
        Common().showToast('Failed to logout');
      }
    } catch (e) {
      if (!context.mounted) {
        return;
      }
      Nav().pop(context);
      Common().showToast('Failed to logout');
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
    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
          statusBarColor: primaryColor,
          statusBarBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.light),
      child: PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          if (didPop) {
            return;
          }
          SystemNavigator.pop();
        },
        child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: primaryColor,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            toolbarHeight: 75,
            leading: IconButton(
              onPressed: () {
                _scaffoldKey.currentState!.openDrawer();
              },
              icon: Image.asset(
                'assets/images/menu.png',
                height: 26,
              ),
            ),
            title: Image.asset(
              'assets/images/logo.png',
              height: 70,
            ),
            centerTitle: true,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: IconButton(
                  onPressed: () async {
                    await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const ExecutiveNotificationScreen()));
                    _reload();
                  },
                  icon: Image.asset(
                    'assets/images/notification.png',
                    height: 36,
                  ),
                ),
              )
            ],
          ),
          drawer: Drawer(
            backgroundColor: primaryColor,
            child: Container(
              padding: const EdgeInsets.only(top: 60),
              child: Column(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      border: BorderDirectional(
                        bottom: BorderSide(color: Colors.white, width: 0.35),
                      ),
                    ),
                    child: ListTile(
                      splashColor: Colors.transparent,
                      onTap: () async {
                        Nav().pop(context);
                        await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const ExecutiveSelectSellerScreen()));
                        _reload();
                      },
                      leading: Image.asset(
                        'assets/images/menu-select-seller.png',
                        height: 24,
                      ),
                      title: const Text(
                        'Select Seller',
                        style: TextStyle(color: Colors.white, fontSize: 13),
                      ),
                      trailing: Image.asset(
                        'assets/images/next.png',
                        height: 13,
                      ),
                    ),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      border: BorderDirectional(
                        bottom: BorderSide(color: Colors.white, width: 0.35),
                      ),
                    ),
                    child: ListTile(
                      splashColor: Colors.transparent,
                      onTap: () async {
                        Nav().pop(context);
                        await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const ExecutiveMySellerScreen()));

                        _reload();
                      },
                      leading: Image.asset(
                        'assets/images/menu-my-seller.png',
                        height: 24,
                      ),
                      title: const Text(
                        'My Sellers',
                        style: TextStyle(color: Colors.white, fontSize: 13),
                      ),
                      trailing: Image.asset(
                        'assets/images/next.png',
                        height: 13,
                      ),
                    ),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      border: BorderDirectional(
                        bottom: BorderSide(color: Colors.white, width: 0.35),
                      ),
                    ),
                    child: ListTile(
                      splashColor: Colors.transparent,
                      onTap: () async {
                        Nav().pop(context);
                        await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const ExecutivePropertiesScreen()));

                        _reload();
                      },
                      leading: Image.asset(
                        'assets/images/menu-properties.png',
                        height: 24,
                      ),
                      title: const Text(
                        'Properties',
                        style: TextStyle(color: Colors.white, fontSize: 13),
                      ),
                      trailing: Image.asset(
                        'assets/images/next.png',
                        height: 13,
                      ),
                    ),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      border: BorderDirectional(
                        bottom: BorderSide(color: Colors.white, width: 0.35),
                      ),
                    ),
                    child: ListTile(
                      splashColor: Colors.transparent,
                      onTap: () async {
                        Nav().pop(context);
                        await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const ExecutiveMyProfileScreen()));

                        _reload();
                      },
                      leading: Image.asset(
                        'assets/images/menu-profile.png',
                        height: 24,
                      ),
                      title: const Text(
                        'Profile',
                        style: TextStyle(color: Colors.white, fontSize: 13),
                      ),
                      trailing: Image.asset(
                        'assets/images/next.png',
                        height: 13,
                      ),
                    ),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      border: BorderDirectional(
                        bottom: BorderSide(color: Colors.white, width: 0.35),
                      ),
                    ),
                    child: ListTile(
                      onTap: () {
                        Nav().pop(context);
                        Nav().push(context, const TermsAndConditionsScreen());
                      },
                      leading: Image.asset(
                        'assets/images/terms-and-conditions.png',
                        height: 24,
                      ),
                      title: const Text(
                        'Terms and Conditions',
                        style: TextStyle(color: Colors.white, fontSize: 13),
                      ),
                      trailing: Image.asset(
                        'assets/images/next.png',
                        height: 13,
                      ),
                    ),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      border: BorderDirectional(
                        bottom: BorderSide(color: Colors.white, width: 0.35),
                      ),
                    ),
                    child: ListTile(
                      onTap: () {
                        Share.share(
                            'Check out Elzsi Task Manager App on \n\n Play Store : https://play.google.com/store/apps/details?id=com.smart.elzsimanager \n\n App Store : ');
                      },
                      leading: Image.asset(
                        'assets/images/share.png',
                        height: 23,
                      ),
                      title: const Text(
                        'Share',
                        style: TextStyle(color: Colors.white, fontSize: 13),
                      ),
                      trailing: Image.asset(
                        'assets/images/next.png',
                        height: 13,
                      ),
                    ),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      border: BorderDirectional(
                        bottom: BorderSide(color: Colors.white, width: 0.35),
                      ),
                    ),
                    child: ListTile(
                      onTap: () {
                        Nav().pop(context);
                        Nav().push(context, const HelpAndSupportScreen());
                      },
                      leading: Image.asset(
                        'assets/images/help.png',
                        height: 24,
                      ),
                      title: const Text(
                        'Help & Contact Support',
                        style: TextStyle(color: Colors.white, fontSize: 13),
                      ),
                      trailing: Image.asset(
                        'assets/images/next.png',
                        height: 13,
                      ),
                    ),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      border: BorderDirectional(
                        bottom: BorderSide(color: Colors.white, width: 0.35),
                      ),
                    ),
                    child: ListTile(
                      onTap: () {
                        Nav().pop(context);
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            content: const Text('Do you want to Logout?'),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    Nav().pop(context);
                                  },
                                  child: const Text('No')),
                              TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    showDialog(
                                      barrierColor: Colors.black54,
                                      context: context,
                                      builder: (context) => PopScope(
                                        canPop: false,
                                        child: Dialog(
                                          backgroundColor: Colors.transparent,
                                          shadowColor: Colors.transparent,
                                          surfaceTintColor: Colors.transparent,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(0),
                                          ),
                                          child: const SpinKitCircle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    );
                                    _logout();
                                  },
                                  child: const Text('Yes'))
                            ],
                          ),
                        );
                      },
                      leading: Image.asset(
                        'assets/images/logout.png',
                        height: 24,
                      ),
                      title: const Text(
                        'Logout',
                        style: TextStyle(color: Colors.white, fontSize: 13),
                      ),
                      trailing: Image.asset(
                        'assets/images/next.png',
                        height: 13,
                      ),
                    ),
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
                topLeft: Radius.circular(17),
                topRight: Radius.circular(17),
              ),
            ),
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const VerticalSpace(height: 15),
                  GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    shrinkWrap: true,
                    itemCount: homeGrid.length,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 1.45,
                            crossAxisSpacing: 15,
                            mainAxisSpacing: 18),
                    itemBuilder: (context, index) => InkWell(
                      onTap: () async {
                        if (index == 0) {
                          await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const ExecutiveSelectSellerScreen()));
                          _reload();
                        } else if (index == 1) {
                          await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const ExecutiveMySellerScreen()));
                          _reload();
                        } else if (index == 2) {
                          await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const ExecutivePropertiesScreen()));
                          _reload();
                        } else if (index == 3) {
                          await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const ExecutiveMyProfileScreen()));
                          _reload();
                        }
                        // index == 0
                        //     ? Nav().push(
                        //         context,
                        //         ExecutiveSelectSellerScreen(
                        //           reloadHomeContent: _homeContent,
                        //         ))
                        //     : index == 1
                        //         ? Nav().push(
                        //             context,
                        //             ExecutiveMySellerScreen(
                        //               reloadHomeContent: _homeContent,
                        //             ))
                        //         : index == 2
                        //             ? Nav().push(
                        //                 context,
                        //                 ExecutivePropertiesScreen(
                        //                   reloadHomeContent: _homeContent,
                        //                 ))
                        //             : Nav().push(
                        //                 context,
                        //                 ExecutiveMyProfileScreen(
                        //                   reloadHomeContent: _homeContent,
                        //                 ));
                      },
                      child: Container(
                        padding: EdgeInsets.only(top: screenWidth * 0.03),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0xFFE7E7E7),
                              spreadRadius: 1.8,
                              blurRadius: 1.8,
                            )
                          ],
                        ),
                        child: Column(
                          children: [
                            Image.asset(
                              homeGrid[index]['image'],
                              height: screenWidth * 0.15,
                            ),
                            const VerticalSpace(height: 11),
                            Text(
                              homeGrid[index]['title'],
                              style: const TextStyle(color: Colors.black),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  const VerticalSpace(height: 25),
                  const Text(
                    'Recent Properties',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  const VerticalSpace(height: 17.5),

                  FutureBuilder(
                    future: _home,
                    builder: ((context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const WaitingShimmer(count: 2, height: 105);
                      } else if (snapshot.hasError) {
                        return const Center(
                            child: Text('Failed to fetch data'));
                      } else {
                        return isLoading
                            ? const WaitingShimmer(count: 2, height: 105)
                            : recentProperties.isEmpty
                                ? const Center(
                                    child: Text(
                                      'No recent properties',
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 11),
                                    ),
                                  )
                                : ListView.builder(
                                    itemCount: recentProperties.length,
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) => InkWell(
                                      onTap: () {
                                        Nav().push(
                                            context,
                                            ExecutiveViewPropertyDetailScreen(
                                              projectNo: recentProperties[index]
                                                  ['id'],
                                              reloadHomeContent: _homeContent,
                                            ));
                                      },
                                      child: Container(
                                        margin:
                                            const EdgeInsets.only(bottom: 15),
                                        padding: const EdgeInsets.all(8.5),
                                        decoration: BoxDecoration(
                                          color: inputBg,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border:
                                              Border.all(color: inputBorder),
                                        ),
                                        child: Row(
                                          children: [
                                            CachedNetworkImage(
                                              imageUrl: recentProperties[index]
                                                  ['is_project_image'],
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
                                                        BorderRadius.circular(
                                                            8)),
                                                child: Shimmer.fromColors(
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
                                              ),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      const Icon(Icons.error),
                                            ),
                                            // ClipRRect(
                                            //   borderRadius:
                                            //       BorderRadius.circular(8),
                                            //   child: Image.network(
                                            //     recentProperties[index]
                                            //         ['is_project_image'],
                                            //     height: 80,
                                            //     width: 80,
                                            //     fit: BoxFit.cover,
                                            //   ),
                                            // ),
                                            const HorizontalSpace(width: 17.5),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  recentProperties[index]
                                                          ?['project_name'] ??
                                                      '',
                                                  style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                const VerticalSpace(height: 6),
                                                SizedBox(
                                                  width: screenWidth * 0.6,
                                                  child: Text(
                                                    recentProperties[index]
                                                            ?['location'] ??
                                                        '',
                                                    overflow: TextOverflow.clip,
                                                    style: const TextStyle(
                                                        fontSize: 12.5),
                                                  ),
                                                ),
                                                const VerticalSpace(height: 6),
                                                Text(
                                                  'Total Units : ${recentProperties[index]?['no_of_units'] ?? ''}',
                                                  style: const TextStyle(
                                                      fontSize: 12.5),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                      }
                    }),
                  ),
                  // PropertiesList(
                  //   properties: homeList,
                  //   moveTo: 'detail1',
                  // )
                  paginationLoader
                      ? const Padding(
                          padding: EdgeInsets.only(top: 5, bottom: 5),
                          child: Loader(),
                        )
                      : const VerticalSpace(height: 0)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
