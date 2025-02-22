

import 'package:bhc/view/bhc1/facade_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../resources/components/appColors.dart';
import 'customize_home.dart';

class ChooseFacadeView extends StatefulWidget {
  const ChooseFacadeView({super.key});

  @override
  State<ChooseFacadeView> createState() => _ChooseFacadeViewState();
}

class _ChooseFacadeViewState extends State<ChooseFacadeView> {
  @override
  Widget build(BuildContext context) {
    final h= MediaQuery.sizeOf(context).height;
    final w= MediaQuery.sizeOf(context).width;
    return Scaffold(
      body:SafeArea(
        child: Container(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: h*0.03,),
                Text('Choose Your Facade',style: GoogleFonts.roboto(color: appColors.orangee,fontSize: 20,fontWeight: FontWeight.w500),),
                SizedBox(height: h*0.02,),
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: 10,
                      itemBuilder: (context,index){
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            children: [
                              SizedBox(height: h*0.03,),

                              InkWell(
                                onTap: (){
                                  showBottomSheet(context: context, builder: (context)=>const FacadeImageView(),backgroundColor: Colors.black.withOpacity(0.5));
                                },
                                child: Container(
                                  height:h*0.15,
                                  width: w*0.3,
                                  decoration: const BoxDecoration(

                                  ),

                                  child: ClipRRect(
                                      borderRadius: BorderRadius.circular(14),

                                      child: Image.asset('assets/images/facade.png',fit: BoxFit.cover,)),
                                ),
                              ),
                              SizedBox(width:w*0.03 ,),
                              Flexible(
                                child: Column(
                                  crossAxisAlignment:CrossAxisAlignment.start,
                                  children: [
                                    Text('Facade name',style: GoogleFonts.roboto(color: appColors.greyy,fontSize: 13),),
                                    SizedBox(height: h*0.01,),

                                    Text('Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry standard.',textAlign: TextAlign.start,style: GoogleFonts.roboto(color: appColors.greyy,fontSize: 10,height: 1.8)),

                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                  ),
                ),
                SizedBox(height: h*0.01,),

                Align(
                  alignment: Alignment.center,
                  child: InkWell(
                    onTap: ()async{
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>const CustomizeHomeView()));


                    },
                    child: Container(
                      height: 60,
                      width: w*0.9,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: appColors.orangee,borderRadius: BorderRadius.circular(15)),
                      child: const Center(child: Text("Next ",style: TextStyle(color: Colors.white,fontWeight: FontWeight.w700,fontSize: 14),)),),
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
