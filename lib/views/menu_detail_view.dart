import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mafatiuljinah_poc/utils/colors.dart';
import '../controllers/category_list_controller.dart';
import 'category_list_view.dart';

class MenuDetailView extends StatelessWidget {
  final String menuItem;

  const MenuDetailView({super.key, required this.menuItem});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CategoryListController());

    if (controller.categoryData.isEmpty) {
      controller.fetchCategoryData(menuItem);
    }

    Future<void> refreshCategoryData() async {
      await controller.fetchCategoryData(menuItem);
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: AppColors.backgroundColor,
        title: Text(
          menuItem,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        } else if (controller.categoryData.isEmpty) {
          return const Center(child: Text("No categories available",style: TextStyle(color: Colors.white),));
        } else {
          return RefreshIndicator(
            onRefresh: refreshCategoryData,
            child: SingleChildScrollView(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: controller.categoryData.keys
                      .map((categoryName) => Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 5.0, horizontal: 16.0),
                    child: GestureDetector(
                      onTap: () {
                        log("Selected category: $categoryName");
                        Get.to(
                              () => CategoryListView(
                            categoryItems: controller
                                .categoryData[categoryName]!,
                            argument: categoryName,
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xffddf4f8),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              offset: const Offset(0, 4),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 20),
                        child: Center(
                          child: Text(
                            categoryName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),
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
