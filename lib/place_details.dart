// lib/place_details.dart

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'wishlist.dart'; // globalWishlist
import 'recommended_place_details.dart';
import 'chat_screen.dart';

const String _goMapsApiKey = 'AlzaSyXT9e0BTU08wNjhzBiNmQsdPDWLj0jpckv';

class PlaceDetailsPage extends StatefulWidget {
  final String placeId;
  const PlaceDetailsPage({super.key, required this.placeId});

  @override
  State<PlaceDetailsPage> createState() => _PlaceDetailsPageState();
}

class _PlaceDetailsPageState extends State<PlaceDetailsPage> {
  bool _loading = true, _isFav = false;
  String _name = '—', _address = '—', _phone = '';
  double? _rating, _lat, _lng;
  List<String> _photos = [];
  List<Map<String, dynamic>> _similarPlaces = [];
  List<Map<String, dynamic>> _properties = [];

  final ScrollController _photoController = ScrollController();
  final PageController _pageController = PageController();
  int _currentPhotoIndex = 0;

  @override
  void initState() {
    super.initState();
    _isFav = globalWishlist.any((i) => i['placeId'] == widget.placeId);
    _fetchDetail();
    _fetchSimilarPlaces();
    _fetchProperties();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _photoController.dispose();
    super.dispose();
  }

