import 'package:fly_chat/Services/alertService.dart';
import 'package:fly_chat/Services/authServices.dart';
import 'package:fly_chat/Services/chatServices.dart';
import 'package:fly_chat/Services/mediaService.dart';
import 'package:get_it/get_it.dart';

Future<void> registerService() async {
  final GetIt getIt = GetIt.instance;

  // getIt.registerSingleton<AlertService>(
  //   AlertService(),
  // );

  getIt.registerSingleton<AuthService>(
    AuthService(),
  );

  getIt.registerSingleton<ChatService>(
    ChatService(),
  );

  getIt.registerSingleton<MediaService>(
    MediaService(),
  );

}

String generateChatID({required String uid1, required String uid2}) {
  List uids = [uid1, uid2];
  uids.sort();
  String chatID = uids.fold("", (id, uid) => "$id$uid");
  return chatID;
}
