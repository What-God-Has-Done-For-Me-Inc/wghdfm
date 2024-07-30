import 'dart:io';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewerScreen extends StatefulWidget {
  const PdfViewerScreen({super.key, required this.path, required this.network});
final String path;
final bool network;
  @override
  _PdfViewerScreen createState() => _PdfViewerScreen();
}

class _PdfViewerScreen extends State<PdfViewerScreen> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();



  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('PDF Viewer'),

        ),
        body: widget.network == true ? SfPdfViewer.network(
          widget.path,
          key: _pdfViewerKey,
        ) : SfPdfViewer.file(File(widget.path),key:_pdfViewerKey),
      ),
    );
  }
}