import 'package:elzsi/Utils/colors.dart';
import 'package:flutter/material.dart';

class Loader extends StatelessWidget {
  const Loader({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: 18,
        width: 18,
        child: CircularProgressIndicator(
          color: primaryColor,
        ),
      ),
    );
  }
}
