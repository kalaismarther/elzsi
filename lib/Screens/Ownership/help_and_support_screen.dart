import 'dart:convert';
import 'package:elzsi/Api/urls.dart';
import 'package:elzsi/Utils/colors.dart';
import 'package:elzsi/Utils/common.dart';
import 'package:elzsi/Utils/horizontalspace.dart';
import 'package:elzsi/utils/navigations.dart';
import 'package:elzsi/Utils/verticalspace.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class HelpAndSupportScreen extends StatefulWidget {
  const HelpAndSupportScreen({super.key});

  @override
  State<HelpAndSupportScreen> createState() => _HelpAndSupportScreenState();
}

class _HelpAndSupportScreenState extends State<HelpAndSupportScreen> {
  late Future _help;

  Map? info;

  Future<void> _getHelpAndContactSupport() async {
    final response = await http.post(Uri.parse('${liveURL}help'));

    var result = json.decode(response.body);
    if (result['status'].toString() == '1') {
      setState(() {
        info = result['data'];
      });
    } else {
      throw Exception('Failed');
    }
  }

  Future _goToCorrespondingApp(String type, String data) async {
    if (data.isEmpty || data == '') {
      return;
    }
    try {
      launchUrl(Uri(scheme: type, path: data));
    } catch (e) {
      Common().showToast('Failed to launch');
    }
  }

  @override
  void initState() {
    _help = _getHelpAndContactSupport();
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
              const HorizontalSpace(width: 9),
              Image.asset(
                'assets/images/prev.png',
                height: 17,
              ),
              const HorizontalSpace(width: 15),
              const Text(
                'Help and Contact Support',
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
          future: _help,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return SpinKitCircle(
                color: primaryColor,
              );
            } else if (snapshot.hasError) {
              return const Center(child: Text('Failed to fetch data'));
            } else {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () {
                        _goToCorrespondingApp(
                            'mailto', info?['admin_email'] ?? '');
                      },
                      child: Row(
                        children: [
                          const Text(
                            'Email : ',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            info?['admin_email'] ?? '',
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue),
                          ),
                        ],
                      ),
                    ),
                    const VerticalSpace(height: 15),
                    InkWell(
                      onTap: () {
                        _goToCorrespondingApp(
                            'tel', info?['helpcontact'] ?? '');
                      },
                      child: Row(
                        children: [
                          const Text(
                            'Mobile : ',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            info?['helpcontact'] ?? '',
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue),
                          ),
                        ],
                      ),
                    ),
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
