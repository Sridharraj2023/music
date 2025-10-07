import 'package:flutter/material.dart';
import '../widgets/gradient_container.dart';

class LegalPdfView extends StatefulWidget {
  final String title;
  final String assetPath; // e.g. assets/legal/terms.pdf (not used anymore but kept for compatibility)
  final bool showAgreeButton; // Whether to show the agree button

  const LegalPdfView({
    super.key, 
    required this.title, 
    required this.assetPath,
    this.showAgreeButton = true,
  });

  @override
  State<LegalPdfView> createState() => _LegalPdfViewState();
}

class _LegalPdfViewState extends State<LegalPdfView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String _getContent() {
    // Determine which content to show based on title or asset path
    if (widget.title.toLowerCase().contains('disclaimer')) {
      return _getDisclaimerText();
    } else {
      return _getTermsAndConditionsText();
    }
  }

  String _getTermsAndConditionsText() {
    return '''
TERMS AND CONDITIONS

Last Updated: ${DateTime.now().year}

1. ACCEPTANCE OF TERMS

By accessing and using the Elevate mobile application ("App"), you accept and agree to be bound by the terms and provisions of this agreement. If you do not agree to these Terms and Conditions, please do not use this App.

2. USE LICENSE

Permission is granted to temporarily download one copy of the App for personal, non-commercial transitory viewing only. This is the grant of a license, not a transfer of title, and under this license you may not:

• Modify or copy the materials
• Use the materials for any commercial purpose or for any public display
• Attempt to reverse engineer any software contained in the App
• Remove any copyright or other proprietary notations from the materials
• Transfer the materials to another person or "mirror" the materials on any other server

3. USER ACCOUNTS

To access certain features of the App, you may be required to create an account. You agree to:

• Provide accurate, current, and complete information during registration
• Maintain and promptly update your account information
• Maintain the security of your password and accept all risks of unauthorized access
• Notify us immediately of any unauthorized use of your account

4. SUBSCRIPTION SERVICES

The App offers various subscription tiers with different features and pricing. By subscribing, you agree to:

• Pay all applicable fees for your selected subscription tier
• Automatic renewal of your subscription unless cancelled
• No refunds for partial subscription periods
• Price changes with 30 days notice

5. CONTENT AND INTELLECTUAL PROPERTY

All content included in the App, such as text, graphics, logos, audio clips, digital downloads, and software, is the property of Elevate or its content suppliers and is protected by international copyright laws.

The compilation of all content on this App is the exclusive property of Elevate and protected by international copyright laws.

6. USER-GENERATED CONTENT

Users may have the ability to post, link, store, share and otherwise make available certain information, text, graphics, or other material. You are responsible for the content you post and agree not to post content that:

• Violates any laws or regulations
• Infringes on intellectual property rights
• Contains viruses or other harmful code
• Is abusive, harassing, or offensive

7. MUSIC AND AUDIO CONTENT

The binaural beats, music, and audio content provided through the App are for personal use only. You may not:

• Download, record, or redistribute the audio content
• Use the audio content for commercial purposes
• Share your account credentials with others
• Circumvent any content protection mechanisms

8. PRIVACY POLICY

Your use of the App is also governed by our Privacy Policy, which is incorporated into these Terms by reference. Please review our Privacy Policy to understand our practices.

9. DISCLAIMERS AND LIMITATIONS OF LIABILITY

The App and its content are provided "as is" without warranties of any kind, either express or implied.

Elevate does not warrant that:
• The App will be uninterrupted or error-free
• Defects will be corrected
• The App is free of viruses or other harmful components

In no event shall Elevate be liable for any damages (including, without limitation, damages for loss of data or profit, or due to business interruption) arising out of the use or inability to use the App.

10. MEDICAL DISCLAIMER

The audio content and binaural beats are not intended to diagnose, treat, cure, or prevent any disease or medical condition. Always seek the advice of your physician or other qualified health provider with any questions you may have regarding a medical condition.

Do not listen to binaural beats while driving or operating heavy machinery.

11. TERMINATION

We reserve the right to terminate or suspend your account and access to the App immediately, without prior notice or liability, for any reason whatsoever, including without limitation if you breach the Terms.

Upon termination, your right to use the App will immediately cease.

12. CHANGES TO TERMS

We reserve the right to modify or replace these Terms at any time. We will provide notice of any material changes by posting the new Terms on this page and updating the "Last Updated" date.

Your continued use of the App after any changes constitutes acceptance of those changes.

13. GOVERNING LAW

These Terms shall be governed and construed in accordance with the laws of the jurisdiction in which Elevate operates, without regard to its conflict of law provisions.

14. CONTACT US

If you have any questions about these Terms and Conditions, please contact us through the App or via email at support@elevateintune.com.

15. SEVERABILITY

If any provision of these Terms is held to be unenforceable or invalid, such provision will be changed and interpreted to accomplish the objectives of such provision to the greatest extent possible under applicable law, and the remaining provisions will continue in full force and effect.

16. WAIVER

No waiver by Elevate of any term or condition set forth in these Terms shall be deemed a further or continuing waiver of such term or condition or a waiver of any other term or condition.

By creating an account and using this App, you acknowledge that you have read, understood, and agree to be bound by these Terms and Conditions.
''';
  }

  String _getDisclaimerText() {
    return '''
DISCLAIMER

Last Updated: ${DateTime.now().year}

PLEASE READ THIS DISCLAIMER CAREFULLY BEFORE USING THE ELEVATE APPLICATION

1. GENERAL INFORMATION

The Elevate application ("App") provides binaural beats and audio content for personal wellness, relaxation, focus, and meditation purposes. This disclaimer governs your use of the App.

2. NOT MEDICAL ADVICE

The content provided through this App is for informational and entertainment purposes only and is not intended to be a substitute for professional medical advice, diagnosis, or treatment.

ALWAYS SEEK THE ADVICE OF YOUR PHYSICIAN OR OTHER QUALIFIED HEALTH PROVIDER with any questions you may have regarding a medical condition. Never disregard professional medical advice or delay in seeking it because of something you have accessed through this App.

3. NO MEDICAL CLAIMS

We make no representations, warranties, or guarantees that the use of binaural beats or any audio content in this App will:

• Cure, treat, or prevent any disease or medical condition
• Improve any specific health condition
• Produce any specific mental or physical result
• Be suitable for everyone

4. INDIVIDUAL RESULTS MAY VARY

Results from using binaural beats and audio content vary from person to person. Your individual results may differ significantly from any testimonials, case studies, or examples provided.

5. CONTRAINDICATIONS AND WARNINGS

DO NOT use this App if you:
• Have epilepsy or are prone to seizures
• Have a pacemaker or other electronic implants
• Are pregnant (without consulting your doctor first)
• Have a history of mental health conditions without professional guidance
• Are taking medications that affect brain function

DO NOT listen to binaural beats while:
• Driving or operating vehicles
• Operating heavy machinery
• Performing tasks requiring alertness
• In situations where loss of awareness could be dangerous

6. POTENTIAL SIDE EFFECTS

Some users may experience:
• Headaches or dizziness
• Nausea or discomfort
• Anxiety or unusual emotional responses
• Sleep disturbances

If you experience any adverse effects, discontinue use immediately and consult a healthcare professional.

7. NOT A REPLACEMENT FOR PROFESSIONAL TREATMENT

This App is not a replacement for:
• Psychotherapy or counseling
• Psychiatric treatment
• Medical treatment
• Prescription medications
• Professional mental health services

If you are experiencing mental health issues, please seek help from qualified mental health professionals.

8. SCIENTIFIC BASIS

While some research suggests potential benefits of binaural beats, the scientific community has not reached a consensus on their effectiveness. The content in this App is based on existing research and traditional practices, but individual experiences may vary.

9. USE AT YOUR OWN RISK

By using this App, you acknowledge and agree that:

• You use the App entirely at your own risk
• Elevate is not responsible for any physical, mental, emotional, or other harm that may result from your use of the App
• You are responsible for consulting with appropriate healthcare professionals before using the App
• You will not hold Elevate liable for any adverse effects or outcomes

10. NO GUARANTEES

We do not guarantee or warrant:
• Specific results or outcomes from using the App
• That the App will meet your individual needs or expectations
• That the audio content is suitable for all users
• Continuous, uninterrupted, or error-free operation of the App

11. THIRD-PARTY CONTENT

The App may contain content, research, or references from third-party sources. We do not endorse, guarantee, or assume responsibility for any third-party content, services, or websites.

12. CHILDREN AND MINORS

This App is not intended for use by children under the age of 18 without parental or guardian supervision and consent. Parents and guardians should carefully consider whether this App is appropriate for their children.

13. MODIFICATIONS TO DISCLAIMER

We reserve the right to update, change, or modify this Disclaimer at any time. Any changes will be posted on this page with an updated "Last Updated" date. Your continued use of the App after any changes constitutes acceptance of the modified Disclaimer.

14. CONSENT AND ACKNOWLEDGMENT

By using this App, you acknowledge that:

• You have read and understood this entire Disclaimer
• You agree to all terms set forth in this Disclaimer
• You understand the risks and limitations associated with using the App
• You will use the App responsibly and in accordance with all warnings and guidelines
• You release Elevate from any liability related to your use of the App

15. EMERGENCY SITUATIONS

If you are experiencing a medical or mental health emergency, do not rely on this App. Instead:

• Call your local emergency number (911 in the US)
• Contact a crisis hotline
• Go to the nearest emergency room
• Contact your healthcare provider immediately

16. CONTACT INFORMATION

If you have questions or concerns about this Disclaimer or the App, please contact us at support@elevateintune.com.

By proceeding to use the Elevate App, you acknowledge that you have read, understood, and agreed to this Disclaimer in its entirety.
''';
  }

  void _handleAgree() {
    // Return true to indicate the user agreed
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GradientContainer(
        child: SafeArea(
          child: Column(
            children: [
              // Header with back button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                      onPressed: () => Navigator.pop(context, false),
                    ),
                    Expanded(
                      child: Text(
                        widget.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              
              // Scrollable content
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Scrollbar(
                    controller: _scrollController,
                    thumbVisibility: true,
                    thickness: 4,
                    radius: const Radius.circular(10),
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      padding: const EdgeInsets.only(right: 12.0),
                      child: Text(
                        _getContent(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              
              // Agree button at the bottom
              if (widget.showAgreeButton)
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: _handleAgree,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      minimumSize: Size(screenWidth * 0.9, 50),
                      elevation: 5,
                    ),
                    child: const Text(
                      "I Agree",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
