class MenuList {
  final List<String> items;

  MenuList({required this.items});

  factory MenuList.fromJson(Map<String, dynamic> json) {
    return MenuList(
      items: List<String>.from(json['data']),
    );
  }
}
