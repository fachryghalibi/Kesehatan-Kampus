import 'package:flutter/material.dart';
import 'package:kesehatan_kampus/service/checkup_service.dart'; 
import 'package:shared_preferences/shared_preferences.dart';

class RiwayatKesehatanPage extends StatefulWidget {
  RiwayatKesehatanPage({super.key});

  @override
  _RiwayatKesehatanPageState createState() => _RiwayatKesehatanPageState();
}

class _RiwayatKesehatanPageState extends State<RiwayatKesehatanPage> {
  late Future<List<Map<String, String>>> healthHistory;
  late int userId;  

  @override
  void initState() {
    super.initState();
    _getUserId();  
  }

  // Function to fetch the userId from SharedPreferences
  Future<void> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getInt('user_id') ?? 0;  // Default 0
    });
  }

  @override
  Widget build(BuildContext context) {
    // show a loading indicator if userId = 0
    if (userId == 0) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // fetch checkup
    healthHistory = CheckupService().getCheckupHistory(userId);

    return Scaffold(
      appBar: AppBar(
        title: Text('Riwayat Kesehatan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<Map<String, String>>>(
          future: healthHistory,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No checkup history found'));
            } else {
              final healthHistory = snapshot.data!;
              return ListView.builder(
                itemCount: healthHistory.length,
                itemBuilder: (context, index) {
                  final record = healthHistory[index];
                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            record['condition']!,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tanggal: ${record['date']}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            record['details']!,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
