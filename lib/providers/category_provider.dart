import 'dart:developer';
import 'package:dio/dio.dart';


import '../modals/category_response.dart';
import '../utils/constants.dart';

class CategoryProvider {
  final String token;
  final Dio _dio = Dio();
  final String baseurl = ApiConstants.baseUrl;

  CategoryProvider(this.token);

  Future<CategoryResponse> fetchCategoryData(String endpoint) async {
    try {
      final response = await _dio.post(
        '$baseurl$endpoint',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      // Log the full response to check its structure
      // log("API Response: ${response.data}");

      if (response.statusCode == 200) {
        return CategoryResponse.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to fetch data from $endpoint');
      }
    } catch (e) {
      log("Error: $e");
      rethrow; // Propagate the error
    }
  }
}
