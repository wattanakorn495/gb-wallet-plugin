import 'package:flutter/material.dart';
import 'package:gbkyc/my_app.dart';

class Gbkyc {
  static Widget register(String phonenumber, {bool isThai = false}) {
    return MyApp(
      phoneNumber: phonenumber,
      isThai: isThai,
    );
  }
}
