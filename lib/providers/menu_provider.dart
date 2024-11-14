import 'package:dio/dio.dart';
import '../modals/menu_list.dart';
import '../utils/constants.dart';

class MenuService {
  final Dio _dio;

  MenuService(String token)
      : _dio = Dio(
          BaseOptions(
            baseUrl: ApiConstants.baseUrl,
            // connectTimeout: const Duration(milliseconds: 15000),
            // receiveTimeout: const Duration(milliseconds: 3000),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          ),
        );

  Future<MenuList> fetchMenuList() async {
    final response = await _dio.get(ApiConstants.menuEndpoint);

    if (response.statusCode == 200) {
      return MenuList.fromJson(response.data);
    } else {
      throw Exception('Failed to fetch menu list');
    }
  }
}
