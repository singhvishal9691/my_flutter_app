import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'new_loginpage.dart'; // Login page par wapas jaane ke liye

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isRegistering = false; // Loading indicator ke liye

  // UPDATED REGISTER FUNCTION
  Future<void> registerUser() async {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bhai, email aur password dono daalo!")),
      );
      return;
    }

    setState(() {
      _isRegistering = true; // Button ko disable/loading karne ke liye
    });

    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/register'), 
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      print("Response Status: ${response.statusCode}"); // Debugging ke liye terminal mein dikhega

      if (response.statusCode == 201 || response.statusCode == 200) {
        // SUCCESS: Account ban gaya
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Mubarak ho! Account ban gaya. Ab Login karo.")),
        );

        // 1 second ruko taaki user message padh le, fir Login page par bhej do
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const NewLoginPage()),
            );
          }
        });
      } else {
        // ERROR: User pehle se hai ya koi aur issue
        // Backend se hum message bhej rahe hain: res.status(400).send({ error: "..." });
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        String errorMessage = errorData['error'] ?? "User pehle se hai ya DB error!";
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
      // SERVER CONNECTIVITY ERROR
      print("Catch Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Server connect nahi ho raha: $e")),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isRegistering = false; // Loading khatam
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      body: Center(
        child: Container(
          width: 350,
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Create Account",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: "Email", 
                  hintText: "example@gmail.com",
                  border: OutlineInputBorder()
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Password", 
                  border: OutlineInputBorder()
                ),
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  onPressed: _isRegistering ? null : registerUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    disabledBackgroundColor: Colors.green.withOpacity(0.5),
                  ),
                  child: _isRegistering 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("REGISTER", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context, 
                    MaterialPageRoute(builder: (context) => const NewLoginPage())
                  );
                },
                child: const Text("Pehle se account hai? Login karo"),
              )
            ],
          ),
        ),
      ),
    );
  }
}