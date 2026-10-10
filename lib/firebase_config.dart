import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<FirebaseApp> initializeFirebase() async {
  // Fetch config from backend
  final response = await http.get(Uri.parse('http://127.0.0.1:8000/users/api/firebase_config/'));
  if (response.statusCode != 200) {
    throw Exception('Failed to load Firebase config');
  }
  final config = jsonDecode(response.body);
  return await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: config['apiKey'],
      authDomain: config['authDomain'],
      projectId: config['projectId'],
      storageBucket: config['storageBucket'],
      messagingSenderId: config['messagingSenderId'],
      appId: config['appId'],
      measurementId: config['measurementId'],
    ),
  );
}
