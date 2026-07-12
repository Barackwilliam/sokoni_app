import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/business_model.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';

class AddBusinessScreen extends StatefulWidget {
  const AddBusinessScreen({super.key});
  @override
  State<AddBusinessScreen> createState() => _State();
}

class _State extends State<AddBusinessScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _desc = TextEditingController();
  final _phone = TextEditingController();
  final _wa = TextEditingController();
  final _address = TextEditingController();

  final _firestore = FirestoreService();
  final _storage = StorageService();
  final _picker = ImagePicker();

  String _category = kCategories.first.id;
  String? _subCat;
  final List<XFile> _images = [];
  double? _lat, _lng;
  bool _saving = false, _gettingLoc = false;

  Future<void> _pickImages() async {
    final picked = await _picker.pickMultiImage(imageQuality: 70);
    if (picked.isNotEmpty) {
      setState(() => _images.addAll(picked.take(5 - _images.length)));
    }
  }

  Future<void> _getLocation() async {
    setState(() => _gettingLoc = true);
    try {
      bool enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) throw Exception('Enable location on your device');
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.deniedForever) {
        throw Exception('Allow location in settings');
      }
      final pos = await Geolocator.getCurrentPosition();
      _lat = pos.latitude;
      _lng = pos.longitude;
      final marks = await placemarkFromCoordinates(pos.latitude, pos.longitude);
      if (marks.isNotEmpty) {
        final p = marks.first;
        _address.text =
            '${p.subLocality ?? p.locality ?? ''}, ${p.locality ?? ''}'.trim();
      }
      setState(() {});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _gettingLoc = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_subCat == null) {
      _err('Please select a service type');
      return;
    }
    if (_lat == null) {
      _err('Please set your business location');
      return;
    }
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _err('Please sign in first');
      return;
    }
    setState(() => _saving = true);
    try {
      // Generate the document id FIRST so images live under the correct
      // Storage path (businesses/{id}/...) — no more orphaned uploads.
      final businessId = _firestore.newBusinessId();
      List<String> urls = [];
      if (_images.isNotEmpty) {
        // Bytes-based upload: works on Android, iOS AND web.
        urls = await _storage.uploadMultipleImages(_images, businessId);
      }
      await _firestore.setBusiness(businessId, BusinessModel(
        id: businessId,
        ownerId: user.uid,
        name: _name.text.trim(),
        category: _category,
        subCategory: _subCat!,
        description: _desc.text.trim(),
        phone: _normalizePhone(_phone.text.trim()),
        whatsapp: _normalizePhone(
            _wa.text.trim().isEmpty ? _phone.text.trim() : _wa.text.trim()),
        imageUrls: urls,
        latitude: _lat!,
        longitude: _lng ?? 0,
        address: _address.text.trim(),
        createdAt: DateTime.now(),
      ));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Business added successfully!'),
            backgroundColor: AppColors.success));
        _name.clear();
        _desc.clear();
        _phone.clear();
        _wa.clear();
        _address.clear();
        setState(() {
          _images.clear();
          _lat = null;
          _lng = null;
          _subCat = null;
        });
      }
    } catch (e) {
      _err('Failed to save: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _err(String m) => ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(m), backgroundColor: AppColors.error));

  /// Normalizes Tanzanian numbers to +255 format (0712... -> +255712...).
  String _normalizePhone(String input) {
    var p = input.replaceAll(' ', '').replaceAll('-', '');
    if (p.startsWith('0')) return '+255${p.substring(1)}';
    if (p.startsWith('255')) return '+$p';
    if (!p.startsWith('+')) return '+255$p';
    return p;
  }

  // Build image thumbnail — web uses Image.network via bytes, mobile uses Image.file
  Widget _thumb(XFile x) {
    if (kIsWeb) {
      return FutureBuilder<Uint8List>(
        future: x.readAsBytes(),
        builder: (_, snap) {
          if (!snap.hasData) {
            return Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12)),
              child: const Center(
                  child: CircularProgressIndicator(
                      color: AppColors.primary, strokeWidth: 2)),
            );
          }
          return ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.memory(snap.data!,
                width: 90, height: 90, fit: BoxFit.cover),
          );
        },
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.file(File(x.path), width: 90, height: 90, fit: BoxFit.cover),
    );
  }

  @override
  Widget build(BuildContext context) {
    final subs = kSubCategories[_category] ?? [];
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.bgGradient),
      child: SafeArea(
          child: Form(
        key: _formKey,
        child:
            CustomScrollView(physics: const BouncingScrollPhysics(), slivers: [
          SliverToBoxAdapter(
              child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Add Business', style: AppTxt.heading(26)),
              const SizedBox(height: 4),
              Text('List your business on Sokoni today', style: AppTxt.sub(13)),
              const SizedBox(height: 28),
              _label('Business Type'),
              Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: kCategories.map((cat) {
                    final sel = cat.id == _category;
                    return GestureDetector(
                      onTap: () => setState(() {
                        _category = cat.id;
                        _subCat = null;
                      }),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 9),
                        decoration: BoxDecoration(
                          color: sel
                              ? cat.color.withValues(alpha: 0.14)
                              : AppColors.bgCard,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: sel
                                  ? cat.color.withValues(alpha: 0.5)
                                  : AppColors.divider),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(cat.icon,
                              size: 14,
                              color: sel ? cat.color : AppColors.textSub),
                          const SizedBox(width: 6),
                          Text(cat.name,
                              style: GoogleFonts.manrope(
                                  fontSize: 13,
                                  fontWeight:
                                      sel ? FontWeight.w700 : FontWeight.w400,
                                  color: sel ? cat.color : AppColors.textSub)),
                        ]),
                      ),
                    );
                  }).toList()),
              const SizedBox(height: 20),
              _label('Service Type'),
              Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: subs.map((s) {
                    final sel = s == _subCat;
                    return GestureDetector(
                      onTap: () => setState(() => _subCat = s),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: sel
                              ? AppColors.primary.withValues(alpha: 0.14)
                              : AppColors.bgCard,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: sel
                                  ? AppColors.primary.withValues(alpha: 0.5)
                                  : AppColors.divider),
                        ),
                        child: Text(s,
                            style: GoogleFonts.manrope(
                                fontSize: 12,
                                fontWeight:
                                    sel ? FontWeight.w700 : FontWeight.w400,
                                color: sel
                                    ? AppColors.primary
                                    : AppColors.textSub)),
                      ),
                    );
                  }).toList()),
              const SizedBox(height: 24),
              _label('Business Name'),
              _field(_name, 'e.g. Ally Electrical Services', true),
              const SizedBox(height: 16),
              _label('Description'),
              _field(_desc, 'Describe what you offer...', true, lines: 3),
              const SizedBox(height: 16),
              _label('Phone Number'),
              _field(_phone, '07XX XXX XXX', true, type: TextInputType.phone),
              const SizedBox(height: 16),
              _label('WhatsApp (if different)'),
              _field(_wa, '07XX XXX XXX', false, type: TextInputType.phone),
              const SizedBox(height: 16),
              _label('Location / Address'),
              _field(_address, 'e.g. Kariakoo, Dar es Salaam', true),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: _gettingLoc ? null : _getLocation,
                child: Container(
                  width: double.infinity,
                  height: 50,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.bgCard,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _lat != null
                          ? AppColors.primary.withValues(alpha: 0.45)
                          : AppColors.divider,
                      width: _lat != null ? 1.5 : 0.5,
                    ),
                  ),
                  child: _gettingLoc
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              color: AppColors.primary, strokeWidth: 2))
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                              Icon(Icons.my_location_rounded,
                                  size: 16,
                                  color: _lat != null
                                      ? AppColors.primary
                                      : AppColors.textSub),
                              const SizedBox(width: 8),
                              Text(
                                  _lat != null
                                      ? '✓  Location saved'
                                      : 'Use My Current Location',
                                  style: GoogleFonts.manrope(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: _lat != null
                                          ? AppColors.primary
                                          : AppColors.textSub)),
                            ]),
                ),
              ),
              const SizedBox(height: 24),
              _label('Photos (max 5)'),
              SizedBox(
                height: 96,
                child: ListView(scrollDirection: Axis.horizontal, children: [
                  ..._images.map((x) => Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: Stack(children: [
                          _thumb(x),
                          Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () => setState(() => _images.remove(x)),
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: const BoxDecoration(
                                      color: AppColors.error,
                                      shape: BoxShape.circle),
                                  child: const Icon(Icons.close_rounded,
                                      size: 12, color: Colors.white),
                                ),
                              )),
                        ]),
                      )),
                  if (_images.length < 5)
                    GestureDetector(
                      onTap: _pickImages,
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: AppColors.bgCard,
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: AppColors.divider, width: 0.5),
                        ),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.add_a_photo_outlined,
                                  color: AppColors.textSub, size: 22),
                              const SizedBox(height: 4),
                              Text('Add Photo',
                                  style: GoogleFonts.manrope(
                                      fontSize: 10,
                                      color: AppColors.textMuted)),
                            ]),
                      ),
                    ),
                ]),
              ),
              const SizedBox(height: 32),
              GestureDetector(
                onTap: _saving ? null : _submit,
                child: Container(
                  width: double.infinity,
                  height: 58,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: _saving ? null : AppColors.primaryGradient,
                    color: _saving ? AppColors.bgCard : null,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: _saving
                        ? []
                        : [
                            BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.45),
                                blurRadius: 22,
                                offset: const Offset(0, 8)),
                          ],
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              color: AppColors.primary, strokeWidth: 2))
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                              Text('Save Business',
                                  style: GoogleFonts.manrope(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700)),
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    shape: BoxShape.circle),
                                child: const Icon(Icons.arrow_forward_rounded,
                                    color: Colors.white, size: 16),
                              ),
                            ]),
                ),
              ),
              const SizedBox(height: 50),
            ]),
          )),
        ]),
      )),
    );
  }

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(t,
            style: GoogleFonts.manrope(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSub,
                letterSpacing: 0.2)),
      );

  Widget _field(TextEditingController ctrl, String hint, bool required,
      {int lines = 1, TextInputType? type}) {
    return TextFormField(
      controller: ctrl,
      maxLines: lines,
      keyboardType: type,
      style: GoogleFonts.manrope(color: AppColors.textWhite, fontSize: 14),
      validator: required
          ? (v) =>
              (v == null || v.trim().isEmpty) ? 'This field is required' : null
          : null,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            GoogleFonts.manrope(color: AppColors.textMuted, fontSize: 14),
        filled: true,
        fillColor: AppColors.bgCard,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.divider, width: 0.5)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.divider, width: 0.5)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
