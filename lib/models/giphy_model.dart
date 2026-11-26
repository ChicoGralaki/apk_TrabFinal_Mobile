class GiphyGif {
  const GiphyGif({required this.url});

  final String url;

  factory GiphyGif.fromJson(Map<String, dynamic> json) {
    final images = json['images'];
    if (images is! Map) throw const FormatException('GIF sem renditions.');
    final fixed = images['fixed_height'];
    final small = images['fixed_height_small'];
    final original = images['downsized_medium'];
    final url =
        _renditionUrl(fixed) ?? _renditionUrl(small) ?? _renditionUrl(original);
    if (url == null) throw const FormatException('GIF sem URL válida.');
    return GiphyGif(url: url);
  }
}

String? _renditionUrl(dynamic rendition) {
  if (rendition is! Map) return null;
  final url = rendition['url'];
  if (url is! String || !url.startsWith('http')) return null;
  return url;
}
