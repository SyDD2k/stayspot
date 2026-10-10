import 'dart:convert'; // For jsonDecode.
import 'dart:io' show File;
import 'dart:typed_data'; // For Uint8List.
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:upi_india/upi_india.dart';
import 'package:http/http.dart' as http;
import 'platform.dart'; // Your conditional platform helper (isAndroid, etc.)
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Token Payment App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const AddPlace(),
    );
  }
}

class AddPlace extends StatefulWidget {
  const AddPlace({ Key? key }) : super(key: key);

  @override
  State<AddPlace> createState() => _AddPlaceState();
}

class _AddPlaceState extends State<AddPlace> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  // Controllers for text fields.
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _rentController = TextEditingController();
  final TextEditingController _tokenController = TextEditingController();
  final TextEditingController _upiIdController = TextEditingController();

  // For MOBILE: store files in File variables.
  File? _tradeCertificate;
  List<File> _propertyImages = [];

  // For WEB: store files as bytes.
  Uint8List? _tradeCertificateBytes;
  List<Uint8List> _propertyImagesBytes = [];

  bool _foodAvailable = false;
  bool _wifiAvailable = false;
  bool _roomsAvailable = false;
  String _selectedPropertyType = "Room";

  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0)
      .animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _rentController.dispose();
    _tokenController.dispose();
    _upiIdController.dispose();
    super.dispose();
  }

  Future<void> _pickTradeCertificate() async {
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      if (kIsWeb) {
        final bytes = await file.readAsBytes();
        setState(() {
          _tradeCertificateBytes = bytes;
        });
      } else {
        setState(() {
          _tradeCertificate = File(file.path);
        });
      }
    }
  }

  Future<void> _pickPropertyImages() async {
    final List<XFile>? images = await _picker.pickMultiImage();
    if (images != null && images.isNotEmpty) {
      if (kIsWeb) {
        for (var img in images) {
          final bytes = await img.readAsBytes();
          setState(() {
            _propertyImagesBytes.add(bytes);
          });
        }
      } else {
        setState(() {
          _propertyImages = images.map((e) => File(e.path)).toList();
        });
      }
    }
  }

  Future<void> _initiateTransaction() async {
    if (_formKey.currentState!.validate()) {
      if (_upiIdController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter owner's UPI ID")),
        );
        return;
      }
      setState(() {
        _isLoading = true;
      });
      UpiIndia upi = UpiIndia();
      List<UpiApp> apps = await upi.getAllUpiApps();
      if (apps.isEmpty) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No UPI apps available on this device.")),
        );
        return;
      }
      UpiResponse response = await upi.startTransaction(
        app: apps.first,
        receiverUpiId: _upiIdController.text,
        receiverName: _nameController.text,
        transactionRefId: 'TxnRef${DateTime.now().millisecondsSinceEpoch}',
        transactionNote: 'Token Payment',
        amount: double.tryParse(_tokenController.text) ?? 0.0,
      );
      setState(() {
        _isLoading = false;
      });
      String paymentMessage;
      if (response.status == UpiPaymentStatus.SUCCESS) {
        paymentMessage = 'Payment Successful!\nTransaction ID: ${response.transactionId}\nDate & Time: ${DateTime.now().toLocal()}';
      } else {
        paymentMessage = 'Payment Failed: ${response.status}';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(paymentMessage)),
      );
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      String baseUrl = "http://127.0.0.1:8000/";
      if (!kIsWeb && isAndroid) {
        baseUrl = "http://10.0.2.2:8000/";
      }
      var uri = Uri.parse('${baseUrl}properties/');
      var request = http.MultipartRequest('POST', uri);
      request.fields['name'] = _nameController.text;
      request.fields['address'] = _addressController.text;
      request.fields['phone'] = _phoneController.text;
      request.fields['rent'] = _rentController.text;
      request.fields['token'] = _tokenController.text;
      request.fields['upi_id'] = _upiIdController.text;
      request.fields['property_type'] = _selectedPropertyType;
      request.fields['food_available'] = _foodAvailable.toString();
      request.fields['wifi_available'] = _wifiAvailable.toString();
      request.fields['rooms_available'] = _roomsAvailable.toString();
      if (kIsWeb) {
        if (_tradeCertificateBytes != null) {
          request.files.add(http.MultipartFile.fromBytes('trade_certificate', _tradeCertificateBytes!, filename: 'trade_certificate.jpg'));
        }
        for (var imgBytes in _propertyImagesBytes) {
          request.files.add(http.MultipartFile.fromBytes('images', imgBytes, filename: 'property_image.jpg'));
        }
      } else {
        if (_tradeCertificate != null) {
          request.files.add(await http.MultipartFile.fromPath('trade_certificate', _tradeCertificate!.path));
        }
        for (var imageFile in _propertyImages) {
          request.files.add(await http.MultipartFile.fromPath('images', imageFile.path));
        }
      }
      var response = await request.send();
      setState(() {
        _isLoading = false;
      });
      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Place added successfully!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to add place!")),
        );
      }
      _formKey.currentState!.reset();
      setState(() {
        _tradeCertificate = null;
        _tradeCertificateBytes = null;
        _propertyImages = [];
        _propertyImagesBytes = [];
        _foodAvailable = false;
        _wifiAvailable = false;
        _roomsAvailable = false;
        _selectedPropertyType = "Room";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final darkBlue = Colors.blue.shade900;
    final offWhite = Colors.grey.shade200;
    const orangeColor = Colors.orange;
    const poppinsTextStyle = TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, color: Colors.white);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Place", style: TextStyle(color: Colors.white, fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
        backgroundColor: darkBlue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Select Property Type", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
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
                  autofillHints: [AutofillHints.name],
                  validator: (value) => value == null || value.isEmpty ? "Please enter a name" : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: "Address",
                    prefixIcon: Icon(Icons.location_on),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.isEmpty ? "Please enter an address" : null,
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
                  validator: (value) => value == null || value.isEmpty ? "Please enter a phone number" : null,
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
                  validator: (value) => value == null || value.isEmpty ? "Please enter rent amount" : null,
                ),
                const SizedBox(height: 16),
                if (_selectedPropertyType == "PG/Hostel") ...[
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _pickTradeCertificate,
                        icon: const Icon(Icons.upload_file),
                        label: const Text("Upload Trade Certificate"),
                        style: ElevatedButton.styleFrom(backgroundColor: offWhite, textStyle: poppinsTextStyle),
                      ),
                      const SizedBox(width: 8),
                      if (kIsWeb)
                        _tradeCertificateBytes != null ? const Icon(Icons.check_circle, color: Colors.green) : const Icon(Icons.cancel, color: Colors.red)
                      else
                        _tradeCertificate != null ? const Icon(Icons.check_circle, color: Colors.green) : const Icon(Icons.cancel, color: Colors.red),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text("Trade Certificate must be legitimate as per Karnataka Govt law, Section 420, IPC.",
                      style: TextStyle(color: Colors.red, fontFamily: 'Poppins')),
                  const SizedBox(height: 16),
                ],
                ElevatedButton.icon(
                  onPressed: _pickPropertyImages,
                  icon: const Icon(Icons.image),
                  label: const Text("Upload Property Images"),
                  style: ElevatedButton.styleFrom(backgroundColor: offWhite, textStyle: poppinsTextStyle),
                ),
                const SizedBox(height: 8),
                kIsWeb
                    ? _propertyImagesBytes.isNotEmpty
                        ? SizedBox(
                            height: 100,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _propertyImagesBytes.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  margin: const EdgeInsets.all(4),
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
                                  child: Image.memory(_propertyImagesBytes[index], fit: BoxFit.cover),
                                );
                              },
                            ),
                          )
                        : const Text("No images selected", style: TextStyle(fontFamily: 'Poppins'))
                    : _propertyImages.isNotEmpty
                        ? SizedBox(
                            height: 100,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _propertyImages.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  margin: const EdgeInsets.all(4),
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
                                  child: Image.file(_propertyImages[index], fit: BoxFit.cover),
                                );
                              },
                            ),
                          )
                        : const Text("No images selected", style: TextStyle(fontFamily: 'Poppins')),
                const SizedBox(height: 16),
                const Text("Amenities", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
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
                TextFormField(
                  controller: _tokenController,
                  decoration: const InputDecoration(
                    labelText: "Token Amount Payment",
                    prefixIcon: Icon(Icons.payment),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) => value == null || value.isEmpty ? "Please enter token amount" : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _upiIdController,
                  decoration: InputDecoration(
                    labelText: "Owner's UPI ID",
                    prefixIcon: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(Icons.account_balance_wallet, color: Colors.green),
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.isEmpty ? "Please enter UPI ID" : null,
                ),
                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _initiateTransaction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: orangeColor,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                      textStyle: poppinsTextStyle,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                        : const Text("Pay via UPI"),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: orangeColor,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                      textStyle: poppinsTextStyle,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                        : const Text("Add Place"),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
