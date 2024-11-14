import 'category.dart'; // Assuming this is the file where the Category model is defined.

class CategoryResponse {
  Map<String, List<Category>> categories;

  CategoryResponse({
    required this.categories,
  });

  // Factory method for parsing JSON data
  factory CategoryResponse.fromJson(Map<String, dynamic> json) {
    // Create a temporary Map to store the categories parsed from JSON
    Map<String, List<Category>> tempCategories = {};

    // Loop through each entry in the JSON object
    json.forEach((key, value) {
      if (value is List) {
        // Convert each list item to a Category object using Category.fromJson
        tempCategories[key] =
            value.map((item) => Category.fromJson(item)).toList();
      }
    });

    return CategoryResponse(
      categories: tempCategories,
    );
  }
}
