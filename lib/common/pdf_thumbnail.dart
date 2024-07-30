import 'dart:async';
import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_pdfviewer_platform_interface/pdfviewer_platform_interface.dart';
import 'package:wghdfm_java/common/pdf_viewer.dart';

class PdfThumbnail extends StatefulWidget {
  final String pdfPath;
  final bool networkPdf;

  const PdfThumbnail(
      {Key? key, required this.pdfPath, required this.networkPdf})
      : super(key: key);

  @override
  _PdfThumbnailState createState() => _PdfThumbnailState();
}

class _PdfThumbnailState extends State<PdfThumbnail> {
  Widget? _thumbnailWidget;

  @override
  void initState() {
    super.initState();
    print("aaya Data");
    print(widget.pdfPath);
    _getThumbnail();
  }

  Future<Uint8List> loadPdfBytes({required String path}) async {
    try {
      final byteData = File(path).readAsBytes();
      return byteData;
    } catch (e) {
      print('Error loading PDF: $e');
      rethrow; // Or handle the error appropriately
    }
  }

  Future<Uint8List> loadNetworkPdfBytes({required String url}) async {
    try {
      final byteData = await http.readBytes(Uri.parse(url));
      return byteData;
    } catch (e) {
      print('Error loading PDF: $e');
      rethrow; // Or handle the error appropriately
    }
  }

  void _getThumbnail() async {
    //Load the PDF document

    var bytes = widget.networkPdf == false
        ? await loadPdfBytes(path: widget.pdfPath)
        : await loadNetworkPdfBytes(url: widget.pdfPath);

    String documentID = '1';
    int pageNumber = 0;
    // Initialize the PDF renderer
    await PdfViewerPlatform.instance.initializePdfRenderer(bytes, documentID);
    // Get the height and width of all the pages
    final pagesHeight =
        await PdfViewerPlatform.instance.getPagesHeight(documentID);
    final pagesWidth =
        await PdfViewerPlatform.instance.getPagesWidth(documentID);

    final ratio = pagesWidth![pageNumber] / pagesHeight![pageNumber];

    // Calculate the thumbnail width and height
    final int thumbnailWidth =
        widget.networkPdf == false ? 200 : Get.width.toInt();
    final int thumbnailHeight = (thumbnailWidth / ratio).toInt();
    // Calculate the thumbnail width and height

    // Get the thumbnail image bytes
    final imageBytes =
        await PdfViewerPlatform.instance.getImage(1, 0, documentID);
    // Close the document
    await PdfViewerPlatform.instance.closeDocument(documentID);

    if (imageBytes == null) {
      return;
    }
    final thumbnail = SizedBox(
        width: thumbnailWidth.toDouble(),
        height: thumbnailHeight.toDouble(),
        child: Image.memory(imageBytes));

    setState(() {
      _thumbnailWidget = thumbnail;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _thumbnailWidget != null
        ? GestureDetector(
            onTap: () {
              Get.to(PdfViewerScreen(
                  path: widget.pdfPath, network: widget.networkPdf));
            },
            child: _thumbnailWidget!)
        : SizedBox(
            width: Get.width,
            child: Center(child: const CircularProgressIndicator()));
  }
}
