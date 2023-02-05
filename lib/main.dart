import 'package:admin/view_all_data.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await
  Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Admin_side',
      theme: ThemeData(

        textTheme: Theme.of(context).textTheme.apply(
          fontSizeFactor: 1.5,
          // fontSizeDelta: 2.0,
          fontFamily: 'Times New Roman'
        ),
        primarySwatch: Colors.blue,
      ),
      home: ViewAllData()
    );
  }
}

