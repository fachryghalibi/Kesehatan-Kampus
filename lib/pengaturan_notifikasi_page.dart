import 'package:flutter/material.dart';
import 'package:kesehatan_kampus/utility/notification_setting.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  _NotificationSettingsPageState createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  bool _newMessages = true;
  bool _promotions = false;
  bool _updates = true;

  @override
  void initState() {
    super.initState();
    loadSettings(); 
  }

  Future<void> loadSettings() async {
    // Memuat pengaturan dari NotificationSettings
    final settings = await NotificationSettings.loadSettings();
    setState(() {
      _newMessages = settings['new_messages'] ?? true;
      _promotions = settings['promotions'] ?? false;
      _updates = settings['updates'] ?? true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan Notifikasi'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Atur Notifikasi',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Pesan Baru'),
              subtitle: const Text('Terima notifikasi untuk pesan baru.'),
              value: _newMessages,
              onChanged: (bool value) {
                setState(() {
                  _newMessages = value;
                });
              },
            ),
            SwitchListTile(
              title: const Text('Promosi'),
              subtitle: const Text('Terima notifikasi untuk promosi dan penawaran.'),
              value: _promotions,
              onChanged: (bool value) {
                setState(() {
                  _promotions = value;
                });
              },
            ),
            SwitchListTile(
              title: const Text('Pembaruan Aplikasi'),
              subtitle: const Text('Terima notifikasi untuk pembaruan aplikasi.'),
              value: _updates,
              onChanged: (bool value) {
                setState(() {
                  _updates = value;
                });
              },
            ),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  // Simpan pengaturan
                  await NotificationSettings.saveSettings(
                    newMessages: _newMessages,
                    promotions: _promotions,
                    updates: _updates,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Pengaturan notifikasi disimpan!'),
                    ),
                  );
                },
                child: const Text('Simpan Pengaturan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
