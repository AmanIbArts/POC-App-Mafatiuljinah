import 'package:get/state_manager.dart';
import 'dart:developer';

import '../modals/menu_list.dart';
import '../providers/database/db_helper.dart';  // Import database helper
import '../providers/menu_provider.dart';
import '../utils/constants.dart';

class MenuListController extends GetxController {
  var menuList = MenuList(items: []).obs;
  var isLoading = true.obs;

  final MenuService _menuService = MenuService(ApiConstants.token);

  @override
  void onInit() {
    super.onInit();
    fetchMenuItems();
  }

  // Fetch the menu items and store in `menuList`
  void fetchMenuItems() async {
    try {
      isLoading(true);

      // Try fetching from the API
      var fetchedMenuList = await _menuService.fetchMenuList();

      if (fetchedMenuList.items.isNotEmpty) {
        // Save the data to local database if it's not empty
        await DatabaseHelper.saveMenuItems(fetchedMenuList.items);
        menuList.value = fetchedMenuList;
        log("Fetched Menu from API successfully");
      } else {
        // If no data is returned, check the local database
        menuList.value = await DatabaseHelper.fetchMenuItems();
        log("Fetched Menu from local database");
      }
    } catch (e) {
      // Handle error: Try fetching from local database if API call fails
      log("Error fetching menu list: $e");
      menuList.value = await DatabaseHelper.fetchMenuItems();
      log("Fetched Menu from local database due to error");
    } finally {
      isLoading(false);
    }
  }
}
