import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/business_model.dart';
import '../services/firestore_service.dart';
import '../utils/constants.dart';
import '../widgets/business_card.dart';
import '../widgets/shimmer_loader.dart';
import 'business_profile_screen.dart';
import 'add_business_screen.dart';
import 'search_screen.dart';
import 'profile_screen.dart';
import 'notifications_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _firestore = FirestoreService();
  int _selectedCat = 0;
  int _navIndex = 0;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        extendBody: true,
        backgroundColor: AppColors.bgBottom,
        bottomNavigationBar: _bottomNav(),
        body: IndexedStack(index: _navIndex, children: [
          _homeFeed(),
          const SearchScreen(),
          const AddBusinessScreen(),
          const ProfileScreen(),
        ]),
      ),
    );
  }

  Widget _bottomNav() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
      child: Container(
        height: 68,
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(36),
          border: Border.all(color: AppColors.divider, width: 0.5),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 30, offset: const Offset(0, 10))],
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          _navBtn(Icons.home_rounded,         'Home',     0),
          _navBtn(Icons.search_rounded,       'Search',   1),
          _navCenter(),
          _navBtn(Icons.storefront_rounded,   'Listings', 0),
          _navBtn(Icons.person_rounded,       'Profile',  3),
        ]),
      ),
    );
  }

  Widget _navBtn(IconData icon, String label, int index) {
    final sel = _navIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _navIndex = index < 3 ? index : 0),
      child: SizedBox(width: 60, child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, size: 22, color: sel ? AppColors.primary : AppColors.textMuted),
        const SizedBox(height: 3),
        Text(label, style: GoogleFonts.manrope(
          fontSize: 9, fontWeight: sel ? FontWeight.w700 : FontWeight.w400,
          color: sel ? AppColors.primary : AppColors.textMuted,
        )),
        const SizedBox(height: 2),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: sel ? 14 : 0, height: 2,
          decoration: BoxDecoration(
            color: AppColors.primary, borderRadius: BorderRadius.circular(2),
            boxShadow: [if (sel) BoxShadow(color: AppColors.primary.withOpacity(0.7), blurRadius: 6)],
          ),
        ),
      ])),
    );
  }

  Widget _navCenter() {
    return GestureDetector(
      onTap: () => setState(() => _navIndex = 2),
      child: Transform.translate(
        offset: const Offset(0, -14),
        child: Container(
          width: 56, height: 56,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.bgBottom, width: 3),
            boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.55), blurRadius: 20, offset: const Offset(0, 8))],
          ),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  Widget _placeholder(String label, IconData icon) => Container(
    decoration: const BoxDecoration(gradient: AppColors.bgGradient),
    child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(width: 70, height: 70,
        decoration: BoxDecoration(color: AppColors.bgCard, shape: BoxShape.circle,
          border: Border.all(color: AppColors.divider)),
        child: Icon(icon, color: AppColors.primary, size: 32)),
      const SizedBox(height: 16),
      Text(label, style: AppTxt.heading(20)),
      const SizedBox(height: 8),
      Text('Coming soon', style: AppTxt.sub(13)),
    ])),
  );

  Widget _homeFeed() {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.bgGradient),
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _header()),
          SliverToBoxAdapter(child: _heroBanner()),
          SliverToBoxAdapter(child: _categories()),
          SliverToBoxAdapter(child: _sectionTitle()),
          _businessList(),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }

  Widget _header() {
    return SafeArea(bottom: false, child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(children: [
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Good Morning 👋', style: GoogleFonts.manrope(color: AppColors.textSub, fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(height: 2),
            Text('Explore Sokoni', style: AppTxt.heading(24)),
          ])),
          GestureDetector(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())), child: _iconBtn(Icons.notifications_outlined)),
          const SizedBox(width: 8),
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(gradient: AppColors.primaryGradient, shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 10)]),
            child: const Icon(Icons.person_rounded, color: Colors.white, size: 20),
          ),
        ]),
        const SizedBox(height: 18),
        GestureDetector(
          onTap: () => setState(() => _navIndex = 1),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.divider, width: 0.5)),
            child: Row(children: [
              const Icon(Icons.search_rounded, color: AppColors.textMuted, size: 20),
              const SizedBox(width: 10),
              Text('Search businesses, services...', style: AppTxt.label(14)),
              const Spacer(),
              Container(padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.tune_rounded, color: AppColors.textSub, size: 14)),
            ]),
          ),
        ),
        const SizedBox(height: 20),
      ]),
    ));
  }

  Widget _iconBtn(IconData icon) => Container(
    width: 40, height: 40,
    decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.divider, width: 0.5)),
    child: Icon(icon, color: AppColors.textSub, size: 20),
  );

  Widget _heroBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 22),
      height: 148,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(fit: StackFit.expand, children: [
          CachedNetworkImage(
            imageUrl: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800',
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(color: AppColors.bgCard),
            errorWidget: (_, __, ___) => Container(color: AppColors.bgCardAlt),
          ),
          Container(decoration: const BoxDecoration(gradient: AppColors.darkOverlay)),
          Container(color: AppColors.primary.withOpacity(0.07)),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.2), borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primary.withOpacity(0.4)),
                  ),
                  child: Text('Featured', style: GoogleFonts.manrope(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w700)),
                ),
                const SizedBox(height: 10),
                Text('Register Your\nBusiness Today', style: AppTxt.heading(17)),
                const SizedBox(height: 6),
                Text('Reach thousands of customers', style: AppTxt.label(12)),
              ])),
              GestureDetector(
                onTap: () => setState(() => _navIndex = 2),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.5), blurRadius: 14, offset: const Offset(0, 4))],
                  ),
                  child: Text('Add Now', style: GoogleFonts.manrope(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _categories() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
        child: Text('CATEGORIES', style: GoogleFonts.manrope(
          fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMuted, letterSpacing: 1.2,
        )),
      ),
      SizedBox(
        height: 100,
        child: ListView.builder(
          scrollDirection: Axis.horizontal, physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          itemCount: kCategories.length,
          itemBuilder: (_, i) {
            final cat = kCategories[i];
            final sel = i == _selectedCat;
            return GestureDetector(
              onTap: () => setState(() => _selectedCat = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: 82, margin: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  color: sel ? cat.color.withOpacity(0.14) : AppColors.bgCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: sel ? cat.color.withOpacity(0.55) : AppColors.divider, width: sel ? 1.5 : 0.5),
                  boxShadow: sel ? [BoxShadow(color: cat.color.withOpacity(0.28), blurRadius: 14, offset: const Offset(0, 4))] : [],
                ),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(cat.icon, color: sel ? cat.color : AppColors.textSub, size: 26),
                  const SizedBox(height: 8),
                  Text(cat.name, style: GoogleFonts.manrope(
                    fontSize: 11, fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                    color: sel ? cat.color : AppColors.textSub,
                  )),
                ]),
              ),
            );
          },
        ),
      ),
      const SizedBox(height: 4),
    ]);
  }

  Widget _sectionTitle() {
    final cat = kCategories[_selectedCat];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(children: [
          Container(width: 3, height: 18,
            decoration: BoxDecoration(color: cat.color, borderRadius: BorderRadius.circular(2),
              boxShadow: [BoxShadow(color: cat.color.withOpacity(0.7), blurRadius: 6)])),
          const SizedBox(width: 10),
          Text(cat.name, style: AppTxt.bold(16)),
        ]),
        Text('See All', style: GoogleFonts.manrope(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w600)),
      ]),
    );
  }

  Widget _businessList() {
    final id = kCategories[_selectedCat].id;
    return StreamBuilder<List<BusinessModel>>(
      stream: _firestore.streamByCategory(id),
      builder: (_, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const SliverToBoxAdapter(child: ShimmerList(count: 4));
        }
        final list = snap.data ?? [];
        if (list.isEmpty) return SliverToBoxAdapter(child: _empty());
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (_, i) => BusinessCard(
              business: list[i], index: i,
              onTap: () => Navigator.push(context, PageRouteBuilder(
                pageBuilder: (_, __, ___) => BusinessProfileScreen(businessId: list[i].id),
                transitionsBuilder: (_, a, __, child) => SlideTransition(
                  position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
                      .animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
                  child: child,
                ),
              )),
            ),
            childCount: list.length,
          ),
        );
      },
    );
  }

  Widget _empty() {
    final cat = kCategories[_selectedCat];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 30),
      child: Column(children: [
        Container(width: 80, height: 80,
          decoration: BoxDecoration(color: cat.color.withOpacity(0.1), shape: BoxShape.circle,
            border: Border.all(color: cat.color.withOpacity(0.25), width: 1)),
          child: Icon(cat.icon, color: cat.color, size: 36)),
        const SizedBox(height: 20),
        Text('No businesses yet', style: AppTxt.bold(16)),
        const SizedBox(height: 8),
        Text('Be the first to add a ${cat.name}\nbusiness on Sokoni!',
          textAlign: TextAlign.center, style: AppTxt.sub(13)),
      ]),
    );
  }
}
