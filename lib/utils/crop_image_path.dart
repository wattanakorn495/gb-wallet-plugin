import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

Future<List<int>> cropImagePath({required String imagePath, required Offset offset, required Size size, required BuildContext context}) async {
  Uint8List imageBytes = File(imagePath).readAsBytesSync();
  img.Image image = img.decodeImage(imageBytes)!;

  double leftFinal = offset.dx * image.width / MediaQuery.of(context).size.width;
  double topFinal = offset.dy * image.height / MediaQuery.of(context).size.height;
  double widthFinal = size.width * image.width / MediaQuery.of(context).size.width;
  double heightFinal = size.height * image.height / MediaQuery.of(context).size.height;

  img.Image cropImage = img.copyCrop(
    image,
    leftFinal.toInt(),
    topFinal.toInt(),
    widthFinal.toInt(),
    heightFinal.toInt(),
  );

  List<int> toJPG = img.encodeJpg(cropImage);
  await File(imagePath).writeAsBytes(toJPG);

  return toJPG;
}
