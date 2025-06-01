import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class KontakDaruratPage extends StatelessWidget {
  final List<Map<String, dynamic>> emergencyContacts = [
    {
      'name': 'Polisi',
      'number': '110',
      'icon': Icons.local_police,
    },
    {
      'name': 'Ambulans',
      'number': '118',
      'icon': Icons.local_hospital,
    },
    {
      'name': 'Pemadam Kebakaran',
      'number': '113',
      'icon': Icons.fire_extinguisher,
    },
    {
      'name': 'Kontak Kesehatan',
      'number': '021-12345678',
      'icon': Icons.medical_services,
    },
  ];

  KontakDaruratPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kontak Darurat'),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: ListView.separated(
          itemCount: emergencyContacts.length,
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) {
            final contact = emergencyContacts[index];
            return _buildContactCard(
              contact['name']!,
              contact['number']!,
              contact['icon'],
              context,
            );
          },
        ),
      ),
    );
  }

  Widget _buildContactCard(
      String name, String number, IconData icon, BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          size: 40,
          color: Colors.teal,
        ),
        title: Text(
          name,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          number,
          style: TextStyle(color: Colors.grey[600]),
        ),
        trailing: const Icon(Icons.call, color: Colors.teal),
        onTap: () {
          _makePhoneCall(number, context);
        },
      ),
    );
  }

  void _makePhoneCall(String number, BuildContext context) async {
    final cleanNumber = number.replaceAll(RegExp(r'\D'), '');

    final Uri launchUri = Uri(
      scheme: 'tel',
      path: cleanNumber,
    );

    try {
      await launchUrl(launchUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    }
  }
}
