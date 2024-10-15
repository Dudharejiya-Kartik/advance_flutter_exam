import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../../model/prodect_model.dart';

class ProductDialog extends StatefulWidget {
  final Product? product;

  const ProductDialog({super.key, this.product});

  @override
  ProductDialogState createState() => ProductDialogState();
}

class ProductDialogState extends State<ProductDialog> {
  final formKey = GlobalKey<FormState>();
  String? name;
  double? price;
  Logger logger = Logger();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.product == null ? 'Add Product' : 'Edit Product'),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              initialValue: widget.product?.name ?? '',
              decoration: const InputDecoration(labelText: 'Product Name'),
              onSaved: (value) => name = value!,
              validator: (value) => value!.isEmpty ? 'Enter a name' : null,
            ),
            TextFormField(
              initialValue: widget.product?.price?.toString() ?? '',
              decoration: const InputDecoration(labelText: 'Product Price'),
              keyboardType: TextInputType.number,
              onSaved: (value) => price = double.tryParse(value!)!,
              validator: (value) => value!.isEmpty ? 'Enter a price' : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (formKey.currentState!.validate()) {
              formKey.currentState!.save();
              Navigator.pop(
                context,
                Product(name: name!, price: price!),
              );
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
