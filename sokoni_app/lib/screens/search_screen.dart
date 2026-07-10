import 'package:flutter/material.dart';
import 'dart:async';
import '../models/business_model.dart';
import '../services/firestore_service.dart';
import '../utils/constants.dart';
import '../widgets/business_card.dart';
import 'business_profile_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  final _firestoreService = FirestoreService();
  List<BusinessModel> _results = [];
  bool _loading = false;
  Timer? _debounce;

  void _onChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () => _search(query));
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _results = []);
      return;
    }
    setState(() => _loading = true);
    final results = await _firestoreService.searchByName(query.trim());
    if (!mounted) return;
    setState(() {
      _results = results;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        title: TextField(
          controller: _controller,
          autofocus: true,
          onChanged: _onChanged,
          decoration: const InputDecoration(
            hintText: 'Tafuta biashara...',
            border: InputBorder.none,
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _results.isEmpty
              ? const Center(
                  child: Text('Andika jina la biashara unayoitafuta',
                      style: TextStyle(color: AppColors.textGrey)),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  itemCount: _results.length,
                  itemBuilder: (context, index) {
                    final business = _results[index];
                    return BusinessCard(
                      business: business,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BusinessProfileScreen(businessId: business.id),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
