// import 'package:delightful_toast/delight_toast.dart';
// import 'package:delightful_toast/toast/components/toast_card.dart';
// import 'package:delightful_toast/toast/utils/enums.dart';
// import 'package:flutter/material.dart';
// import 'package:get_it/get_it.dart';

// class AlertService {
//   final GetIt _getIt = GetIt.instance;

//   AlertService() {}

//   void showToast(
//       {required String text,
//       IconData icon = Icons.info,
//       required BuildContext context}) {
//     try {
//       DelightToastBar(
//           autoDismiss: true,
//           position: DelightSnackbarPosition.top,
//           builder: (context) {
//             return ToastCard(
//               leading: Icon(
//                 icon,
//                 size: 28,
//               ),
//               title: Text(
//                 text,
//                 style: const TextStyle(
//                   fontWeight: FontWeight.w700,
//                   fontSize: 14,
//                 ),
//               ),
//             );
//           }).show(context);
//     } catch (e) {
//       print(e);
//     }
//   }
// }
