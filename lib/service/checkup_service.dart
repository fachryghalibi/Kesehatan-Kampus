import 'dart:convert';
import 'package:http/http.dart' as http;

class CheckupService {
  final String apiUrl = 'https://backendtelkommedikamobile.se4603.my.id/checkup.php';

  // Fetch checkup history using user_id
  Future<List<Map<String, String>>> getCheckupHistory(int userId) async {
    try {
      final response = await http.get(Uri.parse('$apiUrl?user_id=$userId'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

        // Check if there is data
        if (data.isNotEmpty) {
          return data.map((item) {
            return {
              'date': item['checkup_date']?.toString() ?? '',
              'condition': item['diagnosis']?.toString() ?? '',
              'details': item['notes']?.toString() ?? '',
            };
          }).toList();
        } else {
          return [];
        }
      } else {
        throw Exception('Failed to load checkup history');
      }
    } catch (e) {
      print('Error fetching checkup history: $e');
      return [];
    }
  }
}
