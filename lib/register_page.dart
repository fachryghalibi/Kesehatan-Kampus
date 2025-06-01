import 'package:flutter/material.dart';
import 'package:kesehatan_kampus/service/api_service.dart';

//adding sync service
import 'package:kesehatan_kampus/service/sync_database_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  String _fullName = '';
  String _email = '';
  String _phoneNumber = '';
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  final ApiService _apiService = ApiService();

  //sync database service
  SyncDatabaseService syncService = SyncDatabaseService();

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        final data = await _apiService.registerUser(
            _fullName, _email, _passwordController.text, _phoneNumber);

        if (data['success']) {
          // Handle success
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Registration successful. Please log in.'),
              backgroundColor: Colors.green,
            ),
          );
           //syncing user data ---------------------------------------------- to database
           // Sync user data after successful registration
          try {
            bool success = await syncService.syncUsers();  

            if (success) {
             print("User data synced successfully!");
            } else {
              print("Failed to sync user data!");
            }
          } catch (syncError) {
              _showErrorSnackbar('Failed to sync data.');
          }
          //syncing user data end

        
          Future.delayed(const Duration(seconds: 2), () {
            Navigator.pop(context);
          });
        
        } else {
          // Handle failure: Error message for email or phone number
          if (data['error'] == 'Phone number already registered') {
            _showErrorSnackbar('Nomor HP sudah terdaftar.');
          } else if (data['error'] == 'Email already registered') {
            _showErrorSnackbar('Email sudah terdaftar.');
          } else {
            _showErrorSnackbar(data['message'] ?? 'Registration failed.');
          }
        }
      } catch (error) {
        if (error.toString().contains('Phone number already registered')) {
          _showErrorSnackbar('Nomor HP sudah terdaftar.');
        } else if (error.toString().contains('Email already registered') ||
                   error.toString().contains('Email already exists')) {
          _showErrorSnackbar('Email sudah terdaftar.');
        } else {
          _showErrorSnackbar('Failed to connect to server.');
        }
      }
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.teal, Colors.teal.shade700],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.local_hospital,
                            size: 64,
                            color: Color.fromARGB(255, 235, 1, 1)),
                        const SizedBox(height: 16),
                        const Text(
                          'Daftar Akun Baru',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 32),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Nama Lengkap',
                            prefixIcon: const Icon(Icons.person),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Mohon masukkan nama lengkap';
                            }
                            return null;
                          },
                          onSaved: (value) => _fullName = value!,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon: const Icon(Icons.email),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Mohon masukkan email';
                            }
                            if (!value.contains('@')) {
                              return 'Mohon masukkan email yang valid';
                            }
                            return null;
                          },
                          onSaved: (value) => _email = value!,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          // Added phone number field
                          decoration: InputDecoration(
                            labelText: 'Nomor Telepon',
                            prefixIcon: const Icon(Icons.phone),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Mohon masukkan nomor telepon';
                            }
                            return null;
                          },
                          onSaved: (value) => _phoneNumber = value!,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          obscureText: _obscurePassword,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Mohon masukkan password';
                            }
                            if (value.length < 6) {
                              return 'Password minimal 6 karakter';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _confirmPasswordController,
                          decoration: InputDecoration(
                            labelText: 'Konfirmasi Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword =
                                      !_obscureConfirmPassword;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          obscureText: _obscureConfirmPassword,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Mohon konfirmasi password';
                            }
                            if (value != _passwordController.text) {
                              return 'Password tidak cocok';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _register,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          child: Text('Daftar Sekarang',
                              style: TextStyle(fontSize: 18)),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          child: const Text('Sudah punya akun? Login di sini'),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
