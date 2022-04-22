import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'pages/MainPage.dart';

String appName = "NVMA";

void main() async{
  runApp(const MyApp());

  var status = await Permission.storage.status;
  if (!status.isGranted) await Permission.storage.request();
  var manageStatus = await Permission.manageExternalStorage.status;
  if(!manageStatus.isGranted) await Permission.manageExternalStorage.request();
  var micStatus = await Permission.microphone.status;
  if(!micStatus.isGranted) await Permission.microphone.request();
  var bluetoothStatus = await Permission.bluetoothConnect.status;
  if(!bluetoothStatus.isGranted) await Permission.bluetoothConnect.request();
  bluetoothStatus = await Permission.bluetoothScan.status;
  if(!bluetoothStatus.isGranted) await Permission.bluetoothScan.request();
  bluetoothStatus = await Permission.bluetoothAdvertise.status;
  if(!bluetoothStatus.isGranted) await Permission.bluetoothAdvertise.request();
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Noise Vibration Measurement App',
      builder: BotToastInit(),
      theme: ThemeData(
        primarySwatch: Colors.grey,
        pageTransitionsTheme: const PageTransitionsTheme(builders: {TargetPlatform.android: ZoomPageTransitionsBuilder(),}),
      ),
      routes:{
        '/': (context) => const MainPage(),
        '/main': (context) => const MainPage(),
      },
    );
  }
}
