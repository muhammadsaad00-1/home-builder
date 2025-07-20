import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
          'Privacy Policy',
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



            // Introduction
            _buildSectionTitle('Introduction', w),
            SizedBox(height: h * 0.015),
            _buildSectionContent(
              'Welcome to our construction and home building services. We are committed to protecting your privacy and ensuring the security of your personal information. This Privacy Policy explains how we collect, use, and safeguard your information when you use our mobile application and services.',
              w,
            ),
            SizedBox(height: h * 0.025),

            // Information We Collect
            _buildSectionTitle('Information We Collect', w),
            SizedBox(height: h * 0.015),
            _buildSectionContent(
              'We collect information you provide directly to us, such as:\n\n• Personal details (name, email, phone number, address)\n• Project requirements and specifications\n• Payment and billing information\n• Communication preferences\n• Photos and documents related to your construction projects',
              w,
            ),
            SizedBox(height: h * 0.025),

            // How We Use Your Information
            _buildSectionTitle('How We Use Your Information', w),
            SizedBox(height: h * 0.015),
            _buildSectionContent(
              'We use your information to:\n\n• Provide construction and home building services\n• Process payments and manage contracts\n• Communicate about project updates and schedules\n• Improve our services and customer experience\n• Comply with legal and regulatory requirements\n• Send marketing communications (with your consent)',
              w,
            ),
            SizedBox(height: h * 0.025),

            // Information Sharing
            _buildSectionTitle('Information Sharing', w),
            SizedBox(height: h * 0.015),
            _buildSectionContent(
              'We do not sell, trade, or rent your personal information to third parties. We may share your information with:\n\n• Trusted contractors and subcontractors working on your project\n• Payment processors and financial institutions\n• Legal authorities when required by law\n• Service providers who assist in our operations',
              w,
            ),
            SizedBox(height: h * 0.025),

            // Data Security
            _buildSectionTitle('Data Security', w),
            SizedBox(height: h * 0.015),
            _buildSectionContent(
              'We implement appropriate security measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction. This includes encryption, secure servers, and regular security assessments.',
              w,
            ),
            SizedBox(height: h * 0.025),

            // Your Rights
            _buildSectionTitle('Your Rights', w),
            SizedBox(height: h * 0.015),
            _buildSectionContent(
              'You have the right to:\n\n• Access your personal information\n• Correct inaccurate information\n• Delete your personal information\n• Opt-out of marketing communications\n• Data portability\n• Lodge a complaint with regulatory authorities',
              w,
            ),
            SizedBox(height: h * 0.025),

            // Contact Information
            _buildSectionTitle('Contact Us', w),
            SizedBox(height: h * 0.015),
            _buildSectionContent(
              'If you have questions about this Privacy Policy or how we handle your information, please contact us at:\n\nEmail: privacy@yourcompany.com\nPhone: +1 (555) 123-4567\nAddress: 123 Construction Ave, Building City, BC 12345',
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