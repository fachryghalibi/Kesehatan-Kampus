import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:share_plus/share_plus.dart';
import 'package:kesehatan_kampus/service/get_articles.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:like_button/like_button.dart';

class ArticleDetailPage extends StatefulWidget {
  final int articleId;

  const ArticleDetailPage({super.key, required this.articleId});

  @override
  _ArticleDetailPageState createState() => _ArticleDetailPageState();
}

class _ArticleDetailPageState extends State<ArticleDetailPage> {
  // State variables
  bool _isBookmarked = false;
  bool _isLiked = false;
  int _likeCount = 0;
  late Future<Map<String, dynamic>> _articleDetails;
  late SharedPreferences _prefs;


  @override
  void initState() {
    super.initState();
    _fetchArticleDetails();
    _initializePreferences();

  }

    Future<void> _initializePreferences() async {
    _prefs = await SharedPreferences.getInstance();
    _loadSavedStates();
  }

  void _loadSavedStates() {
    setState(() {
      _isBookmarked = _prefs.getBool('bookmark_${widget.articleId}') ?? false;
      _isLiked = _prefs.getBool('like_${widget.articleId}') ?? false;
      _likeCount = _prefs.getInt('likeCount_${widget.articleId}') ?? 0;
    });
  }


  // Method to fetch article details
  void _fetchArticleDetails() {
    _articleDetails = GetArticles.fetchArticleDetails(widget.articleId);
  }

  Future<void> _saveStates() async {
  await _prefs.setBool('bookmark_${widget.articleId}', _isBookmarked);
  await _prefs.setBool('like_${widget.articleId}', _isLiked);
  await _prefs.setInt('likeCount_${widget.articleId}', _likeCount);
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildArticleContent(),
      floatingActionButton: _buildFloatingActionButtons(),
    );
  }

  // Main article content builder
  Widget _buildArticleContent() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _articleDetails,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingIndicator();
        } 
        
        if (snapshot.hasError) {
          return _buildErrorState(snapshot.error.toString());
        } 
        
        if (!snapshot.hasData || snapshot.data == null) {
          return _buildErrorState('Data artikel tidak ditemukan');
        }

        final article = snapshot.data!;

        return CustomScrollView(
          slivers: [
            _buildSliverAppBar(article),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTitle(article),
                    const SizedBox(height: 12),
                    _buildAuthorInfo(article),
                    _buildEngagementSection(),
                    const SizedBox(height: 16),
                    _buildContent(article),
                    const SizedBox(height: 20),
                    _buildTagsSection(),
                    const SizedBox(height: 20),
                    _buildRelatedArticles(),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Loading indicator
  Widget _buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  // Engagement section with like button
  // Di dalam _ArticleDetailPageState class, tambahkan atau modifikasi method-method berikut:

// Perbaikan engagement section
  Widget _buildEngagementSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          LikeButton(
            size: 30,
            isLiked: _isLiked,
            likeCount: _likeCount,
            countBuilder: (count, isLiked, text) {
              return Text(
                count.toString(),
                style: TextStyle(
                  color: isLiked ? Colors.red : Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
            likeBuilder: (bool isLiked) {
              return Icon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                color: isLiked ? Colors.red : Colors.grey,
                size: 30,
              );
            },
            onTap: (bool isLiked) async {
              setState(() {
                _isLiked = !isLiked;
                _likeCount += _isLiked ? 1 : -1;
              });
              await _saveStates();
              return !isLiked;
            },
          ),
          Container(
            height: 30,
            width: 1,
            color: Colors.grey.shade300,
          ),
          _buildCommentSection(),
        ],
      ),
    );
  }

