// Fachry
import 'package:flutter/material.dart';

class PsychTestPage extends StatefulWidget {
  const PsychTestPage({super.key});

  @override
  _PsychTestPageState createState() => _PsychTestPageState();
}

class _PsychTestPageState extends State<PsychTestPage> {
  int _currentQuestionIndex = 0;
  bool _testCompleted = false;
  final Map<String, int> _results = {};
  
  final List<Map<String, dynamic>> _questions = [
        {
          'category': 'Kecemasan',
          'question': 'Seberapa sering Anda merasa cemas atau khawatir berlebihan dalam 2 minggu terakhir?',
          'options': [
            'Tidak pernah',
            'Beberapa hari',
            'Lebih dari setengah hari',
            'Hampir setiap hari'
          ],
        },
        {
          'category': 'Depresi',
          'question': 'Seberapa sering Anda merasa sedih, tertekan atau putus asa dalam 2 minggu terakhir?',
          'options': [
            'Tidak pernah',
            'Beberapa hari',
            'Lebih dari setengah hari',
            'Hampir setiap hari'
          ],
        },
        {
          'category': 'Kecemasan',
          'question': 'Seberapa sering Anda merasa sulit untuk rileks dalam 2 minggu terakhir?',
          'options': [
            'Tidak pernah',
            'Beberapa hari',
            'Lebih dari setengah hari',
            'Hampir setiap hari'
          ],
        },
        {
          'category': 'Depresi',
          'question': 'Seberapa sering Anda kehilangan minat atau kesenangan dalam melakukan sesuatu dalam 2 minggu terakhir?',
          'options': [
            'Tidak pernah',
            'Beberapa hari',
            'Lebih dari setengah hari',
            'Hampir setiap hari'
          ],
        },
        {
          'category': 'Stress',
          'question': 'Seberapa sering Anda merasa stres atau tertekan dengan pekerjaan/kegiatan sehari-hari dalam 2 minggu terakhir?',
          'options': [
            'Tidak pernah',
            'Beberapa hari',
            'Lebih dari setengah hari',
            'Hampir setiap hari'
          ],
        },
        // Additional questions
        {
          'category': 'Kecemasan',
          'question': 'Seberapa sering Anda merasa cemas tentang hal-hal kecil yang biasanya tidak Anda khawatirkan?',
          'options': [
            'Tidak pernah',
            'Beberapa hari',
            'Lebih dari setengah hari',
            'Hampir setiap hari'
          ],
        },
        {
          'category': 'Depresi',
          'question': 'Seberapa sering Anda merasa tidak berharga atau merasa bersalah tanpa alasan yang jelas?',
          'options': [
            'Tidak pernah',
            'Beberapa hari',
            'Lebih dari setengah hari',
            'Hampir setiap hari'
          ],
        },
        {
          'category': 'Stress',
          'question': 'Apakah Anda merasa kesulitan tidur atau bangun terlalu pagi karena stres?',
          'options': [
            'Tidak pernah',
            'Beberapa hari',
            'Lebih dari setengah hari',
            'Hampir setiap hari'
          ],
        },
        {
          'category': 'Kecemasan',
          'question': 'Apakah Anda merasa cemas ketika Anda harus berbicara di depan umum?',
          'options': [
            'Tidak pernah',
            'Beberapa hari',
            'Lebih dari setengah hari',
            'Hampir setiap hari'
          ],
        },
        {
          'category': 'Depresi',
          'question': 'Apakah Anda merasa tidak bersemangat untuk melakukan kegiatan sehari-hari?',
          'options': [
            'Tidak pernah',
            'Beberapa hari',
            'Lebih dari setengah hari',
            'Hampir setiap hari'
          ],
        },
        {
          'category': 'Stress',
          'question': 'Apakah Anda merasa tertekan dengan tuntutan pekerjaan atau sekolah yang terlalu banyak?',
          'options': [
            'Tidak pernah',
            'Beberapa hari',
            'Lebih dari setengah hari',
            'Hampir setiap hari'
          ],
        },
        {
          'category': 'Kecemasan',
          'question': 'Apakah Anda merasa khawatir tentang masalah yang sebenarnya belum terjadi?',
          'options': [
            'Tidak pernah',
            'Beberapa hari',
            'Lebih dari setengah hari',
            'Hampir setiap hari'
          ],
        },
        {
          'category': 'Depresi',
          'question': 'Apakah Anda merasa sulit untuk bangun dari tempat tidur di pagi hari?',
          'options': [
            'Tidak pernah',
            'Beberapa hari',
            'Lebih dari setengah hari',
            'Hampir setiap hari'
          ],
        },
        {
          'category': 'Stress',
          'question': 'Apakah Anda merasa bahwa stres mempengaruhi kesehatan fisik Anda, seperti sakit kepala atau ketegangan otot?',
          'options': [
            'Tidak pernah',
            'Beberapa hari',
            'Lebih dari setengah hari',
            'Hampir setiap hari'
          ],
        },
        {
          'category': 'Kecemasan',
          'question': 'Seberapa sering Anda merasa gelisah atau takut akan sesuatu yang tidak pasti?',
          'options': [
            'Tidak pernah',
            'Beberapa hari',
            'Lebih dari setengah hari',
            'Hampir setiap hari'
          ],
        },
        {
          'category': 'Depresi',
          'question': 'Apakah Anda merasa tidak bisa menikmati hal-hal yang biasanya menyenangkan bagi Anda?',
          'options': [
            'Tidak pernah',
            'Beberapa hari',
            'Lebih dari setengah hari',
            'Hampir setiap hari'
          ],
        },
        {
          'category': 'Stress',
          'question': 'Apakah Anda merasa cemas tentang masa depan atau apa yang akan terjadi?',
          'options': [
            'Tidak pernah',
            'Beberapa hari',
            'Lebih dari setengah hari',
            'Hampir setiap hari'
          ],
        },
  ];

