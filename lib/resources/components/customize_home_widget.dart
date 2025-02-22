

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeWidget extends StatefulWidget {
  HomeWidget({super.key, required this.image,required this.title});
String image;
String title;
  @override

  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {


  @override
  Widget build(BuildContext context) {
    final h= MediaQuery.sizeOf(context).height;
    final w= MediaQuery.sizeOf(context).width;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
              borderRadius:BorderRadius.circular(15),
              child: Image.asset(widget.image,fit: BoxFit.cover,height: 200,width: 500,)),
          Positioned(
            top:0,
            bottom:0,
            left:0,
            right:0,
            child: Column(
              mainAxisAlignment:MainAxisAlignment.center,
              children: [
                Text(widget.title,textAlign: TextAlign.center,style: GoogleFonts.roboto(color: Colors.white,fontSize: 25,fontWeight: FontWeight.w500),),
              ],
            ),
          ),
        ],
      ),
    );


  }
}

