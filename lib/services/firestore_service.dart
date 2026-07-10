import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/business_model.dart';
import '../utils/constants.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;
  CollectionReference get _b => _db.collection(FirestoreCollections.businesses);

  Future<String> addBusiness(BusinessModel b) async {
    final doc = await _b.add(b.toMap()); return doc.id;
  }

  Future<BusinessModel?> getBusinessById(String id) async {
    final doc = await _b.doc(id).get();
    if (!doc.exists) return null;
    return BusinessModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
  }

  Stream<List<BusinessModel>> streamByCategory(String cat) => _b
      .where('category', isEqualTo: cat)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map((d) => BusinessModel.fromMap(d.id, d.data() as Map<String, dynamic>)).toList());

  Future<List<BusinessModel>> searchByName(String q) async {
    final lower = q.toLowerCase();
    final s = await _b.where('nameLower', isGreaterThanOrEqualTo: lower)
        .where('nameLower', isLessThanOrEqualTo: '$lower\uf8ff').limit(30).get();
    return s.docs.map((d) => BusinessModel.fromMap(d.id, d.data() as Map<String, dynamic>)).toList();
  }

  Future<void> addReview(ReviewModel r) async {
    final ref = _db.collection(FirestoreCollections.reviews).doc();
    await ref.set(r.toMap());
    final bRef = _b.doc(r.businessId);
    await _db.runTransaction((tx) async {
      final snap = await tx.get(bRef);
      if (!snap.exists) return;
      final data = snap.data() as Map<String, dynamic>;
      final cur = (data['rating'] ?? 0.0).toDouble();
      final cnt = (data['ratingCount'] ?? 0) as int;
      final newCnt = cnt + 1;
      final newRat = ((cur * cnt) + r.rating) / newCnt;
      tx.update(bRef, {'rating': double.parse(newRat.toStringAsFixed(2)), 'ratingCount': newCnt});
    });
  }

  Stream<List<ReviewModel>> streamReviews(String businessId) => _db
      .collection(FirestoreCollections.reviews)
      .where('businessId', isEqualTo: businessId)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map((d) => ReviewModel.fromMap(d.id, d.data() as Map<String, dynamic>)).toList());
}
