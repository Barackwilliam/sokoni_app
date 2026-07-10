import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../models/business_model.dart';
import '../utils/constants.dart';

/// Card ya biashara inayotumika kwenye Home na search results
class BusinessCard extends StatelessWidget {
  final BusinessModel business;
  final VoidCallback onTap;

  const BusinessCard({super.key, required this.business, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(14),
              ),
              child: SizedBox(
                width: 96,
                height: 96,
                child: business.imageUrls.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: business.imageUrls.first,
                        fit: BoxFit.cover,
                        placeholder: (c, _) =>
                            Container(color: Colors.grey[200]),
                        errorWidget: (c, _, _) => Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.store, color: Colors.grey),
                        ),
                      )
                    : Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.store, color: Colors.grey),
                      ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      business.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: AppColors.textDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      business.subCategory,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textGrey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        RatingBarIndicator(
                          rating: business.rating,
                          itemCount: 5,
                          itemSize: 14,
                          itemBuilder: (context, _) =>
                              const Icon(Icons.star, color: Colors.amber),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${business.ratingCount})',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textGrey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 13,
                          color: AppColors.textGrey,
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            business.address,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textGrey,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (business.isAvailable)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Available',
                              style: TextStyle(
                                fontSize: 9,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
