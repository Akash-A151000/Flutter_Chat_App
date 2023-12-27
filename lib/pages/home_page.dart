import 'package:chat_app/helper/helper_function.dart';
import 'package:chat_app/pages/auth/login_page.dart';
import 'package:chat_app/pages/profile_page.dart';
import 'package:chat_app/pages/search_page.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:chat_app/services/database_service.dart';
import 'package:chat_app/widgets/group_tile.dart';
import 'package:chat_app/widgets/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String userName ="";
  String email = "";
  String groupName="";
  AuthService authService = AuthService();
  Stream? groups;
  bool _isLoading = false;

  String getId(String res){
    return res.substring(0,res.indexOf("_"));
  }

  String getName(String res){
    return res.substring(res.indexOf("_")+1);
  }

  @override
  void initState() {
    super.initState();
    gettingUserData();
  }

  gettingUserData()async{
    await HelperFunction.getUserEmailFromSF().then((value) {
       setState(() {
         email=value!;
       });
    });

     await HelperFunction.getUserNameFromSF().then((value) {
       setState(() {
         userName=value!;
       });
    });

   await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid).getuserGroups().then((snapshot){
           setState(() {
             groups=snapshot;
           });
   });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        title:const Text("Groups",style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 27,
          color: Colors.white,
        ),),
        actions: [
          IconButton(onPressed: (){
              nextScreen(context,const SearchPage());
          }, icon:const Icon(Icons.search))
        ],
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
            Text(userName,
            textAlign: TextAlign.center,
            style:const  TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 30,),

            const Divider(
              height: 2,
            ),

            ListTile(
              onTap: () {
                
              },
              selectedColor: Theme.of(context).primaryColor,
              selected: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 20,vertical: 5),
              leading: const Icon(Icons.group),
              title: const Text("Groups",
              style: TextStyle(color: Colors.black),
              ),

            ),
             ListTile(
              onTap: ()async {
                nextScreenReplacement(context, Profile_Page(userName: userName,email: email,));
              },
           
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
     
      body: groupList(),
      floatingActionButton: FloatingActionButton(onPressed: (){
         popUpDialog(context);
      },
      elevation: 0,
      backgroundColor: Theme.of(context).primaryColor,
      child: const Icon(
        Icons.add,
        color: Colors.white,
        size: 30,
      ),
      ),
    );
  }

  popUpDialog(BuildContext context){
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
        return  AlertDialog(
          title: const Text("Create a group",textAlign: TextAlign.left,),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _isLoading ? Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColor,),):
              TextField(
                onChanged: (value) {
                  setState(() {
                    groupName=value;
                  });
                },
                style:const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(context).primaryColor,
                    
                    ),
                    borderRadius:BorderRadius.circular(20) 
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.red,
                    
                    ),
                    borderRadius:BorderRadius.circular(20) 
                  ),
                ),
                
               )
            ],
          ),
          actions: [
            ElevatedButton(onPressed: (){
                Navigator.pop(context);
            }, child: const Text("CANCEL"),
            style: ElevatedButton.styleFrom(
              primary: Theme.of(context).primaryColor
            )
            
            ),
      
             ElevatedButton(onPressed: (){
                 if (groupName!="") {
                   setState(() {
                     _isLoading=true;
                   });
                   DatabaseService(uid:FirebaseAuth.instance.currentUser!.uid).createGroup(userName, FirebaseAuth.instance.currentUser!.uid, groupName).whenComplete(() {
                    _isLoading=false;
                   });
                   Navigator.of(context).pop();
                   showSnackbar(context, Colors.green, "Group Created Successfully");
                 }
            }, child: const Text("CREATE"),
            style: ElevatedButton.styleFrom(
              primary: Theme.of(context).primaryColor
            )
            
            )
          ],
        );
        }
      );
    },);
  }

  groupList(){
    return StreamBuilder(
      stream: groups,
      builder: (context,AsyncSnapshot snapshot) {
       if (snapshot.hasData) {
         if (snapshot.data['groups']!=null) {
           if (snapshot.data['groups'].length !=0) {
              return ListView.builder(
                itemCount: snapshot.data['groups'].length,
                itemBuilder: (context, index) {
                  int revIndex = snapshot.data['groups'].length-index-1;
                  return GroupTile(
                    groupId: getId(snapshot.data['groups'][revIndex]), 
                    userName: snapshot.data['fullName'],
                     groupName: getName(snapshot.data['groups'][revIndex]));
                },);
           }else{
             return noGroupWidget();
           }
         }else{
          return noGroupWidget();
         }
       }else{
        return Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).primaryColor,
          ),
        );
       }
    },);
  }

  noGroupWidget(){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              popUpDialog(context);
            },
            child: Icon(
              Icons.add_circle,color: Colors.grey[700],size: 75,
            ),
          ),
          const SizedBox(height: 20,),
          const Text("You've not joined any groups, tap on the add icon to create a group or also search from top search",
          textAlign: TextAlign.center,)
        ],
      ),
    );
  }
}