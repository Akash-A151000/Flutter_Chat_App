import 'package:chat_app/pages/auth/register_page.dart';
import 'package:chat_app/services/database_service.dart';
import 'package:chat_app/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../helper/helper_function.dart';
import '../../services/auth_service.dart';
import '../home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String email="";
  String password="";
  final formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  AuthService authservice = AuthService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
     
      body:_isLoading?Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColor,),): SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20,vertical: 80),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children:<Widget> [
              const  Text("Groupie",
                style: TextStyle(fontSize: 40,fontWeight: FontWeight.bold),
                ),
               const SizedBox(height: 10,),
               const Text("Login now to see what they are talking!",style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400
               ),
               ),
               Image.asset("assets/login.png"),
               TextFormField(
                decoration: textInputDecoration.copyWith(
                  labelText: "Email",
                  prefixIcon: Icon(Icons.email,
                  color: Theme.of(context).primaryColor,
                  )
                ),
                onChanged: (value) {
                  setState(() {
                    email=value;
                   
                  });
                },
                validator: (value) {
                   return RegExp(
                                        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                    .hasMatch(value!)
                                ? null
                                : "Please enter a valid email";
                },
               ),

              const SizedBox(height: 15,),
               TextFormField(
                obscureText: true,
                decoration: textInputDecoration.copyWith(
                  labelText: "Password",
                  prefixIcon: Icon(Icons.lock,
                  color: Theme.of(context).primaryColor,
                  ),
                ),
                  onChanged: (value) {
                  setState(() {
                    password=value;
                    
                  });
                },
                validator: (value) {
                  if (value!.length < 6) {
                    return "Password must be atleast 6 characters";
                  }else{
                    return null;
                  }
                },
               ),
               
              const SizedBox(height: 20,),

              SizedBox(
                width:  double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Theme.of(context).primaryColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)
                    )
                  ),
                  onPressed: (){
                   login();
                }, child: const Text("Sign In",style: TextStyle(
                  color: Colors.white,
                  fontSize: 16                                                    
                ),)),
              ),

              const SizedBox(height: 10,),

              Text.rich(TextSpan(
                text: "Don't have an account? ",
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: "Register Here",
                    style: const TextStyle(color:Colors.black, decoration: TextDecoration.underline),
                    recognizer: TapGestureRecognizer()..onTap=() {
                      nextScreen(context, const RegisterPage() );
                    }
                  )
                ]
              ))
              ],
            )),
          ),
      ) ,
    );
  }
login()async{
    if (formKey.currentState!.validate()) {
      setState(() {
        _isLoading=true;
      });

      await authservice
            .loginUserWithEmailAndPassword(email, password)
            .then((value) async{
              if (value==true) {
                QuerySnapshot snapshot= await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
                .gettingUserData(email);

                await HelperFunction.saveUserLoggedInStatus(true);
                await HelperFunction.saveUserEmailSF(email);
                await HelperFunction.saveUserNameSF(
                  snapshot.docs[0]['fullName']
                );
                nextScreenReplacement(context,const HomePage()); 
              }else{
                showSnackbar(context, Colors.red, value);
                setState(() {
                  _isLoading=false;
                });
              }

            });
    }
}
 
}