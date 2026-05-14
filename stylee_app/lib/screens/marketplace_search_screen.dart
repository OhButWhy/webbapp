import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stylee_app/models/marketplace_result.dart';
import 'package:stylee_app/services/backend_api_service.dart';

class MarketplaceSearchScreen extends StatefulWidget {
  final String? imageUrl;
  final String? imagePath;
  final String? queryHint;

  const MarketplaceSearchScreen({
    super.key,
    this.imageUrl,
    this.imagePath,
    this.queryHint,
  });

  @override
  State<MarketplaceSearchScreen> createState() => _MarketplaceSearchScreenState();
}

class _MarketplaceSearchScreenState extends State<MarketplaceSearchScreen> {
  final _backend = BackendApiService.instance;

  bool _isLoading = true;
  String? _error;
  List<MarketplaceResult> _results = const [];

  @override
  void initState() {
    super.initState();
    _runSearch();
  }

  Future<void> _runSearch() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _backend.searchMarketplaceByImage(
        imageUrl: widget.imageUrl,
        imagePath: widget.imagePath,
        query: widget.queryHint,
      );

      final parsed = response
          .map(MarketplaceResult.fromMap)
          .where((item) => item.url.isNotEmpty)
          .take(10)
          .toList();

      if (!mounted) return;
      setState(() {
        _results = parsed;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Не удалось получить результаты: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _copyUrl(String url) async {
    await Clipboard.setData(ClipboardData(text: url));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ссылка скопирована')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Marketplace Search'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 14),
            Text('Ищем товары...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _error!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _runSearch,
                child: const Text('Повторить'),
              ),
            ],
          ),
        ),
      );
    }

    if (_results.isEmpty) {
      return const Center(
        child: Text('Нет результатов поиска'),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      itemCount: _results.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = _results[index];
        return Card(
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0xFFE91E63),
              child: Text(
                'M',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(item.title),
            subtitle: Text('${item.marketplace}\n${item.url}'),
            isThreeLine: true,
            trailing: IconButton(
              icon: const Icon(Icons.copy_all_outlined),
              tooltip: 'Скопировать ссылку',
              onPressed: () => _copyUrl(item.url),
            ),
            onTap: () => _copyUrl(item.url),
          ),
        );
      },
    );
  }
}
