import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import '../../helper/firestore_helper.dart';
import '../../model/prodect_model.dart';

class FirestoreProductCollectionPage extends StatefulWidget {
  final Product? product;

  const FirestoreProductCollectionPage({super.key, this.product});

  @override
  FirestoreProductCollectionPageState createState() =>
      FirestoreProductCollectionPageState();
}

class FirestoreProductCollectionPageState
    extends State<FirestoreProductCollectionPage> {
  final FirestoreDatabaseHelper firestoreDatabaseHelper =
      FirestoreDatabaseHelper();
  final Logger logger = Logger();

  Stream<List<Product>> fetchFirestoreProducts() {
    return firestoreDatabaseHelper.getProductsStream();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firestore Product Collection'),
        centerTitle: true,
      ),
      body: StreamBuilder<List<Product>>(
        stream: fetchFirestoreProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            logger.e('Error fetching data from Firestore: ${snapshot.error}');
            return const Center(child: Text('Error fetching data'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            logger.w('No products found in Firestore');
            return const Center(child: Text('No products in Firestore'));
          }

          final products = snapshot.data!;
          logger.i('Fetched ${products.length} products from Firestore');

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];

              return ListTile(
                title: Text(product.name),
                subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => confirmDeleteProduct(product),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void confirmDeleteProduct(Product product) async {
    bool? confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to delete this product?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await firestoreDatabaseHelper.deleteProduct(product.id.toString());
      logger.i('Deleted product: ${product.name}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Product "${product.name}" deleted')),
      );
    } else {
      logger.i('Deletion of product "${product.name}" was canceled.');
    }
  }
}
