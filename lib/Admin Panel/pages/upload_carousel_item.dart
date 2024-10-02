import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path/path.dart';

class UploadCarouselItem extends StatefulWidget {
  const UploadCarouselItem({super.key});

  @override
  _UploadCarouselItemState createState() => _UploadCarouselItemState();
}

class _UploadCarouselItemState extends State<UploadCarouselItem> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  File? _image;
  bool _isUploading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  Future<void> _uploadCarouselItem() async {
    if (_formKey.currentState?.validate() != true) return;

    setState(() {
      _isUploading = true;
    });

    try {
      // Upload image to Firebase Storage
      String imageUrl = '';
      if (_image != null) {
        String fileName = basename(_image!.path);
        Reference storageReference =
        FirebaseStorage.instance.ref().child('carousel_images/$fileName');
        UploadTask uploadTask = storageReference.putFile(_image!);
        TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
        imageUrl = await taskSnapshot.ref.getDownloadURL();
      }

      // Add carousel item to Firestore
      await FirebaseFirestore.instance.collection('carousel').add({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'imageUrl': imageUrl,
      });

      // Clear form fields and image
      _titleController.clear();
      _descriptionController.clear();
      setState(() {
        _image = null;
        _isUploading = false;
      });

      ScaffoldMessenger.of(context as BuildContext).showSnackBar(
        const SnackBar(content: Text('Carousel item uploaded successfully')),
      );
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(
        SnackBar(content: Text('Error uploading item: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Carousel Item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              _image != null
                  ? Image.file(_image!, height: 200)
                  : const Placeholder(fallbackHeight: 200),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text('Pick Image'),
              ),
              const SizedBox(height: 16.0),
              _isUploading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _uploadCarouselItem,
                child: const Text('Upload Carousel Item'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
