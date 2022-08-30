import 'package:gbkyc/utils/file_uitility.dart';

//ใช้แสดงข้อความ error จากหลังบ้าน
String errorMessages(Map response) {
  return response['response']['error_message'] ?? response['response']['error_messages'][0] ?? 'Something_is_not_right'.tr();
}
