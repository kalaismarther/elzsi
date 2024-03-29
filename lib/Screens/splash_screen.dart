import 'dart:io';

import 'package:elzsi/Services/notification_service.dart';
import 'package:elzsi/Screens/Executive/Dashboard/executive_home_screen.dart';
import 'package:elzsi/Screens/Leader/Dashboard/leader_home_screen.dart';
import 'package:elzsi/Screens/login_screen.dart';
import 'package:elzsi/Utils/common.dart';
import 'package:elzsi/Utils/colors.dart';
import 'package:elzsi/Utils/horizontalspace.dart';
import 'package:elzsi/utils/navigations.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:new_version_plus/new_version_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher_string.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool? alreadyLoggedIn = false;
  bool? executiveLogin = false;
  bool? leaderLogin = false;
  @override
  void initState() {
    _startApp();
    notification();
    super.initState();
  }

  void _startApp() async {
    final newVersion = NewVersionPlus(
        androidId: 'com.smart.elzsimanager', iOSId: 'com.smart.elzsimanager');
    final status = await newVersion.getVersionStatus();

    try {
      if (status != null) {
        if (status.canUpdate) {
          showDialog(
              barrierColor: Colors.black12,
              barrierDismissible: false,
              context: context,
              builder: (context) => PopScope(
                    canPop: false,
                    child: AlertDialog(
                      title: Row(
                        children: [
                          Platform.isIOS
                              ? Image.asset(
                                  'assets/images/appstore.png',
                                  height: 24,
                                )
                              : Image.asset(
                                  'assets/images/playstore.png',
                                  height: 24,
                                ),
                          const HorizontalSpace(width: 10),
                          const Text(
                            'Update Available',
                            style: TextStyle(
                                fontSize: 16.5,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1),
                          ),
                        ],
                      ),
                      content: Platform.isIOS
                          ? const Text(
                              'New version of Elzsi Task Manager is now available on App Store. Please update it')
                          : const Text(
                              'New version of Elzsi Task Manager is now available on Play Store. Please update it'),
                      actions: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10)),
                          onPressed: () {
                            try {
                              if (Platform.isIOS) {
                                Nav().pop(context);
                                Common()
                                    .showToast('Will launch soon on App Store');
                              } else {
                                launchUrlString(status.appStoreLink);
                              }
                            } catch (e) {
                              Common().showToast('Failed to launch');
                            }
                          },
                          child: const Text('Update'),
                        ),
                      ],
                    ),
                  ));
        } else {
          pref = await SharedPreferences.getInstance();
          setState(() {
            alreadyLoggedIn = pref.getBool('loggedIn');
            executiveLogin = pref.getBool('executiveLogin');
            leaderLogin = pref.getBool('leaderLogin');
          });

          Future.delayed(const Duration(milliseconds: 400), () {
            Nav().replace(
                context,
                alreadyLoggedIn == true && executiveLogin == true
                    ? const ExecutiveHomeScreen()
                    : alreadyLoggedIn == true && leaderLogin == true
                        ? const LeaderHomeScreen()
                        : const LoginScreen());
          });
        }
      }
    } catch (e) {
      //
    }
  }

  Future<void> notification() async {
    final fcm = FirebaseMessaging.instance;
    await fcm.requestPermission();
    // ignore: unused_local_variable
    final fcmToken = await fcm.getToken();
    print(fcmToken);

    await FirebaseMessaging.instance.getInitialMessage();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      NotificationService().showNotification(
          title: message.notification?.title, body: message.notification?.body);
    });
  }

  @override
  Widget build(BuildContext context) {
    // double screenWidth = MediaQuery.of(context).size.width;
    // double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: primaryColor,
      body: Center(
        child: Image.asset(
          'assets/images/splashlogo.png',
          height: 250,
          width: 250,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
