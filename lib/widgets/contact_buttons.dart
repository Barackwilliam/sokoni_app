import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/constants.dart';

class ContactButtons extends StatelessWidget {
  final String phone, whatsapp;
  const ContactButtons({super.key, required this.phone, required this.whatsapp});

  Future<void> _call() async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _wa() async {
    final n = whatsapp.replaceAll('+', '').replaceAll(' ', '');
    final uri = Uri.parse('https://wa.me/$n');
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(child: GestureDetector(
        onTap: _call,
        child: Container(
          height: 54, alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.45), blurRadius: 18, offset: const Offset(0, 6))],
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.call_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text('Call Now', style: GoogleFonts.manrope(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
          ]),
        ),
      )),
      const SizedBox(width: 10),
      Expanded(child: GestureDetector(
        onTap: _wa,
        child: Container(
          height: 54, alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.whatsapp.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.whatsapp.withOpacity(0.35), width: 1),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.chat_rounded, color: AppColors.whatsapp, size: 18),
            const SizedBox(width: 8),
            Text('WhatsApp', style: GoogleFonts.manrope(color: AppColors.whatsapp, fontWeight: FontWeight.w700, fontSize: 14)),
          ]),
        ),
      )),
    ]);
  }
}
