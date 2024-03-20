import 'package:elzsi/Services/notification_service.dart';
import 'package:elzsi/Screens/Executive/Dashboard/executive_home_screen.dart';
import 'package:elzsi/Screens/Leader/Dashboard/leader_home_screen.dart';
import 'package:elzsi/Screens/login_screen.dart';
import 'package:elzsi/Utils/common.dart';
import 'package:elzsi/Utils/colors.dart';
import 'package:elzsi/utils/navigations.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    pref = await SharedPreferences.getInstance();
    setState(() {
      alreadyLoggedIn = pref.getBool('loggedIn');
      executiveLogin = pref.getBool('executiveLogin');
      leaderLogin = pref.getBool('leaderLogin');
    });

    Future.delayed(const Duration(seconds: 1, milliseconds: 450), () {
      Nav().replace(
          context,
          alreadyLoggedIn == true && executiveLogin == true
              ? const ExecutiveHomeScreen()
              : alreadyLoggedIn == true && leaderLogin == true
                  ? const LeaderHomeScreen()
                  : const LoginScreen());
    });
  }

  Future<void> notification() async {
    final fcm = FirebaseMessaging.instance;
    await fcm.requestPermission();
    // ignore: unused_local_variable
    final fcmToken = await fcm.getToken();

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