Widget _buildLikeSection() {
  return GestureDetector(
    onTap: () {
      setState(() {
        _isLiked = !_isLiked;
        _isLiked ? _likeCount++ : _likeCount--;
      });
    },
    child: Row(
      children: [
        Icon(
          _isLiked ? Icons.favorite : Icons.favorite_border,
          color: _isLiked ? Colors.red : Colors.grey,
          size: 24,
        ),
        const SizedBox(width: 8),
        Text(
          _likeCount.toString(),
          style: TextStyle(
            color: _isLiked ? Colors.red : Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}

Widget _buildCommentSection() {
  return const Row(
    children: [
      Icon(
        Icons.comment_outlined,
        color: Colors.grey,
        size: 24,
      ),
      SizedBox(width: 8),
      Text(
        '0', // Ganti dengan jumlah komentar sebenarnya
        style: TextStyle(
          color: Colors.grey,
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  );
}

  // Error state with retry option
  Widget _buildErrorState(String errorMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, color: Colors.red),
          const SizedBox(height: 8),
          Text(
            errorMessage, 
            style: const TextStyle(color: Colors.red),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _fetchArticleDetails();
              });
            },
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  // Sliver app bar with image
  Widget _buildSliverAppBar(Map<String, dynamic> article) {
    return SliverAppBar(
      expandedHeight: 200.0,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: _buildAppBarBackground(article),
      ),
    );
  }

  // App bar background with image and gradient
  Widget _buildAppBarBackground(Map<String, dynamic> article) {
    return Stack(
      fit: StackFit.expand,
      children: [
        CachedNetworkImage(
          imageUrl: article['imageUrl'] ?? '', 
          fit: BoxFit.cover,
          placeholder: (context, url) => _buildImagePlaceholder(),
          errorWidget: (context, url, error) => _buildErrorImage(),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.7),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Image placeholder with shimmer effect
  Widget _buildImagePlaceholder() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(color: Colors.white),
    );
  }

  // Error image widget
  Widget _buildErrorImage() {
    return Container(
      color: Colors.grey[300],
      child: const Icon(Icons.image_not_supported),
    );
  }

  // Article title
  Widget _buildTitle(Map<String, dynamic> article) {
    return Text(
      article['title'] ?? 'Title not available',
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // Author information
  Widget _buildAuthorInfo(Map<String, dynamic> article) {
    return Row(
      children: [
        _buildAuthorAvatar(article),
        const SizedBox(width: 8),
        Expanded(
          child: _buildAuthorDetails(article),
        ),
      ],
    );
  }

  // Author avatar
  Widget _buildAuthorAvatar(Map<String, dynamic> article) {
    return CircleAvatar(
      backgroundColor: Theme.of(context).primaryColor,
      child: Text(
        article['author']?.substring(0, 1) ?? 'A',
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  // Author details
  Widget _buildAuthorDetails(Map<String, dynamic> article) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          article['author'] ?? 'Author not available',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        Text(
          article['readTime'] ?? '0 min read',
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }

  // Article content with optional links
  Widget _buildContent(Map<String, dynamic> article) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          article['content'] ?? 'No content available',
          style: const TextStyle(fontSize: 16, height: 1.6),
        ),
        if (article['links'] != null && (article['links'] as List).isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildLinks(article),
        ],
      ],
    );
  }

  // Links section
  Widget _buildLinks(Map<String, dynamic> article) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Links:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ..._buildLinksList(article),
      ],
    );
  }

  // Build list of links
  List<Widget> _buildLinksList(Map<String, dynamic> article) {
    return (article['links'] as List<String>?)?.map((link) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: _buildLinkItem(link),
      );
    }).toList() ?? [];
  }

  // Individual link item
  Widget _buildLinkItem(String link) {
    return InkWell(
      onTap: () => _launchUrl(link),
      child: Text(
        link,
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  // URL launcher
  Future<void> _launchUrl(String link) async {
    if (await canLaunch(link)) {
      await launch(link);
    }
  }

  // Tags section
  Widget _buildTagsSection() {
    List<String> tags = ['Kesehatan', 'Tips', 'Lifestyle'];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: tags.map((tag) => _buildTagChip(tag)).toList(),
    );
  }

  // Individual tag chip
  Widget _buildTagChip(String tag) {
    return Chip(
      label: Text(tag),
      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
      labelStyle: TextStyle(color: Theme.of(context).primaryColor),
    );
  }

  // Related articles section
  Widget _buildRelatedArticles() {
  return FutureBuilder<List<Map<String, dynamic>>>(
    future: GetArticles.fetchRelatedArticles(widget.articleId), // Memuat artikel terkait
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator()); // Loading indicator
      }

      if (snapshot.hasError) {
        return _buildErrorState('Failed to load related articles');
      }

      if (!snapshot.hasData || snapshot.data!.isEmpty) {
        return const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No related articles found'),
        );
      }

      final relatedArticles = snapshot.data!;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Artikel Terkait',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildRelatedArticlesList(relatedArticles),
        ],
      );
    },
  );
}

  // Related articles horizontal list
Widget _buildRelatedArticlesList(List<Map<String, dynamic>> relatedArticles) {
  return SizedBox(
    height: 200,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: relatedArticles.length,
      itemBuilder: (context, index) {
        final article = relatedArticles[index];
        return _buildRelatedArticleCard(article);
      },
    ),
  );
}

  // Individual related article card
 Widget _buildRelatedArticleCard(Map<String, dynamic> article) {
  return Card(
    child: SizedBox(
      width: 160,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CachedNetworkImage(
            imageUrl: article['imageUrl'] ?? '', 
            width: 160,
            height: 120,
            fit: BoxFit.cover,
            placeholder: (context, url) => _buildImagePlaceholder(),
            errorWidget: (context, url, error) => _buildErrorImage(),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              article['title'] ?? 'No title', 
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    ),
  );
}

  // Floating action buttons
  Widget _buildFloatingActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'share',
            onPressed: () {
              Share.share('Check out this article!');
            },
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            child: const Icon(Icons.share),
          ),
          const SizedBox(width: 16),
          FloatingActionButton(
            heroTag: 'bookmark',
            onPressed: () async {
              setState(() {
                _isBookmarked = !_isBookmarked;
              });
              await _saveStates();
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _isBookmarked 
                      ? 'Artikel berhasil ditambahkan ke bookmark' 
                      : 'Artikel dihapus dari bookmark',
                  ),
                  backgroundColor: _isBookmarked ? Colors.green : Colors.red,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            backgroundColor: _isBookmarked ? Colors.green : Colors.white,
            foregroundColor: _isBookmarked ? Colors.white : Colors.black,
            child: Icon(
              _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
            ),
          ),
        ],
      ),
    );
  }

  // Share button
  Widget _buildShareButton() {
    return FloatingActionButton(
      heroTag: 'share',
      onPressed: () {
        Share.share('Check out this article!');
      },
      child: const Icon(Icons.share),
    );
  }

  // Bookmark button
  Widget _buildBookmarkButton() {
    return FloatingActionButton(
      heroTag: 'bookmark',
      onPressed: () {
        setState(() {
          _isBookmarked = !_isBookmarked;
        });
      },
      child: Icon(
        _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
      ),
    );
  }
}