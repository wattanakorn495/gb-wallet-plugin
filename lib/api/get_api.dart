import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gbkyc/api/config_api.dart';
import 'package:gbkyc/utils/error_messages.dart';
import 'package:gbkyc/utils/file_uitility.dart';
import 'package:http/http.dart' as http;

import '../widgets/custom_dialog.dart';

class GetAPI {
  //Call raw
  static Future<Map> call({
    required String url,
    required Authorization headers,
    required BuildContext context,
  }) async {
    try {
      final response = await http.get(Uri.parse(url), headers: setHeaders(headers)).timeout(const Duration(seconds: 30));

      debugPrint('$url ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        await showDialog(
            context: context,
            builder: (builder) => CustomDialog(title: 'Something_went_wrong'.tr(), content: errorMessages(errorNotFound), avatar: false));
        return errorNotFound;
      }
    } on TimeoutException catch (_) {
      await showDialog(
          context: context,
          builder: (builder) => CustomDialog(title: 'Something_went_wrong'.tr(), content: errorMessages(errorTimeout), avatar: false));
      return errorTimeout;
    } on SocketException catch (e) {
      debugPrint('socket error : $e');
      await showDialog(
          context: context,
          builder: (builder) => CustomDialog(title: 'Something_went_wrong'.tr(), content: errorMessages(messageOffline), avatar: false));
      return messageOffline;
    }
  }
}
