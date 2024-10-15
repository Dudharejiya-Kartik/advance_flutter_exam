import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  int? id;
  String? firestoreId;
  String name;
  double price;

  Product({this.id, this.firestoreId, required this.name, required this.price});

  Map<String, dynamic> toMapSQLite() {
    return {
      'id': id,
      'name': name,
      'price': price,
    };
  }

  factory Product.fromSQLite(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      price: map['price'],
    );
  }

  Map<String, dynamic> toMapFirestore() {
    return {
      'name': name,
      'price': price,
    };
  }

  factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Product(
      firestoreId: doc.id, // Use Firestore document ID
      name: data['name'],
      price: data['price'],
    );
  }
}
