import 'package:get/get_rx/src/rx_types/rx_types.dart';

//ตัวแปรกองกลาง
class StateStore {
  static RxString balance = '0.00'.obs;
  static RxString deviceSerial = ''.obs;
  static RxString fcmToken = ''.obs;
  static RxString token = ''.obs;
  static RxString pin = ''.obs;
  static RxString role = ''.obs;
  static RxString lastLoginAt = ''.obs;
  static RxString fileText = ''.obs;
  static RxString countNotification = '0'.obs;
  static RxString version = ''.obs;

  static RxMap profile = {}.obs;
  static RxMap virtualCardInfo = {}.obs;
  static RxMap virtualCardData = {}.obs;

  static RxBool approve = false.obs;
  static RxBool isCorporate = false.obs;
  static RxBool notificationHasData = false.obs;
  static RxBool transactionHasData = false.obs;
  // static RxBool remoteConfigIsDev = true.obs;
  static RxBool virtualStatus = false.obs;
  static RxBool isShowDialog = false.obs;
  static RxBool haveVirtualCard = false.obs;

  static RxList notification = [].obs;
  static RxList recentSearch = [].obs;
  static RxList recentRedeemed = [].obs;
  static RxList transaction = [].obs;

  static clear() {
    balance.value = '0.00';
    token.value = '';
    pin.value = '';
    role.value = '';
    lastLoginAt.value = '';
    fileText.value = '';
    countNotification.value = '0';

    profile.clear();
    virtualCardInfo.clear();
    virtualCardData.clear();

    approve.value = false;
    isCorporate.value = false;
    notificationHasData.value = false;
    transactionHasData.value = false;
    //remoteConfigIsDev.value = true;
    virtualStatus.value = false;
    haveVirtualCard.value = false;

    notification.clear();
    recentSearch.clear();
    recentRedeemed.clear();
    transaction.clear();
  }

  static RxMap careers = {}.obs;
}
