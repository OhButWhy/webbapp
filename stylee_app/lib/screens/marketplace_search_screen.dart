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
  String? _source;
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
      _source = null;
    });

    try {
      print('[MarketplaceSearch] Starting search with: imageUrl=${widget.imageUrl}, queryHint=${widget.queryHint}');
      
      final response = await _backend.searchMarketplaceByImage(
        imageUrl: widget.imageUrl,
        imagePath: widget.imagePath,
        query: widget.queryHint,
      );

      final results = response['results'] as List<Map<String, dynamic>>? ?? [];
      final source = response['source'] as String? ?? 'unknown';
      
      print('[MarketplaceSearch] Response source: $source, results count: ${results.length}');
      
      final parsed = results
          .map(MarketplaceResult.fromMap)
          .where((item) => item.url.isNotEmpty)
          .take(10)
          .toList();

      print('[MarketplaceSearch] Parsed results: ${parsed.length}');
      if (parsed.isNotEmpty) {
        print('[MarketplaceSearch] First result: ${parsed.first.title}');
      }

      if (!mounted) return;
      setState(() {
        _results = parsed;
        _source = source;
        _isLoading = false;
      });
    } catch (e) {
      print('[MarketplaceSearch] Error: $e');
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

  Widget _buildLeading(MarketplaceResult item) {
    final thumb = item.thumbnail;
    if (thumb != null && thumb.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          thumb,
          width: 46,
          height: 46,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const CircleAvatar(
            backgroundColor: Color(0xFFE91E63),
            child: Text(
              'M',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      );
    }
    return const CircleAvatar(
      backgroundColor: Color(0xFFE91E63),
      child: Text(
        'M',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Marketplace Search'),
            if (_source != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _source == 'real' ? Colors.green : Colors.orange,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _source!,
                  style: const TextStyle(fontSize: 11, color: Colors.white),
                ),
              ),
            ],
          ],
        ),
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
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Нет результатов поиска'),
            if (_source != null) ...[
              const SizedBox(height: 8),
              Text('Source: $_source', style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ],
        ),
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
            leading: _buildLeading(item),
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
