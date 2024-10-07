import 'package:get_it/get_it.dart';
import 'package:fly_chat/Services/authServices.dart';
import 'package:fly_chat/Services/chatServices.dart';
import 'package:fly_chat/Services/mediaService.dart';

final GetIt getIt = GetIt.instance;

void setupServiceLocator() {
  getIt.registerLazySingleton<AuthService>(() => AuthService());
  getIt.registerLazySingleton<ChatService>(() => ChatService());
  getIt.registerLazySingleton<MediaService>(() => MediaService());
}
