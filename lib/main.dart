import 'package:chit_chat_app/Model/UserModel.dart';
import 'package:chit_chat_app/Screen/LoginScreen.dart';
import 'package:chit_chat_app/Screen/SignUpScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'Model/FirebaseHelper.dart';
import 'Screen/CompleteProfileScreen.dart';
import 'Screen/HomeScreen.dart';
import 'package:uuid/uuid.dart';

var uid = Uuid();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  User? currentUser = FirebaseAuth.instance.currentUser;
  if(currentUser!=null)
    {
      UserModel? user = await FirebaseHelper.getUserModelById(currentUser.uid);
      if(user!=null) {
        // logged in
        runApp(ChitChatLoggedIn(user: user, firebaseUser: currentUser));
      }
      else{
        // not logged in
        runApp(const ChitChat());
      }
    }
  else{
    // not logged in
    runApp(const ChitChat());
  }


}

// Not logged In
class ChitChat extends StatelessWidget {
  const ChitChat({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        textTheme: TextTheme(
          bodyText1: TextStyle(color: Colors.black54),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}

// Logged In
class ChitChatLoggedIn extends StatelessWidget {
  final UserModel user;
  final User firebaseUser;

  const ChitChatLoggedIn({Key? key, required this.user, required this.firebaseUser}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        textTheme: TextTheme(
          bodyText1: TextStyle(color: Colors.black54),
          bodyText2: TextStyle(color: Colors.black54),
          headline1: TextStyle(color: Colors.black54),
          headline2: TextStyle(color: Colors.black54),
          headline3: TextStyle(color: Colors.black54),
          headline4: TextStyle(color: Colors.black54),
          headline5: TextStyle(color: Colors.black54),
          headline6: TextStyle(color: Colors.black54),
          subtitle1: TextStyle(color: Colors.black54),
          subtitle2: TextStyle(color: Colors.black54),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: HomeScreen(userModel: user, firebaseUser: firebaseUser),
    );
  }
}
