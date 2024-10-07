import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fly_chat/Services/authServices.dart';
import 'package:fly_chat/View/Screens/ChatPage.dart'; // Import the ChatPage
import 'package:fly_chat/models/user.dart'; // Import your User model

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService _authService = AuthService();

  // Function to sign out
  void _signOut() async {
    await _authService.signOut(context: context);
    // Optionally navigate to login page after sign out
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          TextButton(
            onPressed: _signOut,
            child: Text(
              'Sign Out',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final users = snapshot.data!.docs;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              var userData = users[index].data() as Map<String, dynamic>;
              User user = User.fromMap(
                  userData); // Convert Firestore data to User model

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(userData['profileImageUrl'] ??
                        'https://via.placeholder.com/150'),
                    radius: 30,
                  ),
                  title: Text(user.name),
                  onTap: () {
                    // Navigate to ChatPage and pass the User model
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ChatPage(chatUser: user), // Pass the user model
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
