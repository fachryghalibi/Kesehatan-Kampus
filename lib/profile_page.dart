import 'dart:io'; // Import untuk File
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences
import 'package:kesehatan_kampus/bantuan_page.dart';
import 'package:kesehatan_kampus/edit_profile_page.dart';
import 'package:kesehatan_kampus/ganti_password_page.dart';
import 'package:kesehatan_kampus/pengaturan_notifikasi_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String username = '';
  String email = '';
  String? profileImagePath; // Path foto profil
  int userId = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Function to load user data from SharedPreferences
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('full_name') ?? 'User';
      email = prefs.getString('email') ?? 'Email Tidak Ada';
      userId = prefs.getInt('user_id') ?? 0;

      // Ambil path gambar dan verifikasi keberadaan file
      String? imagePath = prefs.getString('profile_image_$userId');
      if (imagePath != null && File(imagePath).existsSync()) {
        profileImagePath = imagePath;
        print('Loaded profile image for user $userId: $imagePath');
      } else {
        profileImagePath = null;
        print('No valid profile image found for user $userId');
      }
    });
  }

  // Function untuk logout
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    Set<String> keys = prefs.getKeys();

    // Simpan email untuk Remember Me jika ada
    String? savedEmail = prefs.getString('saved_email');
    String? savedPassword = prefs.getString('saved_password');
    bool? rememberMe = prefs.getBool('remember_me');

    for (String key in keys) {
      if (!key.startsWith('profile_image_') &&
          !key.startsWith('bookmark_') && 
          !key.startsWith('like_') && 
          !key.startsWith('likeCount_') &&
          key != 'saved_email' &&
          key != 'saved_password' &&
          key != 'remember_me') {
        await prefs.remove(key);
      }

      if (rememberMe == true) {
        await prefs.setString('saved_email', savedEmail ?? '');
        await prefs.setString('saved_password', savedPassword ?? '');
        await prefs.setBool('remember_me', true);
      }
    }

    // Kembalikan saved_email jika sebelumnya ada
    if (savedEmail != null) {
      await prefs.setString('saved_email', savedEmail);
    }

    Navigator.of(context)
        .pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
  }

  // Dialog konfirmasi logout
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Row(
            children: [
              Icon(Icons.logout, color: Colors.red),
              SizedBox(width: 8),
              Text('Konfirmasi Logout'),
            ],
          ),
          content: const Text('Apakah Anda yakin ingin keluar dari Akun?'),
          actions: [
            TextButton(
              child: const Text('Batal'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Logout', style: TextStyle(color: Colors.white)),
              onPressed: () {
                Navigator.of(context).pop();
                _logout();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Pengguna'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: profileImagePath != null
                    ? FileImage(File(profileImagePath!))
                    : null,
                backgroundColor: Colors.grey[300],
                child: profileImagePath == null
                    ? const Icon(Icons.person, size: 50, color: Colors.white)
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                username,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                email,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            ProfileOption(
              icon: Icons.person,
              title: 'Edit Profil',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditProfilePage()),
              ).then((_) => _loadUserData()),
              // Refresh data setelah kembali
            ),
            ProfileOption(
              icon: Icons.security,
              title: 'Ubah Kata Sandi',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChangePasswordPage()),
              ),
            ),
            ProfileOption(
              icon: Icons.notifications,
              title: 'Pengaturan Notifikasi',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => NotificationSettingsPage()),
              ),
            ),
            ProfileOption(
              icon: Icons.help,
              title: 'Bantuan',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HelpPage()),
              ),
            ),
            const Spacer(),
            Center(
              child: ElevatedButton.icon(
                onPressed: _showLogoutDialog,
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(150, 50),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget untuk setiap opsi profil
class ProfileOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const ProfileOption({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.grey.withOpacity(0.3),
        highlightColor: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          child: Row(
            children: [
              Icon(icon, color: Theme.of(context).primaryColor),
              const SizedBox(width: 16),
              Text(title, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}
