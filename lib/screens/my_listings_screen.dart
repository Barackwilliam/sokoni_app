import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/business_model.dart';
import '../services/firestore_service.dart';
import '../utils/constants.dart';
import '../widgets/business_card.dart';
import '../widgets/shimmer_loader.dart';
import 'business_profile_screen.dart';

/// Shows the logged-in user's own businesses with the ability to
/// toggle availability (Open/Closed) and delete a listing.
class MyListingsScreen extends StatelessWidget {
  const MyListingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final firestore = FirestoreService();

    return Container(
      decoration: const BoxDecoration(gradient: AppColors.bgGradient),
      child: SafeArea(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('My Listings', style: AppTxt.heading(26)),
                const SizedBox(height: 4),
                Text('Manage your businesses on Sokoni', style: AppTxt.sub(13)),
              ],
            ),
          ),
          Expanded(
            child: user == null
                ? Center(child: Text('Please sign in first', style: AppTxt.sub(13)))
                : StreamBuilder<List<BusinessModel>>(
                    stream: firestore.streamByOwner(user.uid),
                    builder: (context, snap) {
                      if (snap.connectionState == ConnectionState.waiting) {
                        return const SingleChildScrollView(
                            child: ShimmerList(count: 3));
                      }
                      final list = snap.data ?? [];
                      if (list.isEmpty) return _empty();
                      return ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 120),
                        itemCount: list.length,
                        itemBuilder: (_, i) => Column(children: [
                          BusinessCard(
                            business: list[i],
                            index: i,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BusinessProfileScreen(
                                    businessId: list[i].id),
                              ),
                            ),
                          ),
                          _actionsRow(context, firestore, list[i]),
                        ]),
                      );
                    },
                  ),
          ),
        ]),
      ),
    );
  }

  Widget _actionsRow(
      BuildContext context, FirestoreService firestore, BusinessModel b) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Row(children: [
        Expanded(
          child: GestureDetector(
            onTap: () async {
              try {
                await firestore
                    .updateBusiness(b.id, {'isAvailable': !b.isAvailable});
              } catch (_) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Failed to update, try again'),
                      backgroundColor: AppColors.error));
                }
              }
            },
            child: Container(
              height: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: (b.isAvailable ? AppColors.success : AppColors.textMuted)
                    .withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: (b.isAvailable
                            ? AppColors.success
                            : AppColors.textMuted)
                        .withValues(alpha: 0.35)),
              ),
              child: Text(
                b.isAvailable ? 'Open — tap to close' : 'Closed — tap to open',
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color:
                      b.isAvailable ? AppColors.success : AppColors.textSub,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: () => _confirmDelete(context, firestore, b),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
            ),
            child: const Icon(Icons.delete_outline_rounded,
                color: AppColors.error, size: 18),
          ),
        ),
      ]),
    );
  }

  void _confirmDelete(
      BuildContext context, FirestoreService firestore, BusinessModel b) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text('Delete "${b.name}"?', style: AppTxt.bold(16)),
        content: Text(
            'This will permanently remove the business and its photos. This cannot be undone.',
            style: AppTxt.sub(13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: GoogleFonts.manrope(color: AppColors.textSub)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await firestore.deleteBusiness(b.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Business deleted'),
                      backgroundColor: AppColors.success));
                }
              } catch (_) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Failed to delete, try again'),
                      backgroundColor: AppColors.error));
                }
              }
            },
            child: Text('Delete',
                style: GoogleFonts.manrope(
                    color: AppColors.error, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _empty() {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border:
                  Border.all(color: AppColors.primary.withValues(alpha: 0.25))),
          child: const Icon(Icons.storefront_rounded,
              color: AppColors.primary, size: 36),
        ),
        const SizedBox(height: 20),
        Text('No listings yet', style: AppTxt.bold(16)),
        const SizedBox(height: 8),
        Text('Tap the + button below to add\nyour first business',
            textAlign: TextAlign.center, style: AppTxt.sub(13)),
      ]),
    );
  }
}
