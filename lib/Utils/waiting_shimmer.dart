import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class WaitingShimmer extends StatelessWidget {
  const WaitingShimmer({super.key, required this.count, required this.height});

  final int count;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: count,
      itemBuilder: (context, index) => Container(
        height: height,
        margin: const EdgeInsets.only(bottom: 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Shimmer.fromColors(
          baseColor: const Color(0xFFE2E2E2),
          highlightColor: Colors.grey.shade50,
          child: Container(
            decoration: BoxDecoration(
              color: const Color.fromARGB(169, 226, 226, 226),
              borderRadius: BorderRadius.circular(13),
            ),
          ),
        ),
      ),
    );
  }
}
