class MarketplaceResult {
  final String title;
  final String marketplace;
  final String url;
  final String? thumbnail;

  const MarketplaceResult({
    required this.title,
    required this.marketplace,
    required this.url,
    this.thumbnail,
  });

  factory MarketplaceResult.fromMap(Map<String, dynamic> map) {
    return MarketplaceResult(
      title: map['title']?.toString() ?? 'Без названия',
      marketplace: map['marketplace']?.toString() ?? 'Marketplace',
      url: map['url']?.toString() ?? '',
      thumbnail: map['thumbnail']?.toString(),
    );
  }
}
