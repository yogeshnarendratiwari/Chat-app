import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel{
  String? sender;
  String? text;
  bool? seen;
  Timestamp? createdOn;
  String? messageId;

  MessageModel({this.sender,this.text,this.createdOn,this.seen,this.messageId});

  MessageModel.fromMap(Map<String,dynamic>map){
    sender = map["sender"];
    text = map["text"];
    seen = map["seen"];
    createdOn = map["createdOn"];
    messageId = map["messageId"];
  }
  Map<String,dynamic> toMap(){
    return {
      "sender" : sender,
      "text" : text,
      "seen" : seen,
      "createdOn"  : createdOn,
      "messageId" : messageId,
    };
  }
}