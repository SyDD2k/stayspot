// lib/homepage.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'main.dart';

import 'user_profile.dart';
import 'wishlist.dart';
import 'login_screen.dart';
import 'owner.dart';
import 'place_details.dart';
import 'faq_page.dart';
import 'chatbot.dart';

const String _goMapsApiKey = 'AlzaSyXT9e0BTU08wNjhzBiNmQsdPDWLj0jpckv';

/// Simple model for autocomplete predictions
class AutocompletePrediction {
  final String description;
  final String placeId;
  AutocompletePrediction({required this.description, required this.placeId});
  factory AutocompletePrediction.fromJson(Map<String, dynamic> j) =>
      AutocompletePrediction(
          description: j['description'], placeId: j['place_id']);
}

enum FilterOptions { boys, girls, govtHostels, apartments, rooms }

class Homepage extends StatefulWidget {
  const Homepage({super.key, this.initialSearch});
  final String? initialSearch;
  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();

  late final AnimationController _bodyAnimController;
  late final Animation<double> _bodyFade;

  List<AutocompletePrediction> _suggestions = [];
  bool _showSuggestions = false;
  bool _accomLoading = false;
  FilterOptions? _selectedFilter;

  final List<Map<String, dynamic>> _accommodations = [
    {'name': 'Annapoorneshwari Boys PG', 'address': 'Bogadi 2nd Stage', 'type': FilterOptions.boys},
    {'name': 'Sri S.B. Paying Guest',      'address': 'Bogadi 2nd Stage', 'type': FilterOptions.boys},
    {'name': 'Roy Boys PG',                 'address': 'Bogadi 2nd Stage', 'type': FilterOptions.boys},
    {'name': 'Akshaya PG for Girls',        'address': 'Bogadi 2nd Stage', 'type': FilterOptions.girls},
    {'name': 'Siri Womens PG',              'address': 'Bogadi 2nd Stage North', 'type': FilterOptions.girls},
    {'name': 'Darshini Ladies PG',          'address': 'Siddhalingeshwara Layout', 'type': FilterOptions.girls},
    {'name': 'Brigade Palmgrove',           'address': 'Bogadi Road', 'type': FilterOptions.apartments},
    {'name': 'Gokula Enclave',              'address': 'Bogadi 2nd Stage North', 'type': FilterOptions.apartments},
    {'name': 'Samuday Palacia I Greens A',  'address': 'Bogadi 2nd Stage', 'type': FilterOptions.apartments},
    {'name': 'SC Post Matric Boys Hostel',  'address': 'Siddhalingeshwara Nagar', 'type': FilterOptions.govtHostels},
    {'name': 'SC Post Matric Girls Hostel', 'address': 'Bogadi II Stage', 'type': FilterOptions.govtHostels},
    {'name': 'BCM Hostel',                  'address': 'CFTRI Layout', 'type': FilterOptions.govtHostels},
  ];

