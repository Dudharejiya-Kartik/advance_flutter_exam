import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../../controller/product_controller.dart';
import '../../helper/firestore_helper.dart';
import '../../model/prodect_model.dart';
import '../firestore_product/firestore_add_product.dart';
import '../product_dialoge_page/product_dialogue.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final ProductController productController = ProductController();
  final FirestoreDatabaseHelper firestoreDatabaseHelper =
      FirestoreDatabaseHelper();
  List<Product> products = [];
  Logger logger = Logger();
  late AnimationController controller;
  late Animation<double> animation;

  final List<Color> tileColors = [
    Colors.blue.shade100,
    Colors.green.shade100,
    Colors.orange.shade100,
    Colors.purple.shade100,
    Colors.pink.shade100,
    Colors.teal.shade100,
  ];

  @override
  void initState() {
    super.initState();
    fetchProducts();

    controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    animation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeInOut),
    );

    logger.i('Home Page Initialized');
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void fetchProducts() async {
    products = await productController.fetchProducts();
    logger.i(products);
    setState(() {});
  }

  void showProductDialog([Product? product]) async {
    Product? newProduct = await showDialog(
      context: context,
      builder: (context) => ProductDialog(product: product),
    );

    if (newProduct != null) {
      if (product == null) {
        await productController.addProduct(newProduct);
        await firestoreDatabaseHelper.addProduct(newProduct);
      } else {
        newProduct.id = product.id;
        await productController.updateProduct(newProduct);
        await firestoreDatabaseHelper.updateProduct(
            product.id.toString(), newProduct);
      }
      fetchProducts();
    }
  }

  void confirmDeleteProduct(int id) async {
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
      await productController.deleteProduct(id);
      await firestoreDatabaseHelper.deleteProduct(id.toString());
      fetchProducts();
    }
  }

  void navigateToProductPage(Product product) async {
    await firestoreDatabaseHelper.addProduct(product);
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => FirestoreProductCollectionPage(product: product),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Auction App'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.storage),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const FirestoreProductCollectionPage(),
              ));
            },
          ),
        ],
      ),
      body: products.isEmpty
          ? Center(
              child: FadeTransition(
                opacity: animation,
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.hourglass_empty,
                      size: 100,
                      color: Colors.blue,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'No Products Available',
                      style: TextStyle(fontSize: 18, color: Colors.blueGrey),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                Color tileColor = tileColors[index % tileColors.length];

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: GestureDetector(
                    onTap: () => navigateToProductPage(product),
                    child: ListTile(
                      tileColor: tileColor,
                      title: Text(product.name),
                      subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => showProductDialog(product),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => confirmDeleteProduct(product.id!),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showProductDialog(),
        tooltip: 'Add Product',
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
