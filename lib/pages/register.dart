import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:gbkyc/api/config_api.dart';
import 'package:gbkyc/api/get_api.dart';
import 'package:gbkyc/api/post_api.dart';
import 'package:gbkyc/pages/personal_info.dart';
import 'package:gbkyc/pages/scan_id_detail.dart';
import 'package:gbkyc/personal_info_model.dart';
import 'package:gbkyc/scan_id_card.dart';
import 'package:gbkyc/state_store.dart';
import 'package:gbkyc/utils/check_permission.dart';
import 'package:gbkyc/utils/error_messages.dart';
import 'package:gbkyc/utils/file_uitility.dart';
import 'package:gbkyc/utils/regular_expression.dart';
import 'package:gbkyc/widgets/button_confirm.dart';
import 'package:gbkyc/widgets/custom_dialog.dart';
import 'package:gbkyc/widgets/input_dialog.dart';
import 'package:gbkyc/widgets/numpad.dart';
import 'package:gbkyc/widgets/page_loading.dart';
import 'package:gbkyc/widgets/time_otp.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class Register extends StatefulWidget {
  const Register({Key? key, this.phoneNumber}) : super(key: key);
  final String? phoneNumber;

  @override
  // ignore: library_private_types_in_public_api
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> with WidgetsBindingObserver {
  static const facetecChannel = MethodChannel('gbkyc');
  File? imgFrontIDCard, imgBackIDCard, imgLiveness, imgPassport;

  dynamic resCreateUser, onTapRecognizer, imgLivenessUint8;
  final format = DateFormat('dd/MM/yyyy');

  String? _userLoginID;
  String txPhoneNumber = "";
  String? sendOtpId;
  String countryCode = "+66";
  String? ocrBackLaser;
  late String pathFrontCitizen;
  late String pathBackCitizen;
  String pathSelfie = '';
  String fileNameFrontID = '';
  String fileNameBackID = '';
  String fileNameSelfieID = '';
  String fileNameLiveness = '';
  //passport
  String passportNumber = '';
  String countryCodeName = '';
  String expireDate = '';

  int length = 6;
  int selectedStep = 1;
  int? careerID;
  int? indexProvince, indexDistric, indexSubDistric;
  int failFacematch = 0;

  bool _otpVisible = true;
  bool _scanIDVisible = false;
  bool _dataVisible = false;
  bool _pinSetVisible = false;
  bool _pinConfirmVisible = false;
  bool _kycVisible = false;
  bool _kycVisibleFalse = false;

  bool hasError = false;
  bool expiration = true;
  bool isSuccess = false;
  bool isLoading = false;
  bool resetPIN = false;
  bool validatePhonenumber = false;
  bool ocrFailedAll = false;
  bool isCitizen = true;

  DateTime? datetimeOTP;

  GlobalKey<FormState> formkeyOTP = GlobalKey();

  PersonalInfoModel personalInfo = PersonalInfoModel();

  final otpController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final firstNameENController = TextEditingController();
  final lastNameENController = TextEditingController();
  final addressController = TextEditingController();
  final addressSearchController = TextEditingController();
  final idCardController = TextEditingController();
  final pinController = TextEditingController();
  final birthdayController = TextEditingController();
  final referralCodeController = TextEditingController();

  Timer? _timer;
  late StreamController<ErrorAnimationType> errorController;

  dynamic address;

  @override
  void initState() {
    super.initState();
    GetAPI.call(url: '$register3003/careers', headers: Authorization.auth2, context: context).then((v) => StateStore.careers = v);
    WidgetsBinding.instance.addObserver(this);
    onTapRecognizer = TapGestureRecognizer()
      ..onTap = () {
        debugPrint('on tap recognizer');
        Navigator.pop(context);
      };
    errorController = StreamController<ErrorAnimationType>();
    sendOTP();
  }

  @override
  void dispose() {
    errorController.close();
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !isSuccess) {
      debugPrint('Lifecycle onResume & isSuccess = false');
      setState(() => isLoading = false);
    }
  }

  getAddress(PersonalInfoModel person) async {
    EasyLoading.show();
    final response = await rootBundle.loadString('packages/gbkyc/assets/thai-province-data.json');
    address = jsonDecode(response);

    List dataProvince = address['province'];
    List dataDistrict = address['district'];
    List dataSubDistrict = address['sub_district'];

    if (person.filterAddress!.isNotEmpty && person.filterAddress!.split(' ').length > 2) {
      List filter = person.filterAddress!.split(' ');
      String filterProvince = filter[2];
      String filterDistrict = filter[1];
      String filterSubDistrict = filter[0];

      for (var e in dataProvince) {
        if (RegExp(filterProvince.replaceAll('จ.', '')).hasMatch(e['name_th'])) {
          int provinceID = e['id'];
          for (var e in dataDistrict) {
            if ((RegExp(filterDistrict.replaceAll('อ.', '')).hasMatch(e['name_th']) ||
                    RegExp(filterDistrict.replaceAll('เขต', '')).hasMatch(e['name_th'])) &&
                e['province_id'] == provinceID) {
              int codeDistrict = e['code'];
              for (var e in dataSubDistrict) {
                if (RegExp(filterSubDistrict).hasMatch(e['name_th']) && e['code'].toString().substring(0, 4) == codeDistrict.toString()) {
                  setindexProvince(e['province_id']);
                  setindexDistric(e['district_id']);
                  setindexSubDistric(e['id']);
                }
              }
            }
          }
        }
      }
    }
    EasyLoading.dismiss();
  }

  setSelectedStep(int index) => setState(() => selectedStep = index);

  setDataVisible(bool value) => setState(() => _dataVisible = value);
  setPinVisible(bool value) => setState(() => _pinSetVisible = value);

  setFirstName(String value) {
    firstNameController.text = value;
    personalInfo.firstName = value;
  }

  setLastName(String value) {
    lastNameController.text = value;
    personalInfo.lastName = value;
  }

  setFirstNameEng(String value) {
    firstNameENController.text = value;
    personalInfo.firstNameEng = value;
  }

  setLastnameEng(String value) {
    lastNameENController.text = value;
    personalInfo.lastNameEng = value;
  }

  setAddress(String value) {
    addressController.text = value;
    personalInfo.address = value;
  }

  setAddressSearch(String value) {
    addressSearchController.text = value;
    personalInfo.filterAddress = value;
  }

  setBirthday(String value) {
    birthdayController.text = value;
    personalInfo.birthday = value;
  }

  setIDCard(String value) {
    idCardController.text = value;
    personalInfo.idCard = value;
  }

  setLaserCode(String value) {
    ocrBackLaser = value;
    personalInfo.ocrBackLaser = value;
  }

  setCareerID(int? value) {
    careerID = value;
    personalInfo.careerID = value;
  }

  setReferralCode(String value) => referralCodeController.text = value;

  setindexProvince(int value) => indexProvince = value;
  setindexDistric(int value) => indexDistric = value;
  setindexSubDistric(int value) => indexSubDistric = value;

  setFileFrontCitizen(String value) => pathFrontCitizen = value;
  setFileBackCitizen(String value) => pathBackCitizen = value;
  setFileSelfie(String value) => pathSelfie = value;
  setCitizenToggle(bool value) => isCitizen = value;
  //passport
  setCountryCode(String value) {
    countryCode = value;
    personalInfo.countryCodeName = value;
  }

  setPassportNumber(String value) {
    passportNumber = value;
    personalInfo.passportNumber = value;
  }

  setExpirePassport(String value) {
    expireDate = value;
    personalInfo.expirePassport = value;
  }

  bool getScanIDVisible() {
    return _scanIDVisible;
  }

  bool getDateVisible() {
    return _dataVisible;
  }

  bool getPinVisible() {
    return _pinSetVisible;
  }

  String? getLaserCode() {
    return ocrBackLaser;
  }

  getLivenessFacetec() async {
    try {
      isSuccess = false;
      await facetecChannel.invokeMethod(
        'getLivenessFacetec',
        {"local": isThai ? "th" : "en"},
      );
    } on PlatformException catch (e) {
      debugPrint("Failed to get : '${e.message}'");
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => CustomDialog(
          title: 'facetec_can_not_open'.tr(),
          content: 'system_error_try_again'.tr(),
          avatar: false,
        ),
      );
    }
  }

  getImageFacetec() async {
    try {
      var result = await facetecChannel.invokeMethod('getImageFacetec');
      imgLivenessUint8 = base64Decode(result);
      String dir = (await getApplicationDocumentsDirectory()).path;
      String fullPath = '$dir/imageFacetec.png';
      imgLiveness = File(fullPath);
      debugPrint("img Liveness : $imgLiveness ,unit8 : $imgLivenessUint8");
      await imgLiveness!.writeAsBytes(imgLivenessUint8);
    } on PlatformException catch (e) {
      debugPrint("Failed to get : '${e.message}'");
    }
  }

  getResultFacetec() async {
    try {
      isSuccess = await facetecChannel.invokeMethod('getResultFacetec');
      if (isSuccess) {
        setState(() => isLoading = true);
        await getImageFacetec();
        final imgFromCardByte = isCitizen ? imgFrontIDCard!.readAsBytesSync() : imgPassport!.readAsBytesSync();
        final imgFromCardName = isCitizen ? imgFrontIDCard!.path.split("/").last : imgPassport!.path.split("/").last;
        final res = await PostAPI.callFormData(
            closeLoading: true,
            url: 'https://api.gbwallet.co/register-api/user_profiles/rekognition', //TODO GB PRD
            headers: Authorization.auth2,
            files: [
              http.MultipartFile.fromBytes('face_image', imgLiveness!.readAsBytesSync(), filename: imgLiveness!.path.split("/").last),
              http.MultipartFile.fromBytes('card_image', imgFromCardByte, filename: imgFromCardName),
              http.MultipartFile.fromString('id_card', isCitizen ? idCardController.text : passportNumber)
            ],
            context: context);
        final data = res['response']['data'];

        if (data['similarity'] >= 80) {
          uploadUserData(data);
        } else {
          setState(() => isLoading = false);
          failFacematch++;
          if (failFacematch > 2) {
            showDialog(barrierDismissible: false, context: context, builder: (contextDialog) => dialogKYCfail(contextDialog));
          } else {
            showDialog(
              barrierDismissible: false,
              context: context,
              builder: (context) => CustomDialog(
                title: 'facematch'.tr(),
                content: isCitizen ? 'sub_facematch'.tr() : 'sub_facematch_passport'.tr(),
                avatar: false,
              ),
            );
          }
        }
      }
    } on PlatformException catch (e) {
      debugPrint("Failed to get : '${e.message}'");
    }
  }

  dialogKYCfail(BuildContext contextDialog) {
    return Dialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Stack(alignment: Alignment.topCenter, children: [
        Container(
          margin: const EdgeInsets.only(top: 30, left: 10, right: 10),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
          child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
            Column(children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'liveness_is_unsuccessful'.tr(),
                  style: const TextStyle(fontSize: 20),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 10),
              Image.asset('assets/icons/idCardD.png', package: 'gbkyc', width: 113, fit: BoxFit.cover),
              const SizedBox(height: 10),
              Text(
                isCitizen ? 'Selfie_with_ID_cardMake_sure'.tr() : 'selfie_with_passport_make_sure'.tr(),
                style: const TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            colorGradientLight,
                            colorGradientDark,
                          ],
                        ),
                      ),
                      child: MaterialButton(
                        onPressed: () async {
                          Navigator.pop(contextDialog);
                          if (await CheckPermission.camera(context)) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CameraScanIDCard(
                                    titleAppbar: isCitizen ? 'Selfie_ID_Card'.tr() : 'selfie_passport'.tr(),
                                    enableButton: true,
                                    isFront: true,
                                    noFrame: true),
                              ),
                            ).then((v) async {
                              if (v != null) {
                                int fileSize = await getFileSize(filepath: v);
                                if (!isImage(v)) {
                                  showDialog(
                                    barrierDismissible: true,
                                    context: context,
                                    builder: (context) {
                                      return CustomDialog(
                                        title: 'Something_went_wrong'.tr(),
                                        content: "Extension_not_correct".tr(),
                                        exclamation: true,
                                      );
                                    },
                                  );
                                } else if (fileSize > 10000000) {
                                  showDialog(
                                    barrierDismissible: true,
                                    context: context,
                                    builder: (context) {
                                      return CustomDialog(
                                        title: 'Something_went_wrong'.tr(),
                                        content: "File_size_larger".tr(),
                                        exclamation: true,
                                      );
                                    },
                                  );
                                } else {
                                  setState(() {
                                    _kycVisible = false;
                                    _kycVisibleFalse = true;
                                    pathSelfie = v;
                                    imgFrontIDCard = File(pathSelfie);
                                  });
                                }
                              }
                            });
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.photo_camera_outlined, color: Colors.white),
                            const SizedBox(width: 10),
                            Text(
                              'camera'.tr(),
                              style: const TextStyle(fontSize: 17, color: Colors.white),
                            )
                          ],
                        ),
                      ),
                    ),
                  )
                ]),
              )
            ]),
          ]),
        ),
        CircleAvatar(
          maxRadius: 32,
          backgroundColor: Colors.white,
          child: Image.asset('assets/images/Close.png', package: 'gbkyc', height: 48, width: 48),
        ),
      ]),
    );
  }

  onChangeSetPIN(String number) {
    if (regExpPIN.hasMatch(number)) {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => CustomDialog(
          title: 'invalid_pin'.tr(),
          content: 'You_set_a_PIN_that_is_too_strong_to_guess'.tr(),
          avatar: false,
          onPressedConfirm: () {
            setState(() => resetPIN = true);
            Navigator.pop(context);
          },
        ),
      );
    } else if (number.length == length) {
      setState(() {
        pinController.text = number;
        _pinSetVisible = false;
        _pinConfirmVisible = true;
        resetPIN = true;
      });
    }
  }

  onChangeConfirmPIN(String number) async {
    if (number.length == length) {
      if (number == pinController.text) {
        if (pathSelfie.isNotEmpty) {
          scanFailAndSelfie();
        } else {
          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) => CustomDialog(
              title: 'success_pin'.tr(),
              content: 'sub_success_pin'.tr(),
              onPressedConfirm: () => setState(() {
                Navigator.pop(context);
                selectedStep = 4;
                _pinConfirmVisible = false;
                _kycVisible = true;
                resetPIN = true;
              }),
            ),
          );
        }
      } else {
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) => CustomDialog(
            title: 'invalid_pin'.tr(),
            content: 'please_enter_again'.tr(),
            avatar: false,
            onPressedConfirm: () {
              setState(() => resetPIN = true);
              Navigator.of(context).pop();
            },
          ),
        );
      }
    }
  }

  sendOTP() async {
    StateStore.phoneNumberGlobal = widget.phoneNumber.toString(); //save phone to Global value.
    txPhoneNumber = widget.phoneNumber.toString();
    var otpId = await PostAPI.call(
        url: '$register3003/send_otps',
        headers: Authorization.auth2,
        body: {"phone_number": txPhoneNumber, "country_code": countryCode},
        context: context,
        errorTitle: 'unable_register'.tr());

    if (otpId['success']) {
      var data = otpId['response']['data'];
      setState(() {
        expiration = false;
        sendOtpId = data['send_otp_id'];
        datetimeOTP = DateTime.parse(data['expiration_at']);
      });
    }
  }

  autoSubmitOTP() async {
    setState(() => hasError = false);

    if (formkeyOTP.currentState!.validate() && otpController.text.length == 6) {
      var data = await PostAPI.call(
          url: '$register3003/send_otps/$sendOtpId/verify',
          headers: Authorization.auth2,
          body: {"otp": otpController.text},
          context: context,
          errorTitle: 'incorrect_otp'.tr());
      if (data['success']) {
        setState(() {
          hasError = false;
          expiration = true;
          selectedStep = 2;
          _otpVisible = false;
          _scanIDVisible = true;
        });
      } else {
        setState(() => hasError = true);
      }
    } else {
      errorController.add(ErrorAnimationType.shake);
      setState(() => hasError = true);
    }
  }

  checkResetPIN(state) {
    if (state) {
      Future.delayed(
        const Duration(milliseconds: 500),
        () => setState(() => resetPIN = false),
      );
    }
  }

  onBackButton(int step) {
    switch (step) {
      case 0:
        Navigator.of(context, rootNavigator: true).pop();
        break;
      case 1:
        Navigator.of(context, rootNavigator: true).pop();
        break;
      case 2:
        showDialog(
          context: context,
          builder: (context) => CustomDialog(
            title: 'back'.tr(),
            content: 'Do_you_want_to_go_back_previous_step'.tr(),
            exclamation: true,
            buttonCancel: true,
            onPressedConfirm: () {
              if (!_scanIDVisible) {
                setState(() {
                  Navigator.of(context, rootNavigator: true).pop();
                  _scanIDVisible = true;
                  _dataVisible = false;
                });
              } else {
                Navigator.of(context, rootNavigator: true).pop();
                Navigator.of(context, rootNavigator: true).pop();
              }
            },
          ),
        );
        break;
      case 3:
        if (_pinConfirmVisible) {
          setState(() {
            _pinSetVisible = true;
            _pinConfirmVisible = false;
          });
        } else {
          setState(() {
            selectedStep = 2;
            _dataVisible = true;
            _pinSetVisible = false;
          });
        }
        break;
      case 4:
        setState(() {
          selectedStep = 3;
          _kycVisible = false;
          _kycVisibleFalse = false;
          _pinSetVisible = true;
          isLoading = false;
        });
        break;
      case 5:
        setState(() {
          selectedStep = 3;
          _kycVisible = false;
          _kycVisibleFalse = false;
          _pinSetVisible = true;
          isLoading = false;
        });
        break;
      default:
    }
  }

  Widget _buildIconCheckStep(int step, int state, String name) {
    return Expanded(
      child: Column(children: [
        const SizedBox(
          height: 30,
          width: 50,
          child: Icon(Icons.check, color: Colors.white, size: 16),
        ),
        const SizedBox(height: 10),
        Text(
          name,
          softWrap: false,
          style: TextStyle(fontSize: 12, color: step == state ? colorGradientLight : colorGradientDark),
        ),
      ]),
    );
  }

  Widget _buildTextStep(
    int step,
    int state,
    String number,
    String name,
    double padd,
  ) {
    return Expanded(
      child: Column(children: [
        Text(
          number,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: step == state || state == 2 ? Colors.white : Colors.transparent),
        ),
        const SizedBox(height: 10),
        Text(
          name,
          softWrap: false,
          style: TextStyle(fontSize: 12, color: step == state ? colorGradientLight : colorGradientDark),
        ),
      ]),
    );
  }

  Widget _buildDoneStep() {
    return Expanded(
      child: Container(
        width: 22,
        height: 22,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(begin: Alignment.topCenter, colors: [
            colorGradientDark,
            colorGradientLight,
          ]),
        ),
      ),
    );
  }

  Widget _buildSelectedStep() {
    return Expanded(
      child: Container(
        width: 32,
        height: 32,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(begin: Alignment.topCenter, colors: [
            colorGradientDark,
            colorGradientLight,
          ]),
        ),
      ),
    );
  }

  Widget _buildUnselectedStep() {
    return Expanded(
      child: Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(width: 1, color: colorGradientDark),
          color: Colors.white,
        ),
      ),
    );
  }

  selectBottomView(int step) {
    switch (step) {
      case 0:
        return const SizedBox();
      case 1:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
          decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.grey[300]!))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: ButtonConfirm(
                  text: 'continue'.tr(),
                  onPressed: autoSubmitOTP,
                ),
              ),
            ],
          ),
        );
      case 2:
        return _dataVisible
            ? const SizedBox()
            : Container(
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.grey[300]!))),
                child: Row(children: [
                  Expanded(
                    child: ButtonConfirm(
                      text: 'accepttoscan'.tr(),
                      onPressed: () async {
                        if (await CheckPermission.camera(context)) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CameraScanIDCard(
                                titleAppbar: isCitizen ? 'idcard'.tr() : 'passport_scan'.tr(),
                                isFront: true,
                                noFrame: false,
                                enableButton: false,
                                scanID: true,
                                isCitizenCard: isCitizen,
                              ),
                            ),
                          ).then((data) async {
                            if (data != null && !data['ocrFailedAll']) {
                              if (isCitizen) {
                                personalInfo.idCard = data['ocrFrontID'];
                                personalInfo.firstName = data['ocrFrontName'];
                                personalInfo.lastName = data['ocrFrontSurname'];
                                personalInfo.firstNameEng = data['ocrFrontNameEng'];
                                personalInfo.lastNameEng = data['ocrFrontSurnameEng'];
                                personalInfo.address = data['ocrFrontAddress'];
                                personalInfo.filterAddress = data['ocrFilterAddress'];
                                personalInfo.birthday = data['ocrBirthDay'];
                                personalInfo.ocrBackLaser = data['ocrBackLaser'];
                                await getAddress(personalInfo);

                                setState(() {
                                  idCardController.text = data['ocrFrontID'];
                                  firstNameController.text = data['ocrFrontName'];
                                  lastNameController.text = data['ocrFrontSurname'];
                                  firstNameENController.text = data['ocrFrontNameEng'];
                                  lastNameENController.text = data['ocrFrontSurnameEng'];
                                  addressController.text = data['ocrFrontAddress'];
                                  birthdayController.text = data['ocrBirthDay'];
                                  ocrBackLaser = data['ocrBackLaser'];
                                  ocrFailedAll = data['ocrFailedAll'];
                                  imgFrontIDCard = File(data['frontIDPath']);
                                  imgBackIDCard = File(data['backIDPath']);
                                  _scanIDVisible = false;
                                  _dataVisible = true;
                                });
                              } else {
                                personalInfo.firstName = data['ocrFrontName'];
                                personalInfo.lastName = data['ocrFrontSurname'];
                                personalInfo.address = '';
                                personalInfo.filterAddress = '';
                                personalInfo.birthday = data['ocrBirthDay'];
                                personalInfo.passportNumber = data['passportNumber'];
                                personalInfo.countryCodeName = data['countryCode'];
                                personalInfo.expirePassport = data['expireDate'];
                                await getAddress(personalInfo);

                                setState(() {
                                  firstNameController.text = data['ocrFrontName'];
                                  lastNameController.text = data['ocrFrontSurname'];
                                  birthdayController.text = data['ocrBirthDay'];
                                  ocrFailedAll = data['ocrFailedAll'];
                                  _scanIDVisible = false;
                                  _dataVisible = true;
                                  //passport
                                  imgPassport = File(data['passportIDPath']);
                                  passportNumber = data['passportNumber'];
                                  countryCodeName = data['countryCode'];
                                  expireDate = data['expireDate'];
                                });
                              }
                            } else if (data != null && data['ocrFailedAll']) {
                              personalInfo.idCard = '';
                              personalInfo.firstName = '';
                              personalInfo.lastName = '';
                              personalInfo.firstNameEng = '';
                              personalInfo.lastNameEng = '';
                              personalInfo.address = '';
                              personalInfo.birthday = '';
                              personalInfo.ocrBackLaser = '';
                              personalInfo.filterAddress = '';
                              await getAddress(personalInfo);

                              setState(() {
                                ocrFailedAll = data['ocrFailedAll'];
                                _scanIDVisible = false;
                                _dataVisible = true;
                              });
                            }
                          });
                        }
                      },
                    ),
                  )
                ]),
              );
      case 3:
        return const SizedBox();
      case 4:
        if (!isLoading) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
            decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.grey[300]!))),
            child: _kycVisible
                ? Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              colorGradientLight,
                              colorGradientDark,
                            ],
                          ),
                        ),
                        child: MaterialButton(
                          onPressed: () async {
                            _timer?.cancel();
                            setState(() => isLoading = true);
                            getLivenessFacetec();

                            if (Platform.isIOS) {
                              Future.delayed(const Duration(seconds: 50), () {
                                setState(() => isLoading = false);
                              });
                            }
                            _timer = Timer.periodic(const Duration(seconds: 3), (Timer t) {
                              if (isSuccess) {
                                _timer?.cancel();
                              } else {
                                getResultFacetec();
                              }
                            });
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.photo_camera_outlined, color: Colors.white),
                              const SizedBox(width: 10),
                              Text('camera'.tr(), style: const TextStyle(fontSize: 17, color: Colors.white))
                            ],
                          ),
                        ),
                      ),
                    )
                  ])
                : pathSelfie.isNotEmpty
                    ? Row(children: [
                        Expanded(
                          child: MaterialButton(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                              side: const BorderSide(color: colorGradientDark),
                            ),
                            child: Text('Re-take_photo'.tr(), style: const TextStyle(color: colorGradientDark)),
                            onPressed: () async {
                              if (await CheckPermission.camera(context)) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CameraScanIDCard(
                                        titleAppbar: isCitizen ? 'Selfie_ID_Card'.tr() : 'selfie_passport'.tr(),
                                        enableButton: true,
                                        isFront: true,
                                        noFrame: true,
                                        isCitizenCard: isCitizen),
                                  ),
                                ).then(
                                  (v) async {
                                    if (v != null) {
                                      int fileSize = await getFileSize(filepath: v);
                                      if (!isImage(v)) {
                                        showDialog(
                                          barrierDismissible: true,
                                          context: context,
                                          builder: (context) {
                                            return CustomDialog(
                                              title: 'Something_went_wrong'.tr(),
                                              content: "Extension_not_correct".tr(),
                                              exclamation: true,
                                            );
                                          },
                                        );
                                      } else if (fileSize > 10000000) {
                                        showDialog(
                                          barrierDismissible: true,
                                          context: context,
                                          builder: (context) {
                                            return CustomDialog(
                                              title: 'Something_went_wrong'.tr(),
                                              content: "File_size_larger".tr(),
                                              exclamation: true,
                                            );
                                          },
                                        );
                                      } else {
                                        setState(() {
                                          _kycVisible = false;
                                          _kycVisibleFalse = true;
                                          pathSelfie = v;
                                          imgFrontIDCard = File(pathSelfie);
                                          isLoading = false;
                                        });
                                      }
                                    }
                                  },
                                );
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              gradient: const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  colorGradientLight,
                                  colorGradientDark,
                                ],
                              ),
                            ),
                            child: MaterialButton(
                              child: Text('continue'.tr()),
                              onPressed: () async {
                                facetecFailAndSelfie();
                              },
                            ),
                          ),
                        ),
                      ])
                    : const SizedBox(),
          );
        } else {
          return const SizedBox();
        }
      default:
    }
  }

  uploadUserData(dynamic data) async {
    if (isCitizen) {
      fileNameFrontID = data['card_image_file_name'];
      final resBackID = await PostAPI.callFormData(
          url: '$register3003/users/upload_file',
          headers: Authorization.auth2,
          files: [
            http.MultipartFile.fromBytes(
              'image',
              imgBackIDCard!.readAsBytesSync(),
              filename: imgBackIDCard!.path.split("/").last,
            )
          ],
          context: context);
      fileNameBackID = resBackID['response']['data']['file_name'];
      fileNameLiveness = data['face_image_file_name'];

      resCreateUser = await PostAPI.call(
          url: '$register3003/users',
          headers: Authorization.auth2,
          body: {
            "type_register": 'id_card',
            "id_card": idCardController.text,
            "first_name": firstNameController.text,
            "last_name": lastNameController.text,
            "first_name_en": firstNameENController.text,
            "last_name_en": lastNameENController.text,
            "address": addressController.text,
            "birthday": birthdayController.text,
            "pin": pinController.text,
            "send_otp_id": sendOtpId!,
            "laser": ocrBackLaser!,
            "province_id": '$indexProvince',
            "district_id": '$indexDistric',
            "sub_district_id": '$indexSubDistric',
            "career_id": '$careerID',
            "work_name": '',
            "work_address": '',
            "file_front_citizen": fileNameFrontID,
            "file_back_citizen": fileNameBackID,
            "file_selfie": '',
            "file_liveness": fileNameLiveness,
            "imei": StateStore.deviceSerial,
            "fcm_token": StateStore.fcmToken,
          },
          alert: false,
          context: context);

      setState(() => isLoading = false);
      if (resCreateUser['success']) {
        try {
          await imgFrontIDCard!.delete();
          await imgBackIDCard!.delete();
          await imgLiveness!.delete();
        } catch (e) {
          debugPrint('cannot delete image');
        }
        _userLoginID = resCreateUser['response']['data']['user_login_id'];
        var data = await PostAPI.call(
            url: '$register3003/user_logins/$_userLoginID/login',
            headers: Authorization.none,
            body: {"imei": StateStore.deviceSerial, "pin": pinController.text},
            context: context);

        if (data['success']) {
          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (dialogContext) => CustomDialog(
                title: 'save_success'.tr(),
                content: 'congratulations'.tr(),
                textConfirm: "back_to_main".tr(),
                onPressedConfirm: () {
                  Navigator.pop(dialogContext);
                  Navigator.of(context, rootNavigator: true).pop(_userLoginID);
                }),
          );
        }
      } else {
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) => CustomDialog(
            title: "Something_went_wrong".tr(),
            content: errorMessages(resCreateUser + 1),
            avatar: false,
            onPressedConfirm: () {
              Navigator.pop(context);
              setState(() {
                selectedStep = 2;
                _kycVisible = false;
                _pinConfirmVisible = false;
                _dataVisible = true;
              });
            },
          ),
        );
      }
    } else {
      final resPassport = await PostAPI.callFormData(
          url: '$register3003/users/upload_file',
          headers: Authorization.auth2,
          files: [
            http.MultipartFile.fromBytes(
              'image',
              imgPassport!.readAsBytesSync(),
              filename: imgPassport!.path.split("/").last,
            )
          ],
          context: context);
      fileNameFrontID = resPassport['response']['data']['file_name'];
      fileNameLiveness = data['face_image_file_name'];
      resCreateUser = await PostAPI.call(
          url: '$register3003/users',
          headers: Authorization.auth2,
          body: {
            "type_register": 'passport',
            "id_card": passportNumber,
            "first_name": firstNameController.text,
            "last_name": lastNameController.text,
            "first_name_en": firstNameController.text,
            "last_name_en": lastNameController.text,
            "address": 'none',
            "birthday": birthdayController.text,
            "pin": pinController.text,
            "send_otp_id": sendOtpId ?? '',
            "laser": '',
            "province_id": '',
            "district_id": '',
            "sub_district_id": '',
            "career_id": '$careerID',
            "work_name": '',
            "work_address": '',
            "file_front_citizen": fileNameFrontID,
            "file_back_citizen": '',
            "file_selfie": '',
            "file_liveness": fileNameLiveness,
            "imei": StateStore.deviceSerial,
            "fcm_token": StateStore.fcmToken,
          },
          alert: false,
          context: context);

      setState(() => isLoading = false);
      if (resCreateUser['success']) {
        try {
          await imgLiveness!.delete();
          await imgPassport!.delete();
        } catch (e) {
          debugPrint('cannot delete image');
        }
        _userLoginID = resCreateUser['response']['data']['user_login_id'];
        var data = await PostAPI.call(
            url: '$register3003/user_logins/$_userLoginID/login',
            headers: Authorization.none,
            body: {"imei": StateStore.deviceSerial, "pin": pinController.text},
            context: context);

        if (data['success']) {
          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (dialogContext) => CustomDialog(
                title: 'save_success'.tr(),
                content: 'congratulations'.tr(),
                textConfirm: "back_to_main".tr(),
                onPressedConfirm: () {
                  Navigator.pop(dialogContext);
                  Navigator.of(context, rootNavigator: true).pop(_userLoginID);
                }),
          );
        }
      } else {
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) => CustomDialog(
            title: "Something_went_wrong".tr(),
            content: errorMessages(resCreateUser + 2),
            avatar: false,
            onPressedConfirm: () {
              Navigator.pop(context);
              setState(() {
                selectedStep = 2;
                _kycVisible = false;
                _pinConfirmVisible = false;
                _dataVisible = true;
              });
            },
          ),
        );
      }
    }
  }

  scanFailAndSelfie() async {
    setState(() => isLoading = true);
    final resFrontID = await PostAPI.callFormData(
        url: '$register3003/users/upload_file',
        headers: Authorization.auth2,
        files: [
          http.MultipartFile.fromBytes(
            'image',
            File(pathFrontCitizen).readAsBytesSync(),
            filename: File(pathFrontCitizen).path.split("/").last,
          )
        ],
        context: context);
    fileNameFrontID = resFrontID['response']['data']['file_name'];
    if (isCitizen) {
      final resBackID = await PostAPI.callFormData(
          url: '$register3003/users/upload_file',
          headers: Authorization.auth2,
          files: [
            http.MultipartFile.fromBytes(
              'image',
              File(pathBackCitizen).readAsBytesSync(),
              filename: File(pathBackCitizen).path.split("/").last,
            )
          ],
          context: context);
      fileNameBackID = resBackID['response']['data']['file_name'];
    }
    final resSelfieID = await PostAPI.callFormData(
        url: '$register3003/users/upload_file',
        headers: Authorization.auth2,
        files: [
          http.MultipartFile.fromBytes(
            'image',
            File(pathSelfie).readAsBytesSync(),
            filename: File(pathSelfie).path.split("/").last,
          )
        ],
        context: context);
    fileNameSelfieID = resSelfieID['response']['data']['file_name'];
    resCreateUser = await PostAPI.call(
        url: '$register3003/users',
        headers: Authorization.auth2,
        body: isCitizen
            ? {
                "type_register": 'id_card',
                "id_card": idCardController.text,
                "first_name": firstNameController.text,
                "last_name": lastNameController.text,
                "first_name_en": firstNameENController.text,
                "last_name_en": lastNameENController.text,
                "address": addressController.text,
                "birthday": birthdayController.text,
                "pin": pinController.text,
                "send_otp_id": sendOtpId!,
                "laser": ocrBackLaser!,
                "province_id": '$indexProvince',
                "district_id": '$indexDistric',
                "sub_district_id": '$indexSubDistric',
                "career_id": '$careerID',
                "work_name": '',
                "work_address": '',
                "file_front_citizen": fileNameFrontID,
                "file_back_citizen": fileNameBackID,
                "file_selfie": fileNameSelfieID,
                "file_liveness": '',
                "imei": StateStore.deviceSerial,
                "fcm_token": StateStore.fcmToken,
              }
            : {
                "type_register": 'passport',
                "id_card": passportNumber,
                "first_name": firstNameController.text,
                "last_name": lastNameController.text,
                "first_name_en": firstNameController.text,
                "last_name_en": lastNameController.text,
                "address": 'none',
                "birthday": birthdayController.text,
                "pin": pinController.text,
                "send_otp_id": sendOtpId ?? '',
                "laser": '',
                "province_id": '',
                "district_id": '',
                "sub_district_id": '',
                "career_id": '$careerID',
                "work_name": '',
                "work_address": '',
                "file_front_citizen": fileNameFrontID,
                "file_back_citizen": '',
                "file_selfie": fileNameSelfieID,
                "file_liveness": '',
                "imei": StateStore.deviceSerial,
                "fcm_token": StateStore.fcmToken,
              },
        alert: false,
        context: context);

    if (resCreateUser['success']) {
      try {
        await File(pathFrontCitizen).delete();
        if (isCitizen) await File(pathBackCitizen).delete();
        await File(pathSelfie).delete();
      } catch (e) {
        debugPrint('cannot delete image');
      }

      _userLoginID = resCreateUser['response']['data']['user_login_id'];
      var data = await PostAPI.call(
          url: '$register3003/user_logins/$_userLoginID/login',
          headers: Authorization.none,
          body: {"imei": StateStore.deviceSerial, "pin": pinController.text},
          context: context);

      if (data['success']) {
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (dialogContext) => CustomDialog(
              title: 'save_success'.tr(),
              content: 'congratulations_now'.tr(),
              textConfirm: "back_to_main".tr(),
              onPressedConfirm: () {
                Navigator.pop(dialogContext);
                Navigator.of(context, rootNavigator: true).pop(_userLoginID);
              }),
        );
      }
    } else {
      setState(() {
        isLoading = false;
        resetPIN = true;
      });
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => CustomDialog(
          title: "Something_went_wrong".tr(),
          content: errorMessages(resCreateUser! + 3),
          avatar: false,
          onPressedConfirm: () {
            Navigator.pop(context);
            setState(() {
              selectedStep = 2;
              _pinConfirmVisible = false;
              _dataVisible = true;
            });
          },
        ),
      );
    }
  }

  facetecFailAndSelfie() async {
    final resFrontID = await PostAPI.callFormData(
        url: '$register3003/users/upload_file',
        headers: Authorization.auth2,
        files: [
          http.MultipartFile.fromBytes(
            'image',
            imgFrontIDCard!.readAsBytesSync(),
            filename: imgFrontIDCard!.path.split("/").last,
          )
        ],
        context: context);
    fileNameFrontID = resFrontID['response']['data']['file_name'];
    if (isCitizen) {
      final resBackID = await PostAPI.callFormData(
          url: '$register3003/users/upload_file',
          headers: Authorization.auth2,
          files: [
            http.MultipartFile.fromBytes(
              'image',
              imgBackIDCard!.readAsBytesSync(),
              filename: imgBackIDCard!.path.split("/").last,
            )
          ],
          context: context);
      fileNameBackID = resBackID['response']['data']['file_name'];
    }

    final resSelfieID = await PostAPI.callFormData(
        url: '$register3003/users/upload_file',
        headers: Authorization.auth2,
        files: [
          http.MultipartFile.fromBytes(
            'image',
            File(pathSelfie).readAsBytesSync(),
            filename: File(pathSelfie).path.split("/").last,
          )
        ],
        context: context);
    fileNameSelfieID = resSelfieID['response']['data']['file_name'];
    resCreateUser = await PostAPI.call(
        url: '$register3003/users',
        headers: Authorization.auth2,
        body: isCitizen
            ? {
                "type_register": 'id_card',
                "id_card": idCardController.text,
                "first_name": firstNameController.text,
                "last_name": lastNameController.text,
                "address": addressController.text,
                "birthday": birthdayController.text,
                "pin": pinController.text,
                "send_otp_id": sendOtpId!,
                "laser": ocrBackLaser!,
                "province_id": '$indexProvince',
                "district_id": '$indexDistric',
                "sub_district_id": '$indexSubDistric',
                "career_id": '$careerID',
                "work_name": '',
                "work_address": '',
                "file_front_citizen": fileNameFrontID,
                "file_back_citizen": fileNameBackID,
                "file_selfie": fileNameSelfieID,
                "file_liveness": '',
                "imei": StateStore.deviceSerial,
                "fcm_token": StateStore.fcmToken,
              }
            : {
                "type_register": 'passport',
                "id_card": passportNumber,
                "first_name": firstNameController.text,
                "last_name": lastNameController.text,
                "first_name_en": firstNameController.text,
                "last_name_en": lastNameController.text,
                "address": 'none',
                "birthday": birthdayController.text,
                "pin": pinController.text,
                "send_otp_id": sendOtpId ?? '',
                "laser": '',
                "province_id": '',
                "district_id": '',
                "sub_district_id": '',
                "career_id": '$careerID',
                "work_name": '',
                "work_address": '',
                "file_front_citizen": fileNameFrontID,
                "file_back_citizen": '',
                "file_selfie": fileNameSelfieID,
                "file_liveness": '',
                "imei": StateStore.deviceSerial,
                "fcm_token": StateStore.fcmToken,
              },
        alert: false,
        context: context);

    setState(() => isLoading = false);
    if (resCreateUser['success']) {
      try {
        await imgFrontIDCard!.delete();
        if (isCitizen) await imgBackIDCard!.delete();
        await File(pathSelfie).delete();
      } catch (e) {
        debugPrint('cannot delete image');
      }
      _userLoginID = resCreateUser['response']['data']['user_login_id'];
      var data = await PostAPI.call(
          url: '$register3003/user_logins/$_userLoginID/login',
          headers: Authorization.none,
          body: {"imei": StateStore.deviceSerial, "pin": pinController.text},
          context: context);

      if (data['success']) {
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (dialogContext) => CustomDialog(
              title: 'save_success'.tr(),
              content: 'congratulations_now'.tr(),
              textConfirm: "back_to_main".tr(),
              onPressedConfirm: () {
                Navigator.pop(dialogContext);
                Navigator.of(context, rootNavigator: true).pop(_userLoginID);
              }),
        );
      }
    } else {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => CustomDialog(
          title: "Something_went_wrong".tr(),
          content: errorMessages(resCreateUser + 4),
          avatar: false,
          onPressedConfirm: () {
            Navigator.pop(context);
            setState(() {
              selectedStep = 2;
              _kycVisible = false;
              _kycVisibleFalse = false;
              pathSelfie = '';
              isLoading = false;
              _dataVisible = true;
            });
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    checkResetPIN(resetPIN);
    return WillPopScope(
      onWillPop: () async {
        onBackButton(selectedStep);
        return true;
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          extendBody: true,
          appBar: AppBar(
            leading: BackButton(onPressed: () => onBackButton(selectedStep)),
            title: Text('register'.tr()),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(80),
              child: Container(
                height: 80,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(children: [
                  Stack(children: [
                    const Divider(
                      color: colorGradientDark,
                      thickness: 1.5,
                      height: 30,
                      indent: 50,
                      endIndent: 50,
                    ),
                    Row(children: [
                      selectedStep == 0 ? _buildSelectedStep() : _buildDoneStep(),
                      selectedStep == 1
                          ? _buildSelectedStep()
                          : selectedStep == 2 || selectedStep == 3 || selectedStep == 4 || selectedStep == 5
                              ? _buildDoneStep()
                              : _buildUnselectedStep(),
                      selectedStep == 2 || selectedStep == 5
                          ? _buildSelectedStep()
                          : selectedStep == 3 || selectedStep == 4
                              ? _buildDoneStep()
                              : _buildUnselectedStep(),
                      selectedStep == 3
                          ? _buildSelectedStep()
                          : selectedStep == 4
                              ? _buildDoneStep()
                              : _buildUnselectedStep(),
                      selectedStep == 4 ? _buildSelectedStep() : _buildUnselectedStep()
                    ]),
                    Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      selectedStep == 1
                          ? _buildIconCheckStep(selectedStep, 0, 'phone_number'.tr().replaceAll(' number', ''))
                          : selectedStep == 2 || selectedStep == 5
                              ? _buildIconCheckStep(selectedStep, 0, 'phone_number'.tr().replaceAll(' number', ''))
                              : selectedStep == 3
                                  ? _buildIconCheckStep(selectedStep, 0, 'phone_number'.tr().replaceAll(' number', ''))
                                  : selectedStep == 4
                                      ? _buildIconCheckStep(selectedStep, 0, 'phone_number'.tr().replaceAll(' number', ''))
                                      : _buildTextStep(selectedStep, 0, '1', 'phone_number'.tr().replaceAll(' number', ''), 0),
                      //2
                      selectedStep == 2 || selectedStep == 5
                          ? _buildIconCheckStep(selectedStep, 1, 'OTP')
                          : selectedStep == 3
                              ? _buildIconCheckStep(selectedStep, 1, 'OTP')
                              : selectedStep == 4
                                  ? _buildIconCheckStep(selectedStep, 1, 'OTP')
                                  : selectedStep == 1
                                      ? _buildTextStep(selectedStep, 1, '2', 'OTP', 0)
                                      : _buildTextStep(selectedStep, 1, '', 'OTP', 0),
                      selectedStep == 3 || selectedStep == 4
                          ? _buildIconCheckStep(selectedStep, 2, 'data'.tr())
                          : selectedStep == 2 || selectedStep == 5
                              ? _buildTextStep(selectedStep, 2, '3', 'data'.tr(), 0)
                              : _buildTextStep(selectedStep, 2, '', 'data'.tr(), 0),
                      selectedStep == 4
                          ? _buildIconCheckStep(selectedStep, 3, 'pin'.tr())
                          : selectedStep == 3
                              ? _buildTextStep(selectedStep, 3, '4', 'pin'.tr(), 0)
                              : _buildTextStep(selectedStep, 3, '', 'pin'.tr(), 0),
                      selectedStep == 4 ? _buildTextStep(selectedStep, 4, '5', 'KYC', 0) : _buildTextStep(selectedStep, 4, '', 'KYC', 0)
                    ])
                  ]),
                ]),
              ),
            ),
          ),
          body: SafeArea(
            top: false,
            child: Stack(children: [
              Visibility(
                visible: _otpVisible,
                maintainState: true,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'confirm_phone_num'.tr(),
                        style: const TextStyle(fontSize: 24),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${'enter_pin_sent_phone'.tr()} $txPhoneNumber',
                            style: const TextStyle(color: Colors.black54, fontSize: 16),
                          ),
                          GestureDetector(
                            onTap: () async {
                              await showDialog(
                                  context: context,
                                  builder: (builder) => InputDialog(
                                        title: 'confirm_phone_num'.tr(),
                                        onPressedConfirm: (value) {
                                          StateStore.phoneNumberGlobal = value; //save phone to Global value.
                                          txPhoneNumber = value;
                                          setState(() {
                                            expiration = true;
                                            datetimeOTP = DateTime.now();
                                          });
                                        },
                                      ));
                            },
                            child: const Icon(Icons.edit),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Form(
                        key: formkeyOTP,
                        child: PinCodeTextField(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          appContext: context,
                          pastedTextStyle: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                          length: 6,
                          obscureText: false,
                          obscuringCharacter: '*',
                          animationType: AnimationType.fade,
                          pinTheme: PinTheme(
                            shape: PinCodeFieldShape.box,
                            borderRadius: BorderRadius.circular(5),
                            fieldHeight: 50,
                            fieldWidth: 43,
                            activeColor: hasError ? Colors.red : Colors.white,
                            selectedColor: colorGradientDark,
                            inactiveColor: colorGradientDark,
                            disabledColor: Colors.grey,
                            activeFillColor: Colors.white,
                            selectedFillColor: colorGradientDark,
                            inactiveFillColor: Colors.white,
                          ),
                          cursorColor: Colors.white,
                          animationDuration: const Duration(milliseconds: 300),
                          textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          backgroundColor: Colors.white,
                          enableActiveFill: true,
                          errorAnimationController: errorController,
                          controller: otpController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          boxShadows: const [BoxShadow(offset: Offset(0, 1), color: Colors.black12, blurRadius: 10)],
                          onChanged: (v) {
                            setState(() => hasError = false);
                            if (v.length == 6) autoSubmitOTP();
                          },
                          beforeTextPaste: (text) {
                            return true;
                          },
                        ),
                      ),
                      timeOTP(
                        expiration: expiration,
                        datetimeOTP: datetimeOTP,
                        onPressed: () async {
                          var otpId = await PostAPI.call(
                              url: '$register3003/send_otps',
                              headers: Authorization.auth2,
                              body: {"phone_number": txPhoneNumber, "country_code": countryCode},
                              context: context,
                              errorTitle: 'unable_register'.tr());

                          if (otpId['success']) {
                            setState(() {
                              sendOtpId = otpId['response']['data']['send_otp_id'];
                              datetimeOTP = DateTime.parse(otpId['response']['data']['expiration_at']);

                              otpController.clear();
                              expiration = false;
                            });
                          }
                        },
                        onDone: () => setState(() => expiration = true),
                      ),
                    ],
                  ),
                ),
              ),
              Visibility(
                  visible: _scanIDVisible,
                  maintainState: true,
                  child: ScanIdDetail(
                    isCitizen: isCitizen,
                    setCitizenToggle: setCitizenToggle,
                  )),
              Visibility(
                visible: _dataVisible,
                child: PersonalInfo(
                  isCitizen: isCitizen,
                  ocrAllFailed: ocrFailedAll,
                  person: personalInfo,
                  setSelectedStep: setSelectedStep,
                  setPinVisible: setPinVisible,
                  setFirstName: setFirstName,
                  setLastName: setLastName,
                  setFirstNameEng: setFirstNameEng,
                  setLastNameEng: setLastnameEng,
                  setAddress: setAddress,
                  setAddressSearch: setAddressSearch,
                  setBirthday: setBirthday,
                  setIDCard: setIDCard,
                  setLaserCode: setLaserCode,
                  setCareerID: setCareerID,
                  setindexDistric: setindexDistric,
                  setindexSubDistric: setindexSubDistric,
                  setindexProvince: setindexProvince,
                  setFileFrontCitizen: setFileFrontCitizen,
                  setFileBackCitizen: setFileBackCitizen,
                  setFileSelfie: setFileSelfie,
                  setDataVisible: setDataVisible,
                  address: address,
                  provinceID: indexProvince,
                  districtId: indexDistric,
                  subDistrictId: indexSubDistric,
                  //passport
                  setCountryCode: setCountryCode,
                  setPassportNumber: setPassportNumber,
                  setExpirePassport: setExpirePassport,
                ),
              ),
              Visibility(
                visible: _pinSetVisible,
                child: Container(
                  color: Colors.white,
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text('set_pin'.tr(), style: const TextStyle(fontSize: 30)),
                    Text('enter_pin'.tr(), style: const TextStyle(color: Colors.grey)),
                    Numpad(length: length, onChange: onChangeSetPIN, reset: resetPIN)
                  ]),
                ),
              ),
              Visibility(
                visible: _pinConfirmVisible,
                child: Container(
                  color: Colors.white,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('confirm_pin'.tr(), style: const TextStyle(fontSize: 30)),
                      Text('confirm_enter_pin'.tr(), style: const TextStyle(color: Colors.grey)),
                      Numpad(length: length, onChange: onChangeConfirmPIN, reset: resetPIN)
                    ],
                  ),
                ),
              ),
              Visibility(
                visible: _kycVisible,
                maintainState: true,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  width: double.infinity,
                  color: Colors.white,
                  child: Column(children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('scanface'.tr(), style: const TextStyle(fontSize: 24)),
                        Text(isCitizen ? 'scanface_verify'.tr() : 'scanface_verify_passport'.tr(),
                            style: const TextStyle(color: Colors.black54, fontSize: 16)),
                        const SizedBox(height: 20),
                        Row(children: [
                          const Icon(
                            Icons.check_circle_outline,
                            color: Color(0xFF27AE60),
                          ),
                          const SizedBox(width: 5),
                          Text('photolight'.tr(), style: const TextStyle(color: Colors.black54, fontSize: 16)),
                        ]),
                        Row(children: [
                          const Icon(
                            Icons.check_circle_outline,
                            color: Color(0xFF27AE60),
                          ),
                          const SizedBox(width: 5),
                          Text('faceposition'.tr(), style: const TextStyle(color: Colors.black54, fontSize: 16)),
                        ]),
                        const SizedBox(height: 10),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(children: [
                          Image.asset('assets/images/FaceScan-1.jpg', package: 'gbkyc', scale: 5),
                          Text('Keep_your_face_straight'.tr(), textAlign: TextAlign.center)
                        ]),
                        const SizedBox(width: 20),
                        Column(children: [
                          Image.asset('assets/images/FaceScan-2.jpg', package: 'gbkyc', scale: 5),
                          Text('Shoot_in_a_well_lit_area'.tr(), textAlign: TextAlign.center)
                        ])
                      ],
                    ),
                  ]),
                ),
              ),
              Visibility(
                visible: _kycVisibleFalse,
                maintainState: true,
                child: Container(
                  width: double.infinity,
                  color: Colors.white,
                  child: ListView(physics: const ClampingScrollPhysics(), padding: const EdgeInsets.all(20), children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: pathSelfie == ''
                          ? Image.asset(
                              'assets/icons/idCardD.png',
                              package: 'gbkyc',
                              height: MediaQuery.of(context).size.width,
                              // fit: BoxFit.cover,
                            )
                          : Image.file(
                              File(pathSelfie),
                              height: MediaQuery.of(context).size.width,
                              fit: BoxFit.cover,
                            ),
                    ),
                    const SizedBox(height: 10),
                    Row(children: [
                      const Icon(Icons.error_outline_outlined),
                      const SizedBox(width: 5),
                      Text(
                        isCitizen
                            ? "Make_sure_your_id_card_is_clear_and_without_a_scratch".tr()
                            : 'make_sure_your_passport_is_clear_and_without_a_scratch'.tr(),
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ]),
                  ]),
                ),
              ),
              isLoading ? pageLoading() : const SizedBox(),
            ]),
          ),
          bottomNavigationBar: selectBottomView(selectedStep),
        ),
      ),
    );
  }
}
