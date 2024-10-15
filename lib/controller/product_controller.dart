import '../helper/database_helper.dart';
import '../model/prodect_model.dart';

class ProductController {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<List<Product>> fetchProducts() async {
    return await _dbHelper.getProducts();
  }

  Future<void> addProduct(Product product) async {
    await _dbHelper.addProduct(product);
  }

  Future<void> updateProduct(Product product) async {
    await _dbHelper.updateProduct(product);
  }

  Future<void> deleteProduct(int id) async {
    await _dbHelper.deleteProduct(id);
  }
}
