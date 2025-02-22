

import 'package:another_flushbar/flushbar.dart';
import 'package:another_flushbar/flushbar_route.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';


class Utils{

  static double AverageRating(List<int> rating){
    var averageRating=0;
    for(int i=0;i< rating.length;i++){
      averageRating=averageRating+rating[i];
    }
    return double.parse((averageRating/rating.length).toStringAsFixed(1));
  }
  static void fieldFocusChange(
      BuildContext context ,
      FocusNode current,
      FocusNode nextFocus
      ){
    current.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  static toastMessage(String message){
    Fluttertoast.showToast(msg: message);
  }
  static void flushBarErrorMessage(String message,BuildContext context){
    showFlushbar(context: context, flushbar:Flushbar(
      message:message,
    )..show(context)

    );
  }
  static snackBar(String message,BuildContext context){
    return ScaffoldMessenger.of(context).showSnackBar(

        const SnackBar(content: Text(''))
    );

  }
}