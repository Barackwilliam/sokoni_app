import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/business_model.dart';
import '../utils/constants.dart';

class BusinessCard extends StatelessWidget {
  final BusinessModel business;
  final VoidCallback onTap;
  final int index;
  const BusinessCard({super.key, required this.business, required this.onTap, this.index = 0});

  Color get _color {
    switch (business.category) {
      case 'mafundi': return AppColors.mafundiColor;
      case 'maduka': return AppColors.madukaCOlor;
      case 'beauty': return AppColors.beautyColor;
      case 'restaurant': return AppColors.restaurantColor;
      default: return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 350 + index * 60),
      curve: Curves.easeOutCubic,
      builder: (_, v, child) => Opacity(
        opacity: v, child: Transform.translate(offset: Offset(0, 18 * (1 - v)), child: child),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.divider, width: 0.5),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.35), blurRadius: 14, offset: const Offset(0, 5))],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Row(children: [
              Stack(children: [
                SizedBox(
                  width: 106, height: 112,
                  child: business.imageUrls.isNotEmpty
                      ? CachedNetworkImage(imageUrl: business.imageUrls.first, fit: BoxFit.cover,
                          placeholder: (_, __) => Container(color: _color.withOpacity(0.08),
                            child: Center(child: Icon(Icons.store_rounded, color: _color.withOpacity(0.3), size: 28))),
                          errorWidget: (_, __, ___) => Container(color: _color.withOpacity(0.08),
                            child: Center(child: Icon(Icons.store_rounded, color: _color.withOpacity(0.3), size: 28))))
                      : Container(color: _color.withOpacity(0.08),
                          child: Center(child: Icon(Icons.store_rounded, color: _color.withOpacity(0.4), size: 34))),
                ),
                Positioned(left: 0, top: 0, bottom: 0, child: Container(
                  width: 3,
                  decoration: BoxDecoration(
                    color: _color,
                    boxShadow: [BoxShadow(color: _color.withOpacity(0.9), blurRadius: 8)],
                  ),
                )),
              ]),
              Expanded(child: Padding(
                padding: const EdgeInsets.fromLTRB(13, 13, 10, 13),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(child: Text(business.name,
                      style: GoogleFonts.manrope(fontWeight: FontWeight.w700, fontSize: 14.5,
                        color: AppColors.textWhite, letterSpacing: -0.2),
                      maxLines: 1, overflow: TextOverflow.ellipsis)),
                    if (business.isAvailable) Row(mainAxisSize: MainAxisSize.min, children: [
                      Container(width: 6, height: 6, decoration: BoxDecoration(
                        shape: BoxShape.circle, color: AppColors.success,
                        boxShadow: [BoxShadow(color: AppColors.success.withOpacity(0.8), blurRadius: 6)],
                      )),
                      const SizedBox(width: 4),
                      Text('Open', style: GoogleFonts.manrope(fontSize: 10, color: AppColors.success, fontWeight: FontWeight.w600)),
                    ]),
                  ]),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                    decoration: BoxDecoration(color: _color.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
                    child: Text(business.subCategory, style: GoogleFonts.manrope(fontSize: 10, fontWeight: FontWeight.w600, color: _color)),
                  ),
                  const SizedBox(height: 8),
                  Row(children: [
                    RatingBarIndicator(rating: business.rating, itemCount: 5, itemSize: 12,
                      itemBuilder: (_, __) => const Icon(Icons.star_rounded, color: Color(0xFFF7941D))),
                    const SizedBox(width: 5),
                    Text('${business.rating.toStringAsFixed(1)} · ${business.ratingCount} reviews',
                      style: GoogleFonts.manrope(fontSize: 10, color: AppColors.textMuted)),
                  ]),
                  const SizedBox(height: 6),
                  Row(children: [
                    Icon(Icons.location_on_rounded, size: 11, color: _color.withOpacity(0.8)),
                    const SizedBox(width: 3),
                    Expanded(child: Text(business.address,
                      style: GoogleFonts.manrope(fontSize: 11, color: AppColors.textSub),
                      maxLines: 1, overflow: TextOverflow.ellipsis)),
                  ]),
                ]),
              )),
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.chevron_right_rounded, color: AppColors.textSub, size: 18),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
