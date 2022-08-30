import 'dart:async';
import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:gbkyc/api/config_api.dart';
import 'package:gbkyc/api/post_api.dart';
import 'package:gbkyc/utils/crop_image_path.dart';
import 'package:gbkyc/utils/file_uitility.dart';
import 'package:permission_handler/permission_handler.dart';

import 'widgets/circular_progress.dart';
import 'widgets/custom_dialog.dart';

class CameraScanIDCard extends StatefulWidget {
  final bool? enableButton, isFront, noFrame, scanID;
  final String titleAppbar;

  const CameraScanIDCard({
    Key? key,
    this.enableButton,
    this.isFront,
    this.noFrame,
    this.scanID = false,
    required this.titleAppbar,
  }) : super(key: key);

  @override
  State<CameraScanIDCard> createState() => _CameraScanIDCardState();
}

class _CameraScanIDCardState extends State<CameraScanIDCard> {
  BuildContext? currentContext;
  bool? visibleFront = true;
  bool visibleBack = false;
  bool isBusy = false;
  bool isLoading = false;
  bool? noFrame = false;
  bool flashStatus = false;
  bool hideFlash = false;
  // bool _takeFront = false;
  // bool _takeBack = false;
  bool isInputScan = false;
  int cameraCount = 0, cameraBackCount = 0;

  CameraController? _controller;
  CameraLensDirection _direction = CameraLensDirection.back;
  final GlobalKey _globalKey = GlobalKey();
  // final TextRecognizer textDetector = TextRecognizer();

  late Size size;
  late Offset offset;

  String? frontIDPath;
  String? backIDPath;
  String? dopaFirstName;
  String? dopaLastName;
  String? ocrFrontID;
  String? ocrFrontName;
  String? ocrFrontSurname;
  String? ocrFrontAddress;
  String? ocrFilterAddress;
  String? ocrFrontBirthdayD;
  String? ocrFrontBirthdayM;
  String? ocrFrontBirthdayY;
  String? birthDay;
  String? ocrBackLaser;
  bool ocrFailedAll = false;

  callBackData() async {
    Map data = {};

    data['ocrFrontID'] = ocrFrontID ?? '';
    data['ocrFrontName'] = ocrFrontName ?? '';
    data['ocrFrontSurname'] = ocrFrontSurname ?? '';
    data['ocrFrontAddress'] = ocrFrontAddress ?? '';
    data['ocrFilterAddress'] = ocrFilterAddress ?? '';
    data['ocrBirthDay'] = birthDay ?? '';
    data['ocrBackLaser'] = ocrBackLaser ?? '';
    data['frontIDPath'] = frontIDPath ?? '';
    data['backIDPath'] = backIDPath ?? '';
    data['ocrFailedAll'] = ocrFailedAll;

    // debugPrint(data);
    return data;
  }

  ocrThaiID({String? image, String? side}) async {
    Dio dio = Dio();

    dio.options.baseUrl = '$register3003/users/ocr-thailand-id-card';
    dio.options.headers = {'Authorization2': authorization2};

    FormData formData = FormData.fromMap({"image": image, "side": side});

    var response = await dio.post(dio.options.baseUrl, data: formData).timeout(const Duration(seconds: 30));
    debugPrint('${dio.options.baseUrl}: ${response.data}');

    if (response.data['success']) {
      return response.data['response']['data']['result'];
    }
    return '';
  }

