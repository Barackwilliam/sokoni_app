// Smoke tests that don't require Firebase initialization.
import 'package:flutter_test/flutter_test.dart';
import 'package:sokoni_app/models/business_model.dart';
import 'package:sokoni_app/utils/constants.dart';

void main() {
  test('App has 4 categories with matching sub-categories', () {
    expect(kCategories.length, 4);
    for (final c in kCategories) {
      expect(kSubCategories.containsKey(c.id), true,
          reason: 'Missing sub-categories for ${c.id}');
      expect(kSubCategories[c.id]!.isNotEmpty, true);
    }
  });

  test('BusinessModel round-trips through toMap/fromMap', () {
    final b = BusinessModel(
      id: 'abc',
      ownerId: 'u1',
      name: 'Mama Ntilie',
      category: 'restaurant',
      subCategory: 'Local Food',
      description: 'Chakula kitamu',
      phone: '+255712345678',
      whatsapp: '+255712345678',
      imageUrls: const ['http://x/y.jpg'],
      latitude: -6.8,
      longitude: 39.28,
      address: 'Kariakoo, Dar es Salaam',
      createdAt: DateTime(2026, 1, 1),
    );
    final map = b.toMap();
    expect(map['nameLower'], 'mama ntilie');
    final back = BusinessModel.fromMap('abc', {
      ...map,
      'createdAt': null, // Timestamp path is covered at runtime
    });
    expect(back.name, b.name);
    expect(back.category, 'restaurant');
    expect(back.rating, 0.0);
    expect(back.isAvailable, true);
  });

  test('ReviewModel round-trips through toMap/fromMap', () {
    final r = ReviewModel(
      id: 'r1',
      businessId: 'b1',
      userId: 'u1',
      userName: '+255712345678',
      rating: 4.5,
      comment: 'Huduma nzuri sana',
      createdAt: DateTime(2026, 1, 1),
    );
    final map = r.toMap();
    final back = ReviewModel.fromMap('r1', {...map, 'createdAt': null});
    expect(back.rating, 4.5);
    expect(back.comment, 'Huduma nzuri sana');
  });
}
