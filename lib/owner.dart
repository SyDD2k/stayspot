import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'user_profile.dart';
import 'login_screen.dart';
import 'addplace.dart';          // Ensure this file defines the AddPlace widget.
import 'manageplace.dart';       // Ensure this file defines the ManagePropertiesScreen widget.
import 'owner_messages_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'main.dart'; // Add this import for ThemeProvider

class OwnerPage extends StatefulWidget {
  const OwnerPage({super.key});

  @override
  State<OwnerPage> createState() => _OwnerPageState();
}

class _OwnerPageState extends State<OwnerPage> with TickerProviderStateMixin {
  late final AnimationController _bodyAnimationController;
  late final Animation<double> _bodyFadeAnimation;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _properties = [];
  List<dynamic> _filteredProperties = [];
  bool _isLoading = true;

  // Define a baseUrl without a trailing slash.
  final String baseUrl = "http://127.0.0.1:8000";

  @override
  void initState() {
    super.initState();

    // Animate the body content on load.
    _bodyAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _bodyFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _bodyAnimationController,
        curve: Curves.easeInOut,
      ),
    );
    _bodyAnimationController.forward();

    // Show the info popup after the first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showInfoPopup();
      _fetchProperties();
    });
  }

  @override
  void dispose() {
    _bodyAnimationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _showInfoPopup() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'InfoPopup',
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Owner Dashboard",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: colorScheme.onSurface),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Welcome to the Owner Dashboard. Here you can manage your property, view bookings, and more.",
                    style: TextStyle(fontSize: 16, color: colorScheme.onSurface.withOpacity(0.7)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text("Got It"),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: animation,
            child: child,
          ),
        );
      },
    );
  }

  void _onMenuItemSelected(String value) {
    switch (value) {
      case 'user':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const UserProfilePage()),
        );
        break;
      case 'add':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddPlace()),
        ).then((_) => _fetchProperties());
        break;
      case 'manage':
        // Navigate to the ManagePropertiesScreen which handles fetching and displaying properties.
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ManagePropertiesScreen()),
        );
        break;
      case 'logout':
        Navigator.pushReplacementNamed(context, '/login');
        break;
      case 'messages':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => OwnerMessagesScreen()),
        );
        break;
      default:
        break;
    }
  }

  Future<void> _fetchProperties() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await http.get(Uri.parse('$baseUrl/properties/'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _properties = data;
          _filteredProperties = data;
          _isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to fetch properties. Code: ${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching properties: $e")),
      );
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _filterProperties(String query) {
    setState(() {
      _filteredProperties = _properties.where((property) {
        final name = property['name']?.toString().toLowerCase() ?? '';
        final address = property['address']?.toString().toLowerCase() ?? '';
        final searchLower = query.toLowerCase();
        return name.contains(searchLower) || address.contains(searchLower);
      }).toList();
    });
  }

  String _getPropertyImageUrl(Map<String, dynamic> property) {
    final images = property['images'];
    String? selectedImage;
    if (images != null && images is List && images.isNotEmpty) {
      final first = images[0];
      if (first is Map && first['image'] != null) {
        selectedImage = first['image'];
      }
    }
    if (selectedImage == null) return 'https://via.placeholder.com/400';
    if (selectedImage.toString().startsWith('http')) return selectedImage;
    if (selectedImage.toString().startsWith('/media/')) {
      return '$baseUrl$selectedImage';
    }
    return '$baseUrl/media/$selectedImage';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final user = FirebaseAuth.instance.currentUser;
    final String? displayName = user?.displayName;
    final String? email = user?.email;

    return Scaffold(
      key: _scaffoldKey,
      endDrawerEnableOpenDragGesture: false,
      endDrawer: Drawer(
        backgroundColor: colorScheme.surface,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: colorScheme.primary,
                  backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
                  child: user?.photoURL == null
                      ? (displayName != null && displayName.isNotEmpty
                          ? Text(
                              displayName[0].toUpperCase(),
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onPrimary,
                              ),
                            )
                          : Icon(Icons.person, size: 28, color: colorScheme.onPrimary))
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName ?? 'User Name',
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email ?? '',
                        style: TextStyle(
                          color: colorScheme.onSurface.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            AnimatedMenuItem(
              icon: Icons.person,
              title: 'User',
              iconColor: colorScheme.primary,
              backgroundColor: colorScheme.primaryContainer,
              onTap: () {
                Navigator.pop(context);
                _onMenuItemSelected('user');
              },
            ),
            AnimatedMenuItem(
              icon: Icons.add_business,
              title: 'Add Place',
              iconColor: colorScheme.secondary,
              backgroundColor: colorScheme.secondaryContainer,
              onTap: () {
                Navigator.pop(context);
                _onMenuItemSelected('add');
              },
            ),
            AnimatedMenuItem(
              icon: Icons.settings,
              title: 'Manage Place',
              iconColor: colorScheme.tertiary,
              backgroundColor: colorScheme.tertiaryContainer,
              onTap: () {
                Navigator.pop(context);
                _onMenuItemSelected('manage');
              },
            ),
            AnimatedMenuItem(
              icon: Icons.message,
              title: 'Messages',
              iconColor: colorScheme.primary,
              backgroundColor: colorScheme.primaryContainer,
              onTap: () {
                Navigator.pop(context);
                _onMenuItemSelected('messages');
              },
            ),
            AnimatedMenuItem(
              icon: Icons.logout,
              title: 'Logout',
              iconColor: colorScheme.error,
              backgroundColor: colorScheme.errorContainer,
              onTap: () {
                Navigator.pop(context);
                _onMenuItemSelected('logout');
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 100,
        backgroundColor: theme.brightness == Brightness.dark ? colorScheme.surface : Colors.blue,
        title: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.surface,
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.home, color: colorScheme.primary, size: 30);
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'StaySpot',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        actions: [
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) => IconButton(
              icon: Icon(
                themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                color: colorScheme.onSurface,
              ),
              tooltip: themeProvider.isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
              onPressed: () {
                themeProvider.toggleTheme();
              },
            ),
          ),
          IconButton(
            icon: Icon(Icons.menu, color: colorScheme.onSurface),
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UserProfilePage()),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: CircleAvatar(
                radius: 24,
                backgroundColor: colorScheme.surface,
                backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
                child: user?.photoURL == null
                    ? (displayName != null && displayName.isNotEmpty
                        ? Text(
                            displayName[0].toUpperCase(),
                            style: TextStyle(
                              fontSize: 24,
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : Icon(Icons.account_circle, size: 28, color: colorScheme.primary))
                    : null,
              ),
            ),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _bodyFadeAnimation,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceVariant,
                  border: Border.all(color: colorScheme.primary, width: 1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, color: colorScheme.onSurfaceVariant, size: 28),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        style: TextStyle(color: colorScheme.onSurface),
                        decoration: InputDecoration(
                          hintText: 'Search for properties...',
                          hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                          border: InputBorder.none,
                        ),
                        onChanged: _filterProperties,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: _isLoading
                    ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
                    : _filteredProperties.isEmpty
                        ? Center(
                            child: Text(
                              'No properties found',
                              style: TextStyle(
                                fontSize: 18,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _filteredProperties.length,
                            itemBuilder: (context, index) {
                              final property = _filteredProperties[index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ManagePlaceDetail(
                                        documentId: property['id'].toString(),
                                        baseUrl: baseUrl,
                                      ),
                                    ),
                                  ).then((_) => _fetchProperties());
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  decoration: BoxDecoration(
                                    color: colorScheme.surface,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius: const BorderRadius.horizontal(
                                          left: Radius.circular(12),
                                        ),
                                        child: Image.network(
                                          _getPropertyImageUrl(property),
                                          height: 140,
                                          width: 140,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, error, __) {
                                            return Container(
                                              height: 140,
                                              width: 140,
                                              color: colorScheme.surfaceVariant,
                                              child: Icon(
                                                Icons.image,
                                                size: 40,
                                                color: colorScheme.onSurfaceVariant,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(12),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                property['name'] ?? 'Unknown Place',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: colorScheme.onSurface,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.location_on,
                                                    size: 16,
                                                    color: colorScheme.onSurfaceVariant,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Expanded(
                                                    child: Text(
                                                      property['address'] ?? 'No address',
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: colorScheme.onSurfaceVariant,
                                                      ),
                                                      maxLines: 2,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 12),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.currency_rupee,
                                                    size: 16,
                                                    color: colorScheme.primary,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    '${property['rent'] ?? 'N/A'}',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.bold,
                                                      color: colorScheme.primary,
                                                    ),
                                                  ),
                                                  const Spacer(),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 6,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: colorScheme.primaryContainer,
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Icon(
                                                          Icons.arrow_forward,
                                                          size: 16,
                                                          color: colorScheme.onPrimaryContainer,
                                                        ),
                                                        const SizedBox(width: 4),
                                                        Text(
                                                          'Manage',
                                                          style: TextStyle(
                                                            color: colorScheme.onPrimaryContainer,
                                                            fontWeight: FontWeight.w500,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AnimatedMenuItem extends StatefulWidget {
  final IconData icon;
  final String title;
  final Color iconColor;
  final Color backgroundColor;
  final VoidCallback onTap;

  const AnimatedMenuItem({
    Key? key,
    required this.icon,
    required this.title,
    required this.iconColor,
    required this.backgroundColor,
    required this.onTap,
  }) : super(key: key);

  @override
  _AnimatedMenuItemState createState() => _AnimatedMenuItemState();
}

class _AnimatedMenuItemState extends State<AnimatedMenuItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return MouseRegion(
      onEnter: (event) => setState(() {
        _isHovered = true;
      }),
      onExit: (event) => setState(() {
        _isHovered = false;
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()..scale(_isHovered ? 1.05 : 1.0),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          leading: Icon(widget.icon, color: widget.iconColor),
          title: Text(
            widget.title,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
          onTap: widget.onTap,
        ),
      ),
    );
  }
}
