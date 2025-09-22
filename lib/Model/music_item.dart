class MusicItem {
  final String id;
  final String title;
  final String artist;
  final String fileUrl;
  final int duration;
  final String imageUrl;
  final CategoryType categoryType;
  final Category category;

  MusicItem({
    required this.id,
    required this.title,
    required this.artist,
    required this.fileUrl,
    required this.duration,
    required this.imageUrl,
    required this.categoryType,
    required this.category,
  });

  // Convert JSON response into MusicItem object
  factory MusicItem.fromJson(Map<String, dynamic> json) {
    return MusicItem(
      id: json["_id"],
      title: json["title"],
      artist: json["artist"] ?? "Unknown Artist",
      fileUrl: json["fileUrl"] ?? "",
      duration: json["duration"] ?? 0,
      imageUrl: json["thumbnailUrl"] ?? "",
      categoryType: CategoryType.fromJson(json["categoryType"] ?? {}),
      category: Category.fromJson(json["category"] ?? {}),
    );
  }
}

class Category {
  final String id;
  final String name;
  final String description;

  Category({
    required this.id,
    required this.name,
    required this.description,
  });

  // Convert JSON response into Category object
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json["_id"] ?? "",
      name: json["name"] ?? "",
      description: json["description"] ?? "",
    );
  }
}

class CategoryType {
  final String id;
  final String name;
  final String description;

  CategoryType({
    required this.id,
    required this.name,
    required this.description,
  });

  // Convert JSON response into Category object
  factory CategoryType.fromJson(Map<String, dynamic> json) {
    return CategoryType(
      id: json["_id"] ?? "",
      name: json["name"] ?? "",
      description: json["description"] ?? "",
    );
  }
}
