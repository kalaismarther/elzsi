import 'dart:io';
import 'package:elzsi/Utils/colors.dart';
import 'package:elzsi/Utils/horizontalspace.dart';
import 'package:elzsi/Utils/navigations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class ViewPdfScreen extends StatefulWidget {
  const ViewPdfScreen({super.key, required this.appTitle, required this.file});

  final String appTitle;
  final File file;

  @override
  State<ViewPdfScreen> createState() => _ViewPdfScreenState();
}

class _ViewPdfScreenState extends State<ViewPdfScreen> {
  int currentPageNo = 0;
  int totalPageNo = 0;
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
              Text(
                widget.appTitle,
                style: const TextStyle(color: Colors.white, fontSize: 17.5),
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
        child: Center(
          child: !widget.file.path.endsWith('.pdf')
              ? const Text('This is not pdf')
              : PDFView(
                  filePath: widget.file.path,
                  onPageChanged: (page, total) {
                    setState(() {
                      currentPageNo = page! + 1;
                      totalPageNo = total!;
                    });
                  },
                ),
        ),
      ),
      bottomNavigationBar: Container(
        alignment: Alignment.center,
        color: Colors.white,
        height: 50,
        child: Text('Page $currentPageNo of $totalPageNo'),
      ),
    );
  }
}
