import 'package:chat_app/pages/home_page.dart';
import 'package:chat_app/services/database_service.dart';
import 'package:chat_app/widgets/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../helper/helper_function.dart';

class GroupInfo extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String adminname;
   GroupInfo({super.key,required this.groupId,required this.groupName,required this.adminname});

  @override
  State<GroupInfo> createState() => _GroupInfoState();
}

class _GroupInfoState extends State<GroupInfo> {

  Stream? members;
   String userName = '';

  @override
  void initState() {
    super.initState();
    getMembers();
    getUserName();
  }


getUserName()async{
   await HelperFunction.getUserNameFromSF().then((value) {
       setState(() {
         userName=value!;
       });
    });
}
  getMembers()async{
     DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid).getGroupMembers(widget.groupId).then((value){
         setState(() {
           members=value;
         });
     });
  }

  getId(String res){
   return res.substring(0,res.indexOf("_"));
  }

  String getName(String res){
    return res.substring(res.indexOf('_')+1);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
        title: const Text("Group Info"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(onPressed: (){
               showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (context) {
                   return AlertDialog(
                    title:const Text("Exit"),
                    content:const Text("Are you sure u want to exit the group?"),
                    actions: [
                      IconButton(onPressed: (){
                        Navigator.pop(context);
                      }, icon:const Icon(Icons.cancel,color: Colors.red,)),

                      IconButton(onPressed: ()async{
                         DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid).toggleGroupJoin(widget.groupId,userName, widget.groupName)
                         .whenComplete(() {
                          nextScreenReplacement(context, const HomePage());
                         })
                         ;
                      }, icon: const Icon(Icons.done,color: Colors.green,))
                    ],
                   );
                 },);
          }, icon: Icon(Icons.exit_to_app))
        ],
       ),
       body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 20),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Theme.of(context).primaryColor.withOpacity(0.2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Text(
                      widget.groupName.substring(0,1).toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.white
                      ),
                    ),
                  ),
                  const SizedBox(width: 20,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Gorup: ${widget.groupName}",
                      style:const TextStyle(fontWeight: FontWeight.w500) ,
                      ),

                      const SizedBox(height: 5,),

                      Text(
                        "Admin: ${getName(widget.adminname)}"
                      )
                    ],
                  )
                ],
              ),
            ),
            memberList(),
          ],
        ),
       ),
    );
  }

  memberList(){
    return StreamBuilder(
      stream: members,
      builder: (context,AsyncSnapshot snapshot) {
       if (snapshot.hasData) {
         if (snapshot.data['members']!=null) {
           if (snapshot.data['members'].length!=0) {
             return ListView.builder(
                itemCount: snapshot.data['members'].length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal:5,vertical: 10),
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 30,
                        backgroundColor: Theme.of(context).primaryColor,
                        child: Text(
                          getName(snapshot.data['members'][index])
                          .substring(0,1)
                          .toUpperCase(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                      title: Text(getName(snapshot.data['members'][index])),
                      subtitle: Text(getId(snapshot.data['members'][index])),
                    ),
                  );
                },
             );
           }else{
            return Center(child: Text("No Members"),);          
           }
         }else{
          return const  Center(
            child: Text("No Members"),
          );
         }
       }else{
        return Center(child: CircularProgressIndicator(
          color: Theme.of(context).primaryColor,
        ),);
       }
    },);
  }
}