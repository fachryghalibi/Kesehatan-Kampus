// lib/service/jadwal_dokter_service.dart

import 'package:http/http.dart' as http;
import 'dart:convert';

class GetJadwalDokter {
  final String baseUrl = 'http://10.0.2.2/api_tubes/get_doctor_schedule.php'; 

  // Fetch jadwal dokter
  Future<List<Map<String, dynamic>>> fetchJadwalDokter() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/jadwal-dokter'));
      
      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = json.decode(response.body);
        return List<Map<String, dynamic>>.from(jsonResponse);
      } else {
        throw Exception('Failed to load doctor schedules');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<bool> bookConsultation(String doctorId, String time) async {
    const String apiUrl = "http://10.0.2.2/api_tubes/book_appointment.php"; 

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: json.encode({
          'doctor_id': doctorId,
          'time': time,
        }),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // Assuming a successful response
        final responseData = json.decode(response.body);
        return responseData['success'] ?? false; // Replace with actual response structure
      } else {
        // Handle error responses
        return false;
      }
    } catch (e) {
      print("Error booking consultation: $e");
      return false; // Return false if there was an error
    }
  }

  // Create booking
  Future<bool> createBooking(Map<String, dynamic> bookingData) async {
  try {
    final response = await http.post(
      Uri.parse('http://10.0.2.2/api_tubes/bookings.php'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(bookingData),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['status'] == 'success') {
        return true;
      } else {
        throw Exception('Error: ${jsonResponse['message']}');
      }
    } else {
      throw Exception('Failed to create booking: ${response.body}');
    }
  } catch (e) {
    print('Error creating booking: $e');
    return false;
  }
}


  Future<List<Map<String, dynamic>>> getBookingHistory(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/bookings/$userId'),
        headers: {
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = json.decode(response.body);
        return List<Map<String, dynamic>>.from(jsonResponse);
      } else {
        throw Exception('Failed to load booking history');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<bool> updateBookingStatus(String bookingId, String status) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/bookings/$bookingId'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({'status': status}),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error updating booking status: $e');
    }
  }
}