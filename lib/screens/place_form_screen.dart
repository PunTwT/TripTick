// lib/screens/place_form_screen.dart
// Add/edit a place: name, city, category, must-visit, visited,
// map link, note and photo (Step 10). Returns the Place with Navigator.pop.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/place.dart';
import '../utils/constants.dart';
import '../utils/photo_helper.dart';

class PlaceFormScreen extends StatefulWidget {
  final int tripId;
  final Place? place; // null = new place

  const PlaceFormScreen({super.key, required this.tripId, this.place});

  @override
  State<PlaceFormScreen> createState() => _PlaceFormScreenState();
}

class _PlaceFormScreenState extends State<PlaceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _cityController;
  late final TextEditingController _linkController;
  late final TextEditingController _noteController;
  String? _category;
  late bool _isMustVisit;
  late bool _isVisited;
  String? _photoPath;

  bool get _isEdit => widget.place != null;

  @override
  void initState() {
    super.initState();
    final p = widget.place;
    _nameController = TextEditingController(text: p?.name ?? '');
    _cityController = TextEditingController(text: p?.city ?? '');
    _linkController = TextEditingController(text: p?.mapLink ?? '');
    _noteController = TextEditingController(text: p?.note ?? '');
    _category = p?.category;
    _isMustVisit = p?.isMustVisit ?? false;
    _isVisited = p?.isVisited ?? false;
    _photoPath = p?.photoPath;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    _linkController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  String? _emptyToNull(String text) {
    final t = text.trim();
    return t.isEmpty ? null : t;
  }

  Future<void> _pickPhoto(ImageSource source) async {
    try {
      final path = await pickAndSavePhoto(source);
      if (path != null && mounted) setState(() => _photoPath = path);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not get the photo: $e')),
      );
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final place = Place(
      id: widget.place?.id,
      tripId: widget.tripId,
      name: _nameController.text.trim(),
      city: _emptyToNull(_cityController.text),
      category: _category,
      isMustVisit: _isMustVisit,
      isVisited: _isVisited,
      note: _emptyToNull(_noteController.text),
      photoPath: _photoPath,
      mapLink: _emptyToNull(_linkController.text),
      dayId: widget.place?.dayId, // keep the itinerary day when editing
    );
    Navigator.pop(context, place);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Edit place' : 'New place')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Place name *',
                hintText: 'Example: Fushimi Inari Shrine',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Please enter a name' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _cityController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'City',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: [
                for (final c in {
                  ...kPlaceCategories,
                  if (_category != null) _category!,
                })
                  DropdownMenuItem(value: c, child: Text(c)),
              ],
              onChanged: (v) => setState(() => _category = v),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Must-visit'),
              value: _isMustVisit,
              onChanged: (v) => setState(() => _isMustVisit = v),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Already visited'),
              value: _isVisited,
              onChanged: (v) => setState(() => _isVisited = v),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _linkController,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(
                labelText: 'Map link (optional)',
                hintText: 'Paste a Google Maps link, or leave empty',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _noteController,
              minLines: 3,
              maxLines: 6,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Notes',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            if (_photoPath != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(_photoPath!),
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox(
                    height: 80,
                    child: Center(child: Text('Photo file not found')),
                  ),
                ),
              ),
            Wrap(
              spacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _pickPhoto(ImageSource.camera),
                  icon: const Icon(Icons.photo_camera_outlined),
                  label: const Text('Camera'),
                ),
                OutlinedButton.icon(
                  onPressed: () => _pickPhoto(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Gallery'),
                ),
                if (_photoPath != null)
                  TextButton.icon(
                    onPressed: () => setState(() => _photoPath = null),
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Remove photo'),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save),
              label: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}