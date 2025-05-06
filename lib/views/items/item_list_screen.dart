
import 'package:flutter/material.dart';

class ItemListScreen extends StatelessWidget {
  const ItemListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Koopon Items')),
      body: ListView(
        children: List.generate(5, (index) => ListTile(title: Text('Item \$index'))),
      ),
    );
  }
}
