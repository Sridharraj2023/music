import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../utlis/api_constants.dart';
import '../../utils/responsive_helper.dart';
import '../Widgets/Gradient_Container.dart';

class DisclaimerScreen extends StatefulWidget {
  const DisclaimerScreen({Key? key}) : super(key: key);

  @override
  State<DisclaimerScreen> createState() => _DisclaimerScreenState();
}

class _DisclaimerScreenState extends State<DisclaimerScreen> {
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _disclaimer;

  @override
  void initState() {
    super.initState();
    _fetchDisclaimer();
  }

  Future<void> _fetchDisclaimer() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final response = await http.get(
        Uri.parse('${ApiConstants.resolvedApiUrl}/terms/disclaimer/active'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _disclaimer = data;
          _isLoading = false;
        });
      } else if (response.statusCode == 404) {
        setState(() {
          _error = 'No disclaimer available at this time.';
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load disclaimer');
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading disclaimer: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: GradientContainer(
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: EdgeInsets.all(screenWidth * 0.04),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        'Disclaimer',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenWidth * 0.05,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: ResponsiveCenter(
                  maxWidth: 700,
                  child: Container(
                    margin: EdgeInsets.all(screenWidth * 0.04),
                    padding: EdgeInsets.all(screenWidth * 0.05),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: _buildContent(screenWidth),
                  ),
                ),
              ),

              // I Agree Button
              Padding(
                padding: EdgeInsets.all(screenWidth * 0.04),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, true); // Return true to indicate agreement
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: screenWidth * 0.04,
                    ),
                    minimumSize: Size(screenWidth * 0.9, 50),
                  ),
                  child: Text(
                    "I Agree",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenWidth * 0.045,
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

  Widget _buildContent(double screenWidth) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: screenWidth * 0.15,
              color: Colors.red,
            ),
            SizedBox(height: screenWidth * 0.04),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: screenWidth * 0.04,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: screenWidth * 0.04),
            ElevatedButton(
              onPressed: _fetchDisclaimer,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'Retry',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }

    if (_disclaimer == null) {
      return const Center(
        child: Text('No disclaimer available'),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            _disclaimer!['title'] ?? 'Disclaimer',
            style: TextStyle(
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 18),
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          
          SizedBox(height: screenWidth * 0.02),

          // Version and Date Info
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.03,
              vertical: screenWidth * 0.02,
            ),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.info_outline,
                  size: screenWidth * 0.04,
                  color: Colors.black54,
                ),
                SizedBox(width: screenWidth * 0.02),
                Flexible(
                  child: Text(
                    'Version ${_disclaimer!['version']} • Effective ${_formatDate(_disclaimer!['effectiveDate'])}',
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getResponsiveFontSize(context, 12),
                      color: Colors.black54,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: screenWidth * 0.06),

          // HTML Content
          Html(
            data: _disclaimer!['content'] ?? '',
            style: {
              "body": Style(
                fontSize: FontSize(ResponsiveHelper.getResponsiveFontSize(context, 14)),
                lineHeight: const LineHeight(1.6),
                color: Colors.black87,
              ),
              "h1": Style(
                fontSize: FontSize(ResponsiveHelper.getResponsiveFontSize(context, 18)),
                fontWeight: FontWeight.bold,
                color: Colors.black,
                margin: Margins.only(top: 16, bottom: 8),
              ),
              "h2": Style(
                fontSize: FontSize(ResponsiveHelper.getResponsiveFontSize(context, 16)),
                fontWeight: FontWeight.bold,
                color: Colors.black,
                margin: Margins.only(top: 14, bottom: 7),
              ),
              "h3": Style(
                fontSize: FontSize(ResponsiveHelper.getResponsiveFontSize(context, 15)),
                fontWeight: FontWeight.bold,
                color: Colors.black,
                margin: Margins.only(top: 12, bottom: 6),
              ),
              "p": Style(
                fontSize: FontSize(ResponsiveHelper.getResponsiveFontSize(context, 14)),
                margin: Margins.only(bottom: 12),
              ),
              "ul": Style(
                margin: Margins.only(left: 20, bottom: 12),
              ),
              "ol": Style(
                margin: Margins.only(left: 20, bottom: 12),
              ),
              "li": Style(
                margin: Margins.only(bottom: 6),
              ),
            },
          ),

          SizedBox(height: screenWidth * 0.04),

          // Last Updated
          Center(
            child: Text(
              'Last updated: ${_formatDate(_disclaimer!['updatedAt'])}',
              style: TextStyle(
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 11),
                color: Colors.black38,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),

          SizedBox(height: screenWidth * 0.04),
        ],
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'N/A';
    }
  }
}
