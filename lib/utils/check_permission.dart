import 'package:flutter/material.dart';
import 'package:gbkyc/utils/file_uitility.dart';
import 'package:gbkyc/widgets/custom_dialog.dart';
import 'package:permission_handler/permission_handler.dart';

class CheckPermission {
  static Future<bool> camera(BuildContext context) async {
    if (!await Permission.camera.request().isGranted || await Permission.camera.isPermanentlyDenied) {
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (context) => CustomDialog(
          title: 'Camera_is_disabled'.tr(),
          content: 'access_your_camera_Want_to_go_to_settings'.tr(),
          avatar: false,
          onPressedConfirm: () {
            Navigator.pop(context);
            openAppSettings();
          },
          buttonCancel: true,
        ),
      );
      return false;
    } else {
      return true;
    }
  }

  static photo(BuildContext context) async {
    if (!await Permission.photos.request().isGranted) {
      if (await Permission.photos.isPermanentlyDenied) {
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (context) => CustomDialog(
            title: 'Photo_is_disabled'.tr(),
            content: 'access_your_photo_Want_to_go_to_settings'.tr(),
            avatar: false,
            onPressedConfirm: () {
              Navigator.pop(context);
              openAppSettings();
            },
            buttonCancel: true,
          ),
        );
        return false;
      }
    }
    return true;
  }
}
