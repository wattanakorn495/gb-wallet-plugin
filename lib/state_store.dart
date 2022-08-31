//ตัวแปรกองกลาง
class StateStore {
  static String balance = '0.00';
  static String deviceSerial = '';
  static String fcmToken = '';
  static String token = '';
  static String pin = '';
  static String role = '';
  static String lastLoginAt = '';
  static String fileText = '';
  static String countNotification = '0';
  static String version = '';

  static Map profile = {};
  static Map virtualCardInfo = {};
  static Map virtualCardData = {};

  static bool approve = false;
  static bool isCorporate = false;
  static bool notificationHasData = false;
  static bool transactionHasData = false;
  // static bool remoteConfigIsDev = true;
  static bool virtualStatus = false;
  static bool isShowDialog = false;
  static bool haveVirtualCard = false;

  static List notification = [];
  static List recentSearch = [];
  static List recentRedeemed = [];
  static List transaction = [];

  static clear() {
    balance = '0.00';
    token = '';
    pin = '';
    role = '';
    lastLoginAt = '';
    fileText = '';
    countNotification = '0';

    profile.clear();
    virtualCardInfo.clear();
    virtualCardData.clear();

    approve = false;
    isCorporate = false;
    notificationHasData = false;
    transactionHasData = false;
    //remoteConfigIsDev = true;
    virtualStatus = false;
    haveVirtualCard = false;

    notification.clear();
    recentSearch.clear();
    recentRedeemed.clear();
    transaction.clear();
  }

  static Map careers = {};
}
