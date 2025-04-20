// import 'dart:convert';
// import 'dart:io';
// import 'dart:ui';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:dash_chat_2/dash_chat_2.dart' as dashChat;
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:fly_chat/Models/message.dart';
// import 'package:fly_chat/Services/authServices.dart';
// import 'package:fly_chat/Services/blockTimerService.dart';
// import 'package:fly_chat/Services/mediaService.dart';
// import 'package:fly_chat/View/Screens/blockedScreen.dart';
// import 'package:fly_chat/constants.dart';
// import 'package:fly_chat/models/chat.dart';
// import 'package:fly_chat/models/user.dart' as user;
// import 'package:fly_chat/Services/chatServices.dart';
// import 'package:fly_chat/utils.dart';
// import 'package:get_it/get_it.dart';
// import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart';
// import 'package:path/path.dart';

// class ChatPage extends StatefulWidget {
//   final user.User chatUser;
//   const ChatPage({
//     super.key,
//     required this.chatUser,
//   });

//   @override
//   State<ChatPage> createState() => _ChatPageState();
// }

// class _ChatPageState extends State<ChatPage> {
//   final GetIt _getIt = GetIt.instance;

//   late AuthService _authService;
//   late ChatService _chatService;
//   late MediaService _mediaService;
//   // late TimerService _timerService;
//   bool isLoading = false;

//   dashChat.ChatUser? currentUser, otherUser;

//   @override
//   void initState() {
//     super.initState();
//     _authService = _getIt.get<AuthService>();
//     _chatService = _getIt.get<ChatService>();
//     _mediaService = _getIt.get<MediaService>();
//     // _timerService = _getIt.get<TimerService>();

//     currentUser = dashChat.ChatUser(
//       id: FirebaseAuth.instance.currentUser!.uid,
//       firstName: FirebaseAuth.instance.currentUser!.displayName,
//     );
//     otherUser = dashChat.ChatUser(
//       id: widget.chatUser.uid,
//       firstName: widget.chatUser.name,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.chatUser.name),
//       ),
//       body: Stack(children: [
//         _buildUI(),
//         if (isLoading)
//           Stack(
//             children: [
//               BackdropFilter(
//                 filter: ImageFilter.blur(
//                   sigmaX: 5,
//                   sigmaY: 5,
//                 ),
//                 child: Container(
//                   color: Colors.black.withOpacity(0.2),
//                 ),
//               ),
//               const Center(
//                 child: CircularProgressIndicator(),
//               )
//             ],
//           )
//       ]),
//     );
//   }

//   Widget _buildUI() {
//     return StreamBuilder(
//       stream: _chatService.getChatData(
//         currentUser!.id,
//         otherUser!.id,
//       ),
//       builder: (context, snapshot) {
//         if (!snapshot.hasData) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         Chat? chat = snapshot.data?.data();
//         List<dashChat.ChatMessage> messages = [];
//         if (chat != null && chat.messages != null) {
//           messages = _generateChatMessageList(chat.messages!);
//         }

//         return dashChat.DashChat(
//           messageOptions: const dashChat.MessageOptions(
//             showOtherUsersAvatar: true,
//             showTime: true,
//           ),
//           inputOptions: dashChat.InputOptions(
//             alwaysShowSend: true,
//             trailing: [
//               _mediaMessageButton(context),
//               _videoMediaButton(context)
//             ],
//           ),
//           currentUser: currentUser!,
//           onSend: _sendMessage,
//           messages: messages,
//         );
//       },
//     );
//   }

//   Future<void> _sendMessage(dashChat.ChatMessage chatMessage) async {
//     BuildContext context = this.context; // Capture context from StatefulWidget
//     print("_sendMessage function is called");

//     if (chatMessage.medias?.isNotEmpty ?? false) {
//       print(
//           "chatMessage.medias?.isNotEmpty: ${chatMessage.medias!.isNotEmpty}");
//       print("media type: ${chatMessage.medias!.first.type}");

