import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fly_chat/Services/blockTimerService.dart';
import 'package:fly_chat/View/Screens/SplashScreen.dart';
import 'package:fly_chat/View/Screens/blockedScreen.dart';
import 'package:fly_chat/service_locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
   // Set up GetIt service locator
  setupServiceLocator();
  bool isBlocked = await TimerService.isBlocked();
  runApp(MyApp(isBlocked: isBlocked,));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.isBlocked});

  final bool isBlocked; 
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
       
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: isBlocked ? BlockedScreen() : const SplashScreen(),
    );
  }
}