class MarketplaceResult {
  final String title;
  final String marketplace;
  final String url;

  const MarketplaceResult({
    required this.title,
    required this.marketplace,
    required this.url,
  });

  factory MarketplaceResult.fromMap(Map<String, dynamic> map) {
    return MarketplaceResult(
      title: map['title']?.toString() ?? 'Без названия',
      marketplace: map['marketplace']?.toString() ?? 'Marketplace',
      url: map['url']?.toString() ?? '',
    );
  }
}
