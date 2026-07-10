import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/constants.dart';

/// Button mbili (Call na WhatsApp) - hizi ndizo core actions za MVP
class ContactButtons extends StatelessWidget {
  final String phone;
  final String whatsapp;

  const ContactButtons({super.key, required this.phone, required this.whatsapp});

  Future<void> _call() async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _whatsapp() async {
    final number = whatsapp.replaceAll('+', '').replaceAll(' ', '');
    final uri = Uri.parse('https://wa.me/$number');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _call,
            icon: const Icon(Icons.call, size: 18),
            label: const Text('Piga Simu'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.call,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _whatsapp,
            icon: const Icon(Icons.chat, size: 18),
            label: const Text('WhatsApp'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.whatsapp,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
      ],
    );
  }
}
