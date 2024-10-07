import 'dart:io';
import 'package:fly_chat/Models/message.dart';
import 'package:fly_chat/Services/authServices.dart';
import 'package:fly_chat/models/chat.dart';
import 'package:fly_chat/utils.dart';
import 'package:path/path.dart' as p;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:fly_chat/models/user.dart' as user;

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
  Stream<QuerySnapshot> getUserProfiles() {
    return _firebaseFirestore
        .collection('users')
        .where('uid', isNotEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .snapshots();
  }

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
    });
  }
}
