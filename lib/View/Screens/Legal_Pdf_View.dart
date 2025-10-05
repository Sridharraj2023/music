import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import '../widgets/gradient_container.dart';

class LegalPdfView extends StatefulWidget {
  final String title;
  final String assetPath; // e.g. assets/legal/terms.pdf

  const LegalPdfView({super.key, required this.title, required this.assetPath});

  @override
  State<LegalPdfView> createState() => _LegalPdfViewState();
}

class _LegalPdfViewState extends State<LegalPdfView> {
  bool _opening = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _openPdf();
  }

  Future<void> _openPdf() async {
    try {
      final bytes = await rootBundle.load(widget.assetPath);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/${widget.assetPath.split('/').last}');
      await file.writeAsBytes(bytes.buffer.asUint8List());
      final result = await OpenFilex.open(file.path);
      if (!mounted) return;
      if (result.type != ResultType.done) {
        setState(() => _error = result.message ?? 'Unable to open PDF');
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GradientContainer(
        child: SafeArea(
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      widget.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 12),
              if (_opening) const Center(child: CircularProgressIndicator(color: Colors.white)),
              if (!_opening && _error != null)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(_error!, style: const TextStyle(color: Colors.white)),
                ),
              if (!_opening && _error == null)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Opened in your PDF viewer.', style: TextStyle(color: Colors.white)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
