// lib/pages/consultation_page.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kesehatan_kampus/service/booking_service.dart';
import 'package:kesehatan_kampus/utility/local_notification.dart';
import 'package:kesehatan_kampus/service/jadwal_dokter_service.dart';
import 'package:intl/intl.dart';

import 'package:kesehatan_kampus/service/booking_sync_service.dart';

class BookingPage extends StatefulWidget {
  @override
  _ConsultationPageState createState() => _ConsultationPageState();
}

class _ConsultationPageState extends State<BookingPage> {
  final JadwalDokter _apiService = JadwalDokter();
  final BookingService _bookingService =
      BookingService(); // Add booking service

  List<Map<String, dynamic>> _allDoctors = [];
  List<Map<String, dynamic>> _filteredDoctors = [];
  bool _isLoading = true;
  String _selectedDate = 'Hari ini';
  final List<String> _dateOptions = ['Hari ini', 'Besok', '2 hari lagi'];
  String? _selectedDoctorName;
  String? _selectedTime;

  @override
  void initState() {
    super.initState();
    _fetchDoctors();
  }

  Future<void> _fetchDoctors() async {
    try {
      final schedules = await _apiService.fetchJadwalDokter();
      setState(() {
        _allDoctors = schedules.map((schedule) {
          return {
            'id_dokter': schedule['id_dokter'],
            'name': schedule['name'],
            'specialty': schedule['specialty'],
            'availableTime': _parseAvailableTimes(
              schedule['start_time'],
              schedule['end_time'],
            ),
            'days': schedule['days'].split(','),
            'rating': schedule['rating'] ?? '4.5',
            'experience': schedule['experience'] ?? '5 tahun',
            'start_time': schedule['start_time'],
            'end_time': schedule['end_time'],
          };
        }).toList();

        _filterDoctorsByDate();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  void _filterDoctorsByDate() {
    final now = DateTime.now();
    DateTime selectedDate;

    switch (_selectedDate) {
      case 'Hari ini':
        selectedDate = now;
        break;
      case 'Besok':
        selectedDate = now.add(Duration(days: 1));
        break;
      case '2 hari lagi':
        selectedDate = now.add(Duration(days: 2));
        break;
      default:
        selectedDate = now;
    }

    final dayName = _getDayName(selectedDate.weekday);

    setState(() {
      _filteredDoctors = _allDoctors.where((doctor) {
        return doctor['days'].contains(dayName);
      }).toList();

      // Reset selections when changing date
      _selectedDoctorName = null;
      _selectedTime = null;
    });
  }

  String _getDayName(int day) {
    final days = [
      'Minggu',
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu'
    ];
    return days[day % 7];
  }

  List<String> _parseAvailableTimes(String startTime, String endTime) {
    final startHour = int.parse(startTime.split(":")[0]);
    final endHour = int.parse(endTime.split(":")[0]);

    return List.generate(
      endHour - startHour,
      (index) => "${(startHour + index).toString().padLeft(2, '0')}:00",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Konsultasi Online',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Stack(
        children: [
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: 16.0,
                      right: 16.0,
                      top: 16.0,
                      bottom: 80.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDateSelector(),
                        SizedBox(height: 24),
                        if (_filteredDoctors.isEmpty)
                          Center(
                              child: Text("Tidak ada jadwal dokter tersedia")),
                        if (_filteredDoctors.isNotEmpty) ...[
                          Text(
                            'Dokter Tersedia',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 16),
                          ..._filteredDoctors
                              .map((doctor) => _buildDoctorCard(doctor))
                              .toList(),
                        ],
                      ],
                    ),
                  ),
                ),
          if (_filteredDoctors.isNotEmpty) _buildBottomButton(),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _dateOptions.length,
        itemBuilder: (context, index) {
          final date = _dateOptions[index];
          final isSelected = date == _selectedDate;
          return Padding(
            padding: EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(date),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedDate = date;
                  });
                  _filterDoctorsByDate();
                }
              },
              selectedColor: Theme.of(context).primaryColor,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDoctorCard(Map<String, dynamic> doctor) {
    final doctorName = doctor['name'];
    final bool isDoctorSelected = _selectedDoctorName == doctorName;

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey[200],
                  child: Icon(Icons.person, size: 40, color: Colors.grey),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctorName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        doctor['specialty'],
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 16),
                          SizedBox(width: 4),
                          Text(
                            doctor['rating'],
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(width: 16),
                          Icon(Icons.work, color: Colors.grey, size: 16),
                          SizedBox(width: 4),
                          Text(
                            doctor['experience'],
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              'Waktu Tersedia',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (doctor['availableTime'] as List<String>).map((time) {
                bool isTimeSelected = _selectedTime == time && isDoctorSelected;
                return OutlinedButton(
                  onPressed: () {
                    setState(() {
                      if (isTimeSelected) {
                        _selectedDoctorName = null;
                        _selectedTime = null;
                      } else {
                        _selectedDoctorName = doctorName;
                        _selectedTime = time;
                      }
                    });
                  },
                  child: Text(time),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isTimeSelected
                        ? Colors.white
                        : Theme.of(context).primaryColor,
                    backgroundColor: isTimeSelected
                        ? Theme.of(context).primaryColor
                        : Colors.white,
                    side: BorderSide(color: Theme.of(context).primaryColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButton() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _selectedDoctorName != null && _selectedTime != null
              ? () {
                  final selectedDoctor = _filteredDoctors.firstWhere(
                    (doctor) => doctor['name'] == _selectedDoctorName,
                  );
                  _showBookingConfirmation(
                      context, selectedDoctor, _selectedTime!);
                }
              : null,
          child: Text(
            'Lanjutkan',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            disabledBackgroundColor: Colors.grey[300],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            minimumSize: Size(double.infinity, 50),
          ),
        ),
      ),
    );
  }

  void _showBookingConfirmation(
    BuildContext context,
    Map<String, dynamic> doctor,
    String time,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            children: [
              Icon(Icons.info, color: Theme.of(context).primaryColor),
              SizedBox(width: 8),
              Text('Konfirmasi Konsultasi',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Anda akan memesan konsultasi dengan:'),
              SizedBox(height: 8),
              Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.grey[200],
                    child: Icon(Icons.person, size: 30, color: Colors.grey),
                  ),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctor['name'],
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        doctor['specialty'],
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.calendar_today,
                      color: Theme.of(context).primaryColor, size: 16),
                  SizedBox(width: 8),
                  Text(
                    'Tanggal: $_selectedDate',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.access_time,
                      color: Theme.of(context).primaryColor, size: 16),
                  SizedBox(width: 8),
                  Text(
                    'Waktu: $time',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
          actionsPadding: EdgeInsets.only(bottom: 8, left: 16, right: 16),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Batal'),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Theme.of(context).primaryColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      foregroundColor: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      await _processBooking(doctor, time);
                    },
                    child: Text('Konfirmasi'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      minimumSize: Size(double.infinity, 45),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> _processBooking(Map<String, dynamic> doctor, String time) async {
    try {
      // Get user data from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');
      final fullName = prefs.getString('full_name');
      final email = prefs.getString('email');
      final phoneNumber = prefs.getString('phone_number');

      // Verify that all user data exists
      if (userId == null ||
          fullName == null ||
          email == null ||
          phoneNumber == null) {
        throw Exception('Data pengguna tidak lengkap. Silakan login kembali.');
      }

      // Format booking date
      final now = DateTime.now();
      int additionalDays = 0;
      switch (_selectedDate) {
        case 'Besok':
          additionalDays = 1;
          break;
        case '2 hari lagi':
          additionalDays = 2;
          break;
      }
      final bookingDate = now.add(Duration(days: additionalDays));

      // Create booking data with user information
      final bookingData = {
        'doctor_id': doctor['id_dokter'],
        'doctor_name': doctor['name'],
        'specialty': doctor['specialty'],
        'booking_date': DateFormat('yyyy-MM-dd').format(bookingDate),
        'booking_time': time,
        'status': 'pending',
        'patient_id': userId,
        'patient_name': fullName,
        'patient_email': email,
        'patient_phone': phoneNumber,
      };

      // Use booking service to create booking
      final success = await _bookingService.createBooking(bookingData);

      if (success) {
        // Show success notification
        await LocalNotifications.showSimpleNotification(
          title: 'Booking Berhasil',
          body:
              'Konsultasi Anda telah dijadwalkan dengan ${doctor['name']} pada $_selectedDate pukul $time',
          payload: 'booking_confirmed',
          type: 'newMessages',
        );

        // Show success dialog
        if (context.mounted) {
          _showBookingSuccess(context);
        }
      } else {
        throw Exception('Gagal membuat booking');
      }

      //sync booking
      BookingSyncService syncBooking = BookingSyncService();
      bool bookingSyncSuccess = await syncBooking.syncBookings();
      if (bookingSyncSuccess) {
        print("Bookings synced successfully!");
      } else {
        print("Failed to sync bookings!");
      }

    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showBookingSuccess(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Column(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 50,
              ),
              SizedBox(height: 8),
              Text('Booking Berhasil'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Konsultasi Anda telah berhasil dijadwalkan. Kami akan mengirimkan notifikasi pengingat sebelum waktu konsultasi.',
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Text(
                'Silakan cek menu riwayat konsultasi untuk melihat detail booking Anda.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                // Kembali ke halaman utama
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 45),
              ),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        );
      },
    );
  }
}