//       if (chatMessage.medias!.first.type == dashChat.MediaType.image) {
//         print("yaha image send call kiya hai...");
//         Message message = Message(
//           senderID: chatMessage.user.id,
//           content: chatMessage.medias!.first.url,
//           messageType: MessageType.Image,
//           sentAt: Timestamp.fromDate(chatMessage.createdAt),
//         );

//         await _chatService.sendChatMessage(
//             currentUser!.id, otherUser!.id, message);

//         print("yaha image send huva hoga..");
//       } else if (chatMessage.medias!.first.type == dashChat.MediaType.video) {
//         print("yaha video send call kiya hai...");
//         Message message = Message(
//           senderID: chatMessage.user.id,
//           content: chatMessage.medias!.first.url,
//           messageType: MessageType.Video,
//           sentAt: Timestamp.fromDate(chatMessage.createdAt),
//         );

//         await _chatService.sendChatMessage(
//             currentUser!.id, otherUser!.id, message);

//         print("yaha video send huva hoga..");
//       }
//     } else {
//       print("Text else for _sendMessage");
//       // Text message

//       // before sending text message call verifyText in chatServices to check if message inappropriate or not
//       bool res = await _chatService.verifyText(chatMessage.text);
//       print('res: $res');
//       if (!res) {
//         Message message = Message(
//           senderID: currentUser!.id,
//           content: chatMessage.text,
//           messageType: MessageType.Text,
//           sentAt: Timestamp.fromDate(chatMessage.createdAt),
//         );

//         await _chatService.sendChatMessage(
//             currentUser!.id, otherUser!.id, message);

//         print("yaha text send huva hoga..");
//       } else {
//         print("message is inappropriate");

//         await TimerService.startBlockTimer();
//         print("timer started and push to block screen");
//         Navigator.pushAndRemoveUntil(
//             context,
//             MaterialPageRoute(
//               builder: (context) => BlockedScreen(),
//             ),
//             (route) => false);
//       }
//     }
//   }

//   List<dashChat.ChatMessage> _generateChatMessageList(List<Message> messages) {
//     List<dashChat.ChatMessage> chatMessages = messages.map((m) {
//       if (m.messageType == MessageType.Image) {
//         return dashChat.ChatMessage(
//           medias: [
//             dashChat.ChatMedia(
//               url: m.content!,
//               fileName: '',
//               type: dashChat.MediaType.image,
//             ),
//           ],
//           user: m.senderID == currentUser!.id ? currentUser! : otherUser!,
//           createdAt: m.sentAt!.toDate(),
//         );
//       } else if (m.messageType == MessageType.Video) {
//         return dashChat.ChatMessage(
//           medias: [
//             dashChat.ChatMedia(
//               url: m.content!,
//               fileName: '',
//               type: dashChat.MediaType.video, // Add video type
//             ),
//           ],
//           user: m.senderID == currentUser!.id ? currentUser! : otherUser!,
//           createdAt: m.sentAt!.toDate(),
//         );
//       } else {
//         return dashChat.ChatMessage(
//           text: m.content!,
//           user: m.senderID == currentUser!.id ? currentUser! : otherUser!,
//           createdAt: m.sentAt!.toDate(),
//         );
//       }
//     }).toList();

//     chatMessages.sort((a, b) {
//       return b.createdAt.compareTo(a.createdAt);
//     });

//     return chatMessages;
//   }

//   Widget _videoMediaButton(BuildContext context) {
//     return IconButton(
//         onPressed: () async {
//           XFile? file = await _mediaService.getVideo();
//           if (file != null) {
//             String chatID =
//                 generateChatID(uid1: currentUser!.id, uid2: otherUser!.id);

//             print("analyze video is called");

//             setState(() {
//               isLoading = true;
//             });

//             bool isInappropriate =
//                 await _analyzeVideoForInappropriateContent(file);

//             print("isInappropriate: $isInappropriate");

//             if (!isInappropriate) {
//               String? downloadURL = await _chatService.uploadVideoToChat(
//                 file: file,
//                 chatID: chatID,
//               );

