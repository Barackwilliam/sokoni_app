import 'package:flutter/material.dart';
import '../models/business_model.dart';
import '../services/firestore_service.dart';
import '../utils/constants.dart';
import '../widgets/business_card.dart';
import 'business_profile_screen.dart';
import 'add_business_screen.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  String _selectedCategory = 'mafundi';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddBusinessScreen()),
        ),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Ongeza Biashara', style: TextStyle(color: Colors.white)),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(context)),
            SliverToBoxAdapter(child: _buildCategories()),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  kCategories.firstWhere((c) => c.id == _selectedCategory).name,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            _buildBusinessList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Karibu Sokoni 👋',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'Pata biashara karibu yako',
            style: TextStyle(color: AppColors.textGrey, fontSize: 13),
          ),
          const SizedBox(height: 14),
          InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SearchScreen()),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6),
                ],
              ),
              child: const Row(
                children: [
                  Icon(Icons.search, color: AppColors.textGrey),
                  SizedBox(width: 10),
                  Text('Tafuta biashara, huduma...', style: TextStyle(color: AppColors.textGrey)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 96,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        itemCount: kCategories.length,
        itemBuilder: (context, index) {
          final cat = kCategories[index];
          final selected = cat.id == _selectedCategory;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = cat.id),
            child: Container(
              width: 78,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6),
                      ],
                    ),
                    child: Icon(
                      cat.icon,
                      color: selected ? Colors.white : AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    cat.name,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                      color: selected ? AppColors.primary : AppColors.textDark,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBusinessList() {
    return StreamBuilder<List<BusinessModel>>(
      stream: _firestoreService.streamByCategory(_selectedCategory),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }
        final businesses = snapshot.data ?? [];
        if (businesses.isEmpty) {
          return const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: Center(
                child: Text(
                  'Hakuna biashara bado katika category hii',
                  style: TextStyle(color: AppColors.textGrey),
                ),
              ),
            ),
          );
        }
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final business = businesses[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: BusinessCard(
                  business: business,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BusinessProfileScreen(businessId: business.id),
                    ),
                  ),
                ),
              );
            },
            childCount: businesses.length,
          ),
        );
      },
    );
  }
}
