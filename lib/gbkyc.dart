import 'package:flutter/material.dart';
import 'package:gbkyc/my_app.dart';

class Gbkyc {
  static Widget register(String phonenumber, {bool isThai = false}) {
    return MyApp(
      phoneNumber: '0971796690',
      isThai: isThai,
    );
  }
}
