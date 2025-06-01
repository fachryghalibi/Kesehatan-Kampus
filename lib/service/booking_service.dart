import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class BookingService {
  static const String _baseUrl = 'http://10.0.2.2/api_tubes/book_appointment.php';

  // Create new booking
Future<bool> createBooking(Map<String, dynamic> bookingData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Menggunakan key yang sama dengan yang disimpan saat login
      final String? patientName = prefs.getString('full_name');
      final int? patientId = prefs.getInt('user_id');

      if (patientName == null || patientId == null) {
        throw Exception('User not logged in');
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/create_booking.php'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'doctor_id': bookingData['doctor_id'],
          'doctor_name': bookingData['doctor_name'],
          'specialty': bookingData['specialty'],
          'booking_date': bookingData['booking_date'],
          'booking_time': bookingData['booking_time'],
          'status': 'pending',
          'patient_name': patientName,
          'patient_id': patientId,
          'patient_email': prefs.getString('email'),
          'patient_phone': prefs.getString('phone_number'),
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return jsonResponse['status'] == 'success';
      } else {
        throw Exception('Failed to create booking: ${response.body}');
      }
    } catch (e) {
      print('Error creating booking: $e');
      return false;
    }
  }

  // Get booking history
  Future<List<Map<String, dynamic>>> getBookingHistory() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/get_bookings.php'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => e as Map<String, dynamic>).toList();
      } else {
        throw Exception('Failed to load booking history');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Update booking status
  Future<bool> updateBookingStatus(int bookingId, String status) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/update_booking_status.php'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'booking_id': bookingId,
          'status': status,
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return jsonResponse['status'] == 'success';
      } else {
        throw Exception('Failed to update booking status');
      }
    } catch (e) {
      print('Error updating booking status: $e');
      return false;
    }
  }

  // Get single booking details
  Future<Map<String, dynamic>?> getBookingDetails(int bookingId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/get_booking_details.php?booking_id=$bookingId'),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == 'success') {
          return jsonResponse['data'];
        }
        return null;
      } else {
        throw Exception('Failed to load booking details');
      }
    } catch (e) {
      print('Error getting booking details: $e');
      return null;
    }
  }
}