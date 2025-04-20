import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'HomePage.dart'; // Import your HomePage
import 'LoginPage.dart'; // Import your LoginPage

class CheckUserScreen extends StatefulWidget {
  const CheckUserScreen({super.key});

  @override
  _CheckUserScreenState createState() => _CheckUserScreenState();
}

class _CheckUserScreenState extends State<CheckUserScreen> {
  final bool _isLoading = true; // Variable to manage loading state

  @override
  void initState() {
    super.initState();
    _checkUser(); // Call the method to check user status
  }

  // Function to check if the user is logged in
  void _checkUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    // Wait for 2 seconds for demo purpose (you can remove it in production)
    await Future.delayed(const Duration(seconds: 2));
    
    if (user != null) {
      // If the user is logged in, navigate to HomePage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } else {
      // If no user is logged in, navigate to LoginPage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator() // Show loading indicator while checking user status
            : Container(), // Just a fallback empty container (though this state won't happen in this case)
      ),
    );
  }
}
