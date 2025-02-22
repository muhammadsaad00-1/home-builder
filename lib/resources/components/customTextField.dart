
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class customTextFields{
  static Widget defaultTextField({required String hintText,required TextEditingController controller,required bool obs,required String? Function(String?)? validator}){
    return TextFormField(
      validator: validator,
      obscureText: obs,
      controller: controller,
      cursorColor: const Color(0xfff1f305c),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.poppins(color: Colors.black54,fontSize: 15),
       // prefixIcon: prefixicon,
        enabledBorder: const UnderlineInputBorder(borderSide: BorderSide.none),
        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide.none),
        errorBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red)
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}