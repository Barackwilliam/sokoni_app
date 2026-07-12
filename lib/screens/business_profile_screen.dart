import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/business_model.dart';
import '../services/firestore_service.dart';
import '../utils/constants.dart';
import '../widgets/contact_buttons.dart';

class BusinessProfileScreen extends StatefulWidget {
  final String businessId;
  const BusinessProfileScreen({super.key, required this.businessId});
  @override State<BusinessProfileScreen> createState() => _State();
}

class _State extends State<BusinessProfileScreen> {
  final _firestore = FirestoreService();
  late Future<BusinessModel?> _future;

  @override
  void initState() {
    super.initState();
    _future = _firestore.getBusinessById(widget.businessId);
  }

  void _refresh() {
    setState(() => _future = _firestore.getBusinessById(widget.businessId));
  }

  /// Masks a phone-number username for privacy: +255712345678 -> +255 712 *** 678
  String _maskName(String name) {
    final digits = name.replaceAll(RegExp(r'[^0-9+]'), '');
    if (!digits.startsWith('+') || digits.length < 10) return name;
    return '${digits.substring(0, 7)} *** ${digits.substring(digits.length - 3)}';
  }

  Color _catColor(String cat) {
    switch (cat) {
      case 'mafundi': return AppColors.mafundiColor;
      case 'maduka': return AppColors.madukaColor;
      case 'beauty': return AppColors.beautyColor;
      case 'restaurant': return AppColors.restaurantColor;
      default: return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgBottom,
      body: FutureBuilder<BusinessModel?>(
        future: _future,
        builder: (_, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return Container(decoration: const BoxDecoration(gradient: AppColors.bgGradient),
              child: const Center(child: CircularProgressIndicator(color: AppColors.primary)));
          }
          final b = snap.data;
          if (b == null) {
            return Container(decoration: const BoxDecoration(gradient: AppColors.bgGradient),
              child: Center(child: Text('Not found', style: AppTxt.sub(14))));
          }
          return _content(b);
        },
      ),
    );
  }

  Widget _content(BusinessModel b) {
    final color = _catColor(b.category);
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.bgGradient),
      child: CustomScrollView(physics: const BouncingScrollPhysics(), slivers: [
        SliverAppBar(
          expandedHeight: 240, pinned: true,
          backgroundColor: AppColors.bgTop,
          leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: AppColors.bgCard.withValues(alpha: 0.85), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textWhite, size: 17)),
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(fit: StackFit.expand, children: [
              b.imageUrls.isNotEmpty
                  ? CachedNetworkImage(imageUrl: b.imageUrls.first, fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Container(color: color.withValues(alpha: 0.12),
                        child: Icon(Icons.store_rounded, color: color, size: 60)))
                  : Container(color: color.withValues(alpha: 0.12),
                      child: Icon(Icons.store_rounded, color: color, size: 60)),
              Positioned(bottom: 0, left: 0, right: 0, child: Container(height: 100,
                decoration: const BoxDecoration(gradient: AppColors.darkOverlay))),
            ]),
          ),
        ),

        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 50),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            // Name + verified badge
            Row(children: [
              Expanded(child: Text(b.name, style: AppTxt.heading(22))),
              if (b.isVerified) Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.verified_rounded, color: AppColors.primary, size: 12),
                  const SizedBox(width: 4),
                  Text('Verified', style: GoogleFonts.manrope(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w700)),
                ]),
              ),
            ]),

            const SizedBox(height: 10),

            Row(children: [
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
                child: Text(b.subCategory, style: GoogleFonts.manrope(fontSize: 11, fontWeight: FontWeight.w600, color: color))),
              const SizedBox(width: 10),
              if (b.isAvailable) Row(children: [
                Container(width: 7, height: 7, decoration: BoxDecoration(
                  shape: BoxShape.circle, color: AppColors.success,
                  boxShadow: [BoxShadow(color: AppColors.success.withValues(alpha: 0.8), blurRadius: 6)])),
                const SizedBox(width: 5),
                Text('Open Now', style: GoogleFonts.manrope(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.w600)),
              ]),
            ]),

            const SizedBox(height: 16),

            // Stats card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.divider, width: 0.5)),
              child: Row(children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(b.rating.toStringAsFixed(1), style: GoogleFonts.manrope(
                    fontSize: 30, fontWeight: FontWeight.w800, color: AppColors.textWhite, letterSpacing: -1)),
                  RatingBarIndicator(rating: b.rating, itemCount: 5, itemSize: 14,
                    itemBuilder: (_, __) => const Icon(Icons.star_rounded, color: Color(0xFFF7941D))),
                  const SizedBox(height: 2),
                  Text('${b.ratingCount} reviews', style: AppTxt.label(11)),
                ]),
                const SizedBox(width: 20),
                Container(width: 1, height: 50, color: AppColors.divider),
                const SizedBox(width: 20),
                Expanded(child: Row(children: [
                  const Icon(Icons.location_on_rounded, size: 14, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Expanded(child: Text(b.address, style: AppTxt.sub(13))),
                ])),
              ]),
            ),

            const SizedBox(height: 18),

            // Call + WhatsApp
            ContactButtons(phone: b.phone, whatsapp: b.whatsapp),

            const SizedBox(height: 24),

            Text('About', style: AppTxt.bold(16)),
            const SizedBox(height: 10),
            Text(b.description, style: AppTxt.sub(14)),

            if (b.imageUrls.length > 1) ...[
              const SizedBox(height: 24),
              Text('Gallery', style: AppTxt.bold(16)),
              const SizedBox(height: 12),
              SizedBox(height: 100, child: ListView.separated(
                scrollDirection: Axis.horizontal, physics: const BouncingScrollPhysics(),
                itemCount: b.imageUrls.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) => ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(imageUrl: b.imageUrls[i], width: 100, height: 100, fit: BoxFit.cover)),
              )),
            ],

            const SizedBox(height: 24),

            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Reviews', style: AppTxt.bold(16)),
              GestureDetector(
                onTap: () => _showReviewSheet(b.id, color),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 4))],
                  ),
                  child: Text('Write Review', style: GoogleFonts.manrope(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                ),
              ),
            ]),

            const SizedBox(height: 14),

            StreamBuilder<List<ReviewModel>>(
              stream: _firestore.streamReviews(b.id),
              builder: (_, snap) {
                final reviews = snap.data ?? [];
                if (reviews.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.divider, width: 0.5)),
                    child: Center(child: Text('No reviews yet. Be the first!', style: AppTxt.sub(13))));
                }
                return Column(children: reviews.take(5).map((r) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.divider, width: 0.5)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Container(width: 34, height: 34,
                        decoration: BoxDecoration(color: color.withValues(alpha: 0.14), shape: BoxShape.circle),
                        child: Center(child: Text(r.userName.isNotEmpty ? r.userName[r.userName.startsWith('+') ? 1 : 0].toUpperCase() : 'U',
                          style: GoogleFonts.manrope(color: color, fontWeight: FontWeight.w700, fontSize: 14)))),
                      const SizedBox(width: 10),
                      Expanded(child: Text(_maskName(r.userName), style: AppTxt.bold(13))),
                      RatingBarIndicator(rating: r.rating, itemCount: 5, itemSize: 12,
                        itemBuilder: (_, __) => const Icon(Icons.star_rounded, color: Color(0xFFF7941D))),
                    ]),
                    const SizedBox(height: 8),
                    Text(r.comment, style: AppTxt.sub(13)),
                  ]),
                )).toList());
              },
            ),
          ]),
        )),
      ]),
    );
  }

  void _showReviewSheet(String businessId, Color color) {
    double rating = 5;
    final ctrl = TextEditingController();
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 24, 20, MediaQuery.of(ctx).viewInsets.bottom + 28),
        child: StatefulBuilder(builder: (_, set) => Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 40, height: 4,
            decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 20),
          Text('Write a Review', style: AppTxt.bold(18)),
          const SizedBox(height: 16),
          Center(child: RatingBar.builder(
            initialRating: 5, itemSize: 34,
            itemBuilder: (_, __) => const Icon(Icons.star_rounded, color: Color(0xFFF7941D)),
            onRatingUpdate: (v) => set(() => rating = v),
          )),
          const SizedBox(height: 16),
          TextField(
            controller: ctrl, maxLines: 3,
            style: GoogleFonts.manrope(color: AppColors.textWhite, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Share your experience...',
              hintStyle: GoogleFonts.manrope(color: AppColors.textMuted),
              filled: true, fillColor: AppColors.bgCardAlt,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () async {
              final user = FirebaseAuth.instance.currentUser;
              if (user == null) return;
              if (ctrl.text.trim().isEmpty) {
                ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
                    content: Text('Please write a short comment'),
                    backgroundColor: AppColors.error));
                return;
              }
              try {
                await _firestore.addReview(ReviewModel(
                  id: '', businessId: businessId, userId: user.uid,
                  userName: user.phoneNumber ?? 'User',
                  rating: rating, comment: ctrl.text.trim(), createdAt: DateTime.now(),
                ));
                if (ctx.mounted) Navigator.pop(ctx);
                if (mounted) {
                  _refresh();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Thanks for your review!'),
                      backgroundColor: AppColors.success));
                }
              } catch (_) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
                      content: Text('Failed to submit review, try again'),
                      backgroundColor: AppColors.error));
                }
              }
            },
            child: Container(
              width: double.infinity, height: 54, alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.45), blurRadius: 18, offset: const Offset(0, 6))],
              ),
              child: Text('Submit Review', style: GoogleFonts.manrope(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
            ),
          ),
        ])),
      ),
    );
  }
}
