import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'new_loginpage.dart'; // Iska naam check kar lena apne project ke hisaab se

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _dataController = TextEditingController();
  List dataList = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchData(); // Page khulte hi data load hoga
  }

  // --- Helper: Token Headers Taiyar Karna ---
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token", // Ye 401 error fix karega
    };
  }

  // 1. DATA FETCH (READ)
  Future<void> fetchData() async {
    setState(() => _isLoading = true);
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('http://localhost:3000/data'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        setState(() => dataList = jsonDecode(response.body));
      } else {
        _showSnackBar("Data load nahi hua. Code: ${response.statusCode}");
      }
    } catch (e) {
      _showSnackBar("Connection error!");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // 2. DATA INSERT (CREATE)
  Future<void> addData() async {
    if (_dataController.text.isEmpty) return;
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('http://localhost:3000/data'),
        headers: headers,
        body: jsonEncode({"content": _dataController.text}),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        _dataController.clear();
        fetchData();
        _showSnackBar("Data save ho gaya!");
      }
    } catch (e) {
      _showSnackBar("Nahi save hua!");
    }
  }

  // 3. DATA DELETE (DELETE)
  Future<void> deleteData(String id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('http://localhost:3000/data/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        fetchData();
        _showSnackBar("Delete ho gaya!");
      }
    } catch (e) {
      _showSnackBar("Delete failed!");
    }
  }

  // 4. DATA UPDATE DIALOG (UPDATE)
  void _showUpdateDialog(String id, String currentContent) {
    TextEditingController _updateController = TextEditingController(text: currentContent);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Update Data"),
        content: TextField(controller: _updateController),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              final headers = await _getHeaders();
              final response = await http.put(
                Uri.parse('http://localhost:3000/data/$id'),
                headers: headers,
                body: jsonEncode({"content": _updateController.text}),
              );
              if (response.statusCode == 200) {
                fetchData();
                Navigator.pop(context);
                _showSnackBar("Update successful!");
              }
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("User private Dashboard!!"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const NewLoginPage()));
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _dataController,
              decoration: InputDecoration(
                hintText: "Kuch private likho...",
                suffixIcon: IconButton(icon: const Icon(Icons.send), onPressed: addData),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            const Text("YOUR SECURE DATA", style: TextStyle(fontWeight: FontWeight.bold)),
            const Divider(),
            Expanded(
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : dataList.isEmpty 
                  ? const Center(child: Text("Khali hai bhai!"))
                  : ListView.builder(
                      itemCount: dataList.length,
                      itemBuilder: (context, index) {
                        final item = dataList[index];
                        return Card(
                          child: ListTile(
                            leading: const Icon(Icons.security, color: Colors.green),
                            title: Text(item['content'] ?? ""),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => _showUpdateDialog(item['_id'], item['content']),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => deleteData(item['_id']),
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
    );
  }
}