import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:elegant_notification/elegant_notification.dart';
import 'package:elegant_notification/resources/arrays.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kesehatan_kampus/service/ganti_password_service.dart';


class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final GantiPassword _gantiPasswordService = GantiPassword();

  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasLowercase = false;
  bool _hasDigit = false;
  bool _hasSpecialChar = false;
  bool _isLoading = false;
  int? userID;

  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _loadUserId(); 
    _newPasswordController.addListener(_updatePasswordStrength);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _updatePasswordStrength() {
    setState(() {
      _hasMinLength = _newPasswordController.text.length >= 8;
      _hasUppercase = _newPasswordController.text.contains(RegExp(r'[A-Z]'));
      _hasLowercase = _newPasswordController.text.contains(RegExp(r'[a-z]'));
      _hasDigit = _newPasswordController.text.contains(RegExp(r'[0-9]'));
      _hasSpecialChar =
          _newPasswordController.text.contains(RegExp(r'[!@#\$&*~]'));
    });

    if (_hasMinLength &&
        _hasUppercase &&
        _hasLowercase &&
        _hasDigit &&
        _hasSpecialChar) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _showSuccessNotification() {
    ElegantNotification.success(
      title: const Text(
        "Berhasil!",
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      description: const Text(
        "Kata sandi Anda berhasil diperbarui",
        style: TextStyle(
          fontSize: 14,
        ),
      ),
      animation: AnimationType.fromTop,
      position:
          Alignment.topCenter, // Mengubah notificationPosition menjadi position
      isDismissable: true,
      showProgressIndicator: false,
      width: 360,
      toastDuration: const Duration(seconds: 3),
      autoDismiss: true,
    ).show(context);
  }

  void _showErrorNotification(String message) {
    ElegantNotification.error(
      title: const Text(
        "Gagal!",
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      description: Text(
        message,
        style: const TextStyle(
          fontSize: 14,
        ),
      ),
      animation: AnimationType.fromTop,
      position:
          Alignment.topCenter, // Mengubah notificationPosition menjadi position
      isDismissable: true,
      showProgressIndicator: false,
      width: 360,
      toastDuration: const Duration(seconds: 3),
      autoDismiss: true,
    ).show(context);
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');
    if (userId == null) {
      // Handle the case where user_id is not found
      _showErrorNotification("User ID tidak ditemukan");
      return;
    }
    setState(() {
      userID = userId; // Update userID
    });
  }

  Future<void> _handlePasswordChange() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        if (userID == null) {
          throw Exception('User ID tidak ditemukan');
        }

        final response = await _gantiPasswordService.changePassword(
            userID!, // Use the non-nullable `userID!`
            _oldPasswordController.text,
            _newPasswordController.text);

        if (response['status'] == 'success') {
          _showSuccessNotification();
          if (mounted) _showSuccessDialog();
        } else {
          throw Exception(response['message'] ?? 'Password change failed');
        }
      } catch (e) {
        if (mounted) {
          _showErrorNotification(e.toString().replaceFirst('Exception: ', ''));
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  void _showSuccessDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black45,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (BuildContext buildContext, Animation animation,
          Animation secondaryAnimation) {
        return Center(
          child: Container(
            width: MediaQuery.of(context).size.width - 40,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 60,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Sukses',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(76, 175, 80, 1),
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Kata sandi Anda berhasil diubah',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Color.fromARGB(255, 0, 0, 0),
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close dialog
                      Navigator.of(context).pop(); // Return to previous page
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'OK',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      transitionBuilder: (BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation, Widget child) {
        return ScaleTransition(
          scale: Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.fastOutSlowIn,
            ),
          ),
          child: child,
        );
      },
    );
  }

  Widget _buildRequirementText(String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: isMet ? Colors.green : Colors.transparent,
              border: Border.all(color: isMet ? Colors.green : Colors.grey),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                Icons.check,
                size: 16,
                color: isMet ? Colors.white : Colors.transparent,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              color: isMet ? Colors.black : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField(
    String label,
    TextEditingController controller,
    bool obscureText,
    String? Function(String?) validator,
    VoidCallback onToggleVisibility,
  ) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility_off : Icons.visibility,
            color: Theme.of(context).primaryColor,
          ),
          onPressed: onToggleVisibility,
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ubah Kata Sandi'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.lock_outline,
                        size: 60,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Untuk keamanan akun Anda, pastikan kata sandi baru Anda:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildRequirementText('Minimal 8 karakter', _hasMinLength),
                  _buildRequirementText(
                      'Mengandung huruf besar', _hasUppercase),
                  _buildRequirementText(
                      'Mengandung huruf kecil', _hasLowercase),
                  _buildRequirementText('Mengandung angka', _hasDigit),
                  _buildRequirementText(
                      'Mengandung karakter khusus (!@#\$&*~)', _hasSpecialChar),
                  const SizedBox(height: 32),
                  _buildPasswordField(
                    'Kata Sandi Lama',
                    _oldPasswordController,
                    _obscureOldPassword,
                    (value) {
                      if (value == null || value.isEmpty) {
                        return 'Masukkan kata sandi lama';
                      }
                      return null;
                    },
                    () {
                      setState(() {
                        _obscureOldPassword = !_obscureOldPassword;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  _buildPasswordField(
                    'Kata Sandi Baru',
                    _newPasswordController,
                    _obscureNewPassword,
                    (value) {
                      if (value == null || value.isEmpty) {
                        return 'Masukkan kata sandi baru';
                      }
                      if (!_hasMinLength ||
                          !_hasUppercase ||
                          !_hasLowercase ||
                          !_hasDigit ||
                          !_hasSpecialChar) {
                        return 'Kata sandi tidak memenuhi semua persyaratan';
                      }
                      return null;
                    },
                    () {
                      setState(() {
                        _obscureNewPassword = !_obscureNewPassword;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  _buildPasswordField(
                    'Konfirmasi Kata Sandi Baru',
                    _confirmPasswordController,
                    _obscureConfirmPassword,
                    (value) {
                      if (value == null || value.isEmpty) {
                        return 'Konfirmasi kata sandi baru';
                      }
                      if (value != _newPasswordController.text) {
                        return 'Kata sandi tidak cocok';
                      }
                      return null;
                    },
                    () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                  const SizedBox(height: 40),
                  ScaleTransition(
                    scale: _animation,
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handlePasswordChange,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Text(
                                'Ubah Kata Sandi',
                                style: TextStyle(fontSize: 18),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
