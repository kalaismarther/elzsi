import 'package:flutter/material.dart';

class Nav {
  Future<void> push(context, Widget screenName) async {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => screenName));
  }

  void replace(context, Widget screenName) {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => screenName));
  }

  void pop(context) {
    Navigator.of(context).pop();
  }
}
