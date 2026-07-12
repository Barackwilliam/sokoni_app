import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      _NotifItem(Icons.storefront_rounded, 'New Business Added', 'A new restaurant just joined Sokoni in your area', '2 min ago', AppColors.restaurantColor),
      _NotifItem(Icons.star_rounded, 'Review Received', 'Someone rated your business 5 stars!', '1 hr ago', const Color(0xFFF7941D)),
      _NotifItem(Icons.location_on_rounded, 'Nearby Deal', 'Beauty salon offering 20% discount near Kariakoo', '3 hrs ago', AppColors.beautyColor),
      _NotifItem(Icons.handyman_rounded, 'Artisan Available', 'Electrician now available in your area', '5 hrs ago', AppColors.mafundiColor),
      _NotifItem(Icons.info_rounded, 'Welcome to Sokoni', 'Start discovering businesses near you', 'Yesterday', AppColors.madukaColor),
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Row(children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.divider, width: 0.5)),
                  child: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textWhite, size: 17),
                ),
              ),
              const SizedBox(width: 16),
              Text('Notifications', style: AppTxt.heading(22)),
              const Spacer(),
              Text('Mark all read', style: GoogleFonts.manrope(
                fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
            ]),
          ),

          Expanded(child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: items.length,
            itemBuilder: (_, i) {
              final n = items[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.bgCard, borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.divider, width: 0.5),
                ),
                child: Row(children: [
                  Container(width: 44, height: 44,
                    decoration: BoxDecoration(color: n.color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
                    child: Icon(n.icon, color: n.color, size: 20)),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(n.title, style: GoogleFonts.manrope(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textWhite)),
                    const SizedBox(height: 3),
                    Text(n.body, style: GoogleFonts.manrope(fontSize: 12, color: AppColors.textSub, height: 1.4)),
                    const SizedBox(height: 5),
                    Text(n.time, style: GoogleFonts.manrope(fontSize: 10, color: AppColors.textMuted)),
                  ])),
                ]),
              );
            },
          )),
        ])),
      ),
    );
  }
}

class _NotifItem {
  final IconData icon;
  final String title, body, time;
  final Color color;
  _NotifItem(this.icon, this.title, this.body, this.time, this.color);
}
