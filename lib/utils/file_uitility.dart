import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';

getFileSize({required String filepath}) async {
  var file = File(filepath);
  int fileSize = await file.length();
  return fileSize;
}

bool isImage(String path) {
  RegExp regType = RegExp(r'.jpeg|.jpg|.JPG|.png|.PNG');
  return regType.hasMatch(path.substring(path.length - 4, path.length));
}

dynamic data;

readStringFile() async {
  final String response = await rootBundle.loadString('packages/gbkyc/assets/lang/en-US.json');
  data = await json.decode(response);
}

extension strTr on String {
  String tr() => data[this];
}