  @override
  void initState() {
    super.initState();
    _bodyAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _bodyFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _bodyAnimController, curve: Curves.easeInOut),
    );
    _bodyAnimController.forward();

    if (widget.initialSearch != null) {
      _searchController.text = widget.initialSearch!;
      WidgetsBinding.instance.addPostFrameCallback(
          (_) => _onSearchChanged(widget.initialSearch!));
    }

    WidgetsBinding.instance
        .addPostFrameCallback((_) => _showInstructionsOverlay());
  }

  @override
  void dispose() {
    _bodyAnimController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<List<AutocompletePrediction>> _getAutocomplete(String input) async {
    final uri = Uri.parse('http://127.0.0.1:8000/users/api/autocomplete/?input=$input');
    final r = await http.get(uri);
    if (r.statusCode == 200) {
      final data = json.decode(r.body);
      return (data['predictions'] as List)
          .map((j) => AutocompletePrediction.fromJson(j))
          .toList();
    }
    return [];
  }

  void _onSearchChanged(String text) {
    if (text.isEmpty) {
      setState(() => _showSuggestions = false);
    } else {
      _getAutocomplete(text).then((list) {
        setState(() {
          _suggestions = list;
          _showSuggestions = true;
        });
      });
    }
  }

  Future<void> _onAccommodationTap(Map<String, String> item) async {
    final full = '${item['name']}, ${item['address']}';
    _searchController.text = full;
    setState(() {
      _showSuggestions = false;
      _accomLoading = true;
    });
    final list = await _getAutocomplete(full);
    setState(() => _accomLoading = false);
    if (list.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => PlaceDetailsPage(placeId: list.first.placeId)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No place found for "$full"')),
      );
    }
  }

  void _showInstructionsOverlay() {
    showGeneralDialog(
      barrierDismissible: false,
      barrierLabel: 'Instructions',
      context: context,
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (_, __, ___) => const SizedBox(),
      transitionBuilder: (_, anim, __, child) => FadeTransition(
        opacity: anim,
        child: ScaleTransition(
          scale: anim,
          child: AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text("Welcome to StaySpot!",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            content: const Text(
              "Search for places or tap a card below to go directly to details.\n"
              "Use the filter 🔍 to narrow by category.\n"
              "Tap the menu ☰ for profile, wishlist, or logout.",
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showRoleSelectionDialog();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child:
                    const Text("Continue", style: TextStyle(color: Colors.white)),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _showRoleSelectionDialog() {
    showGeneralDialog(
      barrierDismissible: false,
      barrierLabel: 'Select Role',
      context: context,
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (_, __, ___) => const SizedBox(),
      transitionBuilder: (_, anim, __, child) => FadeTransition(
        opacity: anim,
        child: ScaleTransition(
          scale: anim,
          child: AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text("Select Your Role",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            content: Column(mainAxisSize: MainAxisSize.min, children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.school, color: Colors.white),
                label:
                    const Text("Student", style: TextStyle(color: Colors.white)),
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: const Size.fromHeight(40),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.business, color: Colors.white),
                label:
                    const Text("Owner", style: TextStyle(color: Colors.white)),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const OwnerPage()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  minimumSize: const Size.fromHeight(40),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  Future<void> _onMenuItemSelected(String value) async {
    switch (value) {
      case 'user':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const UserProfilePage()));
        break;
      case 'wishlist':
        final selected = await Navigator.push<String?>(
          context,
          MaterialPageRoute(builder: (_) => const WishlistPage()),
        );
        if (selected != null) {
          _searchController.text = selected;
          _onSearchChanged(selected);
        }
        break;
      case 'logout':
        await FirebaseAuth.instance.signOut();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (_) => false,
        );
        break;
    }
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(builder: (ctx2, setModal) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text("Filter by Category",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Divider(),
            ...FilterOptions.values.map((opt) {
              final labels = {
                FilterOptions.boys: "Boys",
                FilterOptions.girls: "Girls",
                FilterOptions.govtHostels: "Govt. Hostels",
                FilterOptions.apartments: "Apartments",
                FilterOptions.rooms: "Rooms",
              };
              final icons = {
                FilterOptions.boys: Icons.male,
                FilterOptions.girls: Icons.female,
                FilterOptions.govtHostels: Icons.apartment,
                FilterOptions.apartments: Icons.home_work,
                FilterOptions.rooms: Icons.meeting_room,
              };
              final colors = {
                FilterOptions.boys: Colors.blue,
                FilterOptions.girls: Colors.pink,
                FilterOptions.govtHostels: Colors.green,
                FilterOptions.apartments: Colors.orange,
                FilterOptions.rooms: Colors.purple,
              };
              return RadioListTile<FilterOptions>(
                value: opt,
                groupValue: _selectedFilter,
                title: Text(labels[opt]!, style: const TextStyle(fontSize: 16)),
                secondary: Icon(icons[opt], color: colors[opt], size: 28),
                onChanged: (v) {
                  setModal(() => _selectedFilter = v);
                  setState(() {});
                },
              );
            }),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("Apply",
                  style: TextStyle(color: Colors.white, fontSize: 16)),
            )
          ]),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _selectedFilter == null
        ? _accommodations
        : _accommodations
            .where((a) => a['type'] == _selectedFilter)
            .toList();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 80,
        backgroundColor: theme.brightness == Brightness.dark ? (theme.appBarTheme.backgroundColor ?? colorScheme.surface) : Colors.blue,
        title: Row(children: [
          Container(
            width: 50,
            height: 50,
            decoration:
                BoxDecoration(shape: BoxShape.circle, color: colorScheme.surface),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Image.asset('assets/images/logo.png', fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) =>
                      Icon(Icons.home, size: 30, color: colorScheme.primary)),
            ),
          ),
          const SizedBox(width: 8),
          Text('StaySpot',
              style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
        ]),
        actions: [
          // Dark mode toggle button
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) => IconButton(
              icon: Icon(themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode, color: colorScheme.onSurface),
              tooltip: themeProvider.isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
              onPressed: () {
                themeProvider.toggleTheme();
              },
            ),
          ),
          IconButton(
              icon: Icon(Icons.menu, color: colorScheme.onSurface),
              onPressed: () => _scaffoldKey.currentState?.openEndDrawer()),
          StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              final user = snapshot.data;
              return GestureDetector(
                onTap: () => Navigator.push(
                    context, MaterialPageRoute(builder: (_) => const UserProfilePage())),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: colorScheme.surface,
                    backgroundImage:
                        user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
                    child: user?.photoURL == null
                        ? Text(user?.displayName?.substring(0, 1).toUpperCase() ?? 'U',
                            style: TextStyle(
                                color: colorScheme.primary,
                                fontSize: 20,
                                fontWeight: FontWeight.bold))
                        : null,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      endDrawer: Drawer(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          children: [
            // User info card at the top
            StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                final user = snapshot.data;
                final String? photoUrl = user?.photoURL;
                final String displayName = user?.displayName ?? 'User';
                final String email = user?.email ?? '';
                return Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: photoUrl == null ? colorScheme.primary : Colors.transparent,
                        backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
                        child: photoUrl == null
                            ? Text(
                                displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
                                style: TextStyle(fontSize: 32, color: colorScheme.onPrimary, fontWeight: FontWeight.bold),
                              )
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName,
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: colorScheme.onSurface),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              email,
                              style: TextStyle(fontSize: 14, color: colorScheme.onSurface.withOpacity(0.7)),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            // Sidebar items with tile effect
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorScheme.primary.withOpacity(0.1), width: 1.2),
                color: colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withOpacity(0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _AnimatedDrawerItem(
                      icon: Icons.person,
                      title: 'User',
                      color: colorScheme.primary,
                      onTap: () {
                        Navigator.pop(context);
                        _onMenuItemSelected('user');
                      }),
                  Divider(height: 1, color: colorScheme.primary.withOpacity(0.05)),
                  _AnimatedDrawerItem(
                      icon: Icons.favorite,
                      title: 'Wishlist',
                      color: Colors.green,
                      onTap: () {
                        Navigator.pop(context);
                        _onMenuItemSelected('wishlist');
                      }),
                  Divider(height: 1, color: colorScheme.primary.withOpacity(0.05)),
                  _AnimatedDrawerItem(
                      icon: Icons.help_outline,
                      title: 'FAQ',
                      color: Colors.orange,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const FaqPage()));
                      }),
                  Divider(height: 1, color: colorScheme.primary.withOpacity(0.05)),
                  _AnimatedDrawerItem(
                      icon: Icons.logout,
                      title: 'Logout',
                      color: Colors.red,
                      onTap: () {
                        Navigator.pop(context);
                        _onMenuItemSelected('logout');
                      }),
                ],
              ),
            ),
          ],
        ),
      ),
      body: FadeTransition(
        opacity: _bodyFade,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                // Search bar + filter icon
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                          color: colorScheme.primary.withOpacity(0.05),
                          blurRadius: 6,
                          offset: const Offset(0, 3))
                    ],
                  ),
                  child: Row(children: [
                    Icon(Icons.search, color: colorScheme.onSurface.withOpacity(0.7)),
                    const SizedBox(width: 8),
                    Expanded(
                        child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      decoration:
                          InputDecoration(hintText: 'Search for places…', border: InputBorder.none, hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.5))),
                      style: TextStyle(color: colorScheme.onSurface),
                    )),
                    IconButton(
                        icon: Icon(Icons.filter_list, color: colorScheme.primary),
                        onPressed: _showFilterOptions),
                  ]),
                ),

                // Autocomplete suggestions
                if (_showSuggestions && _suggestions.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: ListView.builder(
                      itemCount: _suggestions.length,
                      itemBuilder: (_, i) {
                        final s = _suggestions[i];
                        return _SuggestionTile(
                          description: s.description,
                          onTap: () {
                            _searchController.text = s.description;
                            setState(() => _showSuggestions = false);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => PlaceDetailsPage(placeId: s.placeId)),
                            );
                          },
                        );
                      },
                    ),
                  ),

                const SizedBox(height: 20),

                // Filter chips for quick filtering
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChip(
                        label: const Text('All'),
                        selected: _selectedFilter == null,
                        onSelected: (selected) {
                          setState(() => _selectedFilter = null);
                        },
                      ),
                      const SizedBox(width: 8),
                      ...FilterOptions.values.map((opt) {
                        final labels = {
                          FilterOptions.boys: "Boys",
                          FilterOptions.girls: "Girls",
                          FilterOptions.govtHostels: "Govt. Hostels",
                          FilterOptions.apartments: "Apartments",
                          FilterOptions.rooms: "Rooms",
                        };
                        final colors = {
                          FilterOptions.boys: Colors.blue,
                          FilterOptions.girls: Colors.pink,
                          FilterOptions.govtHostels: Colors.green,
                          FilterOptions.apartments: Colors.orange,
                          FilterOptions.rooms: Colors.purple,
                        };
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(labels[opt]!),
                            selected: _selectedFilter == opt,
                            backgroundColor: colors[opt]!.withOpacity(0.1),
                            selectedColor: colors[opt]!.withOpacity(0.3),
                            onSelected: (selected) {
                              setState(() => _selectedFilter = selected ? opt : null);
                            },
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Accommodation grid with skeleton loader
                Expanded(
                  child: _accomLoading
                      ? ListView.builder(
                          itemCount: 4,
                          itemBuilder: (_, idx) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _SkeletonAccommodationCard(),
                          ),
                        )
                      : ListView.builder(
                          itemCount: filtered.length,
                          itemBuilder: (_, idx) {
                            final item = filtered[idx];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _AccommodationCard(
                                name: item['name'],
                                address: item['address'],
                                onTap: () => _onAccommodationTap({
                                  'name': item['name'] as String,
                                  'address': item['address'] as String
                                }),
                              ),
                            );
                          },
                        ),
                ),
              ]),
            ),
            Directionality(
              textDirection: TextDirection.ltr,
              child: ChatBot(),
            ),
          ],
        ),
      ),
    );
  }
}