//               print("Download URL of Video: $downloadURL");
//               if (downloadURL != null) {
//                 dashChat.ChatMessage chatMessage = dashChat.ChatMessage(
//                   user: currentUser!,
//                   createdAt: DateTime.now(),
//                   medias: [
//                     dashChat.ChatMedia(
//                       url: downloadURL,
//                       fileName: '',
//                       type: dashChat.MediaType.video,
//                     ),
//                   ],
//                 );

//                 await _sendMessage(chatMessage);
//                 setState(() {
//                   isLoading = false;
//                 });
//               }
//             } else {
//               try {

//                 print("analyze video output is true");

//                 setState(() {
//                   isLoading = false;
//                 });

//                 await TimerService.startBlockTimer();
//                 print("timer started and push to block screen");
//                 Navigator.pushAndRemoveUntil(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => BlockedScreen(),
//                     ),
//                     (route) => false);

//               } catch (e) {
//                 print(e.toString());
//               }
//             }

//           }
//         },
//         icon: const Icon(Icons.video_camera_back_outlined));
//   }

//   Widget _mediaMessageButton(BuildContext context) {
//     return IconButton(
//       onPressed: () async {
//         File? file = await _mediaService.getImageFromGallery();
//         if (file != null) {
//           String chatID = generateChatID(
//             uid1: currentUser!.id,
//             uid2: otherUser!.id,
//           );

//           print("analyze image is called here");
//           setState(() {
//             isLoading = true;
//           });
//           bool isInappropriate =
//               await _analyzeImageForInappropriateContent(file);

//           print("isInappropriate: $isInappropriate");
//           if (!isInappropriate) {
//             String? downloadURL = await _chatService.uploadImageToChat(
//               file: file,
//               chatID: chatID,
//             );

//             if (downloadURL != null) {
//               dashChat.ChatMessage chatMessage = dashChat.ChatMessage(
//                 user: currentUser!,
//                 createdAt: DateTime.now(),
//                 medias: [
//                   dashChat.ChatMedia(
//                     url: downloadURL,
//                     fileName: '',
//                     type: dashChat.MediaType.image,
//                   ),
//                 ],
//               );

//               setState(() {
//                 isLoading = false;
//               });
//               _sendMessage(chatMessage);
//             }
//           } else {
//             try {
//               // final url =
//               //     Uri.parse("http://192.168.0.162:4001/print_phone_number");

//               // send email to parent
//               bool result =
//                   await _chatService.send_alert_email(currentUser!.id, file);

//               if (result) {
//                 print("Email sent successfully");
//               } else {
//                 print("Email not sent");
//               }

//               // user.User? userDetails =
//               //     await _authService.getUserDetails(currentUser!.id);

//               // print("User Details: $userDetails");

//               setState(() {
//                 isLoading = false;
//               });

//             } catch (e) {
//               print(e.toString());
//             }
//             _showInappropriateContentAlert(context);
//             // here if isINappropriate is true then start the timer.
//             await TimerService.startBlockTimer();
//             print("timer started and push to block screen");
//             Navigator.pushAndRemoveUntil(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => BlockedScreen(),
//                 ),
//                 (route) => false);
//           }
//         }
//       },
//       icon: const Icon(Icons.image),
//     );
//   }

//   Future<bool> _analyzeVideoForInappropriateContent(XFile file) async {
//     try {
//       print("analyze video in funciton");
//       String fileName = basename(file.path);

//       DocumentSnapshot<Map<String, dynamic>>? snapshot =
//           await _chatService.getCurrentUserProfile();

//       String name = "";
//       String email = "";

//       if (snapshot!.exists) {
//         final data = snapshot.data();
//         if (data != null) {
//           name = data['name'] ?? '';
//           email = data['email'] ?? '';

//           print('Name: $name');
//           print('Email: $email');
//         } else {
//           print('No data found in snapshot');
//         }
//       } else {
//         print('Document does not exist');
//       }

//       var request = http.MultipartRequest('POST', Uri.parse('${API_URL}analyzevideo'))
//         ..fields['name'] = name
//         ..fields['receiver_email'] = email
//         ..files.add(await http.MultipartFile.fromPath('file', file.path,
//             filename: fileName));

