import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../Admin Panel/modals/upload_pdf_modal.dart';
import 'book_detailed_page.dart';

class MyPdfPage extends StatefulWidget {
  const MyPdfPage({super.key});

  @override
  _MyPdfPageState createState() => _MyPdfPageState();
}

class _MyPdfPageState extends State<MyPdfPage> {
  late User? currentUser;

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My PDFs'),
      ),
      body: currentUser != null
          ? StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('books')
            .where('userId', isEqualTo: currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No PDFs uploaded'));
          }
          return ListView(
            children: snapshot.data!.docs.map((document) {
              final book = Book.fromMap(document.data() as Map<String, dynamic>, document.id);
              return Card(
                margin: const EdgeInsets.all(12),
                child: ListTile(
                  title: Text(book.title),
                  subtitle: Text(book.description),
                  leading: book.imageUrl.isNotEmpty
                      ? CircleAvatar(
                    backgroundImage: NetworkImage(book.imageUrl),
                  )
                      : const Icon(Icons.insert_drive_file),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookDetailPage(book: book),
                      ),
                    );
                  },
                ),
              );
            }).toList(),
          );
        },
      )
          : const Center(
        child: Text('You are not logged in.'),
      ),
    );
  }
}
