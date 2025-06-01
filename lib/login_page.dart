import 'package:flutter/material.dart';
import 'package:kesehatan_kampus/service/login_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _email = '';
  String _password = '';
  bool _obscurePassword = true;
  bool _rememberMe = false;

  final LoginService _loginService = LoginService();

  @override
  void initState() {
    super.initState();
    _checkSession();
    _loadSavedCredentials();
  }

   Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('saved_email');
    final savedPassword = prefs.getString('saved_password');
    final rememberMe = prefs.getBool('remember_me') ?? false;

    if (savedEmail != null && savedPassword != null && rememberMe) {
      setState(() {
        _email = savedEmail;
        _password = savedPassword;
        _emailController.text = savedEmail;
        _passwordController.text = savedPassword;
        _rememberMe = true;
      });
    }
  }

    Future<void> _saveCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setString('saved_email', _emailController.text);
      await prefs.setString('saved_password', _passwordController.text);
      await prefs.setBool('remember_me', true);
    } else {
      await prefs.remove('saved_email');
      await prefs.remove('saved_password');
      await prefs.remove('remember_me');
    }
  }

  // Fungsi untuk mengecek sesi login
  Future<void> _checkSession() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (isLoggedIn) {
      final userId = prefs.getInt('user_id');
      print('Logged in user ID: $userId');
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    }
  }

  // Fungsi untuk login
  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );

        final response = await _loginService.login(_email, _password);

        if (context.mounted) {
          Navigator.pop(context);
        }

        if (response['success'] == true) {
          final prefs = await SharedPreferences.getInstance();

          // Save credentials if remember me is checked
          await _saveCredentials();

          await prefs.setString('full_name', response['full_name'] ?? 'User');
          await prefs.setString('email', response['email'] ?? '');
          await prefs.setString('created_at', response['created_at'] ?? '');
          await prefs.setString('phone_number', response['phone_number']);
          await prefs.setBool('isLoggedIn', true);
          final userId = (response['user_id'] ?? 0);
          await prefs.setInt('user_id', userId);

          if (context.mounted) {
            Navigator.pushReplacementNamed(context, '/home');
          }
        } else {
          if (context.mounted) {
            _showErrorSnackbar(response['message'] ?? 'Login gagal');
          }
        }
      } catch (e) {
        print('Error during login: $e');
        if (context.mounted) {
          Navigator.pop(context);
          _showErrorSnackbar('Terjadi kesalahan: $e');
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.teal.shade400, Colors.teal.shade800],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Card(
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
                            Hero(
                              tag: 'appIcon',
                              child: CircleAvatar(
                                backgroundColor: Colors.teal.shade50,
                                radius: 40,
                                child: const Icon(
                                  Icons.local_hospital,
                                  size: 40,
                                  color: Color.fromARGB(255, 248, 0, 0),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Telkom Medika',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Silakan login untuk melanjutkan',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 32),
                            _buildEmailField(),
                            const SizedBox(height: 16),
                            _buildPasswordField(),
                            const SizedBox(height: 8),
                            _buildRememberMeRow(),
                            const SizedBox(height: 24),
                            _buildLoginButton(),
                            const SizedBox(height: 16),
                            _buildRegisterRow(),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Versi 1.0.0',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Email Field
  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      decoration: InputDecoration(
        labelText: 'Email',
        hintText: 'Masukkan email Anda',
        prefixIcon: const Icon(Icons.email),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.teal, width: 2),
        ),
      ),
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Mohon masukkan email';
        } else if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
            .hasMatch(value)) {
          return 'Format email tidak valid';
        }
        return null;
      },
      onChanged: (value) => _email = value,
      onSaved: (value) => _email = value!,
    );
  }

  // Password Field
  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      decoration: InputDecoration(
        labelText: 'Password',
        hintText: 'Masukkan password Anda',
        prefixIcon: const Icon(Icons.lock),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
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
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.teal, width: 2),
        ),
      ),
      obscureText: _obscurePassword,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Mohon masukkan password';
        }
        return null;
      },
      onChanged: (value) => _password = value,
      onSaved: (value) => _password = value!,
    );
  }

  // Remember Me and Forgot Password Row
    Widget _buildRememberMeRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Checkbox(
              value: _rememberMe,
              onChanged: (value) {
                setState(() {
                  _rememberMe = value!;
                });
                _saveCredentials(); // Save credentials when checkbox state changes
              },
            ),
            const Text('Ingat Saya'),
          ],
        ),
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, '/forgot_password');
          },
          child: const Text('Lupa Password?'),
        ),
      ],
    );
  }

  // Login Button
  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: _login,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        backgroundColor: const Color.fromARGB(255, 215, 220, 219),
      ),
      child: const Text(
        'Login',
        style: TextStyle(fontSize: 16),
      ),
    );
  }

  // Register Row
  Widget _buildRegisterRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Belum punya akun?'),
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, '/register');
          },
          child: const Text('Daftar'),
        ),
      ],
    );
  }
}
