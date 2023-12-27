import 'package:chat_app/pages/home_page.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:chat_app/widgets/widgets.dart';
import 'package:flutter/material.dart';

import 'auth/login_page.dart';

class Profile_Page extends StatefulWidget {
  String userName;
  String email;
   Profile_Page({super.key,required this.userName,required this.email});

  @override
  State<Profile_Page> createState() => _Profile_PageState();
}

class _Profile_PageState extends State<Profile_Page> {
  AuthService authService = AuthService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: AppBar(
      backgroundColor: Theme.of(context).primaryColor,
      elevation: 0 ,
      centerTitle: true,
      title: const Text(
        "Profile",
        style: TextStyle(
          color: Colors.white,
          fontSize: 27,
          fontWeight: FontWeight.bold
        ),
      ),
     ),
     drawer: Drawer(
         child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 50),
          children:<Widget> [
            Icon(
              Icons.account_circle,
              size: 150,
              color: Colors.grey[700], 
            ),
            const SizedBox(height: 15,),
            Text(
            widget.userName,
            textAlign: TextAlign.center,
            style:const  TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 30,),

            const Divider(
              height: 2,
            ),

            ListTile(
              onTap: () {
                nextScreen(context, const HomePage());
              },
             
              contentPadding: EdgeInsets.symmetric(horizontal: 20,vertical: 5),
              leading: const Icon(Icons.group),
              title: const Text("Groups",
              style: TextStyle(color: Colors.black),
              ),

            ),
             ListTile(
              onTap: ()async {
                
              },
               selectedColor: Theme.of(context).primaryColor,
              selected: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 20,vertical: 5),
              leading: const Icon(Icons.group),
              title: const Text("Profile",
              style: TextStyle(color: Colors.black),
              ),

            ),
             ListTile(
              onTap: () async{
                showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (context) {
                   return AlertDialog(
                    title:const Text("Logout"),
                    content:const Text("Are you sure u want to logout?"),
                    actions: [
                      IconButton(onPressed: (){
                        Navigator.pop(context);
                      }, icon:const Icon(Icons.cancel,color: Colors.red,)),

                      IconButton(onPressed: ()async{
                        await authService.signOut();
                         Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const LoginPage(),), (route) => false);
                      }, icon: const Icon(Icons.done,color: Colors.green,))
                    ],
                   );
                 },);
              },
             
              contentPadding: EdgeInsets.symmetric(horizontal: 20,vertical: 5),
              leading: const Icon(Icons.exit_to_app),
              title: const Text("Logout",
              style: TextStyle(color: Colors.black),
              ),

            )
          ],
        ),
     ),

     body: Container(
      padding: EdgeInsetsDirectional.symmetric(horizontal: 40,vertical: 140),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(
            Icons.account_circle,
            size: 200,
            color: Colors.grey[700],
          ),
          const SizedBox(height: 15,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Full Name",style: TextStyle(fontSize: 17),),
              Text(widget.userName,style:const TextStyle(fontSize: 17))
            ],
          ),
          Divider(
            height: 20,
          ),
           Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Email",style: TextStyle(fontSize: 17),),
              Text(widget.email,style:const TextStyle(fontSize: 17))
            ],
          )
        ],
      ),
     ),
    );
  }
}