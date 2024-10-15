import 'package:logger/logger.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../model/prodect_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? database;
  Logger logger = Logger();

  DatabaseHelper._internal();

  factory DatabaseHelper() {
    return instance;
  }

  Future<Database> getDatabase() async {
    if (database != null) return database!;
    database = await _initDatabase();
    logger.i('Database initialized');
    return database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'products.db');
    logger.i("Initializing database at $path");
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE products(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            price REAL
          )
        ''');
        logger.i('Table Created');
      },
    );
  }

  Future<int> addProduct(Product product) async {
    final db = await getDatabase();
    logger.i("Adding product: ${product.name}");
    int result = await db.insert('products', product.toMapSQLite());
    logger.i('Product added with ID: $result');
    return result;
  }

  Future<List<Product>> getProducts() async {
    final db = await getDatabase();
    logger.i("Retrieving products");
    var result = await db.query('products');
    List<Product> products =
        result.map((product) => Product.fromSQLite(product)).toList();
    logger.i('Retrieved ${products.length} products');
    return products;
  }

  Future<int> updateProduct(Product product) async {
    final db = await getDatabase();
    logger.i("Updating product: ${product.name}");
    int rowsAffected = await db.update(
      'products',
      product.toMapSQLite(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
    logger.i('Updated $rowsAffected rows');
    return rowsAffected;
  }

  Future<int> deleteProduct(int id) async {
    final db = await getDatabase();
    logger.i("Deleting product with ID: $id");
    int rowsDeleted = await db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
    logger.i('Deleted $rowsDeleted rows');
    return rowsDeleted;
  }
}
