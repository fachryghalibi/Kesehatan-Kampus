import 'package:http/http.dart' as http;

class BookingSyncService {
  final String apiUrl = 'https://backendtelkommedikamobile.se4603.my.id/booking_sync.php'; 

  Future<bool> syncBookings() async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // If (status 200) successfull
        print('Sync successful!');
        print('Response body: ${response.body}');  
        return true;  
      } else {
       
        print('Failed to sync bookings. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        return false;  
      }
    } catch (e) {
      print('Error occurred: $e');  
      return false; 
    }
  }
}
