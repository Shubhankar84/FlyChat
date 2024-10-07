import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dash_chat_2/dash_chat_2.dart' as dashChat;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fly_chat/Models/message.dart';
import 'package:fly_chat/Services/authServices.dart';
import 'package:fly_chat/Services/mediaService.dart';
import 'package:fly_chat/models/chat.dart';
import 'package:fly_chat/models/user.dart' as user;
import 'package:fly_chat/Services/chatServices.dart';
import 'package:fly_chat/utils.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

class ChatPage extends StatefulWidget {
  final user.User chatUser;
  const ChatPage({
    super.key,
    required this.chatUser,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final GetIt _getIt = GetIt.instance;

  late AuthService _authService;
  late ChatService _chatService;
  late MediaService _mediaService;

  dashChat.ChatUser? currentUser, otherUser;

  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    _chatService = _getIt.get<ChatService>();
    _mediaService = _getIt.get<MediaService>();

    currentUser = dashChat.ChatUser(
      id: FirebaseAuth.instance.currentUser!.uid,
      firstName: FirebaseAuth.instance.currentUser!.displayName,
    );
    otherUser = dashChat.ChatUser(
      id: widget.chatUser.uid,
      firstName: widget.chatUser.name,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chatUser.name!),
      ),
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return StreamBuilder(
      stream: _chatService.getChatData(
        currentUser!.id,
        otherUser!.id,
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        Chat? chat = snapshot.data?.data();
        List<dashChat.ChatMessage> messages = [];
        if (chat != null && chat.messages != null) {
          messages = _generateChatMessageList(chat.messages!);
        }

        return dashChat.DashChat(
          messageOptions: const dashChat.MessageOptions(
            showOtherUsersAvatar: true,
            showTime: true,
          ),
          inputOptions: dashChat.InputOptions(
            alwaysShowSend: true,
            trailing: [
              _mediaMessageButton(context),
            ],
          ),
          currentUser: currentUser!,
          onSend: _sendMessage,
          messages: messages,
        );
      },
    );
  }

  Future<void> _sendMessage(dashChat.ChatMessage chatMessage) async {
    if (chatMessage.medias?.isNotEmpty ?? false) {
      // Image message
      if (chatMessage.medias!.first.type == dashChat.MediaType.image) {
        Message message = Message(
          senderID: chatMessage.user.id,
          content: chatMessage.medias!.first.url,
          messageType: MessageType.Image,
          sentAt: Timestamp.fromDate(chatMessage.createdAt),
        );

        await _chatService.sendChatMessage(
            currentUser!.id, otherUser!.id, message);
      }
    } else {
      // Text message
      Message message = Message(
        senderID: currentUser!.id,
        content: chatMessage.text,
        messageType: MessageType.Text,
        sentAt: Timestamp.fromDate(chatMessage.createdAt),
      );

      await _chatService.sendChatMessage(
          currentUser!.id, otherUser!.id, message);
    }
  }

  List<dashChat.ChatMessage> _generateChatMessageList(List<Message> messages) {
    List<dashChat.ChatMessage> chatMessages = messages.map((m) {
      if (m.messageType == MessageType.Image) {
        return dashChat.ChatMessage(
          medias: [
            dashChat.ChatMedia(
              url: m.content!,
              fileName: '',
              type: dashChat.MediaType.image,
            ),
          ],
          user: m.senderID == currentUser!.id ? currentUser! : otherUser!,
          createdAt: m.sentAt!.toDate(),
        );
      } else {
        return dashChat.ChatMessage(
          text: m.content!,
          user: m.senderID == currentUser!.id ? currentUser! : otherUser!,
          createdAt: m.sentAt!.toDate(),
        );
      }
    }).toList();

    chatMessages.sort((a, b) {
      return b.createdAt.compareTo(a.createdAt);
    });

    return chatMessages;
  }

  Widget _mediaMessageButton(BuildContext context) {
    return IconButton(
      onPressed: () async {
        File? file = await _mediaService.getImageFromGallery();
        if (file != null) {
          String chatID = generateChatID(
            uid1: currentUser!.id,
            uid2: otherUser!.id,
          );

          bool isInappropriate =
              await _analyzeImageForInappropriateContent(file);
          print("isInappropriate: ${isInappropriate}");
          if (!isInappropriate) {
            String? downloadURL = await _chatService.uploadImageToChat(
              file: file,
              chatID: chatID,
            );

            if (downloadURL != null) {
              dashChat.ChatMessage chatMessage = dashChat.ChatMessage(
                user: currentUser!,
                createdAt: DateTime.now(),
                medias: [
                  dashChat.ChatMedia(
                    url: downloadURL,
                    fileName: '',
                    type: dashChat.MediaType.image,
                  ),
                ],
              );

              _sendMessage(chatMessage);
            }
          } else {
            try {
              // final url =
              //     Uri.parse("http://192.168.0.162:4001/print_phone_number");
              final url = Uri.parse(
                  "https://duckling-crack-oddly.ngrok-free.app/print_phone_number");
              final response = await http.post(
                url,
                headers: {
                  'Content-Type': 'application/json',
                },
                body: jsonEncode({
                  'phone_number': "+917738874661",
                }),
              );

              if (response.statusCode == 200) {
                print("Phone number sent successfully");
              } else {
                print(
                    "Faild to send to phone no statuscode :${response.statusCode}");
              }
            } catch (e) {
              print(e.toString());
            }
            _showInappropriateContentAlert(context);
          }
        }
      },
      icon: Icon(Icons.image),
    );
  }

  Future<bool> _analyzeImageForInappropriateContent(File file) async {
    try {
      print("analyze image is called");
      String fileName = basename(file.path);
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://duckling-crack-oddly.ngrok-free.app/analyze'),
      );
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          file.path,
          filename: fileName,
        ),
      );
      var response = await request.send();
      print("response of analyze image is ${response.statusCode}");
      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        print("Raw response data: $responseData");
        var jsonData = jsonDecode(responseData);
        print("Json data inappropriate output is $jsonData");

        // Convert the response to a boolean
        if (jsonData is String) {
          return jsonData.toLowerCase() == 'true';
        } else if (jsonData is bool) {
          return jsonData;
        } else {
          print("Unexpected response type: ${jsonData.runtimeType}");
          return false;
        }
      } else {
        print("HTTP error: ${response.statusCode}");
        throw Exception("Failed to analyze image");
      }
    } catch (e) {
      print("Error: $e");
      return false;
    }
  }

  void _showInappropriateContentAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Inappropriate Content'),
          content: Text(
              'The selected image contains inappropriate content and cannot be sent.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  } 
}
