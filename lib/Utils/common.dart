import 'package:elzsi/Database/database_helper.dart';
import 'package:elzsi/Screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

late SharedPreferences pref;

class Common {
  showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.grey.shade900,
      textColor: Colors.white,
      fontSize: 14,
    );
  }

  void logout(context) async {
    await pref.remove('loggedIn');
    await pref.remove('executiveLogin');
    await pref.remove('leaderLogin');
    await DatabaseHelper().deleteDb();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
          builder: (BuildContext context) => const SplashScreen()),
      ModalRoute.withName('/splash_screen'),
    );
  }
}
