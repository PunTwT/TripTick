// lib/utils/maps_helper.dart
// Opens a place in the phone's map app (or browser if no map app).

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/place.dart';

Future<void> openInMaps(BuildContext context, Place place) async {
  bool opened = false;
  try {
    final link = (place.mapLink ?? '').trim();
    final Uri uri;
    if (link.isNotEmpty) {
      // The user saved their own link.
      uri = Uri.parse(link.startsWith('http') ? link : 'https://$link');
    } else {
      // No link saved: search Google Maps for "name, city".
      final query = [
        place.name,
        if ((place.city ?? '').isNotEmpty) place.city!,
      ].join(', ');
      uri = Uri.https(
        'www.google.com',
        '/maps/search/',
        {'api': '1', 'query': query},
      );
    }
    opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {
    opened = false;
  }

  if (!opened && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Could not open the maps app')),
    );
  }
}