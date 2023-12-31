import 'package:chat_app/pages/group_info.dart';
import 'package:chat_app/services/database_service.dart';
import 'package:chat_app/widgets/message_tile.dart';
import 'package:chat_app/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String userName;
  
  ChatPage({super.key,
  required this.groupId,
  required this.groupName,
  required this.userName});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {

  String admin = "";
  Stream<QuerySnapshot>? chats;
  TextEditingController messageController = TextEditingController();

  @override
  void initState() {
    getChatAndAdmin();
    super.initState();
  }
  getChatAndAdmin(){
    DatabaseService().getChats(widget.groupId).then((val){
        setState(() {
          chats = val;
        });
    });

    DatabaseService().getGroupAdmin(widget.groupId).then((value) {
        setState(() {
          admin=value;
        });
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.groupName),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(onPressed: (){
            nextScreen(context, GroupInfo(
              groupId: widget.groupId,
              groupName: widget.groupName,
              adminname: admin,
            ));
          }, icon: Icon(Icons.info))
        ],
      ),
      body: Stack(
        children: <Widget>[

          Positioned.fill(
               bottom: 70,
              child: Align(
              child:  chatMessages(),
              alignment: AlignmentDirectional.topStart,
          )),
           
        

           Positioned(
            bottom: 0,
            left: 0,
             child: Container(
              alignment: Alignment.bottomCenter,
              width: MediaQuery.of(context).size.width,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                width:MediaQuery.of(context).size.width,
                color: Colors.grey[700],
                child: Row(children: [
                  Expanded(child: TextFormField(
                    controller: messageController,
                    style: TextStyle(
                      color: Colors.white,
                    ),
                    decoration: InputDecoration(
                      hintText: "Send a Message...",
                      hintStyle: TextStyle(color: Colors.white,fontSize: 16),
                      border: InputBorder.none
                    ),
                  )),
                  const SizedBox(width: 12,),
           
                  GestureDetector(
                    onTap: () {
                      sendMessage();
                    },
                    child: Container(
                      height: 50,
                      width: 50,
                      decoration:BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(30)
                      ),
                      child: const Center(child: Icon(Icons.send,
                      color: Colors.white,),),
                    ),
                  )
                   
                ],),
              ),
                     ),
           )
        ],
      ),
    );
  }

  chatMessages(){
    return StreamBuilder(
      stream: chats,
      builder: (context,AsyncSnapshot snapshot) {
        return snapshot.hasData?ListView.builder(
          itemCount: snapshot.data.docs.length,
          itemBuilder: (context, index) {
            return MessageTile(
              message: snapshot.data.docs[index]['message'],
              sender: snapshot.data.docs[index]['sender'],
              sendByMe: widget.userName == snapshot.data.docs[index]['sender']
               );
        },):Container();
      },);
  }
  sendMessage(){
     if(messageController.text.isNotEmpty){
      Map<String,dynamic> chatMessageMap = {
        'message':messageController.text,
        "sender":widget.userName,
        "time":DateTime.now().millisecondsSinceEpoch
      };
      DatabaseService().sendMessage(widget.groupId, chatMessageMap);
      setState(() {
        messageController.clear();
      });
     }
  }
}