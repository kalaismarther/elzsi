import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class CircleShimmer extends StatelessWidget {
  const CircleShimmer({super.key, required this.height, required this.width});

  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(shape: BoxShape.circle),
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
    );
  }
}
