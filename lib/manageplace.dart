import 'dart:convert';
import 'dart:io';
import 'dart:typed_data'; // For Uint8List.
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'platform.dart'; // Ensure this file provides isAndroid

/// This widget displays a list of properties fetched from the backend.
/// Tapping a property navigates to its detail screen for update.
class ManagePropertiesScreen extends StatefulWidget {
  const ManagePropertiesScreen({super.key});

  @override
  State<ManagePropertiesScreen> createState() => _ManagePropertiesScreenState();
}

class _ManagePropertiesScreenState extends State<ManagePropertiesScreen> {
  List<dynamic> properties = [];
  bool isLoading = false;
  // Base URL without a trailing slash.
  String baseUrl = "http://127.0.0.1:8000";

  @override
  void initState() {
    super.initState();
    if (!kIsWeb && isAndroid) {
      baseUrl = "http://10.0.2.2:8000";
    }
    _fetchProperties();
  }

  Future<void> _fetchProperties() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.get(Uri.parse('$baseUrl/properties/'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          if (data is List) {
            properties = data.where((item) {
              final id = (item["id"] ?? item["pk"])?.toString().trim() ?? "";
              return id.isNotEmpty && id != "null";
            }).toList();
          } else {
            properties = [];
          }
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
      isLoading = false;
    });
  }

  void _navigateToDetail(String propertyId) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              ManagePlaceDetail(documentId: propertyId, baseUrl: baseUrl)),
    ).then((_) {
      _fetchProperties();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Properties"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : properties.isEmpty
              ? const Center(child: Text("No properties available."))
              : RefreshIndicator(
                  onRefresh: _fetchProperties,
                  child: ListView.builder(
                    itemCount: properties.length,
                    itemBuilder: (context, index) {
                      final property = properties[index];
                      final id = (property["id"] ?? property["pk"])?.toString().trim() ?? "";
                      final name = property["name"] ?? "No Name";
                      final address = property["address"] ?? "No Address";
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: ListTile(
                          title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(address),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text("Delete Property"),
                                  content: const Text("Are you sure you want to delete this property?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(ctx).pop(false),
                                      child: const Text("Cancel"),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.of(ctx).pop(true),
                                      child: const Text("Delete", style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                try {
                                  final response = await http.delete(Uri.parse('$baseUrl/properties/$id/'));
                                  if (response.statusCode == 204) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("Property deleted successfully!")),
                                    );
                                    _fetchProperties();
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text("Failed to delete property. Code: ${response.statusCode}")),
                                    );
                                  }
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("Error deleting property: $e")),
                                  );
                                }
                              }
                            },
                          ),
                          onTap: () => _navigateToDetail(id),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

/// Detail screen for a single property (update only).
class ManagePlaceDetail extends StatefulWidget {
  final String documentId;
  final String baseUrl;
  const ManagePlaceDetail({super.key, required this.documentId, required this.baseUrl});

  @override
  State<ManagePlaceDetail> createState() => _ManagePlaceDetailState();
}

