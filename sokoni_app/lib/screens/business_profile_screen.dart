import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/business_model.dart';
import '../services/firestore_service.dart';
import '../utils/constants.dart';
import '../widgets/contact_buttons.dart';

class BusinessProfileScreen extends StatefulWidget {
  final String businessId;
  const BusinessProfileScreen({super.key, required this.businessId});

  @override
  State<BusinessProfileScreen> createState() => _BusinessProfileScreenState();
}

class _BusinessProfileScreenState extends State<BusinessProfileScreen> {
  final _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<BusinessModel?>(
        future: _firestoreService.getBusinessById(widget.businessId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final business = snapshot.data;
          if (business == null) {
            return const Center(child: Text('Biashara haipatikani'));
          }
          return _buildContent(business);
        },
      ),
    );
  }

  Widget _buildContent(BusinessModel business) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 220,
          pinned: true,
          backgroundColor: AppColors.primary,
          flexibleSpace: FlexibleSpaceBar(
            background: business.imageUrls.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: business.imageUrls.first,
                    fit: BoxFit.cover,
                    errorWidget: (c, _, _) =>
                        Container(color: AppColors.primary),
                  )
                : Container(
                    color: AppColors.primary,
                    child: const Icon(
                      Icons.store,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        business.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (business.isVerified)
                      const Icon(
                        Icons.verified,
                        color: AppColors.primary,
                        size: 22,
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  business.subCategory,
                  style: const TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    RatingBarIndicator(
                      rating: business.rating,
                      itemCount: 5,
                      itemSize: 18,
                      itemBuilder: (c, _) =>
                          const Icon(Icons.star, color: Colors.amber),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${business.rating.toStringAsFixed(1)} (${business.ratingCount} reviews)',
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 16,
                      color: AppColors.textGrey,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        business.address,
                        style: const TextStyle(color: AppColors.textGrey),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: business.isAvailable
                            ? AppColors.primary.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        business.isAvailable ? 'Available' : 'Busy',
                        style: TextStyle(
                          fontSize: 11,
                          color: business.isAvailable
                              ? AppColors.primary
                              : Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                ContactButtons(
                  phone: business.phone,
                  whatsapp: business.whatsapp,
                ),
                const SizedBox(height: 22),
                const Text(
                  'Maelezo',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  business.description,
                  style: const TextStyle(
                    height: 1.5,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 22),
                if (business.imageUrls.length > 1) ...[
                  const Text(
                    'Picha za Kazi',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 90,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: business.imageUrls.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (context, index) => ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: CachedNetworkImage(
                          imageUrl: business.imageUrls[index],
                          width: 90,
                          height: 90,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                ],
                const Text(
                  'Reviews',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                _buildReviewsSection(business.id),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => _showAddReviewSheet(business.id),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 44),
                    side: const BorderSide(color: AppColors.primary),
                  ),
                  child: const Text(
                    'Andika Review',
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewsSection(String businessId) {
    return StreamBuilder<List<ReviewModel>>(
      stream: _firestoreService.streamReviews(businessId),
      builder: (context, snapshot) {
        final reviews = snapshot.data ?? [];
        if (reviews.isEmpty) {
          return const Text(
            'Bado hakuna reviews',
            style: TextStyle(color: AppColors.textGrey),
          );
        }
        return Column(
          children: reviews.take(5).map((r) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        r.userName,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 8),
                      RatingBarIndicator(
                        rating: r.rating,
                        itemCount: 5,
                        itemSize: 13,
                        itemBuilder: (c, _) =>
                            const Icon(Icons.star, color: Colors.amber),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    r.comment,
                    style: const TextStyle(color: AppColors.textDark),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  void _showAddReviewSheet(String businessId) {
    double rating = 5;
    final commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: StatefulBuilder(
            builder: (context, setSheetState) => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Andika Review',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 14),
                Center(
                  child: RatingBar.builder(
                    initialRating: 5,
                    itemSize: 32,
                    itemBuilder: (context, _) =>
                        const Icon(Icons.star, color: Colors.amber),
                    onRatingUpdate: (value) =>
                        setSheetState(() => rating = value),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: commentController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Andika maoni yako...',
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () async {
                      final user = FirebaseAuth.instance.currentUser;
                      if (user == null || commentController.text.trim().isEmpty)
                        return;
                      await _firestoreService.addReview(
                        ReviewModel(
                          id: '',
                          businessId: businessId,
                          userId: user.uid,
                          userName: user.phoneNumber ?? 'Mtumiaji',
                          rating: rating,
                          comment: commentController.text.trim(),
                          createdAt: DateTime.now(),
                        ),
                      );
                      if (context.mounted) Navigator.pop(context);
                      setState(() {});
                    },
                    child: const Text('Tuma Review'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
