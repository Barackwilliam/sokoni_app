import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';
import '../models/business_model.dart';
import '../services/firestore_service.dart';
import '../utils/constants.dart';
import '../widgets/business_card.dart';
import 'business_profile_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _ctrl = TextEditingController();
  final _firestore = FirestoreService();
  List<BusinessModel> _results = [];
  bool _loading = false;
  Timer? _debounce;

  void _onChanged(String q) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () => _search(q));
  }

  Future<void> _search(String q) async {
    if (q.trim().isEmpty) { setState(() => _results = []); return; }
    setState(() => _loading = true);
    final r = await _firestore.searchByName(q.trim());
    if (mounted) setState(() { _results = r; _loading = false; });
  }

  @override
  void dispose() { _debounce?.cancel(); _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.bgGradient),
      child: SafeArea(child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Search', style: AppTxt.heading(26)),
            const SizedBox(height: 4),
            Text('Find what you need near you', style: AppTxt.sub(13)),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.divider, width: 0.5)),
              child: TextField(
                controller: _ctrl, onChanged: _onChanged,
                style: GoogleFonts.manrope(color: AppColors.textWhite, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search businesses...',
                  hintStyle: GoogleFonts.manrope(color: AppColors.textMuted, fontSize: 14),
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textMuted, size: 20),
                  suffixIcon: _ctrl.text.isNotEmpty
                      ? IconButton(icon: const Icon(Icons.close_rounded, color: AppColors.textMuted, size: 18),
                          onPressed: () { _ctrl.clear(); setState(() => _results = []); })
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ]),
        ),
        Expanded(child: _loading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : _results.isEmpty
                ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Container(width: 70, height: 70,
                      decoration: BoxDecoration(color: AppColors.bgCard, shape: BoxShape.circle,
                        border: Border.all(color: AppColors.divider)),
                      child: const Icon(Icons.search_rounded, color: AppColors.textMuted, size: 30)),
                    const SizedBox(height: 16),
                    Text(_ctrl.text.isEmpty ? 'Start typing to search' : 'No results found', style: AppTxt.sub(13)),
                  ]))
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: _results.length,
                    itemBuilder: (_, i) => BusinessCard(
                      business: _results[i], index: i,
                      onTap: () => Navigator.push(context, MaterialPageRoute(
                        builder: (_) => BusinessProfileScreen(businessId: _results[i].id))),
                    ),
                  )),
      ])),
    );
  }
}
