import 'dart:developer';

import 'package:chit_chat_app/Model/ChatRoomModel.dart';
import 'package:chit_chat_app/Model/MessageModel.dart';
import 'package:chit_chat_app/Screen/HomeScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../Model/UserModel.dart';
import '../main.dart';

class ChatRoomScreen extends StatefulWidget {
  final UserModel targetUser;
  final ChatRoomModel chatRoom;
  final UserModel userModel;
  final User firebaseUser;
  const ChatRoomScreen(
      {Key? key,
      required this.targetUser,
      required this.chatRoom,
      required this.userModel,
      required this.firebaseUser})
      : super(key: key);

  @override
  _ChatRoomScreenState createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  TextEditingController messageController = TextEditingController();

  void sendMessage() async{
    String msg = messageController.text.trim();
    if(msg!=""){
      // send message
      MessageModel newMessage = MessageModel(
        messageId: uid.v1(),
        sender: widget.userModel.uid,
        createdOn:Timestamp.now(),
        text: msg,
        seen:  false,
      );
      FirebaseFirestore.instance.collection('ChatRoom').doc(widget.chatRoom.chatRoomId).collection('messages').doc(
        newMessage.messageId
      ).set(newMessage.toMap());
      log("message sent");
      widget.chatRoom.lastMessage = msg;
      FirebaseFirestore.instance.collection('ChatRoom').doc(widget.chatRoom.chatRoomId).set(widget.chatRoom.toMap());

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        actions: [
          IconButton(onPressed: (){
            Navigator.popUntil(context, (route) => route.isFirst);
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context){
              return HomeScreen(userModel: widget.userModel, firebaseUser: widget.firebaseUser);
            }));
          }, icon: Icon(Icons.arrow_back_ios_outlined))
        ],
        backgroundColor: Colors.green,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            CircleAvatar(
            backgroundColor: Colors.grey,
              backgroundImage: NetworkImage(widget.targetUser.profilePic.toString()),
            ),
            SizedBox(width: 15,),
            Text(widget.targetUser.fullName.toString()),

          ],
        ),
      ),
      body: SafeArea(
          child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        child: Column(
          children: [
            Expanded(child: Container(
              padding: EdgeInsets.symmetric(
            horizontal: 10,
        ),
              child: StreamBuilder(
                stream: FirebaseFirestore.instance.collection('ChatRoom').doc(widget.chatRoom.chatRoomId).collection('messages').orderBy("createdOn",descending: true).snapshots(),
                builder: (context,snapshot){
                  if(snapshot.connectionState == ConnectionState.active){
                     if(snapshot.hasData){
                         QuerySnapshot dataSnapshot = snapshot.data as QuerySnapshot;
                         return ListView.builder(
                           physics: const BouncingScrollPhysics(
                              parent:  AlwaysScrollableScrollPhysics()
                           ),
                           reverse:  true,
                           itemCount: dataSnapshot.docs.length,
                           itemBuilder: (context,index){
                             MessageModel currentMsg = MessageModel.fromMap(dataSnapshot.docs[index].data() as Map<String,dynamic>);
                             return Row(
                               mainAxisAlignment: currentMsg.sender == widget.userModel.uid ? MainAxisAlignment.end : MainAxisAlignment.start,
                               children: [
                                 MsgBox(text: currentMsg.text.toString(), isMe: currentMsg.sender == widget.userModel.uid),
                               ],
                             );
                           },
                           
                         );
                         
                     }
                     else if(snapshot.hasError){
                       return Center(
                         child: Text("Error occured"),
                       );
                     }
                     else {
                       return Center(
                         child: Text("Say Hii !"),
                       );
                     }


                  }
                  else{
                    return const Center(
                      child : CircularProgressIndicator()
                    );
                  }

                }
                ,

              ),

            )),
            Container(
              child: Row(
                children: [
                  Flexible(
                      child: TextField(
                        style: TextStyle(color: Colors.black),
                        cursorColor: Colors.black,
                        maxLines: null,
                        controller: messageController,
                    decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "Type your message",
                      hintStyle:  TextStyle(color: Colors.grey),
                    ),
                  )),
                  IconButton(onPressed: () {
                     sendMessage();
                     messageController.clear();
                  }
                  , icon: Icon(Icons.send,color: Colors.green,)),
                ],
              ),
            )
          ],
        ),
      )),
    );
  }
}

class MsgBox extends StatelessWidget {
  MsgBox({Key? key,required this.text,required this.isMe}) : super(key: key);
  final String text;
  bool isMe;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(

        crossAxisAlignment: isMe?CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [

          Padding(
            padding:  EdgeInsets.symmetric(vertical: 5),
            child: Material(
              borderRadius:  BorderRadius.only(
                  topLeft: isMe ? Radius.circular(30.0) : Radius.circular(0) ,
                  bottomLeft: isMe ? Radius.circular(30.0) : Radius.circular(30),
                  topRight: isMe ? Radius.circular(0) : Radius.circular(30),
                  bottomRight: isMe ? Radius.circular(30.0) : Radius.circular(30)
              ),
              elevation: 5.0,
              color: isMe? Colors.green : Colors.blue,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0,horizontal: 20.0),
                child: Text(text,style: const TextStyle(fontSize: 15,color: Colors.white),),
              ),
            ),
          ),
        ],
      ),
    );
  }
}