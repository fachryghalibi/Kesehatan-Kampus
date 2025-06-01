// Fachry
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; 
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart'; 
import 'package:connectivity_plus/connectivity_plus.dart'; 
import 'package:kesehatan_kampus/article_detail_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kesehatan_kampus/service/get_articles.dart';
import 'package:kesehatan_kampus/utility/local_notification.dart';
import 'package:kesehatan_kampus/utility/notification_setting.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  bool isConnected = true;
  String username = '';

  // Daftar notifikasi
  final List<Map<String, dynamic>> _notifications = [
    {
      'title': 'Jadwal Konsultasi',
      'message': 'Konsultasi dengan Dr. Atyan akan dimulai dalam 1 jam',
      'time': '10:00',
      'isRead': false,
    },
    {
      'title': 'Hasil Tes',
      'message': 'Hasil tes psikolog Anda telah tersedia',
      'time': 'Kemarin',
      'isRead': true,
    },
    {
      'title': 'Pengingat Obat',
      'message': 'Waktunya minum obat sesuai resep',
      'time': 'Kemarin',
      'isRead': true,
    },
  ];

  // Daftar layanan
  final List<Map<String, dynamic>> _allServices = [
    {
      'title': 'Konsultasi Online',
      'description': 'Konsultasi dengan dokter melalui chat atau video call',
      'icon': Icons.video_call,
      'color': Colors.blue,
      'route': '/consultation'
    },
    {
      'title': 'Tes Psikolog',
      'description': 'Pemeriksaan psikolog dan tes kesehatan lainnya',
      'icon': Icons.science,
      'color': Colors.green,
      'route': '/psikolog_tes'
    },
  ];

  // Daftar artikel
  List<Map<String, dynamic>> _allArticles = [];
  List<Map<String, dynamic>> _filteredServices = [];
  List<Map<String, dynamic>> _filteredArticles = [];

  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _filteredServices = _allServices;
    _filteredArticles = _allArticles;
    _searchController.addListener(_filterContent);
    _checkConnectivity();
    _loadUsername();
    _fetchArticles();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadUsername(); // Reload username setiap kali dependencies berubah
  }

  

  Future<void> _fetchArticles() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Fetch articles from the database
      final articles = await GetArticles.fetchArticles();

      setState(() {
        _allArticles = articles;
        _filteredArticles = articles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat artikel. Silakan coba lagi.';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('full_name') ?? 'user';
    });
  }

  Future<void> _checkConnectivity() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    setState(() {
      isConnected = connectivityResult != ConnectivityResult.none;
    });

    // Listen to connectivity changes
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      setState(() {
        isConnected = result != ConnectivityResult.none;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterContent() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredServices = _allServices.where((service) {
        return service['title'].toLowerCase().contains(query) ||
            service['description'].toLowerCase().contains(query);
      }).toList();

      _filteredArticles = _allArticles.where((article) {
        return article['title'].toLowerCase().contains(query) ||
            article['author'].toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: !isConnected
          ? _buildNoInternetWidget()
          : RefreshIndicator(
              onRefresh: () async {
                //refresh logic
                await Future.delayed(const Duration(seconds: 1));
                setState(() {});
              },
              child: _buildBody(),
            ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      title: Text(
        'Telkom Medika',
        style: GoogleFonts.lato(
          color: const Color.fromARGB(255, 255, 17, 0),
          fontWeight: FontWeight.w900,
          fontSize: 30,
        ),
      ),
      actions: [
        _buildNotificationButton(),
      ],
    );
  }

  Widget _buildNotificationButton() {
    return Stack(
      children: [
        IconButton(
          icon:
              Icon(Icons.notifications, color: Theme.of(context).primaryColor),
          onPressed: () => _showNotificationsDialog(context),
        ),
        Positioned(
          right: 11,
          top: 11,
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(6),
            ),
            constraints: const BoxConstraints(
              minWidth: 14,
              minHeight: 14,
            ),
            child: const Text(
              '1',
              style: TextStyle(
                color: Colors.white,
                fontSize: 8,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNoInternetWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Tidak ada koneksi internet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 140,
            child: ElevatedButton(
              onPressed: _checkConnectivity,
              child: const Text('Coba Lagi'),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeSection(),
          _buildSearchBar(),
          const SizedBox(height: 30),
          _buildQuickActionsSection(),
          const SizedBox(height: 30),
          _buildMainServicesSection(),
          const SizedBox(height: 30),
          _buildArticlesSection(),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            'Selamat Datang!',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          Text(
            '$username ♡',
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 226, 226, 226),
          borderRadius: BorderRadius.circular(30),
        ),
        child: TextField(
          controller: _searchController,
          style: const TextStyle(),
          decoration: const InputDecoration(
            hintText: 'Cari layanan atau artikel kesehatan...',
            border: InputBorder.none,
            icon: Icon(Icons.search),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    return SizedBox(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        children: [
          _buildQuickAction(
              context, 'Profil', Icons.person, Colors.purple, '/profile'),
          _buildQuickAction(context, 'Booking', Icons.calendar_today,
              Colors.blue, '/booking'),
          _buildQuickAction(context, 'Jadwal', Icons.schedule, Colors.teal,
              '/doctor_schedule'),
          _buildQuickAction(context, 'Riwayat', Icons.history, Colors.orange,
              '/health_history'),
          _buildQuickAction(context, 'Darurat', Icons.phone_in_talk, Colors.red,
              '/emergency_contact'),
        ],
      ),
    );
  }

  Widget _buildMainServicesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Layanan Utama',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ..._filteredServices
              .map((service) => _buildServiceCard(
                    context,
                    service['title'],
                    service['description'],
                    service['icon'],
                    service['color'],
                    service['route'],
                  ))
              ,
        ],
      ),
    );
  }

  Widget _buildArticlesSection() {
    if (_isLoading) {
      return _buildArticleLoadingState();
    }

    if (_errorMessage.isNotEmpty) {
      return _buildArticleErrorState();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Artikel Kesehatan Terbaru',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _filteredArticles.isEmpty
              ? _buildNoArticlesFoundState()
              : Column(
                  children: _filteredArticles
                      .map((article) => _buildArticleCard(
                            article['title'],
                            article['author'],
                            article['readTime'],
                            article['imageUrl'],
                            article['id'], // Pass the article ID
                          ))
                      .toList(),
                ),
        ],
      ),
    );
  }

  Widget _buildArticleLoadingState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Artikel Kesehatan Terbaru',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          // Create 2 shimmer loading cards
          ...List.generate(
              2,
              (index) => Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    height: 20,
                                    width: double.infinity,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    height: 15,
                                    width: 100,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )),
        ],
      ),
    );
  }

  Widget _buildNoArticlesFoundState() {
    return Card(
      color: Colors.grey[200],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            'Tidak ada artikel yang ditemukan.',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAction(BuildContext context, String title, IconData icon,
    Color color, String route) {
  return Padding(
    padding: const EdgeInsets.only(right: 16),
    child: InkWell(
      onTap: () {
        Navigator.pushNamed(context, route).then((_) {
          // Tambahkan logika untuk merefresh halaman HomePage
          setState(() {
            _fetchArticles(); // Jika ada data artikel
            _checkConnectivity(); // Jika memerlukan konektivitas ulang
            _loadUsername(); // Jika username atau profil perlu diperbarui
          });
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    ),
  );
}


  Widget _buildServiceCard(BuildContext context, String title,
      String description, IconData icon, Color color, String route) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, route),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildArticleErrorState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Artikel Kesehatan Terbaru',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            color: Colors.red[50],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      _errorMessage,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                  TextButton(
                    onPressed: _fetchArticles,
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArticleCard(String title, String author, String readTime,
      String imageUrl, String articleId) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: () async {
          try {
            final id = int.tryParse(
                articleId); // Menggunakan tryParse untuk mencegah exception
            if (id == null) {
              throw Exception("Invalid article ID");
            }
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ArticleDetailPage(
                  articleId: id,
                ),
              ),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Gagal memuat detail artikel: $e')),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          author,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Icon(Icons.access_time, size: 12, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          readTime,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    height: 80,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        color: Colors.white,
                        height: 80,
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 80,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image_not_supported),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showNotificationsDialog(BuildContext context) async {
  final notifications = await LocalNotifications.getSavedNotifications();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Saved Notifications'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];

              return ListTile(
                leading: Icon(Icons.notifications),
                title: Text(notification['title'] ?? 'No title'),
                subtitle: Text(notification['body'] ?? 'No body'),
                onTap: () {
                  // Optionally mark as read or take any other action
                  setState(() {
                    notification['isRead'] = true;
                  });
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Close'),
          ),
        ],
      );
    },
  );
}}