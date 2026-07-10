import 'dart:io';
import 'package:flutter/material.dart';
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
  State<AddBusinessScreen> createState() => _AddBusinessScreenState();
}

class _AddBusinessScreenState extends State<AddBusinessScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _phoneController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _addressController = TextEditingController();

  final _firestoreService = FirestoreService();
  final _storageService = StorageService();
  final _picker = ImagePicker();

  String _category = kCategories.first.id;
  String? _subCategory;
  final List<File> _images = [];
  double? _latitude;
  double? _longitude;
  bool _saving = false;
  bool _gettingLocation = false;

  Future<void> _pickImages() async {
    final picked = await _picker.pickMultiImage(imageQuality: 70);
    if (picked.isNotEmpty) {
      setState(() {
        _images.addAll(picked.map((x) => File(x.path)).take(5 - _images.length));
      });
    }
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _gettingLocation = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw Exception('Washa location kwenye simu yako');

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Ruhusu location access kwenye settings');
      }

      final position = await Geolocator.getCurrentPosition();
      _latitude = position.latitude;
      _longitude = position.longitude;

      final placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        _addressController.text = '${p.subLocality ?? p.locality ?? ''}, ${p.locality ?? ''}'.trim();
      }
      setState(() {});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _gettingLocation = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_subCategory == null) {
      _showError('Chagua aina ya huduma');
      return;
    }
    if (_latitude == null || _longitude == null) {
      _showError('Weka location ya biashara yako');
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showError('Lazima uingie kwanza');
      return;
    }

    setState(() => _saving = true);
    try {
      // Tunatumia id ya muda kuandaa folder ya storage, kisha tunaongeza document
      final tempId = DateTime.now().millisecondsSinceEpoch.toString();
      List<String> imageUrls = [];
      if (_images.isNotEmpty) {
        imageUrls = await _storageService.uploadMultipleImages(_images, tempId);
      }

      final business = BusinessModel(
        id: '',
        ownerId: user.uid,
        name: _nameController.text.trim(),
        category: _category,
        subCategory: _subCategory!,
        description: _descController.text.trim(),
        phone: _phoneController.text.trim(),
        whatsapp: _whatsappController.text.trim().isEmpty
            ? _phoneController.text.trim()
            : _whatsappController.text.trim(),
        imageUrls: imageUrls,
        latitude: _latitude!,
        longitude: _longitude!,
        address: _addressController.text.trim(),
        createdAt: DateTime.now(),
      );

      await _firestoreService.addBusiness(business);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Biashara imeongezwa kikamilifu!')),
        );
      }
    } catch (e) {
      _showError('Imeshindikana kuhifadhi, jaribu tena');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final subOptions = kSubCategories[_category] ?? [];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Ongeza Biashara'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            _label('Aina ya Biashara'),
            Wrap(
              spacing: 8,
              children: kCategories.map((cat) {
                final selected = cat.id == _category;
                return ChoiceChip(
                  label: Text(cat.name),
                  selected: selected,
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(color: selected ? Colors.white : AppColors.textDark),
                  onSelected: (_) => setState(() {
                    _category = cat.id;
                    _subCategory = null;
                  }),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            _label('Huduma Maalum'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: subOptions.map((sub) {
                final selected = sub == _subCategory;
                return ChoiceChip(
                  label: Text(sub),
                  selected: selected,
                  selectedColor: AppColors.secondary,
                  labelStyle: TextStyle(color: selected ? Colors.white : AppColors.textDark),
                  onSelected: (_) => setState(() => _subCategory = sub),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            _label('Jina la Biashara'),
            _textField(_nameController, hint: 'Mfano: Ally Electrical Services', validator: true),
            const SizedBox(height: 16),
            _label('Maelezo'),
            _textField(_descController, hint: 'Eleza huduma unazotoa...', maxLines: 3, validator: true),
            const SizedBox(height: 16),
            _label('Namba ya Simu'),
            _textField(_phoneController, hint: '07XX XXX XXX', keyboardType: TextInputType.phone, validator: true),
            const SizedBox(height: 16),
            _label('Namba ya WhatsApp (kama tofauti)'),
            _textField(_whatsappController, hint: '07XX XXX XXX', keyboardType: TextInputType.phone),
            const SizedBox(height: 16),
            _label('Location'),
            _textField(_addressController, hint: 'Mfano: Kariakoo, Dar es Salaam', validator: true),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _gettingLocation ? null : _useCurrentLocation,
              icon: _gettingLocation
                  ? const SizedBox(height: 14, width: 14, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.my_location, size: 18),
              label: Text(_latitude != null ? 'Location imewekwa ✓' : 'Tumia Location ya Sasa'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 44),
                side: const BorderSide(color: AppColors.primary),
                foregroundColor: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            _label('Picha za Biashara (max 5)'),
            SizedBox(
              height: 90,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  ..._images.map((file) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(file, width: 90, height: 90, fit: BoxFit.cover),
                            ),
                            Positioned(
                              top: 2, right: 2,
                              child: GestureDetector(
                                onTap: () => setState(() => _images.remove(file)),
                                child: const CircleAvatar(
                                  radius: 10,
                                  backgroundColor: Colors.black54,
                                  child: Icon(Icons.close, size: 12, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                  if (_images.length < 5)
                    GestureDetector(
                      onTap: _pickImages,
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: const Icon(Icons.add_a_photo_outlined, color: AppColors.textGrey),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _saving
                    ? const SizedBox(
                        height: 20, width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Hifadhi Biashara'),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
      );

  Widget _textField(
    TextEditingController controller, {
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    bool validator = false,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator ? (v) => (v == null || v.trim().isEmpty) ? 'Sehemu hii inahitajika' : null : null,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }
}
