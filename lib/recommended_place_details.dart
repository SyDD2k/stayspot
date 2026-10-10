import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'chat_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class RecommendedPlaceDetailsPage extends StatefulWidget {
  final Map<String, dynamic> place;
  const RecommendedPlaceDetailsPage({super.key, required this.place});

  @override
  State<RecommendedPlaceDetailsPage> createState() => _RecommendedPlaceDetailsPageState();
}

class _RecommendedPlaceDetailsPageState extends State<RecommendedPlaceDetailsPage> {
  Map<String, dynamic>? _dbPlace;
  List<Map<String, dynamic>> _otherPlaces = [];
  bool _loading = true;
  int _userRating = 0;
  double _averageRating = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchProperties();
    _fetchRatings();
  }

  Future<void> _fetchProperties() async {
    setState(() => _loading = true);
    try {
      final uri = Uri.parse('http://127.0.0.1:8000/users/properties/');
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final all = List<Map<String, dynamic>>.from(data);
        final match = all.firstWhere(
          (p) => p['name']?.toString().toLowerCase() == widget.place['name']?.toString().toLowerCase(),
          orElse: () => widget.place,
        );
        setState(() {
          _dbPlace = match;
          _otherPlaces = all.where((p) => p['name'] != match['name']).toList();
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
      }
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Future<void> _fetchRatings() async {
    try {
      final uri = Uri.parse('http://127.0.0.1:8000/api/ratings/get/?place_name=${widget.place['name']}');
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List && data.isNotEmpty) {
          final ratings = data.map((r) => r['rating'] as int).toList();
          final avgRating = ratings.reduce((a, b) => a + b) / ratings.length;
          setState(() {
            _averageRating = avgRating;
          });
        }
      }
    } catch (e) {
      print('Error fetching ratings: $e');
    }
  }

  Future<void> _submitRating(int rating) async {
    try {
      final uri = Uri.parse('http://127.0.0.1:8000/api/ratings/submit/');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'place_name': widget.place['name'],
          'rating': rating,
        }),
      );
      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Rating submitted successfully!')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to submit rating.')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error submitting rating: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final place = _dbPlace ?? widget.place;
    final double? lat = place['lat'] is double ? place['lat'] : (place['lat'] is num ? (place['lat'] as num).toDouble() : null);
    final double? lng = place['lng'] is double ? place['lng'] : (place['lng'] is num ? (place['lng'] as num).toDouble() : null);
    final phone = place['phone'] ?? '';
    final rating = place['rating'] is num ? (place['rating'] as num).toDouble() : null;
    final imageUrl = place['image_url'] ?? ((place['images'] is List && (place['images'] as List).isNotEmpty && (place['images'] as List).first is Map && (place['images'] as List).first['image'] != null) ? (place['images'] as List).first['image'] : null);
    final price = place['price']?.toString();
    final description = place['description'] ?? '';
    final owner = place['owner'] ?? '';
    final foodAvailable = place['food_available'] == true || place['food_available'] == 'true';
    final wifiAvailable = place['wifi_available'] == true || place['wifi_available'] == 'true';
    final roomsAvailable = place['rooms_available'] == true || place['rooms_available'] == 'true';
    return Scaffold(
      appBar: AppBar(
        title: Text(place['name'] ?? 'Recommended Place'),
        backgroundColor: Colors.blue,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (imageUrl != null)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  imageUrl,
                                  height: 200,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    height: 200,
                                    color: Colors.grey[300],
                                    child: const Center(child: Icon(Icons.broken_image, size: 50)),
                                  ),
                                ),
                              ),
                            const SizedBox(height: 16),
                            Row(children: [
                              const Icon(Icons.home, color: Colors.blue, size: 28),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  place['name'] ?? '',
                                  style: GoogleFonts.poppins(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ]),
                            const Divider(height: 32),
                            Row(children: [
                              const Icon(Icons.location_on, color: Colors.redAccent),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  place['address'] ?? '',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ),
                            ]),
                            if (price != null && price.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              Row(children: [
                                const Icon(Icons.attach_money, color: Colors.green),
                                const SizedBox(width: 12),
                                Text(
                                  price,
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    color: Colors.green[800],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ]),
                            ],
                            if (description.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              Text('Description', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              Text(description, style: GoogleFonts.poppins(fontSize: 15)),
                            ],
                            if (owner.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              Row(children: [
                                const Icon(Icons.person, color: Colors.blueGrey),
                                const SizedBox(width: 12),
                                Text(
                                  owner,
                                  style: GoogleFonts.poppins(fontSize: 16, color: Colors.blueGrey),
                                ),
                              ]),
                            ],
                            const SizedBox(height: 16),
                            // Map preview
                            if (lat != null && lng != null)
                              Semantics(
                                label: 'Map preview of location',
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    'https://maps.googleapis.com/maps/api/staticmap?center=$lat,$lng&zoom=16&size=600x200&markers=color:blue%7C$lat,$lng&key=AIzaSyXT9e0BTU08wNjhzBiNmQsdPDWLj0jpckv',
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
                                child: const Center(child: Icon(Icons.map, size: 40, color: Colors.grey)),
                              ),
                            const SizedBox(height: 16),
                            // Amenities section (using food, wifi, rooms_available)
                            Text('Amenities', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                _AmenityIcon(icon: Icons.fastfood, label: 'Food', enabled: foodAvailable),
                                _AmenityIcon(icon: Icons.wifi, label: 'WiFi', enabled: wifiAvailable),
                                _AmenityIcon(icon: Icons.meeting_room, label: 'Rooms Available', enabled: roomsAvailable),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Chat with Owner Button (only for manually uploaded places)
                            if (place['id'] != null) ...[
                              ElevatedButton.icon(
                                icon: Icon(Icons.chat_bubble_outline),
                                label: Text('Chat with Owner'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  minimumSize: Size(double.infinity, 48),
                                  textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChatScreen(
                                        propertyId: place['id'].toString(),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 16),
                            ],
                            // Phone
                            Row(children: [
                              const Icon(Icons.phone, color: Colors.green),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  phone.isNotEmpty ? phone : 'No phone number',
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
                                _averageRating > 0 ? '${_averageRating.toStringAsFixed(1)} / 5.0' : 'No rating',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ]),
                            // User rating for manually added places (no id)
                            if (place['id'] != null) ...[
                              const SizedBox(height: 8),
                              Text('Rate this place:', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w500)),
                              const SizedBox(height: 4),
                              _StarRating(
                                rating: _userRating,
                                onRatingChanged: (value) {
                                  setState(() {
                                    _userRating = value;
                                  });
                                  _submitRating(value);
                                },
                              ),
                            ],
                            const SizedBox(height: 24),
                            // Token Payment Button
                            Container(
                              width: double.infinity,
                              height: 56,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Colors.blue, Colors.blueAccent],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blue.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () async {
                                    final url = Uri.parse('https://razorpay.me/@nikhilbhargavgurumurthy');
                                    if (await canLaunchUrl(url)) {
                                      await launchUrl(url);
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Could not launch payment link')),
                                      );
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 24),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.payment,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          'Token Payment',
                                          style: GoogleFonts.poppins(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    if (_otherPlaces.isNotEmpty) ...[
                      Text('Other Recommended Places', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue)),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 260,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _otherPlaces.length,
                          itemBuilder: (context, index) {
                            final other = _otherPlaces[index];
                            return Container(
                              width: 220,
                              margin: const EdgeInsets.only(right: 16),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => RecommendedPlaceDetailsPage(place: other),
                                    ),
                                  );
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
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                        child: Image.network(
                                          other['image_url'] ?? ((other['images'] is List && (other['images'] as List).isNotEmpty && (other['images'] as List).first is Map && (other['images'] as List).first['image'] != null) ? (other['images'] as List).first['image'] : null) ?? 'https://via.placeholder.com/200',
                                          height: 140,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Container(
                                            height: 140,
                                            color: Colors.grey[300],
                                            child: const Center(child: Icon(Icons.broken_image, size: 40)),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              other['name'] ?? 'Unknown Place',
                                              style: GoogleFonts.poppins(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              other['address'] ?? 'No address',
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
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }
}

// Update _AmenityIcon to support enabled/disabled state
class _AmenityIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool enabled;
  const _AmenityIcon({required this.icon, required this.label, this.enabled = false});
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
              backgroundColor: enabled ? Colors.blue[50] : Colors.grey[200],
              child: Icon(icon, color: enabled ? Colors.blue : Colors.grey, size: 22),
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12, color: enabled ? Colors.black : Colors.grey)),
        ],
      ),
    );
  }
}

class _StarRating extends StatelessWidget {
  final int rating;
  final ValueChanged<int> onRatingChanged;
  const _StarRating({required this.rating, required this.onRatingChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return IconButton(
          icon: Icon(
            index < rating ? Icons.star : Icons.star_border,
            color: Colors.orange,
            size: 28,
          ),
          onPressed: () => onRatingChanged(index + 1),
          splashRadius: 20,
        );
      }),
    );
  }
} 