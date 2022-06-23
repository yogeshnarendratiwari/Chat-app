import 'package:flutter/material.dart';

class UIHelper {
  static void showLoadingDialog(String title, BuildContext context) {
    AlertDialog loadingDialog = AlertDialog(
      backgroundColor: Colors.white,
      content: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 30),
            Text(title,style: TextStyle(color:Colors.green),),
          ],
        ),
      ),
    );
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => loadingDialog);
  }

  static void showAlertDialog(
      BuildContext context, String title, String content) {
    AlertDialog alertDialog = AlertDialog(
      elevation: 10,
      backgroundColor: Colors.white,
      title: Text(title,style: TextStyle(color:Colors.red,fontWeight: FontWeight.bold),),
      content: Text(content,style: TextStyle(color:Colors.black)),
      actions: [
        TextButton(
            onPressed: () {
              // close loading dialog
              Navigator.pop(context);
            },
            child: Text("Ok",style: TextStyle(color:Colors.green,fontWeight: FontWeight.bold,fontSize: 15),)),
      ],
    );
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => alertDialog);
  }
  static void snackBar(BuildContext context,String content){
    final snackBar =  SnackBar(
      elevation: 1.0,
      duration: Duration(seconds: 1),
      backgroundColor: Colors.red,
      content: Text(content,style: TextStyle(color: Colors.white),),
    );
    ScaffoldMessenger.of(context).showSnackBar(
        snackBar);
  }
}
