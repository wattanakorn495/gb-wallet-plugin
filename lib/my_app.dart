import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:gbkyc/pages/register.dart';
import 'package:gbkyc/utils/file_uitility.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:responsive_framework/responsive_framework.dart';

import 'address_bloc.dart';
import 'utils/device_serial.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

void configLoading() {
  EasyLoading.instance
    ..loadingStyle = EasyLoadingStyle.light
    ..radius = 10
    ..contentPadding = const EdgeInsets.all(14)
    ..indicatorWidget = Container(
      height: 50,
      width: 50,
      decoration: const BoxDecoration(color: Colors.transparent, shape: BoxShape.circle),
      child: const LoadingIndicator(
        indicatorType: Indicator.ballRotateChase,
        colors: [Color(0xFFFF9F02)],
        strokeWidth: 4,
      ),
    )
    ..userInteractions = false
    ..dismissOnTap = false;
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key, required this.phoneNumber, required this.isThai, this.onConfirmOTP}) : super(key: key);
  final String phoneNumber;
  final bool isThai;
  final void Function(String phonenumber)? onConfirmOTP;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    WidgetsFlutterBinding.ensureInitialized();
    HttpOverrides.global = MyHttpOverrides();
    initDeviceSerial();
    configLoading();
    getENV();
  }

  getENV() async {
    await dotenv.load(fileName: 'packages/gbkyc/assets/.env');
    // await readStringFile(widget.isThai);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]); //ปรับให้แอปเป็นแนวตั้ง
    // Intl.defaultLocale = Get.deviceLocale.toString(); //ตั้งภาษาแรกตามพื้นที่
    // initializeDateFormatting(Get.deviceLocale.toString(), null); //ตั้งปฏิทินแรกตามพื้นที่

    return MultiBlocProvider(
      providers: [BlocProvider(create: (_) => AddressBloc())],
      child: MaterialApp(
        // localizationsDelegates: context.localizationDelegates,
        // supportedLocales: context.supportedLocales,
        debugShowCheckedModeBanner: false,
        builder: EasyLoading.init(
          builder: (context, child) => ResponsiveWrapper.builder(child,
              // maxWidth: 1200,
              // minWidth: 480,
              // defaultScale: true,
              background: Container(color: const Color(0xFFF5F5F5))),
        ),
        home: FutureBuilder(
            future: readStringFile(widget.isThai),
            builder: ((context, snapshot) => Register(
                  phoneNumber: widget.phoneNumber,
                  onConfirmOTP: widget.onConfirmOTP,
                ))),
        title: 'GB Wallet',
        theme: ThemeData(
          primaryColor: colorGradientDark,
          colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.white),
          unselectedWidgetColor: colorGradientLight,
          fontFamily: 'kanit',
          dividerTheme: const DividerThemeData(color: Colors.grey, space: 0),
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 1,
            systemOverlayStyle: SystemUiOverlayStyle.dark,
            backgroundColor: Colors.white,
            titleTextStyle: TextStyle(color: Colors.black, fontSize: 17, fontFamily: 'kanit', package: 'gbkyc'),
            iconTheme: IconThemeData(color: Colors.black),
          ),
          buttonTheme: ButtonThemeData(
            height: 50,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            textTheme: ButtonTextTheme.accent,
          ),
          inputDecorationTheme: InputDecorationTheme(
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: colorGradientDark, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: colorGradientDark),
              borderRadius: BorderRadius.circular(8),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: true,
            fillColor: Colors.white,
            labelStyle: const TextStyle(fontSize: 16, color: Colors.black54, fontFamily: 'kanit', package: 'gbkyc'),
            hintStyle: const TextStyle(color: Colors.grey, fontFamily: 'kanit', package: 'gbkyc'),
            counterStyle: const TextStyle(fontSize: 0),
            errorStyle: const TextStyle(fontFamily: 'kanit', package: 'gbkyc'),
          ),
          textTheme: const TextTheme(
            button: TextStyle(fontSize: 17, fontFamily: 'kanit', package: 'gbkyc'),
            bodyText1: TextStyle(fontFamily: 'kanit', package: 'gbkyc'),
            bodyText2: TextStyle(fontFamily: 'kanit', package: 'gbkyc'),
          ),
          textSelectionTheme: const TextSelectionThemeData(cursorColor: colorGradientDark),
          scaffoldBackgroundColor: Colors.white,
        ),
      ),
    );
  }
}
