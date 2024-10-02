import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:notes_hub/login/sign_up_page.dart';
import 'package:provider/provider.dart';

import '../../Admin Panel/modals/upload_pdf_modal.dart';
import '../helper_class/custom_image_widget.dart';
import '../provider/provider.dart';
import 'pdfViewerScreen.dart';

class BookDetailPage extends StatefulWidget {
  final Book book;

  const BookDetailPage({super.key, required this.book});

  @override
  _BookDetailPageState createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
  late bool _isLiked;

  @override
  void initState() {
    super.initState();
    final wishlistProvider =
        Provider.of<WishlistProvider>(context, listen: false);
    _isLiked = wishlistProvider.isWishlisted(widget.book.id);
  }

  Future<void> _toggleWishlist() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SignUpWithPhoneNumber()),
      );
      return;
    }

    final wishlistProvider =
        Provider.of<WishlistProvider>(context, listen: false);

    setState(() {
      _isLiked = !_isLiked;
    });

    await wishlistProvider.toggleWishlistItem(widget.book.id);

    final wishlistRef =
        FirebaseFirestore.instance.collection('wishlists').doc(user.uid);

    if (_isLiked) {
      await wishlistRef.set({
        'bookIds': FieldValue.arrayUnion([widget.book.id])
      }, SetOptions(merge: true));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Book added to wishlist!')),
      );
    } else {
      await wishlistRef.update({
        'bookIds': FieldValue.arrayRemove([widget.book.id])
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Book removed from wishlist!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: CustomCachedImage(
                  imageUrl: widget.book.imageUrl,
                  width: 170,
                  height: 250,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.deepPurpleAccent,
                child: Icon(Iconsax.lamp_on, color: Colors.white),
              ),
              title: Text(
                widget.book.title,
                style: const TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                  overflow: TextOverflow.ellipsis,
                ),
                maxLines: 2,
              ),
              subtitle: Text(
                'Credit/Author: ${widget.book.author}',
                style: const TextStyle(
                  fontSize: 14.0,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              trailing: IconButton(
                onPressed: _toggleWishlist,
                icon: Icon(
                  _isLiked ? Iconsax.heart5 : Iconsax.heart,
                  color: _isLiked ? Colors.deepPurpleAccent : Colors.grey,
                ),
              ),
            ),
            const Divider(),
            const SizedBox(height: 8.0),
            Text(
              'Description: ${widget.book.description}',
              style: const TextStyle(
                fontSize: 16.0,
              ),
            ),
            const SizedBox(height: 16.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Category: ${widget.book.category}',
                  style: const TextStyle(fontSize: 16.0),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  'Pages: ${widget.book.pageCount}',
                  style: const TextStyle(fontSize: 16.0),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  'Size: ${widget.book.size.toStringAsFixed(2)} MB',
                  style: const TextStyle(fontSize: 16.0),
                ),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PdfViewerPage(
                          pdfUrl: widget.book.pdfUrl,
                          pdfFileName: widget.book.title),
                    ),
                  );
                },
                child: const Text('View PDF'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
