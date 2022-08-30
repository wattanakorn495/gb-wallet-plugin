import 'package:flutter/material.dart';
import 'package:gbkyc/my_app.dart';

class Gbkyc {
  static Widget show() {
    // return FutureBuilder(
    //     future: EasyLocalization.ensureInitialized(),
    //     builder: (context, snapshot) {
    //       return EasyLocalization(
    //           supportedLocales: const [Locale('en', 'US'), Locale('th', 'TH')],
    //           path: 'assets/lang', // <-- change the path of the translation files
    //           fallbackLocale: const Locale('en', 'US'),
    //           child: const MyApp());
    //     });
    return const MyApp();
  }
}