//       var response = await request.send();
//       print("response of analyze video is ${response.statusCode}");
//       if (response.statusCode == 200) {
//         var responseData = await response.stream.bytesToString();
//         print("Raw response data: $responseData");
//         var jsonData = jsonDecode(responseData);
//         print("Json data inappropriate output is $jsonData");

//         // Convert the response to a boolean
//         if (jsonData is String) {
//           return jsonData.toLowerCase() == 'true';
//         } else if (jsonData is bool) {
//           return jsonData;
//         } else {
//           print("Unexpected response type: ${jsonData.runtimeType}");
//           return false;
//         }
//       } else {
//         print("HTTP error: ${response.statusCode}");
//         throw Exception("Failed to analyze image");
//       }
//     } catch (e) {
//       print("Error: $e");
//       return true;
//     }
//   }

//   Future<bool> _analyzeImageForInappropriateContent(File file) async {
//     try {
//       print("analyze image is called");
//       String fileName = basename(file.path);
//       var request = http.MultipartRequest('POST', Uri.parse('${API_URL}analyze')
//           // Uri.parse('http://192.168.0.162:4001/analyze'),
//           // Uri.parse('https://duckling-crack-oddly.ngrok-free.app/analyze'),
//           );
//       request.files.add(
//         await http.MultipartFile.fromPath(
//           'image',
//           file.path,
//           filename: fileName,
//         ),
//       );
//       var response = await request.send();
//       print("response of analyze image is ${response.statusCode}");
//       if (response.statusCode == 200) {
//         var responseData = await response.stream.bytesToString();
//         print("Raw response data: $responseData");
//         var jsonData = jsonDecode(responseData);
//         print("Json data inappropriate output is $jsonData");

//         // Convert the response to a boolean
//         if (jsonData is String) {
//           return jsonData.toLowerCase() == 'true';
//         } else if (jsonData is bool) {
//           return jsonData;
//         } else {
//           print("Unexpected response type: ${jsonData.runtimeType}");
//           return false;
//         }
//       } else {
//         print("HTTP error: ${response.statusCode}");
//         throw Exception("Failed to analyze image");
//       }
//     } catch (e) {
//       print("Error: $e");
//       return true;
//     }
//   }

//   void _showInappropriateContentAlert(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text('Inappropriate Content'),
//           content: const Text(
//               'The selected image contains inappropriate content and cannot be sent.'),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('OK'),
//             ),
//           ],
//         );
//       },
//     );
//   }

// }

// New code for updated UI of video playing

