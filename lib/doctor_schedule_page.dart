import 'package:flutter/material.dart';
import 'package:kesehatan_kampus/service/jadwal_dokter_service.dart'; 

class DoctorSchedulePage extends StatefulWidget {
  const DoctorSchedulePage({super.key});

  @override
  _DoctorSchedulePageState createState() => _DoctorSchedulePageState();
}

class _DoctorSchedulePageState extends State<DoctorSchedulePage> {
  final JadwalDokter _apiService = JadwalDokter();
  List<Map<String, dynamic>> _schedules = [];

  @override
  void initState() {
    super.initState();
    _loadSchedules();
  }

  Future<void> _loadSchedules() async {
    try {
      final schedules = await _apiService.fetchJadwalDokter();
      setState(() {
        _schedules = schedules;
      });
    } catch (e) {
      print('Error fetching schedules: $e');
    }
  }

  String _formatSchedule(Map<String, dynamic> schedule) {
    final days = schedule['days'].split(',').join(' & ');
    return '$days, ${schedule['start_time']} - ${schedule['end_time']}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jadwal Dokter'),
      ),
      body: _schedules.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _schedules.length,
              itemBuilder: (context, index) {
                final schedule = _schedules[index];
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: Colors.teal,
                      radius: 25,
                      child: Text(
                        schedule['name'].substring(4, 5),
                        style: const TextStyle(fontSize: 20, color: Colors.white),
                      ),
                    ),
                    title: Text(
                      schedule['name'],
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.medical_services, size: 16, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text(schedule['specialty']),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.schedule, size: 16, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text(_formatSchedule(schedule)),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}