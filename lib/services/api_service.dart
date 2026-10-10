import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiService {
  // Determine base URL dynamically for web or mobile
  static String get baseUrl {
    if (kIsWeb) {
      return "http://127.0.0.1:8000";
    } else {
      return "http://10.0.2.2:8000";
    }
  }

  /// Fetch all test models
  static Future<List<dynamic>> fetchTestModels() async {
    final url = Uri.parse("${baseUrl}/users/api/testmodels/");
    print("Fetching data from: $url");

    try {
      final response = await http.get(url);

      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print("Error: Failed to fetch data. Status: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Network Error: $e");
      return [];
    }
  }

  /// Create a new test model
  static Future<bool> createTestModel(String name, String password) async {
    final url = Uri.parse("${baseUrl}/users/api/testmodels/create/");
    print("Sending POST request to: $url");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"name": name, "password": password}),
      );

      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 201) {
        print("✅ Successfully created test model!");
        return true;
      } else {
        print("⚠️ Failed to create test model. Status: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("❌ Network error: $e");
      return false;
    }
  }

  // FAQ API
  Future<List<dynamic>> fetchFaqQuestions() async {
    final response = await http.get(Uri.parse('${baseUrl}/faq/questions/'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load FAQ questions');
    }
  }

  Future<List<dynamic>> searchFaqQuestions(String query) async {
    final response = await http.get(Uri.parse('${baseUrl}/faq/questions/?search=$query'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to search FAQ questions');
    }
  }

  Future<Map<String, dynamic>> fetchFaqQuestionDetail(int questionId) async {
    final response = await http.get(Uri.parse('${baseUrl}/faq/questions/$questionId/'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load FAQ question detail');
    }
  }

  Future<void> postFaqQuestion(String text) async {
    final response = await http.post(
      Uri.parse('${baseUrl}/faq/questions/'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'text': text}),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to post FAQ question');
    }
  }

  Future<void> postFaqAnswer(int questionId, String text) async {
    final response = await http.post(
      Uri.parse('${baseUrl}/faq/answers/'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'question': questionId, 'text': text}),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to post FAQ answer');
    }
  }

  Future<int> likeFaqQuestion(int questionId) async {
    final response = await http.post(Uri.parse('${baseUrl}/faq/questions/$questionId/like/'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['likes'] as int;
    } else {
      throw Exception('Failed to like question');
    }
  }

  Future<int> dislikeFaqQuestion(int questionId) async {
    final response = await http.post(Uri.parse('${baseUrl}/faq/questions/$questionId/dislike/'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['dislikes'] as int;
    } else {
      throw Exception('Failed to dislike question');
    }
  }
}
