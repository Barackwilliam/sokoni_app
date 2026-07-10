import 'package:flutter/material.dart';

/// Rangi kuu za app
class AppColors {
  static const Color primary = Color(0xFF1B7A43); // green - soko/biashara
  static const Color secondary = Color(0xFFFFA500); // orange accent
  static const Color background = Color(0xFFF7F8FA);
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textGrey = Color(0xFF7A7A7A);
  static const Color whatsapp = Color(0xFF25D366);
  static const Color call = Color(0xFF1B7A43);
}

/// Categories kuu nne za MVP
class AppCategory {
  final String id;
  final String name;
  final IconData icon;

  const AppCategory({required this.id, required this.name, required this.icon});
}

const List<AppCategory> kCategories = [
  AppCategory(id: 'mafundi', name: 'Mafundi', icon: Icons.handyman),
  AppCategory(id: 'maduka', name: 'Maduka', icon: Icons.storefront),
  AppCategory(id: 'beauty', name: 'Beauty', icon: Icons.spa),
  AppCategory(id: 'restaurant', name: 'Restaurant', icon: Icons.restaurant),
];

/// Sub-categories kwa kila category kuu (zinatumika kwenye Add Business
/// ili owner achague aina ya huduma anayotoa)
const Map<String, List<String>> kSubCategories = {
  'mafundi': ['Umeme', 'Ujenzi', 'Mabomba', 'Vifaa vya Umeme', 'Useremala'],
  'maduka': ['Electronics', 'Fashion', 'Beauty Products', 'Supermarket', 'Vifaa vya Nyumbani', 'Hardware'],
  'beauty': ['Hair Salon', 'Nails', 'Makeup', 'Spa & Massage', 'Barbershop', 'Skincare'],
  'restaurant': ['Local Food', 'Fast Food', 'BBQ', 'Sea Food', 'Juice & Drinks'],
};

/// Majina ya Firestore collections - yawekwe sehemu moja ili
/// kuepuka typo errors kote kwenye app
class FirestoreCollections {
  static const String businesses = 'businesses';
  static const String users = 'users';
  static const String reviews = 'reviews';
}

const String kAppName = 'Sokoni';
