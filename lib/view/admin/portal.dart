import 'package:bhc/resources/components/appColors.dart';
import 'package:bhc/view/admin/custom_management.dart';
import 'package:bhc/view/admin/lead_management.dart';
import 'package:bhc/view/admin/project-assig.dart';
import 'package:bhc/view_model/auth_view_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class PortalView extends StatefulWidget {
  const PortalView({super.key});

  @override
  State<PortalView> createState() => _PortalViewState();
}

class _PortalViewState extends State<PortalView> {
  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);

    final h= MediaQuery.sizeOf(context).height;
    final w= MediaQuery.sizeOf(context).width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Consumer<AuthViewModel>(
            builder: ( context,changeState,  child) {
              return Column(
                children: [
                  Center(child: Image.asset(
                    'assets/images/logo.png', height: 200,)),
                  SizedBox(height: h * 0.01,),
                  InkWell(
                    onTap: (){
                      authViewModel.changeActiveTab(1);
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>const LeadManagementView()));
                    },
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color:authViewModel.currentTab==1?appColors.orangee:Colors.white ,

                      ),

                      child: Row(
                        children: [
                          SizedBox(width: w*0.02,),
                          Icon(Icons.person, size: 25, color: authViewModel.currentTab==1?Colors.white:Colors.black ,),
                          SizedBox(width: w * 0.03,),
                          Text('Lead Management', style: GoogleFonts.poppins(
                              color: authViewModel.currentTab==1?Colors.white:Colors.black , fontSize: 15),)
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: h * 0.03,),
                  InkWell(
                    onTap: (){
                      authViewModel.changeActiveTab(2);
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>const CustomManagementView()));
                    },
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color:authViewModel.currentTab==2?appColors.orangee:Colors.white ,

                      ),

                      child: Row(
                        children: [
                          SizedBox(width: w*0.02,),
                          Icon(Icons.person, size: 25, color: authViewModel.currentTab==2?Colors.white:Colors.black ,),
                          SizedBox(width: w * 0.03,),
                          Text('Customization Management',
                            style: GoogleFonts.poppins(
                                color: authViewModel.currentTab==2?Colors.white:Colors.black , fontSize: 15),)
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: h * 0.03,),
                  InkWell(
                    onTap: (){
                      authViewModel.changeActiveTab(3);
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>const ProjectAssView()));
                    },
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color:authViewModel.currentTab==3?appColors.orangee:Colors.white ,

                      ),

                      child: Row(
                        children: [
                          SizedBox(width: w*0.02,),
                          Icon(Icons.person, size: 25, color:authViewModel.currentTab==3?Colors.white:Colors.black ,),
                          SizedBox(width: w * 0.03,),
                          Text('Project Assignment', style: GoogleFonts.poppins(
                              color: authViewModel.currentTab==3?Colors.white:Colors.black , fontSize: 15),)
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: h * 0.03,),
                  InkWell(
                    onTap: (){
                      authViewModel.changeActiveTab(4);
                    },
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color:authViewModel.currentTab==4?appColors.orangee:Colors.white ,

                      ),
                      child: Row(
                        children: [
                          SizedBox(width: w*0.02,),
                          Icon(Icons.person, size: 25, color: authViewModel.currentTab==4?Colors.white:Colors.black ,),
                          SizedBox(width: w * 0.03,),
                          Text('Reports & Progress', style: GoogleFonts.poppins(
                              color: authViewModel.currentTab==4?Colors.white:Colors.black , fontSize: 15),)
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: h * 0.03,),
                  InkWell(
                    onTap: (){
                      authViewModel.changeActiveTab(5);
                    },
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color:authViewModel.currentTab==5?appColors.orangee:Colors.white ,

                      ),
                      child: Row(
                        children: [
                          SizedBox(width: w*0.02,),
                          Icon(Icons.person, size: 25, color:authViewModel.currentTab==5?Colors.white:Colors.black ,),
                          SizedBox(width: w * 0.03,),
                          Text('Logout', style: GoogleFonts.poppins(
                              color: authViewModel.currentTab==5?Colors.white:Colors.black , fontSize: 15),)
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }
          ),
        ),
      ),
    );
  }
}
