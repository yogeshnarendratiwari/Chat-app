import 'dart:developer';

import 'package:chit_chat_app/Model/ChatRoomModel.dart';
import 'package:chit_chat_app/Model/UserModel.dart';
import 'package:chit_chat_app/Screen/ChatRoomScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../main.dart';

class SearchScreen extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;
  const SearchScreen(
      {Key? key, required this.userModel, required this.firebaseUser})
      : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController _searchController = TextEditingController();

  // chat Room model
  Future<ChatRoomModel?> getChatRoomModel(UserModel targetUser) async {
    ChatRoomModel? chatRoom;
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("ChatRoom")
        .where("participants.${widget.userModel.uid}", isEqualTo: true)
        .where("participants.${targetUser.uid}", isEqualTo: true)
        .get();
    if (snapshot.docs.length > 0) {
      log("Chat room already created");
      var docData = snapshot.docs[0].data();
      ChatRoomModel existingChatRoom =
          ChatRoomModel.fromMap(docData as Map<String, dynamic>);
      chatRoom = existingChatRoom;
    } else {
      ChatRoomModel newChatRoom = ChatRoomModel(
          chatRoomId: uid.v1(),
          lastMessage: "",
          participants: {
            widget.userModel.uid.toString(): true,
            targetUser.uid.toString(): true
          });
      await FirebaseFirestore.instance
          .collection('ChatRoom')
          .doc(newChatRoom.chatRoomId)
          .set(newChatRoom.toMap());
      log("New chat room created");
      chatRoom = newChatRoom;
    }
    return chatRoom;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.green,
        automaticallyImplyLeading: false,
        title: Text("Search"),
        actions: [
          Expanded(
            child: TextField(
              cursorColor: Colors.white30,
              controller: _searchController,
              onChanged: (value) {},
              style: const TextStyle(
                color: Colors.white,
              ),
              decoration: const InputDecoration(
                  contentPadding: EdgeInsets.only(
                      left: 20.0, right: 20.0, top: 20.0, bottom: 5.0),
                  hintText: 'Search username.....',
                  hintStyle: TextStyle(
                    color: Colors.white30,
                  ),
                  border: InputBorder.none),
            ),
          ),
          IconButton(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              onPressed: () {
                setState(() {});
              },
              icon: const Icon(Icons.search))
        ],
      ),
      body: SafeArea(
          child: Container(
        padding: EdgeInsets.symmetric(
          vertical: 20,
          horizontal: 10,
        ),
        child: Column(
          children: [
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .where('email', isEqualTo: _searchController.text)
                  .where('email', isNotEqualTo: widget.userModel.email)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.active) {
                  if (snapshot.hasData) {
                    QuerySnapshot querySnapshot =
                        snapshot.data as QuerySnapshot;
                    if (querySnapshot.docs.length > 0) {
                      Map<String, dynamic> userMap =
                          querySnapshot.docs[0].data() as Map<String, dynamic>;
                      UserModel searchedUser = UserModel.fromMap(userMap);
                      return ListTile(
                        tileColor: Colors.white24,
                        onTap: () async {
                          ChatRoomModel? chatRoomModel =
                              await getChatRoomModel(searchedUser);
                          if (chatRoomModel != null) {
                            Navigator.pop(context);
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ChatRoomScreen(
                                          targetUser: searchedUser,
                                          firebaseUser: widget.firebaseUser,
                                          userModel: widget.userModel,
                                          chatRoom: chatRoomModel,
                                        )));
                          }
                        },
                        trailing: Icon(
                          Icons.keyboard_arrow_right,
                          color: Colors.black,
                        ),
                        title: Text(searchedUser.fullName!,
                            style: const TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                        subtitle: Text(searchedUser.email!,
                            style: const TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                                fontWeight: FontWeight.bold)),
                        leading: CircleAvatar(
                          backgroundImage:
                              NetworkImage(searchedUser.profilePic!),
                          backgroundColor: Colors.blueGrey,
                        ),
                      );
                    } else {
                      return const Center(
                          heightFactor: 20,
                          child: Text(
                            "No results found",
                            style: TextStyle(
                                color: Colors.grey,
                                fontSize: 25,
                                fontWeight: FontWeight.bold),
                          ));
                    }
                  } else if (snapshot.hasError) {
                    return const Center(
                        child: Text(
                      "An error occurred",
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: 25,
                          fontWeight: FontWeight.bold),
                    ));
                  } else {
                    return const Center(
                        heightFactor: 20, 
                        child: Text(
                          "No results found",
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 25,
                              fontWeight: FontWeight.bold),
                        ));
                  }
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            )
          ],
        ),
      )),
    );
  }
}
