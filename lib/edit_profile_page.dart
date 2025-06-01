import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kesehatan_kampus/service/profile_service.dart';

//adding sync service
import 'package:kesehatan_kampus/service/sync_database_service.dart';



class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  bool _isLoading = false;
  String? _userId;
  File? _imageFile; 

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _loadUserData();

    
  }

Future<void> _loadUserData() async {
  final prefs = await SharedPreferences.getInstance();
  setState(() {
    _userId = prefs.getInt('user_id')?.toString();
    _nameController.text = prefs.getString('full_name') ?? 'Tidak ada nama';
    _emailController.text = prefs.getString('email') ?? 'Email Tidak Ditemukan';
    _phoneController.text = prefs.getString('phone_number') ?? 'No Hp tidak ada';

    if (_userId != null) {
      final imagePath = prefs.getString('profile_image_$_userId');
      if (imagePath != null && File(imagePath).existsSync()) {
        _imageFile = File(imagePath);
      }
    }
  });

  //sync service
  SyncDatabaseService syncService = SyncDatabaseService();

  // Sync users before running the app
  bool success = await syncService.syncUsers();  

  if (success) {
    print("User data synced successfully!");
  } else {
    print("Failed to sync user data!");
  }
}

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      _saveImagePath(pickedFile.path);
    }
  }

Future<void> _saveImagePath(String path) async {
  final prefs = await SharedPreferences.getInstance();
  if (_userId != null) {
    await prefs.setString('profile_image_$_userId', path);
    print('Menyimpan foto profil untuk user $_userId: $path');
    
    final savedPath = prefs.getString('profile_image_$_userId');
    print('Verifikasi path tersimpan: $savedPath');
  }
}

  Future<void> _updateProfile() async {
    if (_userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User ID tidak ditemukan')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final profileService = ProfileService();
    final response = await profileService.updateProfile(
      _userId!,
      _nameController.text,
      _emailController.text,
      _phoneController.text,
    );

    if (response['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'])),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'])),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profil'),
        actions: [
          IconButton(
            icon: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Icon(Icons.save),
            onPressed: _isLoading
                ? null
                : () {
                    if (_formKey.currentState!.validate()) {
                      _updateProfile();
                    }
                  },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: _imageFile != null
                        ? FileImage(_imageFile!) as ImageProvider
                        : null, 
                    backgroundColor: Colors.grey[300],
                    child: _imageFile == null
                        ? const Icon(Icons.person, size: 50, color: Colors.white)
                        : null,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: PopupMenuButton<String>(
                      icon: const Icon(Icons.camera_alt, color: Colors.white),
                      onSelected: (value) {
                        if (value == 'Galeri') {
                          _pickImage(ImageSource.gallery);
                        } else if (value == 'Kamera') {
                          _pickImage(ImageSource.camera);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'Galeri',
                          child: Row(
                            children: [
                              Icon(Icons.photo, color: Colors.blue),
                              SizedBox(width: 8),
                              Text('Pilih dari Galeri'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'Kamera',
                          child: Row(
                            children: [
                              Icon(Icons.camera_alt, color: Colors.green),
                              SizedBox(width: 8),
                              Text('Ambil Foto'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Lengkap',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Nama tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Email tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Nomor Telepon',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Nomor telepon tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
