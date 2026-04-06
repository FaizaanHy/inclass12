import 'package:flutter/material.dart';
import '../models/item.dart';

class ItemForm extends StatefulWidget {
  final Function(Item) onSubmit;
  final Item? existingItem;

  const ItemForm({
    super.key,
    required this.onSubmit,
    this.existingItem,
  });

  @override
  State<ItemForm> createState() => _ItemFormState();
}

class _ItemFormState extends State<ItemForm> {
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();

  String? error;

  @override
  void initState() {
    super.initState();

    if (widget.existingItem != null) {
      _nameController.text = widget.existingItem!.name;
      _quantityController.text =
          widget.existingItem!.quantity.toString();
      _priceController.text =
          widget.existingItem!.price.toString();
    }
  }

  void submit() {
    final name = _nameController.text.trim();
    final quantity = int.tryParse(_quantityController.text);
    final price = double.tryParse(_priceController.text);

    if (name.isEmpty) {
      setState(() => error = "Name cannot be empty");
      return;
    }

    if (quantity == null) {
      setState(() => error = "Quantity must be a number");
      return;
    }

    if (price == null) {
      setState(() => error = "Price must be valid");
      return;
    }

    final item = Item(
      id: widget.existingItem?.id ?? '',
      name: name,
      quantity: quantity,
      price: price,
    );

    widget.onSubmit(item);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingItem == null
            ? "Add Item"
            : "Edit Item"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(labelText: "Name"),
          ),
          TextField(
            controller: _quantityController,
            decoration: InputDecoration(labelText: "Quantity"),
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: _priceController,
            decoration: InputDecoration(labelText: "Price"),
            keyboardType: TextInputType.number,
          ),
          if (error != null)
            Text(error!, style: TextStyle(color: Colors.red)),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: submit,
            child: Text(widget.existingItem == null ? "Add" : "Update"),
          ),
        ],
      ),
      ),
    );
  }
}