import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../modals/menu_list.dart';

class DatabaseHelper {
  static Database? _database;

  // Singleton pattern for the database
  static Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  // Initialize the database
  static Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'menu_items.db');
    return openDatabase(
      path,
      onCreate: (db, version) async {
        await db.execute(''' 
          CREATE TABLE menu_items(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT
          )
        ''');
      },
      version: 1,
    );
  }

  // Save menu items to the database, ensuring no duplicates
  static Future<void> saveMenuItems(List<String> menuItems) async {
    final db = await database;

    // Clear the table before inserting new data to prevent duplicates
    await db.delete('menu_items');

    // Insert new menu items into the database
    for (var item in menuItems) {
      await db.insert('menu_items', {'name': item},
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }


  // Fetch menu items from the database
  static Future<MenuList> fetchMenuItems() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('menu_items');
    List<String> items = List.generate(maps.length, (i) {
      return maps[i]['name'] as String;
    });

    return MenuList(items: items);
  }

  // Clear the menu items table
  static Future<void> clearMenuItems() async {
    final db = await database;
    await db.delete('menu_items');
  }
}
