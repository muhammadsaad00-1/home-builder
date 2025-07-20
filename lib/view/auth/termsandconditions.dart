import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.sizeOf(context).height;
    final w = MediaQuery.sizeOf(context).width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Terms & Conditions',
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontSize: w * 0.045,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: w * 0.05,
          vertical: h * 0.02,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Center(
              child: Image.asset(
                'assets/images/logo.png',
                height: w * 0.15,
              ),
            ),
            SizedBox(height: h * 0.03),



            // Acceptance of Terms
            _buildSectionTitle('Acceptance of Terms', w),
            SizedBox(height: h * 0.015),
            _buildSectionContent(
              'By accessing and using our construction and home building services, you accept and agree to be bound by the terms and provision of this agreement. If you do not agree to abide by the above, please do not use this service.',
              w,
            ),
            SizedBox(height: h * 0.025),

            // Services Description
            _buildSectionTitle('Services Description', w),
            SizedBox(height: h * 0.015),
            _buildSectionContent(
              'We provide comprehensive construction and home building services including but not limited to:\n\n• Residential construction and renovation\n• Commercial building projects\n• Project planning and design consultation\n• Material procurement and management\n• Quality inspection and project supervision\n• Post-construction maintenance services',
              w,
            ),
            SizedBox(height: h * 0.025),

            // Client Responsibilities
            _buildSectionTitle('Client Responsibilities', w),
            SizedBox(height: h * 0.015),
            _buildSectionContent(
              'As a client, you agree to:\n\n• Provide accurate project requirements and specifications\n• Make timely payments as per the agreed schedule\n• Obtain necessary permits and approvals\n• Provide site access during working hours\n• Communicate changes or concerns promptly\n• Comply with local building codes and regulations',
              w,
            ),
            SizedBox(height: h * 0.025),

            // Payment Terms
            _buildSectionTitle('Payment Terms', w),
            SizedBox(height: h * 0.015),
            _buildSectionContent(
              'Payment terms are as follows:\n\n• Initial deposit required upon contract signing\n• Progress payments based on project milestones\n• Final payment upon project completion and approval\n• Late payments may incur additional charges\n• All prices are subject to applicable taxes\n• Payment methods accepted: cash, check, bank transfer, and major credit cards',
              w,
            ),
            SizedBox(height: h * 0.025),

            // Project Timeline
            _buildSectionTitle('Project Timeline', w),
            SizedBox(height: h * 0.015),
            _buildSectionContent(
              'Project timelines are estimates based on normal conditions. Delays may occur due to:\n\n• Weather conditions\n• Material availability\n• Permit processing delays\n• Client-requested changes\n• Unforeseen site conditions\n• Force majeure events',
              w,
            ),
            SizedBox(height: h * 0.025),

            // Warranty and Liability
            _buildSectionTitle('Warranty and Liability', w),
            SizedBox(height: h * 0.015),
            _buildSectionContent(
              'We provide warranty coverage for:\n\n• Structural work: 10 years\n• General construction: 2 years\n• Electrical and plumbing: 1 year\n• Paint and finishes: 1 year\n\nOur liability is limited to the cost of repairs or replacement of defective work. We are not liable for consequential or indirect damages.',
              w,
            ),
            SizedBox(height: h * 0.025),

            // Termination
            _buildSectionTitle('Termination', w),
            SizedBox(height: h * 0.015),
            _buildSectionContent(
              'Either party may terminate this agreement with written notice. In case of termination:\n\n• Client is responsible for payment of completed work\n• Materials ordered become property of the client\n• Site must be returned in safe condition\n• Final settlement within 30 days of termination',
              w,
            ),
            SizedBox(height: h * 0.025),

            // Dispute Resolution
            _buildSectionTitle('Dispute Resolution', w),
            SizedBox(height: h * 0.015),
            _buildSectionContent(
              'Any disputes arising from this agreement will be resolved through:\n\n1. Direct negotiation between parties\n2. Mediation by a neutral third party\n3. Arbitration if mediation fails\n4. Local court jurisdiction as last resort',
              w,
            ),
            SizedBox(height: h * 0.025),

            // Changes to Terms
            _buildSectionTitle('Changes to Terms', w),
            SizedBox(height: h * 0.015),
            _buildSectionContent(
              'We reserve the right to modify these terms and conditions at any time. Changes will be effective immediately upon posting. Continued use of our services constitutes acceptance of the modified terms.',
              w,
            ),
            SizedBox(height: h * 0.025),

            // Contact Information
            _buildSectionTitle('Contact Information', w),
            SizedBox(height: h * 0.015),
            _buildSectionContent(
              'For questions about these Terms & Conditions, please contact us at:\n\nEmail: legal@yourcompany.com\nPhone: +1 (555) 123-4567\nAddress: 123 Construction Ave, Building City, BC 12345\nBusiness Hours: Monday - Friday, 8:00 AM - 6:00 PM',
              w,
            ),
            SizedBox(height: h * 0.05),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, double width) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: width * 0.045,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildSectionContent(String content, double width) {
    return Text(
      content,
      style: GoogleFonts.poppins(
        fontSize: width * 0.035,
        height: 1.6,
        color: Colors.black87,
      ),
      textAlign: TextAlign.justify,
    );
  }
}