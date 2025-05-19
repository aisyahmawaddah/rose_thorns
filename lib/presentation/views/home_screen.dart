import 'package:flutter/material.dart';
import 'add_item_screen.dart';
import 'order_screen.dart';

class ItemListPage extends StatelessWidget {
  const ItemListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5F6FF),
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            _buildHeader(),
            
            // Action Buttons Section
            _buildActionButtons(context),
            
            // Category Section
            _buildCategorySection(),
            
            // Items Grid
            Expanded(
              child: _buildItemsGrid(),
            ),
            
            // Bottom Navigation
            _buildBottomNavigation(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          // Menu Icon
          Icon(
            Icons.menu,
            color: Color(0xFF473173),
            size: 28,
          ),
          SizedBox(width: 16),
          
          // Personalized Greeting with Username
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hi, Izzati!',
                style: TextStyle(
                  color: Color(0xFF473173),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
              Text(
                'What do you want to sell today?',
                style: TextStyle(
                  color: Color(0xFF473173),
                  fontSize: 12,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
          
          Spacer(),
          
          // Profile Avatar
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.person,
              size: 30,
              color: Color(0xFF8A56AC),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: [
          // Add Item Button
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddItemScreen()),
                );
              },
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Click here\nto add item',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFAF5DC2),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Order History Button
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const OrderHistoryScreen()),
                );
              },
              icon: const Icon(Icons.history, color: Colors.white),
              label: const Text(
                'View Order\nHistory',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8A56AC),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection() {
    final categories = [
      {'name': 'Clothes', 'icon': Icons.checkroom},
      {'name': 'Cosmetics', 'icon': Icons.face},
      {'name': 'Shoes', 'icon': Icons.hiking},
      {'name': 'Electronics', 'icon': Icons.devices},
      {'name': 'Food', 'icon': Icons.restaurant},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            'Category',
            style: TextStyle(
              color: Color(0xFF473173),
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
        ),
        SizedBox(
          height: 70,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: categories.map((category) {
              return Column(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: const Color(0xFFF9E7FF),
                    child: Icon(
                      category['icon'] as IconData,
                      color: const Color(0xFF8A56AC),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    category['name'] as String,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF473173),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildItemsGrid() {
    final items = [
      {
        'name': 'Zara Trench Coat',
        'status': 'Lightly used',
        'price': 'RM 30.00',
        'seller': 'uzziefern',
        'icon': Icons.checkroom, // IconData
      },
      {
        'name': 'Astrid McStella Sweater',
        'status': 'Lightly used',
        'price': 'RM 10.00',
        'seller': 'uzziefern',
        'icon': Icons.style, // IconData
      },
      {
        'name': 'AI Textbook',
        'status': 'Lightly used',
        'price': 'RM 25.00',
        'seller': 'uzziefern',
        'icon': Icons.menu_book, // IconData
      },
      {
        'name': 'iPad 3rd Generation',
        'status': 'Lightly used',
        'price': 'RM 450.00',
        'seller': 'uzziefern',
        'icon': Icons.tablet, // IconData
      },
    ];

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Item Image or Icon
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Container(
                    width: double.infinity,
                    color: index % 4 == 0
                        ? const Color(0xFFE8DCCA)
                        : index % 4 == 1
                            ? const Color(0xFF6B94B3)
                            : index % 4 == 2
                                ? const Color(0xFF98D973)
                                : const Color(0xFF808080),
                    child: Center(
                      child: Icon(
                        item['icon'] as IconData, // Explicitly cast as IconData
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),

              // Item Details
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item['name'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Color(0xFF473173),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      item['status'] as String,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['price'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Color(0xFFFF80AB),
                      ),
                    ),
                    Row(
                      children: [
                        // Seller Icon
                        const CircleAvatar(
                          radius: 10,
                          backgroundColor: Color(0xFFF9E7FF),
                          child: Icon(
                            Icons.person,
                            size: 12,
                            color: Color(0xFF8A56AC),
                          ),
                        ),
                        const SizedBox(width: 4),
                        // Seller Name
                        Text(
                          item['seller'] as String,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        ),
                        const Spacer(),
                        // Edit Icon
                        GestureDetector(
                          onTap: () {},
                          child: const Icon(
                            Icons.edit,
                            size: 16,
                            color: Color(0xFF8A56AC),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Delete Icon
                        GestureDetector(
                          onTap: () {},
                          child: const Icon(
                            Icons.delete,
                            size: 16,
                            color: Color(0xFF8A56AC),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomNavigation(BuildContext context) {
    return Container(
      height: 60,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home, 'Home', true),
          _buildNavItem(Icons.bookmark_border, 'Wishlist', false),
          _buildSellButton(context),
          _buildNavItem(Icons.notifications_none, 'Updates', false),
          _buildNavItem(Icons.person_outline, 'Profile', false),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isSelected) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: isSelected ? const Color(0xFF8A56AC) : Colors.grey,
          size: 24,
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isSelected ? const Color(0xFF8A56AC) : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildSellButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddItemScreen()),
        );
      },
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: const Color(0xFF8A56AC),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF8A56AC).withOpacity(0.4),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }
}

// Main App
class PrelovedApp extends StatelessWidget {
  const PrelovedApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Preloved App',
      theme: ThemeData(
        primaryColor: const Color(0xFF8A56AC),
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: const Color(0xFFE5F6FF),
      ),
      home: const ItemListPage(),
    );
  }
}

void main() {
  runApp(const PrelovedApp());
}