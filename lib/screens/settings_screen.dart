// lib/screens/settings_screen.dart
// Theme (light/dark), backup (export/import), sample data, test notification.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';
import '../providers/trip_provider.dart';
import '../services/backup_service.dart';
import '../services/notification_service.dart';
import '../services/sample_data.dart';
import '../widgets/dialogs.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _msg(BuildContext context, String text) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _export(BuildContext context) async {
    try {
      await BackupService().exportAndShare();
    } catch (e) {
      _msg(context, 'Export failed: $e');
    }
  }

  Future<void> _copyJson(BuildContext context) async {
    try {
      final json = await BackupService().createBackupJson();
      await Clipboard.setData(ClipboardData(text: json));
      _msg(context, 'Backup copied to the clipboard');
    } catch (e) {
      _msg(context, 'Copy failed: $e');
    }
  }

  /// Dialog with a big text box where the user pastes the backup JSON.
  Future<String?> _askJson(BuildContext context) {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Import backup'),
        content: TextField(
          controller: controller,
          minLines: 4,
          maxLines: 8,
          decoration: const InputDecoration(
            hintText: 'Paste the backup JSON here',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final data = await Clipboard.getData(Clipboard.kTextPlain);
              controller.text = data?.text ?? '';
            },
            child: const Text('Paste'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text('Import'),
          ),
        ],
      ),
    );
  }

  Future<void> _import(BuildContext context) async {
    final text = await _askJson(context);
    if (text == null || text.trim().isEmpty || !context.mounted) return;

    final ok = await confirmDialog(
      context,
      title: 'Replace all data?',
      message: 'Importing deletes your current trips and replaces them with the backup.',
      confirmLabel: 'Replace',
    );
    if (!ok || !context.mounted) return;

    try {
      await BackupService().importFromJson(text);
      if (!context.mounted) return;
      await context.read<TripProvider>().loadTrips();
      _msg(context, 'Backup imported ✅');
    } on FormatException catch (e) {
      _msg(context, 'Import failed: ${e.message}');
    } catch (e) {
      _msg(context, 'Import failed: $e');
    }
  }

  Future<void> _loadSample(BuildContext context) async {
    try {
      await SampleData.load();
      if (!context.mounted) return;
      await context.read<TripProvider>().loadTrips();
      _msg(context, 'Sample data added (Japan trip + Paris wishlist)');
    } catch (e) {
      _msg(context, 'Could not add sample data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Appearance', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(
                  value: ThemeMode.system,
                  label: Text('System'),
                  icon: Icon(Icons.phone_android)),
              ButtonSegment(
                  value: ThemeMode.light,
                  label: Text('Light'),
                  icon: Icon(Icons.light_mode)),
              ButtonSegment(
                  value: ThemeMode.dark,
                  label: Text('Dark'),
                  icon: Icon(Icons.dark_mode)),
            ],
            selected: {theme.themeMode},
            onSelectionChanged: (s) => theme.setThemeMode(s.first),
          ),
          const Divider(height: 32),
          Text('Backup', style: Theme.of(context).textTheme.titleMedium),
          ListTile(
            leading: const Icon(Icons.ios_share),
            title: const Text('Export and share backup'),
            subtitle: const Text('Creates a .json file'),
            onTap: () => _export(context),
          ),
          ListTile(
            leading: const Icon(Icons.copy),
            title: const Text('Copy backup to clipboard'),
            onTap: () => _copyJson(context),
          ),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Import backup (paste JSON)'),
            subtitle: const Text('Replaces all current data'),
            onTap: () => _import(context),
          ),
          const Divider(height: 32),
          Text('Demo and testing',
              style: Theme.of(context).textTheme.titleMedium),
          ListTile(
            leading: const Icon(Icons.science_outlined),
            title: const Text('Load sample data'),
            subtitle: const Text('Adds a Japan trip and a Paris wishlist'),
            onTap: () => _loadSample(context),
          ),
          ListTile(
            leading: const Icon(Icons.notifications_active_outlined),
            title: const Text('Send test notification'),
            onTap: () => NotificationService.instance.showTestNotification(),
          ),
        ],
      ),
    );
  }
}