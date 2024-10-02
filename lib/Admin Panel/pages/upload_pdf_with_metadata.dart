import 'dart:async';
import 'dart:io';
import 'dart:convert'; // Add this line

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf_render/pdf_render.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _image;
  File? _pdf;
  bool _isFeatured = false;
  bool _isPopular = false;
  int _pdfPageCount = 0;
  double _pdfSizeInMB = 0.0;
  String? _selectedCategory;
  double _uploadProgress = 0.0;

  final List<String> _categories = [
    'Class 6th-10th',
    'Class 11th & 12th',
    'Programming',
    'Technology',
    'JEE',
    'NEET',
    'College',
    'GATE',
    'NDA',
    'UPSC',
    'Others',
  ];

  Future<void> _getImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  Future<void> _getPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _pdf = File(result.files.single.path!);
        _detectPdfMetadata();
      });
    }
  }

  Future<void> _detectPdfMetadata() async {
    if (_pdf != null) {
      final pdfDocument = await PdfDocument.openFile(_pdf!.path);
      final pageCount = pdfDocument.pageCount;
      final fileSize = await _pdf!.length();
      final fileSizeInMB = fileSize / (1024 * 1024);

      setState(() {
        _pdfPageCount = pageCount;
        _pdfSizeInMB = fileSizeInMB;
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _uploadBook() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      // No internet connection
      _showSnackBar('No Internet Connection');
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Uploading...'),
            ],
          ),
        );
      },
    );

    try {
      final imageFileName = const Uuid().v4();
      final imageRef = FirebaseStorage.instance
          .ref()
          .child('book_covers')
          .child('$imageFileName.jpg');
      final imageUploadTask = imageRef.putFile(_image!);

      final pdfFileName = const Uuid().v4();
      final pdfRef = FirebaseStorage.instance
          .ref()
          .child('pdfs')
          .child('$pdfFileName.pdf');
      final pdfUploadTask = pdfRef.putFile(_pdf!);

      setState(() {
        _uploadProgress = 0.0;
      });

      final StreamSubscription<TaskSnapshot> streamSubscription =
          pdfUploadTask.snapshotEvents.listen((event) {
        final progress = event.bytesTransferred / event.totalBytes;
        setState(() {
          _uploadProgress = progress;
        });
      });

      await Future.wait([imageUploadTask, pdfUploadTask]);

      final imageUrl = await imageRef.getDownloadURL();
      final pdfUrl = await pdfRef.getDownloadURL();

      await FirebaseFirestore.instance.collection('books').add({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'category': _selectedCategory,
        'author': _authorController.text,
        'imageUrl': imageUrl,
        'pdfUrl': pdfUrl,
        'featured': _isFeatured,
        'popular': _isPopular,
        'pageCount': _pdfPageCount,
        'sizeInMB': _pdfSizeInMB,
        // Associate the uploaded PDF with the logged-in user
      });

      Navigator.pop(context); // Close the AlertDialog
      _formKey.currentState!.reset();
      _titleController.clear();
      _descriptionController.clear();
      _authorController.clear();
      setState(() {
        _image = null;
        _pdf = null;
        _isFeatured = false;
        _isPopular = false;
        _pdfPageCount = 0;
        _pdfSizeInMB = 0.0;
        _selectedCategory = null;
        _uploadProgress = 0.0;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Note uploaded successfully')),
      );
    } catch (error) {
      Navigator.pop(context); // Close the AlertDialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $error')),
      );
    }
  }

  Future<void> _showUploadGuidelinesDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Upload Guidelines',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '1. Enter meta data correctly.',
                ),
                SizedBox(height: 8),
                Text(
                  '2. Give a well cover page of PDF ( or Take a screenshot of the first page of the PDF upload as the cover page).',
                ),
                SizedBox(height: 8),
                Text(
                  '3. Select a PDF and make sure it should be a note. Only notes are allowed; otherwise, your account will be suspended.',
                ),
                SizedBox(height: 8),
                Text(
                  '4. Make sure to upload your own notes. Otherwise, provide proper credit in the credit section.',
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  // notification logic
  //Define this function to send a notification
  Future<void> sendNotification(
      String title, String description, String imageUrl) async {
    final FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Set up the notification payload
    final notification = {
      'title': 'New PDF Uploaded',
      'body': '$title\n$description',
      'image': imageUrl, // Optional image
    };

    // Sending notification to all users or topic subscription
    final String topic = 'all'; // Assuming 'all' is the topic for all users
    await messaging.subscribeToTopic(topic);

    // Construct the message to be sent
    final message = {
      'notification': notification,
      'topic': '/topics/$topic',
    };

    // Use the Firebase Cloud Messaging API to send the message
    final String serverKey = '79c559e1fdb1eaf06950770c879219982c57239a';
    final String url = 'https://fcm.googleapis.com/fcm/send';
    final http.Response response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverKey',
      },
      body: jsonEncode(message),
    );

    if (response.statusCode == 200) {
      print('Notification sent successfully');
    } else {
      print('Failed to send notification');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Note'),
        actions: [
          IconButton(
            onPressed: () {
              _showUploadGuidelinesDialog(context);
            },
            icon: const Icon(Iconsax.info_circle),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4, // Increase the number of lines
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _authorController,
                decoration: const InputDecoration(
                  labelText: 'Author/Credit',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an author';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a category';
                  }
                  return null;
                },
                value: _selectedCategory ?? _categories.first,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: _isFeatured,
                    onChanged: (value) {
                      setState(() {
                        _isFeatured = value!;
                      });
                    },
                  ),
                  const Text('Featured'),
                  Checkbox(
                    value: _isPopular,
                    onChanged: (value) {
                      setState(() {
                        _isPopular = value!;
                      });
                    },
                  ),
                  const Text('Popular'),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _getImage,
                child: const Text('Select Image'),
              ),
              const SizedBox(height: 16),
              if (_image != null) // Show image preview if an image is selected
                SizedBox(height: 200, child: Image.file(_image!)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _getPdf,
                child: const Text('Select PDF'),
              ),
              if (_pdf != null) // Show PDF metadata if a PDF is selected
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    Text(
                      'PDF Pages: $_pdfPageCount',
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      'PDF Size: ${_pdfSizeInMB.toStringAsFixed(2)} MB',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  await sendNotification(
                    _titleController.text,
                    _descriptionController.text,
                    _image!.path,
                  );
                  await _uploadBook();
                },
                child: const Text('Upload Note'),
              ),
              const SizedBox(height: 16),
              if (_uploadProgress > 0.0 && _uploadProgress < 1.0)
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: _uploadProgress,
                        backgroundColor: Colors.grey,
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '${(_uploadProgress * 100).toStringAsFixed(2)}%',
                        style: const TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