  Future<void> _fetchDetail() async {
    final uri = Uri.parse('http://127.0.0.1:8000/users/api/place_details/?place_id=${widget.placeId}');
    final response = await http.get(uri);
    print('Raw HTTP response: \\n${response.body}'); // Debug print
    if (response.statusCode == 200) {
      final data = json.decode(response.body)['result'];
      print('Place Details Response: \\n${json.encode(data)}');  // Debug log
      setState(() {
        _name = data['name'] ?? '—';
        _address = data['formatted_address'] ?? '—';
        _phone = data['formatted_phone_number'] ?? '';
        _rating = (data['rating'] != null) ? (data['rating'] as num).toDouble() : null;
        _lat = data['geometry']?['location']?['lat']?.toDouble();
        _lng = data['geometry']?['location']?['lng']?.toDouble();
        print('Extracted lat: \\n[32m[1m[4m[7m[41m[42m[43m[44m[45m[46m[47m[49m[100m[101m[102m[103m[104m[105m[106m[107m${_lat} lng: ${_lng}'); // Debug print
        final photosList = data['photos'] as List? ?? [];
        print('Photos from API: $photosList');  // Debug log
        _photos = photosList.map((p) => p['photo_reference'] as String).toList();
        print('Extracted photo references: $_photos');  // Debug log
        _loading = false;
      });
    } else {
      print('Error response: ${response.statusCode} - ${response.body}');  // Debug log
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching details (${response.statusCode})')),
      );
    }
  }

  Future<void> _fetchSimilarPlaces() async {
    final uri = Uri.parse('http://127.0.0.1:8000/users/api/places/');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _similarPlaces = List<Map<String, dynamic>>.from(data['places']);
      });
    }
  }

  Future<void> _fetchProperties() async {
    try {
      final uri = Uri.parse('http://127.0.0.1:8000/users/properties/');
      print('Fetching properties from: $uri'); // Debug log
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Properties response: $data'); // Debug log
        setState(() {
          _properties = List<Map<String, dynamic>>.from(data);
        });
      } else {
        print('Error fetching properties: ${response.statusCode} - ${response.body}'); // Debug log
      }
    } catch (e) {
      print('Error fetching properties: $e');
    }
  }

  String _getPropertyImageUrl(Map<String, dynamic> property) {
    final images = property['images'];
    String? selectedImage;
    if (images != null && images is List && images.isNotEmpty) {
      final first = images[0];
      if (first is Map && first['image'] != null) {
        selectedImage = first['image'];
      }
    } else if (property['image'] != null) {
      selectedImage = property['image'];
    }
    if (selectedImage == null) return 'https://via.placeholder.com/400';
    if (selectedImage.toString().startsWith('http')) return selectedImage;
    if (selectedImage.toString().startsWith('/media/')) {
      return 'http://127.0.0.1:8000$selectedImage';
    }
    return 'http://127.0.0.1:8000/media/$selectedImage';
  }

  String _photoUrl(String ref, int maxWidth) {
    return 'http://127.0.0.1:8000/users/api/place_photo/?photo_reference=$ref&maxwidth=$maxWidth';
  }

  void _navigateToPropertyDetails(Map<String, dynamic> property) {
    // Navigate to place details with the property's place_id
    if (property['place_id'] != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PlaceDetailsPage(placeId: property['place_id']),
        ),
      );
    }
  }

  Widget _buildPhotoIndicator() {
    return Positioned(
      bottom: 16,
      left: 0,
      right: 0,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _photos.asMap().entries.map((entry) {
              return Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentPhotoIndex == entry.key 
                      ? Colors.white 
                      : Colors.white.withOpacity(0.5),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_currentPhotoIndex + 1} / ${_photos.length}',
              style: GoogleFonts.poppins(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Place Details',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context)
        ),
        actions: [
          IconButton(
            icon: Icon(_isFav ? Icons.favorite : Icons.favorite_border, color: Colors.white),
            onPressed: () {
              setState(() {
                if (_isFav) {
                  globalWishlist.removeWhere((i) => i['placeId'] == widget.placeId);
                } else {
                  globalWishlist.add({
                    'placeId': widget.placeId,
                    'name': _name,
                    'address': _address,
                  });
                }
                _isFav = !_isFav;
              });
            },
          )
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Photos with PageView and indicators
                  if (_photos.isNotEmpty)
                    SizedBox(
                      height: 250,
                      width: double.infinity,
                      child: Stack(
                        children: [
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: PageView.builder(
                              controller: _pageController,
                              itemCount: _photos.length,
                              onPageChanged: (index) {
                                setState(() {
                                  _currentPhotoIndex = index;
                                });
                              },
                              // Add scroll physics for better web support
                              scrollBehavior: MaterialScrollBehavior().copyWith(
                                dragDevices: {
                                  PointerDeviceKind.mouse,
                                  PointerDeviceKind.touch,
                                  PointerDeviceKind.stylus,
                                  PointerDeviceKind.unknown
                                },
                              ),
                              itemBuilder: (ctx, i) {
                                final ref = _photos[i];
                                final url = _photoUrl(ref, 800);
                                return GestureDetector(
                                  onTap: () {
                                    // Add navigation buttons for web
                                    if (i > 0) {
                                      showDialog(
                                        context: context,
                                        builder: (_) => Stack(
                                          children: [
                                            Image.network(
                                              url,
                                              fit: BoxFit.contain,
                                              height: double.infinity,
                                              width: double.infinity,
                                            ),
                                            Positioned(
                                              left: 16,
                                              top: 0,
                                              bottom: 0,
                                              child: IconButton(
                                                icon: Icon(Icons.chevron_left, color: Colors.white, size: 40),
                                                onPressed: () {
                                                  _pageController.previousPage(
                                                    duration: Duration(milliseconds: 300),
                                                    curve: Curves.easeInOut,
                                                  );
                                                },
                                              ),
                                            ),
                                            if (i < _photos.length - 1)
                                              Positioned(
                                                right: 16,
                                                top: 0,
                                                bottom: 0,
                                                child: IconButton(
                                                  icon: Icon(Icons.chevron_right, color: Colors.white, size: 40),
                                                  onPressed: () {
                                                    _pageController.nextPage(
                                                      duration: Duration(milliseconds: 300),
                                                      curve: Curves.easeInOut,
                                                    );
                                                  },
                                                ),
                                              ),
                                          ],
                                        ),
                                      );
                                    }
                                  },
                                  child: Image.network(
                                    url,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        Container(
                                          color: Colors.grey[300],
                                          child: const Icon(Icons.broken_image, size: 50)
                                        ),
                                  ),
                                );
                              },
                            ),
                          ),
                          _buildPhotoIndicator(),
                          // Add navigation arrows for web
                          if (_photos.length > 1) ...[
                            Positioned(
                              left: 8,
                              top: 0,
                              bottom: 0,
                              child: Center(
                                child: IconButton(
                                  icon: Icon(Icons.chevron_left, color: Colors.white, size: 36),
                                  onPressed: () {
                                    _pageController.previousPage(
                                      duration: Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                    );
                                  },
                                ),
                              ),
                            ),
                            Positioned(
                              right: 8,
                              top: 0,
                              bottom: 0,
                              child: Center(
                                child: IconButton(
                                  icon: Icon(Icons.chevron_right, color: Colors.white, size: 36),
                                  onPressed: () {
                                    _pageController.nextPage(
                                      duration: Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Name
                            Row(children: [
                              const Icon(Icons.home, color: Colors.blue, size: 28),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _name,
                                  style: GoogleFonts.poppins(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ]),
                            const Divider(height: 32),

                            // Address
                            Row(children: [
                              const Icon(Icons.location_on, color: Colors.redAccent),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _address,
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ),
                            ]),
                            const SizedBox(height: 16),

                            // Map preview
                            if (_lat != null && _lng != null)
                              Semantics(
                                label: 'Map preview of location',
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    'https://staticmap.openstreetmap.de/staticmap.php?center=$_lat,$_lng&zoom=16&size=600x200&markers=$_lat,$_lng,red-pushpin',
                                    height: 120,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      height: 120,
                                      color: Colors.grey[300],
                                      child: const Center(child: Icon(Icons.map, size: 40)),
                                    ),
                                  ),
                                ),
                              )
                            else
                              Container(
                                height: 120,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Location not available',
                                    style: TextStyle(color: Colors.grey, fontSize: 16),
                                  ),
                                ),
                              ),
                            const SizedBox(height: 16),

                            // Amenities section
                            Text('Amenities', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                _AmenityIcon(icon: Icons.wifi, label: 'WiFi'),
                                _AmenityIcon(icon: Icons.ac_unit, label: 'AC'),
                                _AmenityIcon(icon: Icons.local_parking, label: 'Parking'),
                                _AmenityIcon(icon: Icons.kitchen, label: 'Kitchen'),
                                _AmenityIcon(icon: Icons.local_laundry_service, label: 'Laundry'),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Phone
                            Row(children: [
                              const Icon(Icons.phone, color: Colors.green),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _phone.isNotEmpty ? _phone : 'No phone number',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ),
                            ]),
                            const SizedBox(height: 16),

                            // Rating
                            Row(children: [
                              const Icon(Icons.star, color: Colors.orange),
                              const SizedBox(width: 12),
                              Text(
                                _rating != null ? '${_rating!.toStringAsFixed(1)} / 5.0' : 'No rating',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ]),
                            const SizedBox(height: 24),

                            // Action Buttons
                            Row(
                              children: [
                                Expanded(
                                  child: _ActionButton(
                                    label: 'Get Uber',
                                    color: Colors.black,
                                    onTap: (_lat != null && _lng != null)
                                        ? () {
                                            launchUrl(
                                              Uri.parse(
                                                  'https://m.uber.com/?action=setPickup&dropoff[latitude]=${_lat!}&dropoff[longitude]=${_lng!}'),
                                              mode: LaunchMode.externalApplication,
                                            );
                                          }
                                        : null,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _ActionButton(
                                    label: 'Get Directions',
                                    color: Colors.green,
                                    onTap: () {
                                      final dest = Uri.encodeComponent(_address);
                                      launchUrl(
                                        Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$dest'),
                                        mode: LaunchMode.externalApplication,
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Similar Places
                  if (_similarPlaces.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'More Places to Explore',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 280,
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        itemCount: _similarPlaces.length,
                        itemBuilder: (context, index) {
                          final place = _similarPlaces[index];
                          return Container(
                            width: 220,
                            margin: EdgeInsets.only(right: 16),
                            child: Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                                    child: Image.network(
                                      place['image_url'] ?? 'https://via.placeholder.com/200',
                                      height: 150,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          place['name'] ?? 'Unknown Place',
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          place['address'] ?? 'No address',
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Recommended Properties
                  if (_properties.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Recommended Places',
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 280,
                            child: ScrollConfiguration(
                              behavior: ScrollConfiguration.of(context).copyWith(
                                dragDevices: {
                                  PointerDeviceKind.mouse,
                                  PointerDeviceKind.touch,
                                  PointerDeviceKind.stylus,
                                  PointerDeviceKind.unknown
                                },
                              ),
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _properties.length,
                                itemBuilder: (context, index) {
                                  final property = _properties[index];
                                  return Stack(
                                    children: [
                                      Container(
                                        width: MediaQuery.of(context).size.width - 32,
                                        margin: EdgeInsets.only(right: 16),
                                        child: GestureDetector(
                                          onTap: () {
                                            if (property['place_id'] != null) {
                                              _navigateToPropertyDetails(property);
                                            } else {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) => RecommendedPlaceDetailsPage(place: property),
                                                ),
                                              );
                                            }
                                          },
                                          child: Card(
                                            elevation: 4,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                ClipRRect(
                                                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                                                  child: Image.network(
                                                    _getPropertyImageUrl(property),
                                                    height: 160,
                                                    width: double.infinity,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (_, error, __) {
                                                      print('Image error: $error for property: ${property['image']}');
                                                      return Container(
                                                        height: 160,
                                                        color: Colors.grey[300],
                                                        child: Icon(Icons.image, size: 40, color: Colors.grey[400]),
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
                                                          style: GoogleFonts.poppins(
                                                            fontSize: 18,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                        const SizedBox(height: 8),
                                                        Text(
                                                          property['address'] ?? 'No address',
                                                          style: GoogleFonts.poppins(
                                                            fontSize: 14,
                                                            color: Colors.grey[600],
                                                          ),
                                                          maxLines: 2,
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                        const Spacer(),
                                                        if (property['price'] != null) ...[
                                                          Text(
                                                            '\$${property['price']}',
                                                            style: GoogleFonts.poppins(
                                                              fontSize: 18,
                                                              fontWeight: FontWeight.bold,
                                                              color: Colors.green[700],
                                                            ),
                                                          ),
                                                        ],
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      // Add navigation hint arrows
                                      if (index == 0)
                                        Positioned(
                                          right: 24,
                                          top: 0,
                                          bottom: 0,
                                          child: Center(
                                            child: Container(
                                              padding: EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: Colors.black54,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                Icons.chevron_right,
                                                color: Colors.white,
                                                size: 24,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback? onTap;
  
  const _ActionButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 16,
        ),
      ),
    );
  }
}

// Add amenity icon widget
class _AmenityIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  const _AmenityIcon({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          Semantics(
            label: label,
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.blue[50],
              child: Icon(icon, color: Colors.blue, size: 22),
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
