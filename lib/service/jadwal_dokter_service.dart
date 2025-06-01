import 'dart:convert';
import 'package:http/http.dart' as http;

class JadwalDokter {
  static const String _baseUrl = 'http://10.0.2.2/api_tubes/jadwal_dokter_api.php';

  Future<List<Map<String, dynamic>>> fetchJadwalDokter() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => e as Map<String, dynamic>).toList();
      } else {
        throw Exception('Failed to load jadwal dokter');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

}