/// Sidebar item with hover animation
class _AnimatedDrawerItem extends StatefulWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;
  const _AnimatedDrawerItem({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });
  @override
  State<_AnimatedDrawerItem> createState() => _AnimatedDrawerItemState();
}

class _AnimatedDrawerItemState extends State<_AnimatedDrawerItem> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        transform: _hover ? (Matrix4.identity()..scale(1.03)) : Matrix4.identity(),
        decoration: BoxDecoration(
          color: _hover ? widget.color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListTile(
          leading: Icon(widget.icon, color: widget.color),
          title: Text(widget.title, style: TextStyle(color: widget.color)),
          onTap: widget.onTap,
        ),
      ),
    );
  }
}

/// Suggestion item with light border on hover
class _SuggestionTile extends StatefulWidget {
  final String description;
  final VoidCallback onTap;
  const _SuggestionTile({required this.description, required this.onTap});
  @override
  State<_SuggestionTile> createState() => _SuggestionTileState();
}

class _SuggestionTileState extends State<_SuggestionTile> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(
                color: _hover ? Colors.grey.shade400 : Colors.transparent),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(widget.description),
        ),
      ),
    );
  }
}

/// Accommodation card: modern design with image
class _AccommodationCard extends StatefulWidget {
  final String name;
  final String address;
  final VoidCallback onTap;
  const _AccommodationCard({
    required this.name,
    required this.address,
    required this.onTap,
  });
  @override
  State<_AccommodationCard> createState() => _AccommodationCardState();
}

