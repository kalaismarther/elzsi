import 'dart:convert';
import 'package:elzsi/Api/urls.dart';
import 'package:elzsi/Utils/colors.dart';
import 'package:elzsi/Utils/horizontalspace.dart';
import 'package:elzsi/utils/navigations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;

class TermsAndConditionsScreen extends StatefulWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  State<TermsAndConditionsScreen> createState() =>
      _TermsAndConditionsScreenState();
}

class _TermsAndConditionsScreenState extends State<TermsAndConditionsScreen> {
  late Future _termsAndConditions;

  String? termsAndConditions;

  Future<void> _getTermsAndConditions() async {
    final response = await http.post(Uri.parse('${liveURL}page/terms'));

    var result = json.decode(response.body);
    if (result['status'].toString() == '1') {
      setState(() {
        termsAndConditions = result['data'];
      });
    } else {
      throw Exception('Failed');
    }
  }

  @override
  void initState() {
    _termsAndConditions = _getTermsAndConditions();
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
                'Terms and Conditions',
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
          future: _termsAndConditions,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return SpinKitCircle(
                color: primaryColor,
              );
            } else if (snapshot.hasError) {
              return const Center(child: Text('Failed to fetch data'));
            } else {
              return SingleChildScrollView(
                  child: Html(data: termsAndConditions ?? ''));
            }
          },
        ),
      ),
    );
  }
}
