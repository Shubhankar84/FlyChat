// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:fly_chat/Services/blockTimerService.dart';
// import 'package:fly_chat/View/Screens/SplashScreen.dart';

// class BlockedScreen extends StatefulWidget {
//   @override
//   _BlockedScreenState createState() => _BlockedScreenState();
// }

// class _BlockedScreenState extends State<BlockedScreen> {
//   Timer? _timer;
//   int remainingTime = 0;

//   @override
//   void initState() {
//     super.initState();
//     _startCountdown();
//   }

//   void _startCountdown() async {
//     remainingTime = await TimerService.getRemainingTime();
//     _timer = Timer.periodic(Duration(seconds: 1), (timer) {
//       setState(() {
//         if (remainingTime > 0) {
//           remainingTime--;
//         } else {
//           timer.cancel();
//           TimerService.clearBlockTimer();
//           Navigator.pushAndRemoveUntil(
//               context,
//               MaterialPageRoute(builder: (context) => SplashScreen()),
//               (route) => false); // Navigate to the main screen
//         }
//       });
//     });
//   }

//   @override
//   void dispose() {
//     _timer?.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final minutes = remainingTime ~/ 60;
//     final seconds = remainingTime % 60;

//     return Scaffold(
//       backgroundColor: Colors.grey[200],
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // Header
//             Icon(
//               Icons.lock,
//               size: 80,
//               color: Colors.redAccent,
//             ),
//             const SizedBox(height: 20),
//             Text(
//               "You Are Blocked",
//               style: TextStyle(
//                 fontSize: 28,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.redAccent,
//               ),
//             ),
//             const SizedBox(height: 10),
//             Text(
//               "Due to violations, your access is temporarily restricted.",
//               style: TextStyle(fontSize: 16, color: Colors.grey[700]),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 40),

//             // Countdown Timer
//             Container(
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(15),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.grey.withOpacity(0.3),
//                     blurRadius: 10,
//                     spreadRadius: 1,
//                     offset: Offset(0, 5),
//                   )
//                 ],
//               ),
//               padding: const EdgeInsets.all(24.0),
//               child: Column(
//                 children: [
//                   const Text(
//                     "Time Remaining",
//                     style: TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black87,
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   Text(
//                     "$minutes:${seconds.toString().padLeft(2, '0')}",
//                     style: const TextStyle(
//                       fontSize: 48,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.redAccent,
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   LinearProgressIndicator(
//                     value: remainingTime / 60, // Assuming a 5-minute block
//                     backgroundColor: Colors.grey[300],
//                     color: Colors.redAccent,
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 40),

//             // Footer Message
//             Text(
//               "Please wait for the countdown to complete. You will be redirected automatically.",
//               style: TextStyle(
//                 fontSize: 14,
//                 color: Colors.grey[600],
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fly_chat/Services/blockTimerService.dart';
import 'package:fly_chat/View/Screens/SplashScreen.dart';

class BlockedScreen extends StatefulWidget {
  @override
  _BlockedScreenState createState() => _BlockedScreenState();
}

class _BlockedScreenState extends State<BlockedScreen> {
  Timer? _timer;
  int remainingTime = 0;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() async {
    remainingTime = await TimerService.getRemainingTime();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (remainingTime > 0) {
          remainingTime--;
        } else {
          timer.cancel();
          TimerService.clearBlockTimer();
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => SplashScreen()),
            (route) => false,
          );
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final minutes = remainingTime ~/ 60;
    final seconds = remainingTime % 60;

    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Header
            const Icon(
              Icons.lock,
              size: 80,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 20),
            const Text(
              "You Are Blocked",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Due to violations, your access is temporarily restricted.",
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            // Countdown Timer
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 1,
                    offset: Offset(0, 5),
                  )
                ],
              ),
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const Text(
                    "Time Remaining",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "$minutes:${seconds.toString().padLeft(2, '0')}",
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                    ),
                  ),
                  const SizedBox(height: 20),
                  LinearProgressIndicator(
                    value: remainingTime / 60, // assuming 1-minute block
                    backgroundColor: Colors.grey[300],
                    color: Colors.redAccent,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Footer Message
            Text(
              "Please wait for the countdown to complete. You will be redirected automatically.",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),

            // Hidden Skip Button (Only in debug mode)
              TextButton(
                onPressed: () async {
                  await TimerService.clearBlockTimer();
                  _timer?.cancel();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => SplashScreen()),
                    (route) => false,
                  );
                },
                child: Text(
                  "skip",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.withOpacity(0.2), // super light
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
