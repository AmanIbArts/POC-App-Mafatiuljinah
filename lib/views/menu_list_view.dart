import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mafatiuljinah_poc/utils/colors.dart';

import '../controllers/menu_list_controller.dart';
import 'menu_detail_view.dart';

class MenuListView extends StatelessWidget {
  const MenuListView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MenuListController());

    Future<void> refreshMenuItems() async {
      // Call the controller method to fetch the menu list again
      controller.fetchMenuItems();
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        title: const Text("Main Menu",
        style: TextStyle(color: Colors.white),),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(
            color: Colors.white,
          ));
        } else if (controller.menuList.value.items.isEmpty) {
          return const Center(child: Text("No menu items available",style: TextStyle(color: Colors.white),));
        } else {
          return RefreshIndicator(
            onRefresh: refreshMenuItems,
            child: SingleChildScrollView(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: controller.menuList.value.items
                      .map((menuItem) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        title: Center(
                          child: Text(
                            menuItem,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        onTap: () {
                          log("selected ----> $menuItem");
                          Get.to(() => MenuDetailView(menuItem: menuItem));
                        },
                      ),
                    ),
                  ))
                      .toList(),
                ),
              ),
            ),
          );
        }
      }),
    );
  }
}
