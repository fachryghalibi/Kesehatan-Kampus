import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProfileService {
  static const String apiUrl = 'https://backendtelkommedikamobile.se4603.my.id/update_profile.php';

  Future<Map<String, dynamic>> updateProfile(
      String userId, String name, String email, String phone) async {
    try {
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'email': email,
          'full_name': name,
          'phone_number': phone,
        }),
      );

      if (response.statusCode == 200) {
        // Simpan data ke SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('full_name', name);
        await prefs.setString('email', email);
        await prefs.setString('phone_number', phone);
        return {'success': true, 'message': 'Profil berhasil diperbarui'};
      } else {
        final error = jsonDecode(response.body)['error'] ?? 'Gagal memperbarui profil';
        return {'success': false, 'message': error};
      }
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan: $e'};
    }
  }
}
