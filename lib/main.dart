import 'package:flutter/material.dart';
import 'package:kesehatan_kampus/login_page.dart';
import 'package:kesehatan_kampus/register_page.dart';
import 'package:kesehatan_kampus/forgot_password_page.dart';
import 'package:kesehatan_kampus/home_page.dart';
import 'package:kesehatan_kampus/booking_page.dart';
import 'package:kesehatan_kampus/doctor_schedule_page.dart';
import 'package:kesehatan_kampus/riwayat_kesehatan_page.dart';
import 'package:kesehatan_kampus/kontak_darurat_page.dart';
import 'package:kesehatan_kampus/profile_page.dart';
import 'package:kesehatan_kampus/edit_profile_page.dart';
import 'package:kesehatan_kampus/ganti_password_page.dart';
import 'package:kesehatan_kampus/pengaturan_notifikasi_page.dart';
import 'package:kesehatan_kampus/bantuan_page.dart';
import 'package:kesehatan_kampus/konsultasi_online_page.dart';
import 'package:kesehatan_kampus/psikologi_test.dart';
import 'package:kesehatan_kampus/utility/local_notification.dart';

//adding sync service
import 'package:kesehatan_kampus/service/sync_database_service.dart';
import 'package:kesehatan_kampus/service/booking_sync_service.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalNotifications.init();
  
  //sync service
  SyncDatabaseService syncService = SyncDatabaseService();
  BookingSyncService syncBooking = BookingSyncService();

  // Sync users 
  bool success = await syncService.syncUsers();  

  if (success) {
    print("User data synced successfully!");
  } else {
    print("Failed to sync user data!");
  }

  // Sync bookings after syncing users
  bool bookingSyncSuccess = await syncBooking.syncBookings();
  if (bookingSyncSuccess) {
    print("Bookings synced successfully!");
  } else {
    print("Failed to sync bookings!");
  }


  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Klinik Kesehatan Kampus',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Colors.grey[100],
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/forgot_password': (context) => ForgotPasswordPage(),
        '/home': (context) => HomePage(),
        '/booking': (context) => BookingPage(),
        '/doctor_schedule': (context) => DoctorSchedulePage(),
        '/health_history': (context) => RiwayatKesehatanPage(),
        '/emergency_contact': (context) => KontakDaruratPage(),
        '/profile': (context) => ProfilePage(),
        '/edit_profile': (context) => EditProfilePage(),
        '/ganti_password': (context) => const ChangePasswordPage(),
        '/notifikasi_set': (context) => NotificationSettingsPage(),
        '/bantuan': (context) => HelpPage(),
        '/consultation': (context) => ConsultationPage(),
        '/psikolog_tes': (context) => PsychTestPage(),
      },
    );
  }
}
