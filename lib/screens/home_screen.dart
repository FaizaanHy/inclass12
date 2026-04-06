import 'package:flutter/material.dart';
import '../models/item.dart';
import '../services/firestore_service.dart';
import '../widgets/item_form.dart';

class HomeScreen extends StatelessWidget {
  final FirestoreService service = FirestoreService();

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Inventory App"),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ItemForm(
                    onSubmit: (item) => service.addItem(item),
                  ),
                ),
              );
            },
          ),
        ],
      ),

      body: StreamBuilder<List<Item>>(
        stream: service.streamItems(),
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final items = snapshot.data ?? [];

          if (items.isEmpty) {
            return Center(child: Text("No items yet"));
          }

          // ⭐ Enhancement 1: Total Inventory Value
          double totalValue = items.fold(
            0,
            (sum, item) => sum + (item.price * item.quantity),
          );

          return Column(
            children: [

              // ⭐ Display total value
              Padding(
                padding: EdgeInsets.all(10),
                child: Text(
                  "Total Value: \$${totalValue.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];

                    return ListTile(
                      title: Text(item.name),
                      subtitle: Text(
                        "Qty: ${item.quantity} | \$${item.price.toStringAsFixed(2)}",
                      ),

                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [

                          // ✏️ EDIT BUTTON
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ItemForm(
                                    existingItem: item,
                                    onSubmit: (updatedItem) =>
                                        service.updateItem(updatedItem),
                                  ),
                                ),
                              );
                            },
                          ),

                          // 🗑️ DELETE BUTTON WITH CONFIRMATION
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text("Confirm Delete"),
                                  content: Text(
                                      "Are you sure you want to delete this item?"),
                                  actions: [
                                    TextButton(
                                      child: Text("Cancel"),
                                      onPressed: () =>
                                          Navigator.pop(context),
                                    ),
                                    TextButton(
                                      child: Text("Delete"),
                                      onPressed: () {
                                        service.deleteItem(item.id);
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}