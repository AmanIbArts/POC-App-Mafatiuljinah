import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mafatiuljinah_poc/views/menu_detail_view.dart';
import 'views/menu_list_view.dart';
import 'views/category_detail_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Menu App',
      initialRoute: '/',
      theme: ThemeData(
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: <TargetPlatform, PageTransitionsBuilder>{
            // Set the predictive back transitions for Android.
            TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
          },
        ),
      ),
      getPages: [
        GetPage(name: '/', page: () => const MenuListView()),
        GetPage(
            name: '/menu-detail',
            page: () => const MenuDetailView(
              menuItem: '',
            )),
        GetPage(
            name: '/category-detail', page: () => const CategoryDetailView()),
      ],
    );
  }
}
