import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Chrome (Web) ke liye localhost sahi hai
  final String baseUrl = "http://localhost:3000"; 

  // 1. REGISTER: Naya user banane ke liye
  Future<bool> register(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/register"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"username": username, "password": password}),
      );

      // Agar status 201 (Created) ya 200 hai toh success
      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      }
    } catch (e) {
      print("Register Error: $e");
    }
    return false;
  }

  // 2. LOGIN: Token lekar local storage mein save karta hai
  Future<bool> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"username": username, "password": password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        // Server se mila hua token save kar liya
        await prefs.setString('token', data['token']); 
        return true;
      }
    } catch (e) {
      print("Login Error: $e");
    }
    return false;
  }


  // 3. FETCH DATA: Sirf login user ka data lata hai
  Future<List<dynamic>> fetchData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.get(
        Uri.parse("$baseUrl/data"),
        headers: {
          "Authorization": token ?? "" // Header mein token bhej rahe hain
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print("Fetch Error: $e");
    }
    return [];
  }

  // 4. ADD DATA: Naya data save karta hai
  Future<void> addData(String content) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      await http.post(
        Uri.parse("$baseUrl/data"),
        headers: {
          "Content-Type": "application/json", 
          "Authorization": token ?? ""
        },
        body: jsonEncode({"content": content}),
      );
    } catch (e) {
      print("Add Data Error: $e");
    }
  }

  // Update Data
Future<bool> updateData(String id, String newContent) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  final response = await http.put(
    Uri.parse("$baseUrl/data/$id"),
    headers: {"Content-Type": "application/json", "Authorization": token ?? ""},
    body: jsonEncode({"content": newContent}),
  );
  return response.statusCode == 200;
}

// Delete Data
Future<bool> deleteData(String id) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  final response = await http.delete(
    Uri.parse("$baseUrl/data/$id"),
    headers: {"Authorization": token ?? ""},
  );
  return response.statusCode == 200;
}

}