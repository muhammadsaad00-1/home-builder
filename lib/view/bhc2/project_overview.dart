import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../resources/components/appColors.dart';

class projectOverview extends StatefulWidget {
  const projectOverview({super.key});

  @override
  State<projectOverview> createState() => _projectOverviewState();
}

class _projectOverviewState extends State<projectOverview> {
  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.sizeOf(context).height;
    final w = MediaQuery.sizeOf(context).width;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: h * 0.03,
            ),
            Center(
                child: Text(
              'Project Overview',
              style: GoogleFonts.roboto(
                  color: appColors.orangee,
                  fontSize: 22,
                  fontWeight: FontWeight.w500),
            )),
            SizedBox(
              height: h * 0.03,
            ),
            Expanded(
              child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: 9,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Project name',
                            style: GoogleFonts.roboto(
                                color: appColors.greyy,
                                fontSize: 14,
                                fontWeight: FontWeight.w500),
                          ),
                          SizedBox(
                            height: h * 0.03,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Status',
                                style: GoogleFonts.roboto(
                                    color: appColors.greyy,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400),
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.data_saver_off_rounded),
                                  SizedBox(
                                    width: w * 0.02,
                                  ),
                                  Text(
                                    'In progress',
                                    style: GoogleFonts.roboto(
                                        color: appColors.greyy,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(
                            height: h * 0.02,
                          ),
                        ],
                      ),
                    );
                  }),
            ),
            Align(
              alignment: Alignment.center,
              child: InkWell(
                onTap: () async {
                  showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                            actions: [
                              Container(
                                height: h * 0.5,
                                width: w * 0.9,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(40),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    DottedBorder(
                                      color: appColors.orangee,
                                      strokeWidth: 1,
                                      dashPattern: const [6, 3],
                                      borderType: BorderType.RRect,
                                      radius: const Radius.circular(12),
                                      child: SizedBox(
                                        height: h * 0.3,
                                        width: w * 0.7,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const SizedBox(
                                              height: 30,
                                            ),
                                            const Center(
                                                child: Icon(
                                              Icons.image,
                                              color: appColors.orangee,
                                              size: 50,
                                            )),
                                            SizedBox(
                                              height: h * 0.01,
                                            ),
                                            Center(
                                              child: MaterialButton(
                                                minWidth: 100,
                                                height: 50,
                                                onPressed: () {},
                                                child: Text(
                                                  "upload images",
                                                  style: GoogleFonts.roboto(
                                                      color: appColors.orangee,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: h * 0.07,
                                    ),
                                    Align(
                                      alignment: Alignment.center,
                                      child: InkWell(
                                        onTap: () async {
                                          Navigator.pop(context);
                                        },
                                        child: Container(
                                          height: 60,
                                          width: w * 0.9,
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                              color: appColors.orangee,
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              border: Border.all(
                                                  color: Colors.white,
                                                  width: 1)),
                                          child: const Center(
                                              child: Text(
                                            "Continue ",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 14),
                                          )),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ));
                },
                child: Container(
                  height: 60,
                  width: w * 0.9,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: appColors.orangee,
                      borderRadius: BorderRadius.circular(15)),
                  child: const Center(
                      child: Text(
                    "Upload ",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14),
                  )),
                ),
              ),
            ),
            SizedBox(
              height: h * 0.01,
            ),
          ],
        ),
      ),
    );
  }
}
