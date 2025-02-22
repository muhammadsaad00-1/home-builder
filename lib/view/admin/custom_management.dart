import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../resources/components/appColors.dart';

class CustomManagementView extends StatefulWidget {
  const CustomManagementView({super.key});

  @override
  State<CustomManagementView> createState() => _CustomManagementViewState();
}

class _CustomManagementViewState extends State<CustomManagementView> {
  final int totalItems = 4 * 8;

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.sizeOf(context).height;
    final w = MediaQuery.sizeOf(context).width;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: h * 0.02),
              Text(
                'Cutomization Management',
                style: GoogleFonts.roboto(
                  color: appColors.orangee,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: h * 0.03),
              Align(
                alignment: Alignment.centerRight,
                child: InkWell(
                  onTap: ()async{


                  },
                  child: Container(
                    height: 50,
                    width: w*0.3,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: appColors.orangee,borderRadius: BorderRadius.circular(16)),
                    child: const Center(child: Text("Add new",style: TextStyle(color: Colors.white,fontWeight: FontWeight.w700,fontSize: 14),)),),
                ),
              ),
              SizedBox(height: h * 0.02),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4, // Number of columns
                    crossAxisSpacing: 8.0, // Space between columns
                    mainAxisSpacing: 8.0, // Space between rows
                  ),
                  itemCount: totalItems,
                  itemBuilder: (context, index) {
                    return Center(
                      child: Text(
                        'List',
                        style: GoogleFonts.roboto(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    );
                  },
                  padding: const EdgeInsets.all(8.0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
