import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../utils/constants.dart';

class ShimmerBusinessCard extends StatelessWidget {
  const ShimmerBusinessCard({super.key});
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.bgCard,
      highlightColor: AppColors.surface,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        height: 112,
        decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(18)),
        child: Row(children: [
          Container(width: 106, decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(18), bottomLeft: Radius.circular(18)),
          )),
          Expanded(child: Padding(
            padding: const EdgeInsets.fromLTRB(13, 14, 13, 14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Container(height: 14, width: 150, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6))),
              Container(height: 10, width: 80,  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6))),
              Container(height: 10, width: 120, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6))),
              Container(height: 10, width: 140, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6))),
            ]),
          )),
        ]),
      ),
    );
  }
}

class ShimmerList extends StatelessWidget {
  final int count;
  const ShimmerList({super.key, this.count = 5});
  @override
  Widget build(BuildContext context) => Column(
    children: List.generate(count, (_) => const ShimmerBusinessCard()),
  );
}
