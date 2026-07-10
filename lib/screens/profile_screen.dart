import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/constants.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final phone = user?.phoneNumber ?? 'Guest';

    return Container(
      decoration: const BoxDecoration(gradient: AppColors.bgGradient),
      child: SafeArea(child: ListView(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        children: [
          const SizedBox(height: 10),
          Text('Profile', style: AppTxt.heading(26)),
          const SizedBox(height: 24),

          // Avatar + name card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.divider, width: 0.5),
            ),
            child: Row(children: [
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 14)],
                ),
                child: const Icon(Icons.person_rounded, color: Colors.white, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('My Account', style: AppTxt.bold(16)),
                const SizedBox(height: 4),
                Text(phone, style: AppTxt.sub(13)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                  ),
                  child: Text('Verified User', style: GoogleFonts.manrope(
                    color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w600)),
                ),
              ])),
            ]),
          ),

          const SizedBox(height: 20),

          // Menu items
          _section('My Business', [
            _item(Icons.storefront_rounded, 'My Listings', 'View your businesses', AppColors.primary),
            _item(Icons.bar_chart_rounded, 'Analytics', 'Track your performance', AppColors.primary),
          ]),

          const SizedBox(height: 16),

          _section('Settings', [
            _item(Icons.notifications_rounded, 'Notifications', 'Manage alerts', AppColors.madukaCOlor),
            _item(Icons.location_on_rounded, 'Location', 'Update your area', AppColors.restaurantColor),
            _item(Icons.language_rounded, 'Language', 'English', AppColors.beautyColor),
          ]),

          const SizedBox(height: 16),

          _section('About', [
            _item(Icons.info_outline_rounded, 'About Sokoni', 'Version 1.0.0', AppColors.textSub),
            _item(Icons.privacy_tip_outlined, 'Privacy Policy', '', AppColors.textSub),
          ]),

          const SizedBox(height: 24),

          // Sign out
          GestureDetector(
            onTap: () async {
              await FirebaseAuth.instance.signOut();
            },
            child: Container(
              height: 54, alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.error.withOpacity(0.3)),
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.logout_rounded, color: AppColors.error, size: 18),
                const SizedBox(width: 8),
                Text('Sign Out', style: GoogleFonts.manrope(
                  color: AppColors.error, fontSize: 14, fontWeight: FontWeight.w700)),
              ]),
            ),
          ),
          const SizedBox(height: 30),
        ],
      )),
    );
  }

  Widget _section(String title, List<Widget> items) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(title.toUpperCase(), style: GoogleFonts.manrope(
          fontSize: 11, fontWeight: FontWeight.w600,
          color: AppColors.textMuted, letterSpacing: 1.2)),
      ),
      Container(
        decoration: BoxDecoration(
          color: AppColors.bgCard, borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider, width: 0.5),
        ),
        child: Column(children: List.generate(items.length, (i) => Column(children: [
          items[i],
          if (i < items.length - 1) Divider(color: AppColors.divider, height: 0, thickness: 0.5, indent: 52),
        ]))),
      ),
    ]);
  }

  Widget _item(IconData icon, String title, String sub, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(children: [
        Container(width: 36, height: 36,
          decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 18)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textWhite)),
          if (sub.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(sub, style: GoogleFonts.manrope(fontSize: 11, color: AppColors.textSub)),
          ],
        ])),
        const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 18),
      ]),
    );
  }
}
