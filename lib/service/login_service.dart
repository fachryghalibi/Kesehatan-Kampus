import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginService {
  final String _baseUrl = 'https://backendtelkommedikamobile.se4603.my.id/login.php'; 

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      // Parse respons JSON
      final Map<String, dynamic> responseData = json.decode(response.body);

      // Cek status kode respons
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'full_name': responseData['full_name'] ?? 'User',
          'email': responseData['email'] ?? 'Failed Email',
          'user_id': responseData['user_id'] ?? 'User Id failed',
          'created_at': responseData['created_at'],
          'phone_number': responseData['phone_number']
        };
      } else {
        // Login gagal
        return {
          'success': false,
          'message': responseData['message'] ?? 'Login gagal',
        };
      }
    } catch (e) {
      // Tangani error koneksi atau parsing
      return {
        'success': false,
        'message': 'Terjadi kesalahan',
      };
    }
  }
}