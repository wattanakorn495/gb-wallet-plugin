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

dynamic dataLang;
bool isThai = false;

readStringFile(bool isTh) async {
  isThai = isTh;
  final String response = isTh
      ? await rootBundle.loadString('packages/gbkyc/assets/lang/th-TH.json')
      : await rootBundle.loadString('packages/gbkyc/assets/lang/en-US.json');
  dataLang = await json.decode(response);
}

extension StrTr on String {
  String tr() {
    return (dataLang == null || dataLang[this] == null) ? ' ' : dataLang[this];
  }
}

const colorGradientLight = Color(0xFF5C57F2);
const colorGradientDark = Color(0xFF2C2A74);
