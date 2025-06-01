import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  _HelpPageState createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  List<Map<String, String>> faqs = [
    {
      'question': 'Apa itu Aplikasi Ini?',
      'answer': 'Aplikasi ini adalah platform untuk mengelola profil pengguna dan berbagai pengaturan terkait akun.'
    },
    {
      'question': 'Bagaimana cara mengedit profil?',
      'answer': 'Untuk mengedit profil, buka halaman "Edit Profil" di menu profil pengguna.'
    },
    {
      'question': 'Mengapa saya perlu mengubah kata sandi?',
      'answer': 'Mengubah kata sandi secara berkala dapat meningkatkan keamanan akun Anda.'
    },
    {
      'question': 'Bagaimana cara mengatur notifikasi?',
      'answer': 'Anda dapat mengatur jenis notifikasi yang ingin diterima di halaman "Pengaturan Notifikasi".'
    },
    {
      'question': 'Apa yang harus dilakukan jika lupa kata sandi?',
      'answer': 'Jika Anda lupa kata sandi, Anda dapat mengikuti prosedur pemulihan kata sandi di halaman login.'
    },
  ];

  late List<Map<String, String>> filteredFaqs;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredFaqs = faqs;
    _searchController.addListener(_filterFaqs);
  }

  void _filterFaqs() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      filteredFaqs = faqs
          .where((faq) =>
              faq['question']!.toLowerCase().contains(query) ||
              faq['answer']!.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bantuan'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.help_outline,
                    size: 60,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Panduan Penggunaan Aplikasi',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Temukan jawaban untuk pertanyaan umum Anda di sini',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              _buildSearchBar(),
              const SizedBox(height: 24),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredFaqs.length,
                itemBuilder: (context, index) {
                  return _buildFaqItem(
                    filteredFaqs[index]['question']!,
                    filteredFaqs[index]['answer']!,
                  );
                },
              ),
              const SizedBox(height: 32),
              _buildContactSupport(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade50,
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Cari pertanyaan...',
          prefixIcon: Icon(Icons.search, color: Theme.of(context).primaryColor),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            color: Colors.grey.shade50,
            child: Text(
              answer,
              style: TextStyle(fontSize: 14, color: Colors.grey[800]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSupport() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          const Text(
            'Masih Butuh Bantuan?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Hubungi tim dukungan kami untuk bantuan lebih lanjut',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Kontak dukungan akan segera tersedia!'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Hubungi Dukungan',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}