import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dash_chat_2/dash_chat_2.dart' as dashChat;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fly_chat/Models/message.dart';
import 'package:fly_chat/Services/authServices.dart';
import 'package:fly_chat/Services/blockTimerService.dart';
import 'package:fly_chat/Services/mediaService.dart';
import 'package:fly_chat/View/Screens/blockedScreen.dart';
import 'package:fly_chat/View/Screens/videoPlayerPage.dart';
import 'package:fly_chat/constants.dart';
import 'package:fly_chat/models/chat.dart';
import 'package:fly_chat/models/user.dart' as user;
import 'package:fly_chat/Services/chatServices.dart';
import 'package:fly_chat/utils.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
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
  // late TimerService _timerService;
  bool isLoading = false;

  dashChat.ChatUser? currentUser, otherUser;

  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    _chatService = _getIt.get<ChatService>();
    _mediaService = _getIt.get<MediaService>();
    // _timerService = _getIt.get<TimerService>();

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
        title: Text(widget.chatUser.name),
      ),
      body: Stack(children: [
        _buildUI(),
        if (isLoading)
          Stack(
            children: [
              BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 5,
                  sigmaY: 5,
                ),
                child: Container(
                  color: Colors.black.withOpacity(0.2),
                ),
              ),
              const Center(
                child: CircularProgressIndicator(),
              )
            ],
          )
      ]),
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
          messageOptions: dashChat.MessageOptions(
            showOtherUsersAvatar: true,
            showTime: true,
            messageMediaBuilder: (message, previousMessage, nextMessage) {
              if (message.medias != null && message.medias!.isNotEmpty) {
                final media = message.medias!.first;

                if (media.type == dashChat.MediaType.image) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Image.network(
                      media.url,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.broken_image),
                    ),
                  );
                }

                if (media.type == dashChat.MediaType.video) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              VideoPlayerPage(videoUrl: media.url),
                        ),
                      );
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.network(
                          'https://tilesolutions.ca/resources/themes/tilesolutions/images/play2.png',
                          height: 150,
                          width: 150,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            height: 150,
                            width: 150,
                            color: Colors.black12,
                            child: const Icon(Icons.videocam, size: 50),
                          ),
                        ),
                        // const Icon(Icons.play_circle_fill,
                        //     size: 50, color: Colors.white),
                      ],
                    ),
                  );
                }
              }

              // Let DashChat handle non-media (text) messages
              return const SizedBox.shrink();
            },
          ),
          inputOptions: dashChat.InputOptions(
            alwaysShowSend: true,
            trailing: [
              _mediaMessageButton(context),
              _videoMediaButton(context)
            ],
          ),
          currentUser: currentUser!,
          onSend: _sendMessage,
          messages: messages,
        );
      },
    );
  }

  String getVideoThumbnailUrl(String videoUrl) {
    // Replace with actual logic if thumbnail URLs are stored differently
    return videoUrl + "?thumb=true";
  }

  Future<void> _sendMessage(dashChat.ChatMessage chatMessage) async {
    BuildContext context = this.context; // Capture context from StatefulWidget
    print("_sendMessage function is called");

    if (chatMessage.medias?.isNotEmpty ?? false) {
      print(
          "chatMessage.medias?.isNotEmpty: ${chatMessage.medias!.isNotEmpty}");
      print("media type: ${chatMessage.medias!.first.type}");

      if (chatMessage.medias!.first.type == dashChat.MediaType.image) {
        print("yaha image send call kiya hai...");
        Message message = Message(
          senderID: chatMessage.user.id,
          content: chatMessage.medias!.first.url,
          messageType: MessageType.Image,
          sentAt: Timestamp.fromDate(chatMessage.createdAt),
        );

        await _chatService.sendChatMessage(
            currentUser!.id, otherUser!.id, message);

        print("yaha image send huva hoga..");
      } else if (chatMessage.medias!.first.type == dashChat.MediaType.video) {
        print("yaha video send call kiya hai...");
        Message message = Message(
          senderID: chatMessage.user.id,
          content: chatMessage.medias!.first.url,
          messageType: MessageType.Video,
          sentAt: Timestamp.fromDate(chatMessage.createdAt),
        );

        await _chatService.sendChatMessage(
            currentUser!.id, otherUser!.id, message);

        print("yaha video send huva hoga..");
      }
    } else {
      print("Text else for _sendMessage");
      // Text message

      // before sending text message call verifyText in chatServices to check if message inappropriate or not
      bool res = await _chatService.verifyText(chatMessage.text);
      print('res: $res');
      if (!res) {
        Message message = Message(
          senderID: currentUser!.id,
          content: chatMessage.text,
          messageType: MessageType.Text,
          sentAt: Timestamp.fromDate(chatMessage.createdAt),
        );

        await _chatService.sendChatMessage(
            currentUser!.id, otherUser!.id, message);

        print("yaha text send huva hoga..");
      } else {
        print("message is inappropriate");

        await TimerService.startBlockTimer();
        print("timer started and push to block screen");
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => BlockedScreen(),
            ),
            (route) => false);
      }
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
      } else if (m.messageType == MessageType.Video) {
        return dashChat.ChatMessage(
          medias: [
            dashChat.ChatMedia(
              url: m.content!,
              fileName: '',
              type: dashChat.MediaType.video, // Add video type
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

  Widget _videoMediaButton(BuildContext context) {
    return IconButton(
        onPressed: () async {
          XFile? file = await _mediaService.getVideo();
          if (file != null) {
            String chatID =
                generateChatID(uid1: currentUser!.id, uid2: otherUser!.id);

            print("analyze video is called");

            setState(() {
              isLoading = true;
            });

            bool isInappropriate =
                await _analyzeVideoForInappropriateContent(file);

            print("isInappropriate: $isInappropriate");

            if (!isInappropriate) {
              String? downloadURL = await _chatService.uploadVideoToChat(
                file: file,
                chatID: chatID,
              );

              print("Download URL of Video: $downloadURL");
              if (downloadURL != null) {
                dashChat.ChatMessage chatMessage = dashChat.ChatMessage(
                  user: currentUser!,
                  createdAt: DateTime.now(),
                  medias: [
                    dashChat.ChatMedia(
                      url: downloadURL,
                      fileName: '',
                      type: dashChat.MediaType.video,
                    ),
                  ],
                );

                await _sendMessage(chatMessage);
                setState(() {
                  isLoading = false;
                });
              }
            } else {
              try {
                print("analyze video output is true");

                setState(() {
                  isLoading = false;
                });

                await TimerService.startBlockTimer();
                print("timer started and push to block screen");
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BlockedScreen(),
                    ),
                    (route) => false);
              } catch (e) {
                print(e.toString());
              }
            }
          }
        },
        icon: const Icon(Icons.video_camera_back_outlined));
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

          print("analyze image is called here");
          setState(() {
            isLoading = true;
          });
          bool isInappropriate =
              await _analyzeImageForInappropriateContent(file);

          print("isInappropriate: $isInappropriate");
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

              setState(() {
                isLoading = false;
              });
              _sendMessage(chatMessage);
            }
          } else {
            try {
              // final url =
              //     Uri.parse("http://192.168.0.162:4001/print_phone_number");

              // send email to parent
              bool result =
                  await _chatService.send_alert_email(currentUser!.id, file);

              if (result) {
                print("Email sent successfully");
              } else {
                print("Email not sent");
              }

              // user.User? userDetails =
              //     await _authService.getUserDetails(currentUser!.id);

              // print("User Details: $userDetails");

              setState(() {
                isLoading = false;
              });
            } catch (e) {
              print(e.toString());
            }
            _showInappropriateContentAlert(context);
            // here if isINappropriate is true then start the timer.
            await TimerService.startBlockTimer();
            print("timer started and push to block screen");
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => BlockedScreen(),
                ),
                (route) => false);
          }
        }
      },
      icon: const Icon(Icons.image),
    );
  }

  Future<bool> _analyzeVideoForInappropriateContent(XFile file) async {
    try {
      print("analyze video in funciton");
      String fileName = basename(file.path);

      DocumentSnapshot<Map<String, dynamic>>? snapshot =
          await _chatService.getCurrentUserProfile();

      String name = "";
      String email = "";

      if (snapshot!.exists) {
        final data = snapshot.data();
        if (data != null) {
          name = data['name'] ?? '';
          email = data['email'] ?? '';

          print('Name: $name');
          print('Email: $email');
        } else {
          print('No data found in snapshot');
        }
      } else {
        print('Document does not exist');
      }

      var request =
          http.MultipartRequest('POST', Uri.parse('${API_URL}analyzevideo'))
            ..fields['name'] = name
            ..fields['receiver_email'] = email
            ..files.add(await http.MultipartFile.fromPath('file', file.path,
                filename: fileName));

      var response = await request.send();
      print("response of analyze video is ${response.statusCode}");
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
      return true;
    }
  }

  Future<bool> _analyzeImageForInappropriateContent(File file) async {
    try {
      print("analyze image is called");
      String fileName = basename(file.path);
      var request = http.MultipartRequest('POST', Uri.parse('${API_URL}analyze')
          // Uri.parse('http://192.168.0.162:4001/analyze'),
          // Uri.parse('https://duckling-crack-oddly.ngrok-free.app/analyze'),
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
      return true;
    }
  }

  void _showInappropriateContentAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Inappropriate Content'),
          content: const Text(
              'The selected image contains inappropriate content and cannot be sent.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