class _AccommodationCardState extends State<_AccommodationCard> {
  bool _hover = false;
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _fetchPlacePhoto();
  }

  Future<void> _fetchPlacePhoto() async {
    try {
      final searchResponse = await http.get(
        Uri.parse('http://127.0.0.1:8000/users/api/text_search/?query=${widget.name}, ${widget.address}')
      );
      
      if (searchResponse.statusCode == 200) {
        final searchData = json.decode(searchResponse.body);
        final photos = searchData['results']?[0]?['photos'] as List?;
        
        if (photos != null && photos.isNotEmpty) {
          final photoRef = photos[0]['photo_reference'] as String;
          setState(() {
            _imageUrl = 'http://127.0.0.1:8000/users/api/place_photo/?photo_reference=$photoRef&maxwidth=800';
          });
        }
      }
    } catch (e) {
      print('Error fetching place photo: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Accommodation card for \\"${widget.name}\\" at \\"${widget.address}\\"',
      button: true,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            transform: _hover ? (Matrix4.identity()..translate(0, -5, 0)) : Matrix4.identity(),
            height: 200,
            width: MediaQuery.of(context).size.width < 600 ? double.infinity : 500,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(_hover ? 0.2 : 0.1),
                  blurRadius: _hover ? 8 : 4,
                  offset: Offset(0, _hover ? 4 : 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Image with loading and error states
                  _imageUrl != null
                      ? Semantics(
                          label: 'Image of ${widget.name}',
                          child: CachedNetworkImage(
                            imageUrl: _imageUrl!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: Colors.grey[200],
                              child: const Center(child: CircularProgressIndicator()),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey[200],
                              child: const Center(
                                child: Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
                              ),
                            ),
                          ),
                        )
                      : Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                        stops: const [0.5, 1.0],
                      ),
                    ),
                  ),
                  // Content
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          widget.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                offset: Offset(0, 1),
                                blurRadius: 2,
                                color: Colors.black45,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on, color: Colors.white, size: 16),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                widget.address,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 14,
                                  shadows: const [
                                    Shadow(
                                      offset: Offset(0, 1),
                                      blurRadius: 2,
                                      color: Colors.black45,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Add skeleton card widget for loading state
class _SkeletonAccommodationCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Loading accommodation card',
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.grey[300]!,
                      Colors.grey[200]!,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: 120,
                    height: 20,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 80,
                    height: 16,
                    color: Colors.grey[350],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
