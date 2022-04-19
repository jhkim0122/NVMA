import 'package:flutter/material.dart';

import 'pages/MainPage.dart';

String appName = "NVMA";

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Noise Vibration Measurement App',
      theme: ThemeData(
        primarySwatch: const MaterialColor(
            0xFFFFC289, <int,Color>{
              50: Color(0xFFFCDCCC),
              100: Color(0xFFF8C58F),
              200: Color(0xFFFFC289),
              300: Color(0xFFFFB066),
              400: Color(0xFFF88C48),
              500: Color(0xFFFF8B1E),
              600: Color(0xFFF97900),
              700: Color(0xFFF16208),
              800: Color(0xFFCE5407),
              900: Color(0xFFAC4606),
            }
        ),
        pageTransitionsTheme: const PageTransitionsTheme(builders: {TargetPlatform.android: ZoomPageTransitionsBuilder(),}),
      ),
      routes:{
        '/': (context) => const MainPage(),
        '/main': (context) => const MainPage(),
      },
    );
  }
}
