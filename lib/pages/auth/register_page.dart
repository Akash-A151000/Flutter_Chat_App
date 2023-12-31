import 'package:chat_app/helper/helper_function.dart';
import 'package:chat_app/pages/auth/login_page.dart';
import 'package:chat_app/pages/home_page.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../widgets/widgets.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _isLoading = false;
  final formkey = GlobalKey<FormState>();
  String email="";
  String password = "";
  String fullName = "";
  AuthService authservice = AuthService();
  
  @override
  Widget build(BuildContext context) {
     return Scaffold(
     
      body:_isLoading?Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColor,),): SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20,vertical: 80),
          child: Form(
            key: formkey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children:<Widget> [
              const  Text("Groupie",
                style: TextStyle(fontSize: 40,fontWeight: FontWeight.bold),
                ),
               const SizedBox(height: 10,),
               const Text("Create your account now to chat and explore",style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400
               ),
               ),
               Image.asset("assets/register.png"),
               TextFormField(
                decoration: textInputDecoration.copyWith(
                  labelText: "Full Name",
                  prefixIcon: Icon(Icons.person,
                  color: Theme.of(context).primaryColor,
                  )
                ),
                onChanged: (value) {
                  setState(() {
                    fullName=value;
                   
                  });
                },
                validator: (value) {
                   if (value!.isNotEmpty) {
                     return null;
                   }else{
                    return "Name cannot be empty";
                   }
                },
               ),

               const SizedBox(height: 15,),


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
                   register();
                }, child: const Text("Register",style: TextStyle(
                  color: Colors.white,
                  fontSize: 16                                                    
                ),)),
              ),

              const SizedBox(height: 10,),

              Text.rich(TextSpan(
                text: "Already have an account? ",
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: "Login now",
                    style: const TextStyle(color:Colors.black, decoration: TextDecoration.underline),
                    recognizer: TapGestureRecognizer()..onTap=() {
                      nextScreen(context, const LoginPage() );
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
  register()async{
    if (formkey.currentState!.validate()) {
      setState(() {
        _isLoading=true;
      });

      await authservice
            .registerUserWithEmailAndPassword(fullName, email, password)
            .then((value) async{
              if (value==true) {
                await HelperFunction.saveUserLoggedInStatus(true);
                await HelperFunction.saveUserEmailSF(email);
                await HelperFunction.saveUserNameSF(fullName);
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