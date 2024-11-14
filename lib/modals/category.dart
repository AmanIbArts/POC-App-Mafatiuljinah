
import 'content_data.dart';

class Category {
  final String category;
  final int id;
  final String title;
  final String isFav;
  final List<ContentData> cdata;

  Category({
    required this.category,
    required this.id,
    required this.title,
    required this.isFav,
    required this.cdata,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      category: json['cat'] ?? '',
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      isFav: json['isfav'] ?? 'No',
      cdata: json['cdata'] != null
          ? (json['cdata'] as List)
              .map((data) => ContentData.fromJson(data))
              .toList()
          : [], // Return an empty list if "cdata" is null
    );
  }
}
