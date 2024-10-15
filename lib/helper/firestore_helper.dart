import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

import '../model/prodect_model.dart';

class FirestoreDatabaseHelper {
  final CollectionReference productCollection =
      FirebaseFirestore.instance.collection('products');
  final Logger logger = Logger();

  Future<void> addProduct(Product product) async {
    try {
      await productCollection.add(product.toMapFirestore());
      logger.i('Product "${product.name}" added successfully to Firestore');
    } catch (e) {
      logger.e('Failed to add product "${product.name}" to Firestore: $e');
    }
  }

  Stream<List<Product>> getProductsStream() {
    logger.i('Listening to product stream from Firestore');
    return productCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Product.fromFirestore(doc);
      }).toList();
    });
  }

  Future<void> updateProduct(String id, Product product) async {
    try {
      await productCollection.doc(id).update(product.toMapFirestore());
      logger.i('Product "${product.name}" updated successfully in Firestore');
    } catch (e) {
      logger.e('Failed to update product "${product.name}" in Firestore: $e');
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await productCollection.doc(id).delete();
      logger.i('Product with ID $id deleted successfully from Firestore');
    } catch (e) {
      logger.e('Failed to delete product with ID $id from Firestore: $e');
    }
  }
}
