import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../resources/components/appColors.dart';

class ProjectAssView extends StatefulWidget {
  const ProjectAssView({super.key});

  @override
  State<ProjectAssView> createState() => _ProjectAssViewState();
}
TextEditingController supController=TextEditingController();
class _ProjectAssViewState extends State<ProjectAssView> {
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
                'Project Assignment',
                style: GoogleFonts.roboto(
                  color: appColors.orangee,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: h * 0.03),
              Align(
                alignment: Alignment.centerRight,
                child: InkWell(
                  onTap: ()async{

                    showDialog(
                      context: context,
                      builder: (context) =>
                          AlertDialog(
                            title: const Text('Select supervisor'),
                            content:        Container(
                                                decoration: BoxDecoration(

                                                  borderRadius: BorderRadius.circular(10),
                                                  border: Border.all(color: Colors.grey.shade200)
                                                ),
                                                child: TextField(

                                                  controller: supController,
                                                  cursorColor: Colors.black,
                                                  decoration: InputDecoration(
                                                    border:const OutlineInputBorder() ,
                                                    contentPadding: const EdgeInsets.symmetric(horizontal:10,vertical: 10),
                                                    enabledBorder:  OutlineInputBorder(
                                                      borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
                                                    ),
                                                    //UnderlineInputBorder(borderSide:BorderSide.none),
                                                    focusedBorder: const OutlineInputBorder(
                                                    borderSide: BorderSide(color: Color(0xFF03045E), width: 1),
                                                    ),

                                                    // errorBorder: OutlineInputBorder(
                                                    //     borderSide: BorderSide(color: Color(0xfffcbd5e)),
                                                    // ),
                                                    hintText: "Supervisor",
                                                    hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400,fontSize: 12),
                                                  ),
                                                  style: GoogleFonts.poppins(fontSize: 12),
                                                ),
                                              ),
                            actions: [
                              OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: appColors.orangee, width: 2.0), // Outline color and width
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8), // Optional: Rounded corners
                                  ),
                                ),
                                onPressed: () => Navigator.pop(context),

                                child: Text('Cancel',style: GoogleFonts.poppins(color: appColors.orangee)),
                              ),
                              Container(
                                decoration:BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: MaterialButton(
                                  color:appColors.orangee,
                                  onPressed: () async {

                                  },
                                  child: Text('Confirm',style: GoogleFonts.poppins(color: Colors.white),),
                                ),
                              ),
                            ],
                          ),
                    );
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
