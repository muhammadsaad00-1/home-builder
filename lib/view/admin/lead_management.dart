import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../resources/components/appColors.dart';

class LeadManagementView extends StatefulWidget {
  const LeadManagementView({super.key});

  @override
  State<LeadManagementView> createState() => _LeadManagementViewState();
}

class _LeadManagementViewState extends State<LeadManagementView> {
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
                'Lead Management',
                style: GoogleFonts.roboto(
                  color: appColors.orangee,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
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
