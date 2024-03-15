import 'package:elzsi/Api/api_call.dart';
import 'package:elzsi/Database/database_helper.dart';
import 'package:elzsi/Utils/colors.dart';
import 'package:elzsi/Utils/horizontalspace.dart';
import 'package:elzsi/Utils/loader.dart';
import 'package:elzsi/utils/navigations.dart';
import 'package:elzsi/Utils/verticalspace.dart';
import 'package:elzsi/Utils/waiting_shimmer.dart';
import 'package:flutter/material.dart';

class LeaderExecutiveScreen extends StatefulWidget {
  const LeaderExecutiveScreen({super.key});

  @override
  State<LeaderExecutiveScreen> createState() => _LeaderExecutiveScreenState();
}

class _LeaderExecutiveScreenState extends State<LeaderExecutiveScreen> {
  late Future _getExecutives;
  //CONTROLLERS
  final _scrollController = ScrollController();

  //FOR LOADER
  bool paginationLoader = false;

  //FOR PAGINTION
  int? pageNo;
  List executivesList = [];

  Future<void> _getExecutivesList() async {
    setState(() {
      pageNo = executivesList.length;
    });
    final userInfo = await DatabaseHelper().initDb();
    var data = {"user_id": userInfo.userId, "page_no": executivesList.length};

    if (!context.mounted) {
      return;
    }
    try {
      final result =
          await Api().getExecutivesList(data, userInfo.token, context);

      if (result['status'].toString() == '1') {
        setState(() {
          executivesList.addAll(result['data']);
        });
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
    _getExecutives = _getExecutivesList();
    _scrollController.addListener(() {
      if (_scrollController.position.maxScrollExtent ==
          _scrollController.offset) {
        if (pageNo != null && pageNo != executivesList.length) {
          setState(() {
            paginationLoader = true;
          });
          _getExecutivesList();
        }
      }
    });
    super.initState();
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
                'Executives',
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
            future: _getExecutives,
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
                return executivesList.isEmpty
                    ? const Center(
                        child: Text(
                          'No executives found',
                          style: TextStyle(color: Colors.grey, fontSize: 11),
                        ),
                      )
                    : SingleChildScrollView(
                        child: Column(
                          children: [
                            const VerticalSpace(height: 10),
                            ListView.builder(
                              itemCount: executivesList.length,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) => Container(
                                margin: const EdgeInsets.all(7.5),
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color: inputBg,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: inputBorder),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Name : ${executivesList[index]?['agent_name'] ?? ''}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      'Mobile Number : ${executivesList[index]?['agent_mobile'] ?? ''}',
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      'Mail address : ${executivesList[index]?['agent_email'] ?? ''}',
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ],
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
          )),
    );
  }
}
