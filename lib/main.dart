import 'package:chat_app/helper/helper_function.dart';
import 'package:chat_app/pages/auth/login_page.dart';
import 'package:chat_app/pages/home_page.dart';
import 'package:chat_app/shared/constants.dart';
import 'package:firebase_core/firebase_core.dart';
import "package:flutter/material.dart";
import 'package:flutter/foundation.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(options: FirebaseOptions(
      apiKey: Constatnts.apiKey,
      appId: Constatnts.appId,
      messagingSenderId: Constatnts.messagingSenderId, 
      projectId: Constatnts.projectId));
  }else{
    await Firebase.initializeApp();
  }
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  bool _isSignedIn = false;


  @override
  void initState() {
    super.initState();
    getUserLoggedInstatus();
  }

  getUserLoggedInstatus()async{
    await HelperFunction.getUserLoggedInstatus().then((value) {
      if (value!=null) {
        setState(() {
           _isSignedIn=value;
        });
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Constatnts().primaryColor,
        scaffoldBackgroundColor: Colors.white
      ),
      debugShowCheckedModeBanner: false,
      home: _isSignedIn?const HomePage():const LoginPage(),
    );
  }
}