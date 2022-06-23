import 'package:chit_chat_app/Model/ChatRoomModel.dart';
import 'package:chit_chat_app/Model/FirebaseHelper.dart';
import 'package:chit_chat_app/Screen/ChatRoomScreen.dart';
import 'package:chit_chat_app/Screen/LoginScreen.dart';
import 'package:chit_chat_app/Screen/SearchScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../Model/UIHelper.dart';
import '../Model/UserModel.dart';

class HomeScreen extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;
  const HomeScreen(
      {Key? key, required this.userModel, required this.firebaseUser})
      : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
            icon : Icon(Icons.person),
          onPressed: () {
              UIHelper.showAlertDialog(context,"About us", "Page not created yet! :(");
          },
        ),
       backgroundColor: Colors.green,
        actions: [
          IconButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.popUntil(context, (route) => route.isFirst);
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>LoginScreen()));
              },
              icon: Icon(FontAwesomeIcons.signOut))
        ],
        title: Text("Chat app"),
        centerTitle: true,
      ),
      body: Container(
          child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('ChatRoom')
                  .where("participants.${widget.userModel.uid}",
                      isEqualTo: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.active) {
                  if (snapshot.hasData) {
                    QuerySnapshot chatRoomSnapshot =
                        snapshot.data as QuerySnapshot;
                    return ListView.builder(
                      physics: BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics()),
                      itemCount: chatRoomSnapshot.docs.length,
                      itemBuilder: (context, index) {
                        ChatRoomModel chatRoomModel = ChatRoomModel.fromMap(
                            chatRoomSnapshot.docs[index].data()
                                as Map<String, dynamic>);

                        Map<String, dynamic> participants =
                            chatRoomModel.participants!;
                        List<String> participantsKeys =
                            participants.keys.toList();
                        participantsKeys.remove(widget.userModel.uid);
                        return FutureBuilder(
                          future: FirebaseHelper.getUserModelById(
                              participantsKeys[0]),
                          builder: (context, userData) {
                            if (userData.connectionState ==
                                ConnectionState.done) {
                              if (userData.data != null) {
                                UserModel targetUser =
                                    userData.data as UserModel;
                                return ListTile(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ChatRoomScreen(
                                                    targetUser: targetUser,
                                                    chatRoom: chatRoomModel,
                                                    userModel: widget.userModel,
                                                    firebaseUser:
                                                        widget.firebaseUser)));
                                  },
                                  title: Text(targetUser.fullName.toString(),style : TextStyle(color: Colors.black),),
                                  subtitle: chatRoomModel.lastMessage.toString() !="" ? Text(
                                      chatRoomModel.lastMessage.toString(),style : TextStyle(color: Colors.green) ): Text("Say Hii!",style: TextStyle(color: Colors.blue),),
                                  leading: CircleAvatar(
                                    backgroundImage: NetworkImage(
                                        targetUser.profilePic.toString()),
                                  ),
                                );
                              } else {
                                return Container();
                              }
                            } else {
                              return Container();
                            }
                          },
                        );
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(snapshot.error.toString()),
                    );
                  } else {
                    return Center(
                      child: Text("No Chats",style: TextStyle(color: Colors.black),),
                    );
                  }
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              })),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SearchScreen(
                      userModel: widget.userModel,
                      firebaseUser: widget.firebaseUser)));
        },
        child: const Icon(FontAwesomeIcons.rocketchat,color: Colors.white,),
      ),
    );
  }
}
