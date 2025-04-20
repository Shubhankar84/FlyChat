import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fly_chat/Services/authServices.dart';
import 'package:fly_chat/View/Screens/ChatPage.dart'; // Import the ChatPage
import 'package:fly_chat/View/Screens/LoginPage.dart';
import 'package:fly_chat/constants.dart';
import 'package:fly_chat/models/user.dart'; // Import your User model

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService _authService = AuthService();

  final TextEditingController _urlController = TextEditingController();

  // Function to sign out
  void _signOut() async {
    print("User signout");
    await _authService.signOut(context: context);
    Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (context) => LoginPage()), (route) => false);
    // Optionally navigate to login page after sign out
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          TextButton(
            onPressed: _signOut,
            child: const Text(
              'Sign Out',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _urlController,
                    decoration: InputDecoration(
                      labelText: "API URL",
                      prefixIcon: const Icon(Icons.lock),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                TextButton(
                  onPressed: () {
                    API_URL = _urlController.text.trim();
                    setState(() {});
                  }, // Implement forgot password functionality here
                  child: const Text("Set URL",
                      style: TextStyle(color: Colors.green)),
                ),
              ],
            ),
            const SizedBox(
              height: 8,
            ),
            Text("Current URL : $API_URL"),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance.collection('users').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final users = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      var userData =
                          users[index].data() as Map<String, dynamic>;
                      User user = User.fromMap(
                          userData); // Convert Firestore data to User model

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(
                                userData['profileImageUrl'] ??
                                    'https://via.placeholder.com/150'),
                            radius: 30,
                          ),
                          title: Text(user.name),
                          onTap: () {
                            // Navigate to ChatPage and pass the User model
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatPage(
                                    chatUser: user), // Pass the user model
                              ),
                            );
                          },
                        ),
                      );
                    },
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
