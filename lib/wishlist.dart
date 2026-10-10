// lib/wishlist.dart

import 'package:flutter/material.dart';
import 'homepage.dart'; // for navigation back

/// Global in-memory wishlist
List<Map<String, String>> globalWishlist = [];

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;
  bool _gridView = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Widget _buildWishlistContent() {
    if (_gridView) {
      return GridView.builder(
        key: const ValueKey("wishlistGrid"),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.2,
        ),
        itemCount: globalWishlist.length,
        itemBuilder: (ctx, i) {
          final item = globalWishlist[i];
          return Semantics(
            label: 'Wishlist item: ${item['name']}, ${item['address']}',
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  final combined = '${item['name']}, ${item['address']}';
                  Navigator.pop(context, combined);
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.favorite, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              item['name']!,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item['address']!,
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.grey),
                          onPressed: () {
                            setState(() {
                              globalWishlist.removeAt(i);
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    }
    // List view fallback
    return ListView.builder(
      key: const ValueKey("wishlistExists"),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      itemCount: globalWishlist.length,
      itemBuilder: (ctx, i) {
        final item = globalWishlist[i];
        return Semantics(
          label: 'Wishlist item: ${item['name']}, ${item['address']}',
          child: Card(
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: const Icon(Icons.favorite, color: Colors.red),
              title: Text(item['name']!),
              subtitle: Text(item['address']!),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.grey),
                onPressed: () {
                  setState(() {
                    globalWishlist.removeAt(i);
                  });
                },
              ),
              onTap: () {
                // Return "name, address" back to Homepage
                final combined = '${item['name']}, ${item['address']}';
                Navigator.pop(context, combined);
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyWishlistView() {
    return Center(
      key: const ValueKey("emptyWishlist"),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/empty_wishlist.png',
              height: 150,
              width: 150,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.favorite_border, color: Colors.grey, size: 100),
            ),
            const SizedBox(height: 24),
            const Text(
              "Your wishlist is empty",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Add items you love to your wishlist\nfor quick access anytime.",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const Homepage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child:
                  const Text("Browse Items", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasItems = globalWishlist.isNotEmpty;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Wishlist"),
        backgroundColor: Colors.blue,
        actions: [
          if (hasItems)
            IconButton(
              icon: Icon(_gridView ? Icons.view_list : Icons.grid_view),
              tooltip: _gridView ? 'Switch to list view' : 'Switch to grid view',
              onPressed: () {
                setState(() => _gridView = !_gridView);
              },
            ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: hasItems
              ? Column(
                  children: [
                    Divider(thickness: 1.2, color: Colors.blue.withOpacity(0.2)),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text('Your Wishlist', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(child: _buildWishlistContent()),
                  ],
                )
              : _buildEmptyWishlistView(),
        ),
      ),
    );
  }
}
