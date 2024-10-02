import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

class PdfViewerPage extends StatefulWidget {
  final String pdfUrl;
  final String pdfFileName;

  const PdfViewerPage(
      {super.key, required this.pdfUrl, required this.pdfFileName});

  @override
  _PdfViewerPageState createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  String? _downloadedFilePath;
  double _downloadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _requestStoragePermission();
    _checkIfFileExists();
  }

  Future<void> _requestStoragePermission() async {
    final status = await Permission.storage.request();
    if (!status.isGranted) {
      // Permission not granted, handle it accordingly
    }
  }

  Future<void> _checkIfFileExists() async {
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/${widget.pdfFileName}.pdf');
    if (await file.exists()) {
      setState(() {
        _downloadedFilePath = file.path;
      });
    }
  }

  Future<void> _downloadPdf() async {
    try {
      const Center(child: Text('Downloading PDF...'));
      final directory = await getTemporaryDirectory();
      final savePath = '${directory.path}/${widget.pdfFileName}.pdf';

      final dio = Dio();
      final response = await dio.download(
        widget.pdfUrl,
        savePath,
        onReceiveProgress: (receivedBytes, totalBytes) {
          final progress = receivedBytes / totalBytes;
          setState(() {
            _downloadProgress = progress;
          });
        },
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Download complete. File saved at: $savePath'),
        ),
      );

      setState(() {
        _downloadedFilePath = savePath;
        _downloadProgress = 0.0;
      });
    } catch (e) {
      Center(child: Text('Error downloading PDF: $e'));
    }
  }

  Future<String> _getFilePath(String fileName) async {
    return '${(await getTemporaryDirectory()).path}/$fileName.pdf';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pdfFileName),
        actions: _downloadedFilePath != null
            ? [
                IconButton(
                  onPressed: () {
                    if (_downloadedFilePath != null) {
                      Share.share(
                        'Check out this amazing PDF from our app!\n\n'
                        'App Details: notes hub- a place for all your notes\n'
                       'App Download Link: shandynotes.com\n\n'
                        'PDF: $_downloadedFilePath',
                      );
                    }
                  },
                  icon: const Icon(Icons.share),
                ),
              ]
            : null,
      ),
      body: _downloadedFilePath != null
          ? const PDF().cachedFromUrl(
              widget.pdfUrl,
              placeholder: (progress) => const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [CircularProgressIndicator()],
                ),
              ),
            )
          : Center(
              child: _downloadProgress > 0
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(value: _downloadProgress),
                        const SizedBox(height: 10),
                        Text(
                            '${(_downloadProgress * 100).toStringAsFixed(2)}%'),
                      ],
                    )
                  : OutlinedButton(
                      onPressed: () async {
                        if (_downloadedFilePath == null) {
                          await _downloadPdf();
                        }
                      },
                      child: const Text('Download PDF'),
                    ),
            ),
    );
  }
}
