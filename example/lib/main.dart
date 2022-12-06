import 'package:flutter/material.dart';
import 'package:gbkyc/gbkyc.dart';
import 'package:get/get.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return const GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final phoneController = TextEditingController();
  bool isThai = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test GB SDK')),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextFormField(
                  controller: phoneController,
                  style: const TextStyle(fontSize: 16),
                  textInputAction: TextInputAction.next,
                  validator: (v) {
                    if (v?.length != 10) {
                      return 'please enter number equal 10';
                    }
                    return null;
                  },
                  maxLength: 10,
                  keyboardType: TextInputType.number,
                  onChanged: ((value) => _formKey.currentState?.validate()),
                  decoration: const InputDecoration(labelText: 'Phone number')),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text(
                    'EN',
                    style: TextStyle(fontSize: 20, color: Colors.blue),
                  ),
                  Switch(
                    value: isThai,
                    onChanged: (value) => setState(() {
                      isThai = !isThai;
                    }),
                    activeColor: Colors.red,
                    inactiveTrackColor: Colors.blue[300],
                    inactiveThumbColor: Colors.blue,
                  ),
                  const Text(
                    'TH',
                    style: TextStyle(fontSize: 20, color: Colors.red),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              MaterialButton(
                height: 60,
                minWidth: double.infinity,
                color: Colors.blue,
                onPressed: () {
                  if (_formKey.currentState!.validate() && phoneController.text.length == 10) {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => Gbkyc.register(phoneController.text, isThai: isThai))).then((v) {
                      if (v != null) {
                        debugPrint('สมัครสำเร็จ : $v');
                      }
                    });
                  }
                },
                child: const Text(
                  'Open GB SDK',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