  final Map<String, List<String>> _recommendations = {
    'Kecemasan': [
      'Latihan pernapasan dalam',
      'Meditasi mindfulness',
      'Olahraga teratur',
      'Kurangi konsumsi kafein',
    ],
    'Depresi': [
      'Tetap aktif secara sosial',
      'Buat jadwal harian',
      'Terapi bicara',
      'Jaga pola tidur teratur',
    ],
    'Stress': [
      'Time management',
      'Hobi yang menyenangkan',
      'Yoga atau stretching',
      'Journaling',
    ],
  };

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
          'Tes Psikologi',
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _testCompleted ? _buildResults() : _buildTest(),
    );
  }

  Widget _buildTest() {
    final question = _questions[_currentQuestionIndex];
    
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(
              value: (_currentQuestionIndex + 1) / _questions.length,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
            ),
            const SizedBox(height: 24),
            Text(
              'Pertanyaan ${_currentQuestionIndex + 1} dari ${_questions.length}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              question['question'],
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            ..._buildOptions(question['options']),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildOptions(List<String> options) {
    return options.asMap().entries.map((entry) {
      final index = entry.key;
      final option = entry.value;
      
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: ElevatedButton(
          onPressed: () => _handleAnswer(index),
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.black87,
            backgroundColor: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  option,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      );
    }).toList();
  }

  void _handleAnswer(int answerIndex) {
    final category = _questions[_currentQuestionIndex]['category'];
    _results[category] = (_results[category] ?? 0) + answerIndex;

    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      setState(() {
        _testCompleted = true;
      });
    }
  }

  Widget _buildResults() {
    final Map<String, double> normalizedResults = {};
    _results.forEach((category, score) {
      normalizedResults[category] = score / 
          _questions.where((q) => q['category'] == category).length / 3 * 100;
    });

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hasil Tes Anda',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            ...normalizedResults.entries.map((entry) => _buildResultBar(
              entry.key,
              entry.value,
            )),
            const SizedBox(height: 32),
            const Text(
              'Rekomendasi',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ..._buildRecommendations(normalizedResults),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _showConsultationDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 225, 225, 225),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Konsultasi dengan Psikolog',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultBar(String category, double percentage) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                category,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(_getColorForPercentage(percentage)),
            minHeight: 10,
          ),
        ],
      ),
    );
  }

  Color _getColorForPercentage(double percentage) {
    if (percentage < 30) return Colors.green;
    if (percentage < 70) return Colors.orange;
    return Colors.red;
  }

  List<Widget> _buildRecommendations(Map<String, double> results) {
    List<Widget> widgets = [];
    
    results.forEach((category, score) {
      if (score > 30) {
        widgets.add(
          Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Untuk $category:',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ..._recommendations[category]!.map((rec) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: Theme.of(context).primaryColor, size: 20),
                        const SizedBox(width: 8),
                        Text(rec),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          ),
        );
      }
    });
    
    return widgets;
  }

  void _showConsultationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Konsultasi'),
          content: const Text('Apakah Anda ingin melanjutkan untuk konsultasi dengan psikolog?'),
          actions: [
            TextButton(
              child: const Text('Batal'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text('Ya, Lanjutkan'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushNamed(context, '/consultation');
              },
            ),
          ],
        );
      },
    );
  }
}