  @override
  void initState() {
    super.initState();

    currentContext = context;
    cameraCount = 0;
    cameraBackCount = 0;
    noFrame = widget.noFrame;
    visibleFront = widget.isFront;
    if (noFrame!) _direction = CameraLensDirection.front;
    _startLiveFeed();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final RenderBox renderBox = _globalKey.currentContext?.findRenderObject() as RenderBox;
      size = renderBox.size;
      offset = renderBox.localToGlobal(Offset.zero);
    });
  }

  @override
  void dispose() {
    super.dispose();
    // textDetector.close();
    _controller?.dispose();
  }

  Future _startLiveFeed() async {
    if (await Permission.camera.request().isGranted) {
      final camera = await availableCameras().then(
        (List<CameraDescription> cameras) => cameras.firstWhere(
          (CameraDescription camera) => camera.lensDirection == _direction,
        ),
      );
      _controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
      );
      _controller!.initialize().then((_) {
        if (!mounted) {
          return;
        }
        // if (widget.scanID!) {
        //   isInputScan = true;
        //   _controller?.startImageStream(_processCameraImage);
        // }
        _controller!.setFlashMode(FlashMode.off);

        setState(() {});
      });
    } else {
      if (await Permission.camera.isPermanentlyDenied) {
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (context) => CustomDialog(
            title: 'Camera_is_disabled'.tr(),
            content: 'access_your_camera_Want_to_go_to_settings' /*.tr()*/,
            avatar: false,
            onPressedConfirm: () {
              Navigator.pop(context);
              openAppSettings();
            },
            buttonCancel: true,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: Key('CameraScanIDCard_plugin_${DateTime.now().toString()}'),
      body: Stack(children: [
        visibleFront! ? _cameraFrontPreviewWidget() : _cameraBackPreviewWidget(),
        Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              height: kToolbarHeight + 40,
              child: AppBar(elevation: 0, title: Text(widget.titleAppbar)),
            )),
        Align(
          alignment: Alignment.bottomCenter,
          child: widget.enableButton!
              ? Container(height: 120, width: double.infinity, color: Colors.white, child: _cameraNoORC())
              : Container(
                  height: 120,
                  color: Colors.white,
                  child: Row(children: [
                    hideFlash
                        ? const Expanded(child: SizedBox())
                        : Expanded(
                            child: GestureDetector(
                              onTap: () {
                                if (_controller!.value.flashMode == FlashMode.off) {
                                  _controller!.setFlashMode(FlashMode.torch);
                                } else {
                                  _controller!.setFlashMode(FlashMode.off);
                                }
                                setState(() => flashStatus = !flashStatus);
                              },
                              child: Icon(
                                flashStatus ? Icons.flash_on : Icons.flash_off,
                              ),
                            ),
                          ),
                    Expanded(
                      child: FloatingActionButton(
                        backgroundColor: Colors.white,
                        onPressed: visibleFront! ? _onCaptureFrontPressed : _onCaptureBackPressed,
                        child: const Icon(
                          Icons.lens,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const Expanded(child: SizedBox())
                  ]),
                ),
        ),
        Center(child: SizedBox(key: _globalKey, height: MediaQuery.of(context).size.height / 2.5, width: double.infinity)),
        // if (frontIDPath != null) Image.file(File(frontIDPath!))
      ]),
    );
  }

  Widget ocrGuideFrame(bool isFront) {
    if (!_controller!.value.isInitialized) {
      return Container();
    }
    return Stack(children: [
      Center(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.only(bottom: kBottomNavigationBarHeight),
          child: CameraPreview(_controller!),
        ),
      ),
      if (!noFrame!)
        SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Opacity(
            opacity: 0.8,
            child: Image.asset(
              isFront ? 'assets/images/crop_front_id_${'language'.tr()}.png' : 'assets/images/crop_back_id_${'language'.tr()}.png',
              package: 'gbkyc',
              fit: BoxFit.fitWidth,
            ),
          ),
        ),
      if (!noFrame!)
        Positioned(
          top: MediaQuery.of(context).size.height / 5,
          left: 0,
          right: 0,
          child: Text(
            isFront ? 'Please_arrange_the_front_of_the_card'.tr() : 'Please_arrange_the_back_of_the_card'.tr(),
            style: const TextStyle(fontSize: 16, color: Colors.white),
            textAlign: TextAlign.center,
          ),
        )
    ]);
  }

  /// Display Camera preview.
  Widget _cameraFrontPreviewWidget() {
    if (_controller == null || !_controller!.value.isInitialized) {
      return circularProgress();
    } else if (isLoading) {
      return Container(
        decoration: const BoxDecoration(color: Colors.grey),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomPaint(foregroundPainter: Paint()),
            circularProgress(),
            const SizedBox(height: 5),
            Text('${'System_is_processing'.tr()}...', style: const TextStyle(color: Colors.white)),
          ],
        ),
      );
    } else {
      return ocrGuideFrame(true);
    }
  }

  /// Display Camera preview.
  Widget _cameraBackPreviewWidget() {
    if (_controller == null || !_controller!.value.isInitialized) {
      return circularProgress();
    } else if (isLoading) {
      return Container(
          decoration: const BoxDecoration(color: Colors.grey),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            CustomPaint(foregroundPainter: Paint()),
            circularProgress(),
            const SizedBox(height: 5),
            Text('${'System_is_processing'.tr()}...', style: const TextStyle(color: Colors.white)),
          ]));
    } else {
      return ocrGuideFrame(false);
    }
  }

  //Display the control bar with buttons to take pictures
  Widget _cameraNoORC() {
    if (isLoading) {
      return Container(
        decoration: const BoxDecoration(color: Colors.grey),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomPaint(foregroundPainter: Paint()),
          ],
        ),
      );
    }
    return Row(children: [
      noFrame!
          ? const Expanded(child: SizedBox())
          : Expanded(
              child: GestureDetector(
                onTap: () {
                  if (_controller!.value.flashMode == FlashMode.off) {
                    _controller!.setFlashMode(FlashMode.torch);
                  } else {
                    _controller!.setFlashMode(FlashMode.off);
                  }
                  setState(() => flashStatus = !flashStatus);
                },
                child: Icon(flashStatus ? Icons.flash_on : Icons.flash_off),
              ),
            ),
      Expanded(
        child: FloatingActionButton(
          backgroundColor: Colors.white,
          onPressed: _onCaptureNoOCR,
          child: const Icon(
            Icons.lens,
            color: Colors.black,
          ),
        ),
      ),
      const Expanded(child: SizedBox())
      // !noFrame
      //     ? Expanded(child: SizedBox())
      //     : Expanded(
      //         child: GestureDetector(
      //           child: Icon(
      //             Icons.autorenew,
      //             color: Colors.black,
      //           ),
      //           onTap: _switchLiveCamera,
      //         ),
      //       ),
    ]);
  }

  _onCaptureFrontPressed() async {
    // if (_controller!.value.isStreamingImages) {
    //   await _controller?.stopImageStream();
    // }
    try {
      setState(() => isLoading = true);
      await _controller!.takePicture().then((v) => frontIDPath = v.path);

      List<int> toJPG = await cropImagePath(imagePath: frontIDPath!, offset: offset, size: size, context: context);
      String base64 = base64Encode(toJPG);

      final resFront = await ocrThaiID(image: base64, side: "front");
      if (resFront.isNotEmpty) {
        String fullAddress = resFront['address_th'];
        List address = fullAddress.split(RegExp(r" ต.| แขวง"));
        List arrName = [], arrBirthday = [];

        if (resFront['name_th'].toString().contains(' ')) arrName = resFront['name_th'].split(' ');
        if (resFront['date_of_birth_en'].toString().contains(' ')) arrBirthday = resFront['date_of_birth_en'].split(' ');

        if (arrName.isNotEmpty) {
          if (/*context.locale.toString()*/ "en_US" == 'th_TH') {
            ocrFrontName = arrName[arrName.length - 2];
            ocrFrontSurname = arrName[arrName.length - 1];
          } else {
            List arrEnName = resFront['first_name_en'].split(' ');
            ocrFrontName = arrEnName[arrEnName.length - 1];
            ocrFrontSurname = resFront['last_name_en'];
          }

          dopaFirstName = arrName[arrName.length - 2];
          dopaLastName = arrName[arrName.length - 1];
        }

        ocrFrontID = resFront['id_number'].replaceAll(RegExp(r"\s+\b|\b\s"), "");
        ocrFrontAddress = address[0];
        ocrFilterAddress = address[1];
        ocrFrontBirthdayD = arrBirthday[0];
        ocrFrontBirthdayM = arrBirthday[1];
        ocrFrontBirthdayY = arrBirthday[2];

        setState(() {
          isLoading = false;
          visibleFront = false;
          visibleBack = true;
        });

        await _startLiveFeed();
      } else {
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) => CustomDialog(
            title: 'Something_went_wrong'.tr(),
            content: 'ID_card_scan_failed_Please_try_again'.tr(),
            avatar: false,
            onPressedConfirm: () async {
              Navigator.pop(context);

              setState(() {
                cameraCount++;
                isLoading = false;
                // _takeFront = false;
              });

              if (cameraCount == 3) {
                ocrFailedAll = true;
                Navigator.pop(this.context, callBackData());
              } else {
                await _startLiveFeed();
              }
            },
          ),
        );
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  _onCaptureBackPressed() async {
    // if (_controller!.value.isStreamingImages) {
    //   await _controller?.stopImageStream();
    // }
    try {
      setState(() => isLoading = true);
      await _controller!.takePicture().then((v) => backIDPath = v.path);

      List<int> toJPG = await cropImagePath(imagePath: backIDPath!, offset: offset, size: size, context: context);
      String base64 = base64Encode(toJPG);

      final resBack = await ocrThaiID(image: base64, side: 'back');

      if (resBack.isNotEmpty) {
        ocrBackLaser = resBack['laser_number'].replaceAll(RegExp("-"), "");
        final convertFrontBirthdayM = ocrFrontBirthdayM == 'Jan.'
            ? '01'
            : ocrFrontBirthdayM == 'Feb.'
                ? '02'
                : ocrFrontBirthdayM == 'Mar.'
                    ? '03'
                    : ocrFrontBirthdayM == 'Apr.'
                        ? '04'
                        : ocrFrontBirthdayM == 'May'
                            ? '05'
                            : ocrFrontBirthdayM == 'Jun.'
                                ? '06'
                                : ocrFrontBirthdayM == 'Jul.'
                                    ? '07'
                                    : ocrFrontBirthdayM == 'Aug.'
                                        ? '08'
                                        : ocrFrontBirthdayM == 'Sep.'
                                            ? '09'
                                            : ocrFrontBirthdayM == 'Oct.'
                                                ? '10'
                                                : ocrFrontBirthdayM == 'Nov.'
                                                    ? '11'
                                                    : '12';
        final convertFrontBirthdayD = ocrFrontBirthdayD == '1'
            ? '01'
            : ocrFrontBirthdayD == '2'
                ? '02'
                : ocrFrontBirthdayD == '3'
                    ? '03'
                    : ocrFrontBirthdayD == '4'
                        ? '04'
                        : ocrFrontBirthdayD == '5'
                            ? '05'
                            : ocrFrontBirthdayD == '6'
                                ? '06'
                                : ocrFrontBirthdayD == '7'
                                    ? '07'
                                    : ocrFrontBirthdayD == '8'
                                        ? '08'
                                        : ocrFrontBirthdayD == '9'
                                            ? '09'
                                            : ocrFrontBirthdayD;
        birthDay = '$convertFrontBirthdayD/$convertFrontBirthdayM/$ocrFrontBirthdayY';

        var verifyDOPA = await PostAPI.call(
            url: '$register3003/users/verify_dopa',
            headers: Authorization.auth2,
            body: {
              "id_card": ocrFrontID!,
              "first_name": dopaFirstName!,
              "last_name": dopaLastName!,
              "birthday": birthDay!,
              "laser": ocrBackLaser!,
            },
            context: context);

        if (verifyDOPA['success']) {
          Navigator.pop(this.context, callBackData());
        } else {
          // if (File(backIDPath) != null) {
          //   await File(backIDPath).delete();
          // }
          setState(() {
            cameraBackCount++;
            isLoading = false;
            // _takeBack = false;
          });

          if (cameraBackCount == 3) {
            // await File(frontIDPath).delete();
            ocrFailedAll = true;
            Navigator.pop(this.context, callBackData());
          } else {
            await _startLiveFeed();
          }
        }
      } else {
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) => CustomDialog(
            title: 'Something_went_wrong'.tr(),
            content: 'ID_card_scan_failed_Please_try_again'.tr(),
            avatar: false,
            onPressedConfirm: () async {
              Navigator.pop(context);

              // if (File(backIDPath) != null) {
              //   await File(backIDPath).delete();
              // }

              setState(() {
                cameraBackCount++;
                isLoading = false;
                // _takeBack = false;
              });

              if (cameraBackCount == 3) {
                // await File(frontIDPath).delete();
                ocrFailedAll = true;
                Navigator.pop(this.context, callBackData());
              } else {
                await _startLiveFeed();
              }
            },
          ),
        );
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  _onCaptureNoOCR() async {
    try {
      setState(() => isLoading = true);
      await _controller!.takePicture().then((v) {
        Navigator.pop(context, v.path);
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}

class Paint extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawColor(Colors.grey.withOpacity(0.6), BlendMode.dstOut);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