class _ManagePlaceDetailState extends State<ManagePlaceDetail> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _rentController = TextEditingController();
  final TextEditingController _tokenController = TextEditingController();

  String _selectedPropertyType = "PG/Hostel";
  String _tradeCertificateStatus = "Not Uploaded";

  // We use _newPropertyImages for new images (for both web and mobile)
  List<dynamic> _newPropertyImages = [];
  List<String> _existingImages = [];
  bool _foodAvailable = false;
  bool _wifiAvailable = false;
  bool _roomsAvailable = false;

  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  final Color orangeColor = Colors.orange;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    _fetchPlaceDetails();
  }

  Future<void> _fetchPlaceDetails() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final uri = Uri.parse('${widget.baseUrl}/properties/${widget.documentId}/');
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _nameController.text = data["name"] ?? "";
          _addressController.text = data["address"] ?? "";
          _phoneController.text = data["phone"] ?? "";
          _rentController.text = data["rent"]?.toString() ?? "";
          _tokenController.text = data["token"]?.toString() ?? "";
          _selectedPropertyType = data["property_type"] ?? "PG/Hostel";
          _foodAvailable = (data["food_available"] == true || data["food_available"] == "true");
          _wifiAvailable = (data["wifi_available"] == true || data["wifi_available"] == "true");
          _roomsAvailable = (data["rooms_available"] == true || data["rooms_available"] == "true");
          _tradeCertificateStatus = data["trade_certificate_status"] ?? "Not Uploaded";
          _existingImages = List<String>.from(
            (data["images"] ?? []).map((e) => e is String ? e : e["image"] as String)
          );
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to fetch details. Code: ${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching details: $e")),
      );
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _pickPropertyImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images != null && images.isNotEmpty) {
      if (kIsWeb) {
        List<Uint8List> tempBytes = [];
        for (var img in images) {
          final bytes = await img.readAsBytes();
          tempBytes.add(bytes);
        }
        _newPropertyImages = tempBytes;
      } else {
        _newPropertyImages = images.map((e) => e.path).toList();
      }
      setState(() {});
    }
  }

  Future<void> _updatePlace() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        final uri = Uri.parse('${widget.baseUrl}/properties/${widget.documentId}/');
        var request = http.MultipartRequest('PATCH', uri);
        request.fields['name'] = _nameController.text;
        request.fields['address'] = _addressController.text;
        request.fields['phone'] = _phoneController.text;
        request.fields['rent'] = _rentController.text;
        request.fields['token'] = _tokenController.text;
        request.fields['property_type'] = _selectedPropertyType;
        request.fields['food_available'] = _foodAvailable.toString();
        request.fields['wifi_available'] = _wifiAvailable.toString();
        request.fields['rooms_available'] = _roomsAvailable.toString();

        if (_newPropertyImages.isNotEmpty) {
          // If new images are selected, do not send existing_images (or send empty list)
          request.fields['existing_images'] = jsonEncode([]);
          if (kIsWeb) {
            for (var imageBytes in _newPropertyImages) {
              request.files.add(http.MultipartFile.fromBytes(
                'images',
                imageBytes,
                filename: 'property_image.jpg',
              ));
            }
          } else {
            for (var imagePath in _newPropertyImages) {
              request.files.add(await http.MultipartFile.fromPath('images', imagePath));
            }
          }
        } else {
          // If no new images, keep the existing ones
          request.fields['existing_images'] = jsonEncode(_existingImages);
        }

        var streamedResponse = await request.send();
        var response = await http.Response.fromStream(streamedResponse);

        if (streamedResponse.statusCode == 200) {
          // Update the local state with the new data
          var responseData = jsonDecode(response.body);
          setState(() {
            _existingImages = List<String>.from(
              (responseData['images'] ?? []).map((e) => e is String ? e : e['image'] as String)
            );
            _newPropertyImages = [];
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Property updated successfully!")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to update. Code: ${streamedResponse.statusCode}")),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error updating property: $e")),
        );
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _rentController.dispose();
    _tokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const poppinsTextStyle =
        TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, color: Colors.white);
    final darkBlue = Colors.blue.shade900;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Property",
            style: TextStyle(color: Colors.white, fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
        backgroundColor: darkBlue,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Select Property Type",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text("Room", style: TextStyle(fontFamily: 'Poppins')),
                              value: "Room",
                              groupValue: _selectedPropertyType,
                              onChanged: (value) {
                                setState(() {
                                  _selectedPropertyType = value!;
                                });
                              },
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text("PG/Hostel", style: TextStyle(fontFamily: 'Poppins')),
                              value: "PG/Hostel",
                              groupValue: _selectedPropertyType,
                              onChanged: (value) {
                                setState(() {
                                  _selectedPropertyType = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: _selectedPropertyType == "Room" ? "Name of Room" : "Name of PG/Hostel",
                          prefixIcon: const Icon(Icons.home),
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) => value == null || value.isEmpty ? "Enter a name" : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(
                          labelText: "Address",
                          prefixIcon: Icon(Icons.location_on),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value == null || value.isEmpty ? "Enter address" : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: "Phone Number",
                          prefixIcon: Icon(Icons.phone),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) => value == null || value.isEmpty ? "Enter phone number" : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _rentController,
                        decoration: const InputDecoration(
                          labelText: "Rent Amount",
                          prefixIcon: Icon(Icons.currency_rupee),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) => value == null || value.isEmpty ? "Enter rent amount" : null,
                      ),
                      const SizedBox(height: 16),
                      if (_selectedPropertyType == "PG/Hostel")
                        Row(
                          children: [
                            const Icon(Icons.upload_file, color: Colors.grey),
                            const SizedBox(width: 8),
                            const Text("Trade Certificate: ", style: TextStyle(fontFamily: 'Poppins')),
                            Text(_tradeCertificateStatus,
                                style: const TextStyle(
                                    color: Colors.green, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
                          ],
                        ),
                      if (_selectedPropertyType == "PG/Hostel") const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _pickPropertyImages,
                        icon: const Icon(Icons.image),
                        label: const Text("Update Property Images"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 185, 183, 175),
                          textStyle: poppinsTextStyle,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Display new images if selected.
                      _newPropertyImages.isNotEmpty
                          ? SizedBox(
                              height: 100,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _newPropertyImages.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                    margin: const EdgeInsets.all(4),
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                    ),
                                    child: kIsWeb
                                        ? Image.memory(_newPropertyImages[index], fit: BoxFit.cover)
                                        : Image.file(
                                            File(_newPropertyImages[index]),
                                            fit: BoxFit.cover,
                                          ),
                                  );
                                },
                              ),
                            )
                          : const Text("No new images selected", style: TextStyle(fontFamily: 'Poppins')),
                      const SizedBox(height: 16),
                      // Display existing images inside the update form.
                      _existingImages.isNotEmpty
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Existing Property Images:",
                                  style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  height: 100,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: _existingImages.length,
                                    itemBuilder: (context, index) {
                                      // Check if the URL is relative; if so, prepend the base URL.
                                      String imageUrl = _existingImages[index];
                                      if (!imageUrl.startsWith("http")) {
                                        imageUrl = '${widget.baseUrl}$imageUrl';
                                      }
                                      return Container(
                                        margin: const EdgeInsets.all(4),
                                        width: 100,
                                        height: 100,
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.grey),
                                        ),
                                        child: Image.network(imageUrl, fit: BoxFit.cover),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            )
                          : const Text("No existing images", style: TextStyle(fontFamily: 'Poppins')),
                      const SizedBox(height: 16),
                      const Text("Amenities",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: const [
                                Icon(Icons.fastfood),
                                SizedBox(width: 8),
                                Text("Food", style: TextStyle(fontFamily: 'Poppins')),
                              ],
                            ),
                          ),
                          Switch(
                            value: _foodAvailable,
                            onChanged: (val) {
                              setState(() {
                                _foodAvailable = val;
                              });
                            },
                            activeColor: Colors.green,
                            inactiveThumbColor: Colors.red,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: const [
                                Icon(Icons.wifi),
                                SizedBox(width: 8),
                                Text("Wifi", style: TextStyle(fontFamily: 'Poppins')),
                              ],
                            ),
                          ),
                          Switch(
                            value: _wifiAvailable,
                            onChanged: (val) {
                              setState(() {
                                _wifiAvailable = val;
                              });
                            },
                            activeColor: Colors.green,
                            inactiveThumbColor: Colors.red,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: const [
                                Icon(Icons.meeting_room),
                                SizedBox(width: 8),
                                Text("Rooms Available", style: TextStyle(fontFamily: 'Poppins')),
                              ],
                            ),
                          ),
                          Switch(
                            value: _roomsAvailable,
                            onChanged: (val) {
                              setState(() {
                                _roomsAvailable = val;
                              });
                            },
                            activeColor: Colors.green,
                            inactiveThumbColor: Colors.red,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Update button only.
                      Center(
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _updatePlace,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: orangeColor,
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
                            textStyle: poppinsTextStyle,
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                              : const Text("Update Property"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
