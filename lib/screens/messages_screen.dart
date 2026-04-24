import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:screen_protector/screen_protector.dart';
import 'package:xml/xml.dart';
import '../core/app_colors.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  bool loading = true;
  String searchText = "";
  List<NewsItem> news = [];

  final List<String> rssUrls = [
  "https://www.aa.com.tr/tr/rss/default?cat=guncel",
  "https://www.aa.com.tr/tr/rss/default?cat=dunya",
  "https://www.aa.com.tr/tr/rss/default?cat=ekonomi",
  "https://www.aa.com.tr/tr/rss/default?cat=spor",
  "https://www.aa.com.tr/tr/rss/default?cat=bilim-teknoloji",
];

  @override
  void initState() {
    super.initState();
    enableProtection();
    fetchAllNews();
  }

  Future<void> enableProtection() async {
    try {
      await ScreenProtector.preventScreenshotOn();
      await ScreenProtector.protectDataLeakageOn();
      await ScreenProtector.protectDataLeakageWithBlur();
    } catch (_) {}
  }

  Future<void> disableProtection() async {
    try {
      await ScreenProtector.preventScreenshotOff();
      await ScreenProtector.protectDataLeakageOff();
      await ScreenProtector.protectDataLeakageWithBlurOff();
    } catch (_) {}
  }

  Future<void> fetchAllNews() async {
    setState(() => loading = true);

    final List<NewsItem> allNews = [];

    for (final url in rssUrls) {
      try {
        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          final document = XmlDocument.parse(response.body);
          final items = document.findAllElements("item");

          for (final item in items) {
            final title = item.getElement("title")?.innerText.trim() ?? "";
            final description =
                item.getElement("description")?.innerText.trim() ?? "";
            final link = item.getElement("link")?.innerText.trim() ?? "";
            final pubDate = item.getElement("pubDate")?.innerText.trim() ?? "";

            String imageUrl = "";

            final enclosure = item.getElement("enclosure");
            if (enclosure != null) {
              imageUrl = enclosure.getAttribute("url") ?? "";
            }

            if (imageUrl.isEmpty) {
              final mediaContent = item.findElements("media:content").firstOrNull;
              if (mediaContent != null) {
                imageUrl = mediaContent.getAttribute("url") ?? "";
              }
            }

            if (title.isNotEmpty) {
              allNews.add(
                NewsItem(
                  title: title,
                  description: description,
                  link: link,
                  imageUrl: imageUrl,
                  date: pubDate,
                ),
              );
            }
          }
        }
      } catch (_) {}
    }

    setState(() {
      news = allNews;
      loading = false;
    });
  }

  List<NewsItem> get filteredNews {
    if (searchText.trim().isEmpty) return news;

    return news.where((item) {
      final q = searchText.toLowerCase();
      return item.title.toLowerCase().contains(q) ||
          item.description.toLowerCase().contains(q);
    }).toList();
  }

  @override
  void dispose() {
    disableProtection();
    super.dispose();
  }

  Widget newsCard(NewsItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.imageUrl.isNotEmpty)
              Image.network(
                item.imageUrl,
                height: 170,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const SizedBox.shrink();
                },
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.lock_rounded,
                        size: 17,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 6),
                      Text(
                        "Gizli Haber Akışı",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    item.title,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.description
                        .replaceAll(RegExp(r'<[^>]*>'), '')
                        .trim(),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.subtitle,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  if (item.date.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      item.date,
                      style: const TextStyle(
                        color: AppColors.subtitle,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final shownNews = filteredNews;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          "Gizli Haberler",
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        centerTitle: true,
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.text,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: fetchAllNews,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 10, 22, 22),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: AppColors.mainGradient,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.security_rounded,
                      color: Colors.white,
                      size: 34,
                    ),
                    SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        "Koruma modu aktif. Haber akışı gizli alanda görüntüleniyor.",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                onChanged: (value) {
                  setState(() {
                    searchText = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: "Haberlerde ara...",
                  prefixIcon: const Icon(Icons.search_rounded),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: loading
                    ? const Center(child: CircularProgressIndicator())
                    : shownNews.isEmpty
                        ? const Center(
                            child: Text(
                              "Haber bulunamadı.",
                              style: TextStyle(
                                color: AppColors.subtitle,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: fetchAllNews,
                            child: ListView.builder(
                              itemCount: shownNews.length,
                              itemBuilder: (context, index) {
                                return newsCard(shownNews[index]);
                              },
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NewsItem {
  final String title;
  final String description;
  final String link;
  final String imageUrl;
  final String date;

  NewsItem({
    required this.title,
    required this.description,
    required this.link,
    required this.imageUrl,
    required this.date,
  });
}