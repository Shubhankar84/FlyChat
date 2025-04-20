import 'dart:convert';
import 'dart:io';
import 'package:fly_chat/Models/message.dart';
import 'package:fly_chat/Services/authServices.dart';
import 'package:fly_chat/constants.dart';
import 'package:fly_chat/models/chat.dart';
import 'package:fly_chat/utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:fly_chat/models/user.dart' as user;
import 'package:http/http.dart' as http;

class ChatService {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  final GetIt _getIt = GetIt.instance;
  late AuthService _authService;
  CollectionReference? _userCollection;
  CollectionReference? _chatsCollection;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  ChatService() {
    _authService = _getIt.get<AuthService>();
    _setupCollectionReferences();
  }

  // Remove student/professional logic, only use the User model
  user.User _fromFirestore(Map<String, dynamic> data) {
    return user.User.fromMap(data);
  }

  void _setupCollectionReferences() {
    _userCollection = _firebaseFirestore
        .collection('users')
        .withConverter<user.User>(
          fromFirestore: (snapshots, _) => _fromFirestore(snapshots.data()!),
          toFirestore: (userProfile, _) => userProfile.toJson(),
        );

    _chatsCollection =
        _firebaseFirestore.collection('chats').withConverter<Chat>(
              fromFirestore: (snapshots, _) => Chat.fromJson(snapshots.data()!),
              toFirestore: (chat, _) => chat.toJson(),
            );
  }

  // Fetch other user profiles (excluding the current user)
  Stream<QuerySnapshot> getUserProfilesExcludingCurrentUser() {
    return _firebaseFirestore
        .collection('users')
        .where('uid', isNotEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .snapshots();
  }

Future<DocumentSnapshot<Map<String, dynamic>>?> getCurrentUserProfile() async {
  QuerySnapshot<Map<String, dynamic>> snapshot = await _firebaseFirestore
      .collection('users')
      .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
      .get();

  if (snapshot.docs.isNotEmpty) {
    return snapshot.docs.first;
  } else {
    return null; // or throw an exception if needed
  }
}


  Future<bool> send_alert_email(String currUid, File imageFile) async {
    try {
      QuerySnapshot snapshot = await _firebaseFirestore
          .collection('users')
          .where('uid', isEqualTo: currUid)
          .get();

      if (snapshot.docs.isNotEmpty) {
        var userData = snapshot.docs.first.data() as Map<String, dynamic>;
        String name = userData['name'];
        String email = userData['email'];

        print("name to which email is sent: $name");
        print("email to which email is sent: $email");

        final uri = Uri.parse("${API_URL}send_email");

        var request = http.MultipartRequest('POST', uri)
          ..fields['name'] = name
          ..fields['receiver_email'] = email
          ..files.add(await http.MultipartFile.fromPath(
            'image',
            imageFile.path,
          ));

        var streamedResponse = await request.send();
        var response = await http.Response.fromStream(streamedResponse);

        print("status: ${response.statusCode}, body: ${response.body}");

        return response.statusCode == 200;
      }

      return false;
    } catch (e) {
      print("Error sending email: $e");
      return false;
    }
  }

  // Future<bool> send_alert_email(String currUid) async {
  //   try {
  //     QuerySnapshot snapshot = await _firebaseFirestore
  //         .collection('users')
  //         .where('uid', isEqualTo: currUid)
  //         .get();

  //     if (snapshot.docs.isNotEmpty) {
  //       var userData = snapshot.docs.first.data() as Map<String, dynamic>;
  //       String name = userData['name'];
  //       String email = userData['email'];

  //       print("name to which email is sent: $name");
  //       print("email to which email is sent: $email");

  //       final url = Uri.parse("${API_URL}send_email");
  //       final response = await http.post(
  //         url,
  //         headers: {
  //           'Content-Type': 'application/json',
  //         },
  //         body: jsonEncode({
  //           'name': name,
  //           'receiver_email': email,
  //         }),
  //       );

  //       if (response.statusCode == 200) {
  //         return true;
  //       }
  //     }
  //     return false;
  //   } catch (e) {
  //     print("Error: $e");
  //     return false;
  //   }
  // }

  Future<bool> checkChatExists(String uid1, String uid2) async {
    String chatID = generateChatID(uid1: uid1, uid2: uid2);
    final result = await _chatsCollection?.doc(chatID).get();
    if (result != null) {
      return result.exists;
    }
    return false;
  }

  Future<void> createNewChat(String uid1, String uid2) async {
    String chatID = generateChatID(uid1: uid1, uid2: uid2);
    final docRef = _chatsCollection!.doc(chatID);
    final chat = Chat(
      id: chatID,
      participants: [uid1, uid2],
      messages: [],
    );
    await docRef.set(chat);
  }

  Future<void> sendChatMessage(
      String uid1, String uid2, Message message) async {
    String chatID = generateChatID(uid1: uid1, uid2: uid2);
    final docRef = _chatsCollection!.doc(chatID);

    final docSnapshot = await docRef.get();
    if (!docSnapshot.exists) {
      print('Chat document does not exist, creating a new chat.');
      await createNewChat(uid1, uid2);
    }

    print('Updating chat document with new message: ${message.toJson()}');

    await docRef.update({
      'messages': FieldValue.arrayUnion([message.toJson()]),
    });
  }

  Stream<DocumentSnapshot<Chat>> getChatData(String uid1, String uid2) {
    String chatID = generateChatID(uid1: uid1, uid2: uid2);
    return _chatsCollection!.doc(chatID).snapshots()
        as Stream<DocumentSnapshot<Chat>>;
  }

  Future<String?> uploadImageToChat(
      {required File file, required String chatID}) async {
    Reference fileRef = _firebaseStorage
        .ref('chats/$chatID')
        .child('${DateTime.now().toIso8601String()}${p.extension(file.path)}');

    UploadTask task = fileRef.putFile(file);

    return task.then((p) {
      if (p.state == TaskState.success) {
        return fileRef.getDownloadURL();
      }
      return null;
    });
  }

  // Future<String?> uploadVideoToChat(
  //     {required XFile file, required String chatID}) async {
  //   Reference fileRef = _firebaseStorage
  //       .ref('chats/$chatID')
  //       .child('${DateTime.now().toIso8601String()}${p.extension(file.path)}');

  //   UploadTask task = fileRef.putFile(file);

  //   return task.then((p) {
  //     if (p.state == TaskState.success) {
  //       return fileRef.getDownloadURL();
  //     }
  //     return null;
  //   });
  // }

  // check if chat message is inappropriate or not

  Future<bool> verifyText(String msg) async {
    // var request = http.MultipartRequest('POST', Uri.parse('${API_URL}analyze')

    final url = Uri.parse("${API_URL}classifytext");

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'text': msg,
        },
      );

      if (response.statusCode == 200) {
        // Expecting response body to be: true or false
        return response.body.toLowerCase().contains('true');
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Exception: $e');
      return false;
    }
  }

  Future<String?> uploadVideoToChat({
    required XFile file,
    required String chatID,
  }) async {
    print("Upload videoToChat Function is called");
    File convertedFile = File(file.path); // Convert XFile to File

    Reference fileRef = FirebaseStorage.instance
        .ref('chats/$chatID')
        .child('${DateTime.now().toIso8601String()}${p.extension(file.path)}');

    UploadTask task = fileRef.putFile(convertedFile);

    try {
      TaskSnapshot snapshot = await task;
      if (snapshot.state == TaskState.success) {
        return await fileRef.getDownloadURL();
      }
    } catch (e) {
      print('Error uploading video: $e');
    }
    return null;
  }
}
