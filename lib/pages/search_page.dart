import 'package:chat_app/helper/helper_function.dart';
import 'package:chat_app/pages/chat_page.dart';
import 'package:chat_app/services/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../widgets/widgets.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchController = TextEditingController();
  QuerySnapshot? searchSnapshot;
  bool hasUserSearched = false;
  bool isLoading = false;
  String userName = '';
  User? user;
  bool isJoined = false;

  getId(String res){
   return res.substring(0,res.indexOf("_"));
  }

  String getName(String res){
    return res.substring(res.indexOf('_')+1);
  }

  @override
  void initState() {
    super.initState();
    getCurrentUserIdAndName();
  }

  getCurrentUserIdAndName()async{
    await HelperFunction.getUserNameFromSF().then((value) {
       setState(() {
         userName=value!;
       });
    });
    user = FirebaseAuth.instance.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text("Search",
        style:TextStyle(
        fontSize: 27,
        fontWeight: FontWeight.bold,
        color: Colors.white
        ) ,
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            color: Theme.of(context).primaryColor,
            padding:const EdgeInsets.symmetric(horizontal: 15,vertical: 10),
            child: Row(
               children: [
                Expanded(
                  child:TextField(
                    controller: searchController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Search Groups...",
                      hintStyle: TextStyle(color: Colors.white)
                    ),
                  ) 
                  ),
                  GestureDetector(
                    onTap: () {
                      initiateSearch();
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      child:const Icon(Icons.search,color: Colors.white,),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40),
                        color: Colors.white.withOpacity(0.1)
                      ),
                    ),
                  )
               ],
            ),
          ),
          isLoading ? Center(child: CircularProgressIndicator(),):groupList(),
        ],
      ),
    );
  }
  initiateSearch()async{
   if(searchController.text.isNotEmpty){
    setState(() {
      isLoading=true;
    });
    await DatabaseService()
    .searchByName(searchController.text)
    .then((snapshot){
         setState(() {
           searchSnapshot = snapshot;
           isLoading=false;
           hasUserSearched=true;
         });
    });
   }
  }
  groupList(){
    return hasUserSearched?ListView.builder(
      shrinkWrap: true,
      itemCount: searchSnapshot!.docs.length,
      itemBuilder: (context, index) {
        return groupTile(
        userName,
        searchSnapshot!.docs[index]['groupId'],
        searchSnapshot!.docs[index]['groupName'],
         searchSnapshot!.docs[index]['admin'],
        );
      },
      )
      :Container();
  }
  joinedOrNot(String userName,String groupId,String groupName,String admin)async{
    await DatabaseService(uid: user!.uid).isUserJoined(groupName, groupId, userName)
    .then((value){
      setState(() {
        isJoined=value;
      });
    });
  }

  Widget groupTile(String userName,String groupId,String groupName,String admin){
      joinedOrNot(userName,groupId,groupName,admin);
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 10,vertical: 5),
          leading: CircleAvatar(
            radius: 30,
            backgroundColor: Theme.of(context).primaryColor,
            child: Text(
              groupName.substring(0,1).toUpperCase(),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          title: Text(groupName,style: const TextStyle(fontWeight: FontWeight.w500),),
          subtitle: Text("Admin: ${getName(admin)}"),
          trailing: InkWell(
            onTap: ()async {
              await DatabaseService(uid: user!.uid).toggleGroupJoin(groupId, userName, groupName);
              if(isJoined){
                setState(() {
                  isJoined=!isJoined;
                });
                showSnackbar(context,Colors.green,"Successfully Joined The Group");
                Future.delayed(Duration(seconds: 2),() {
                  nextScreen(context, ChatPage(groupId: groupId, groupName: groupName, userName: userName));
                },);
              }else{
                setState(() {
                  isJoined=!isJoined;
                });
                 showSnackbar(context,Colors.red,"Left The Group $groupName"); 
              }
            },
            child: isJoined?Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.black,
                border: Border.all(color: Colors.white,width: 1)
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
              child: const Text("Joined",
              style:TextStyle(
                color: Colors.white
              ) ,
              ),

            ):Container(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
               padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                child: const Text("Join Now",
              style:TextStyle(
                color: Colors.white
              ) ,
              ),
            ),
          ),
        );
  }
}