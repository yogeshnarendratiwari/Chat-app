import 'package:chit_chat_app/Model/UserModel.dart';
import 'package:chit_chat_app/Screen/CompleteProfileScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Model/UIHelper.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool passflag = true;
  bool conpassflag = true;
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();

  void checkValues() {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String confirm_password = _confirmPasswordController.text.trim();

    if (email == "" || password == "" || confirm_password == "") {
      UIHelper.showAlertDialog(context, "Incomplete data","Please fill all the required fields");
    } else if (password != confirm_password) {
      UIHelper.showAlertDialog(context, "Password mismatch","The passwords you enter do not match");
    } else {
      print("Sign up successful");
      signUp(email+"@ChitChat.com", password);
    }
  }

  void signUp(String email, String password) async {
    UIHelper.showLoadingDialog("Creating new account...", context);
    UserCredential? credential;
    try {
      credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (ex) {
      Navigator.pop(context);
      UIHelper.showAlertDialog(context, "An error occurred",ex.code.toString() );
    }
    if (credential != null) {
      String uid = credential.user!.uid;
      UserModel user = UserModel(
        uid: uid,
        email: email,
        fullName: "",
        profilePic: "",
      );
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set(user.toMap())
          .then((value){
            Navigator.popUntil(context, (route) => route.isFirst);
            Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context)=> CompleteProfileScreen(userModel: user, firebaseUser: credential!.user!))
      );});
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Container(
            margin: EdgeInsets.symmetric(
              horizontal: 30,
            ),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Hero(
                      tag: 'logo',
                      child: Container(
                        height: 150.0,
                        child: Image.asset('images/logo.gif'),
                      ),
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    TextField(
                      keyboardType: TextInputType.name,
                      controller: _emailController,
                      decoration: const InputDecoration(
                        hintText: 'Enter your username',
                        hintStyle: TextStyle(
                          color: Colors.grey,
                        ),
                        contentPadding:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(32.0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blueAccent, width: 1.0),
                          borderRadius: BorderRadius.all(Radius.circular(32.0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color:Colors.red, width: 2.0),
                          borderRadius: BorderRadius.all(Radius.circular(32.0)),
                        ),
                      ),
                    ),
                    SizedBox(height: 10,),
                    TextField(
                      keyboardType: TextInputType.visiblePassword,
                      controller: _passwordController,
                      obscureText: passflag,

                      decoration: InputDecoration(
                        suffixIcon: IconButton(onPressed: (){
                          setState(() {
                            passflag = !passflag;
                          });
                        }, icon: Icon(Icons.adjust_sharp)),
                      hintText: 'Enter your password',
                      hintStyle: TextStyle(
                        color: Colors.grey,
                      ),
                      contentPadding:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(32.0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blueAccent, width: 1.0),
                        borderRadius: BorderRadius.all(Radius.circular(32.0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color:Colors.red, width: 2.0),
                        borderRadius: BorderRadius.all(Radius.circular(32.0)),
                      ),
                    ),
                    ),
                    SizedBox(height: 10,),
                    TextField(
                      keyboardType: TextInputType.visiblePassword,
                      controller: _confirmPasswordController,
                      obscureText: conpassflag,
                      decoration:  InputDecoration(
                        suffixIcon: IconButton(onPressed: (){
                          setState(() {
                            conpassflag = !conpassflag;
                          });
                        }, icon: Icon(Icons.adjust_sharp)),
                        hintText: 'Enter your confirm password',
                        hintStyle: TextStyle(
                          color: Colors.grey,
                        ),
                        contentPadding:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(32.0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blueAccent, width: 1.0),
                          borderRadius: BorderRadius.all(Radius.circular(32.0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color:Colors.red, width: 2.0),
                          borderRadius: BorderRadius.all(Radius.circular(32.0)),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Material(
                        color: Colors.blueAccent,
                        borderRadius: BorderRadius.all(Radius.circular(30.0)),
                        elevation: 5.0,
                        child: MaterialButton(
                          onPressed: () {
                            checkValues();
                          },
                          minWidth: 200.0,
                          height: 42.0,
                          child: Text(
                            'Register',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        bottomNavigationBar: Container(
          margin: const EdgeInsets.only(bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Already have an account ?  ",style: TextStyle(color: Colors.black)),
              CupertinoButton(
                padding: EdgeInsets.all(0),
                  child: Text("Log in",style: TextStyle(color: Colors.green,fontWeight: FontWeight.bold)),
                  onPressed: () {
                    Navigator.pop(context);
                  })
            ],
          ),
        ),
      ),
    );
  }
}
