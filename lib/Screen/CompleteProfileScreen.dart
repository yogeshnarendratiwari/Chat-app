import 'dart:io';
import 'package:chit_chat_app/Screen/HomeScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import '../Model/UIHelper.dart';
import '../Model/UserModel.dart';

class CompleteProfileScreen extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const CompleteProfileScreen({Key? key,required this.userModel, required this.firebaseUser}) : super(key: key);


  @override
  _CompleteProfileScreenState createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {

  TextEditingController _fullnameController = TextEditingController();

   File? _imagefile;
  void selectImage(ImageSource imageSource) async{
    XFile? pickedFile = await ImagePicker().pickImage(source:imageSource);
    if(pickedFile!=null){
      cropImage(pickedFile);
    }
  }



  void cropImage(XFile pickedFile) async{
     File? croppedImage = await ImageCropper().cropImage(
         sourcePath: pickedFile.path,
         aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
         compressQuality: 20,
     );
     if(croppedImage!=null){
       setState(() {
         _imagefile = croppedImage;
       });
     }

  }

  void showPhotoOptions(){
    showDialog(context: context, builder: (context){
      return AlertDialog(
        title: Text("Upload profile picture"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(FontAwesomeIcons.image),
              title: Text("Select from gallery"),
              onTap: (){
                Navigator.pop(context);
               selectImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: Icon(FontAwesomeIcons.camera),
              title: Text("Take a photo"),
              onTap: (){
                Navigator.pop(context);
                selectImage(ImageSource.camera);
              },
            )
          ],
        ),
      );
    }
    );
  }

  void checkValues(){
    String fullName = _fullnameController.text.trim();
    if(fullName == "" || _imagefile == null){
      UIHelper.showAlertDialog(context, "Incomplete data","Please fill all the required fields and upload a profile picture");
    }
    else{
      uploadData();
    }

  }

  void uploadData() async{
    UIHelper.showLoadingDialog("Uploading image...", context);
    UploadTask uploadTask = FirebaseStorage.instance.ref("profile").child(widget.userModel.uid.toString()).putFile(_imagefile!);
    TaskSnapshot snapshot = await uploadTask;
    String? imageUrl = await snapshot.ref.getDownloadURL();
    String? fullname = _fullnameController.text.trim();
    widget.userModel.fullName = fullname;
    widget.userModel.profilePic = imageUrl;
    await FirebaseFirestore.instance.collection('users').doc(widget.userModel.uid).set(widget.userModel.toMap()).then((value) => print('Data uploaded'));
    Navigator.popUntil(context, (route) => route.isFirst);
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context){
      return HomeScreen(userModel:widget.userModel, firebaseUser: widget.firebaseUser);
    }));

  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text("Complete Profile"),
          centerTitle: true,
          backgroundColor: Colors.green,
        ),
        body: SafeArea(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 40,vertical: 50),
            child: ListView(
              children: [
                SizedBox(
                  height: 40,
                ),
                CupertinoButton(
                  onPressed: (){
                    showPhotoOptions();
                  },
                  child: CircleAvatar(
                    backgroundColor: Colors.green,
                    radius: 60,
                    backgroundImage:(_imagefile!=null)?FileImage(_imagefile!) : null,
                    child: (_imagefile==null) ? Icon(Icons.person,size:60,color: Colors.white,) : null,
                  ),
                ),
                SizedBox(
                  height: 40,
                ),
                TextField(
                  keyboardType: TextInputType.name,
                  controller: _fullnameController,
                  decoration: const InputDecoration(
                    hintText: 'Enter your name',
                    hintStyle:TextStyle(
                      color: Colors.grey,
                    ),
                    contentPadding:
                    EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(32.0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                      BorderSide(color: Colors.green, width: 1.5),
                      borderRadius: BorderRadius.all(Radius.circular(32.0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                      BorderSide(color: Colors.red, width: 1.5),
                      borderRadius: BorderRadius.all(Radius.circular(32.0)),
                    ),
                  ),
                ),

                SizedBox(
                  height: 10,
                ),

                Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0,horizontal: 50),
                  child: Material(
                    color: Colors.green,
                    borderRadius: BorderRadius.all(Radius.circular(30.0)),
                    elevation: 5.0,
                    child: MaterialButton(
                      onPressed: () {
                        checkValues();
                      },
                      minWidth: 100.0,
                      height: 42.0,
                      child: Text(
                        'Submit',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
