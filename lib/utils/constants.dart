import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color bgTop      = Color(0xFF2A2418);
  static const Color bgBottom   = Color(0xFF1A1610);
  static const Color bgCard     = Color(0xFF1E1A14);
  static const Color bgCardAlt  = Color(0xFF252018);
  static const Color surface    = Color(0xFF2E2820);
  static const Color divider    = Color(0xFF3A3228);

  static const Color primary    = Color(0xFFF7941D);
  static const Color primaryDeep= Color(0xFFE0820F);

  static const Color textWhite  = Color(0xFFFFFFFF);
  static const Color textSub    = Color(0xFF9B9B9B);
  static const Color textMuted  = Color(0xFF5A5248);

  static const Color success    = Color(0xFF4CAF50);
  static const Color error      = Color(0xFFFF453A);
  static const Color whatsapp   = Color(0xFF25D366);

  static const Color mafundiColor    = Color(0xFFF7941D);
  static const Color madukaCOlor     = Color(0xFF4A9EFF);
  static const Color beautyColor     = Color(0xFFFF6EA3);
  static const Color restaurantColor = Color(0xFF4CAF50);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFF7941D), Color(0xFFE0820F)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  static const LinearGradient bgGradient = LinearGradient(
    colors: [Color(0xFF2A2418), Color(0xFF1A1610)],
    begin: Alignment.topCenter, end: Alignment.bottomCenter,
  );
  static const LinearGradient darkOverlay = LinearGradient(
    colors: [Colors.transparent, Color(0xDD1A1610)],
    begin: Alignment.topCenter, end: Alignment.bottomCenter,
  );
}

class AppTxt {
  static TextStyle heading(double size) => GoogleFonts.manrope(
    fontSize: size, fontWeight: FontWeight.w800,
    color: AppColors.textWhite, letterSpacing: -0.5,
  );
  static TextStyle sub(double size) => GoogleFonts.manrope(
    fontSize: size, fontWeight: FontWeight.w400,
    color: AppColors.textSub, height: 1.5,
  );
  static TextStyle bold(double size, {Color? color}) => GoogleFonts.manrope(
    fontSize: size, fontWeight: FontWeight.w700,
    color: color ?? AppColors.textWhite,
  );
  static TextStyle label(double size) => GoogleFonts.manrope(
    fontSize: size, fontWeight: FontWeight.w500,
    color: AppColors.textSub,
  );
}

class AppCategory {
  final String id, name, subtitle, imageUrl;
  final IconData icon;
  final Color color;
  const AppCategory({required this.id, required this.name, required this.icon,
    required this.color, required this.subtitle, required this.imageUrl});
}

const List<AppCategory> kCategories = [
  AppCategory(id: 'mafundi', name: 'Artisans', icon: Icons.handyman_rounded,
    color: Color(0xFFF7941D), subtitle: 'Find skilled workers',
    imageUrl: 'https://images.unsplash.com/photo-1621905251918-48416bd8575a?w=400'),
  AppCategory(id: 'maduka', name: 'Shops', icon: Icons.storefront_rounded,
    color: Color(0xFF4A9EFF), subtitle: 'Buy what you need',
    imageUrl: 'https://images.unsplash.com/photo-1555529669-e69e7aa0ba9a?w=400'),
  AppCategory(id: 'beauty', name: 'Beauty', icon: Icons.spa_rounded,
    color: Color(0xFFFF6EA3), subtitle: 'Salons & beauty care',
    imageUrl: 'https://images.unsplash.com/photo-1560066984-138daab0473b?w=400'),
  AppCategory(id: 'restaurant', name: 'Restaurant', icon: Icons.restaurant_rounded,
    color: Color(0xFF4CAF50), subtitle: 'Delicious food nearby',
    imageUrl: 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=400'),
];

const Map<String, List<String>> kSubCategories = {
  'mafundi':    ['Electrician','Construction','Plumber','Carpenter','Painter','Welder'],
  'maduka':     ['Electronics','Fashion','Beauty Products','Supermarket','Hardware','Stationery'],
  'beauty':     ['Hair Salon','Nails','Makeup','Spa & Massage','Barbershop','Skincare'],
  'restaurant': ['Local Food','Fast Food','BBQ','Sea Food','Juice & Drinks','Bakery'],
};

class FirestoreCollections {
  static const String businesses = 'businesses';
  static const String users      = 'users';
  static const String reviews    = 'reviews';
}

const String kAppName = 'Sokoni';
