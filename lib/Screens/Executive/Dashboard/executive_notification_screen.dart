import 'package:elzsi/Api/api_call.dart';
import 'package:elzsi/Database/database_helper.dart';
import 'package:elzsi/Utils/colors.dart';
import 'package:elzsi/Utils/horizontalspace.dart';
import 'package:elzsi/Utils/loader.dart';
import 'package:elzsi/Utils/navigations.dart';
import 'package:elzsi/Utils/verticalspace.dart';
import 'package:elzsi/Utils/waiting_shimmer.dart';
import 'package:flutter/material.dart';

class ExecutiveNotificationScreen extends StatefulWidget {
  const ExecutiveNotificationScreen(
      {super.key, required this.reloadHomeContent});

  final Function() reloadHomeContent;

  @override
  State<ExecutiveNotificationScreen> createState() =>
      _ExecutiveNotificationScreenState();
}

class _ExecutiveNotificationScreenState
    extends State<ExecutiveNotificationScreen> {
  @override
  void initState() {
    _getNotifications = _getNotificationsList();
    _scrollController.addListener(() {
      if (_scrollController.position.maxScrollExtent ==
          _scrollController.offset) {
        if (pageNo != null && pageNo != notifications.length) {
          setState(() {
            paginationLoader = true;
          });
          _getNotificationsList();
        }
      }
    });
    super.initState();
  }

  //FUTURE
  late Future _getNotifications;

  //CONTROLLERS
  final _scrollController = ScrollController();

  //NOTIFICATIONS
  List notifications = [];

  //FOR PAGINATION
  int? pageNo;
  bool paginationLoader = false;

  //GETTING NOTIFICATIONS
  Future<void> _getNotificationsList() async {
    setState(() {
      pageNo = notifications.length;
    });
    final userInfo = await DatabaseHelper().initDb();
    var data = {"user_id": userInfo.userId, "page_no": notifications.length};

    if (!context.mounted) {
      return;
    }
    try {
      final result =
          await Api().getNotifications(data, userInfo.token, context);

      if (result['status'].toString() == '1') {
        setState(() {
          notifications.addAll(result['data']);
          paginationLoader = false;
        });
      } else {
        setState(() {
          paginationLoader = false;
        });
      }
    } catch (e) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Something Went Wrong')));
    }
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
                const HorizontalSpace(width: 7),
                Image.asset(
                  'assets/images/prev.png',
                  height: 15,
                ),
                const HorizontalSpace(width: 15),
                const Text(
                  'Notifications',
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
            future: _getNotifications,
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
                return notifications.isEmpty
                    ? const Center(
                        child: Text(
                          'No notifications',
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
                                itemCount: notifications.length,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) => Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 7.5),
                                      child: Card(
                                        color: inputBg,
                                        child: Padding(
                                          padding: const EdgeInsets.all(12.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                notifications[index]
                                                        ?['title'] ??
                                                    '',
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15),
                                              ),
                                              const VerticalSpace(height: 10),
                                              Text(
                                                notifications[index]
                                                        ?['message'] ??
                                                    '',
                                                style: TextStyle(
                                                    fontSize: 13,
                                                    color:
                                                        Colors.grey.shade600),
                                              ),
                                              const VerticalSpace(height: 8),
                                              Text(
                                                notifications[index]
                                                        ?['is_created_ago'] ??
                                                    '',
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.black),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    )),
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
