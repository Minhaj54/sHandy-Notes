import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:notes_hub/pages/user_profile_page.dart';
import 'package:provider/provider.dart';

import '../../Admin Panel/modals/upload_pdf_modal.dart';
import '../helper_class/custom_image_widget.dart';
import '../provider/provider.dart';
import 'book_detailed_page.dart';

class WishlistPage extends StatelessWidget {
  const WishlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text('Please log in to view your wishlist.'));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wishlist'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('wishlists')
            .doc(user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const ShimmerLoading();
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData ||
              !snapshot.data!.exists ||
              snapshot.data!['bookIds'] == null) {
            return const Center(child: Text('Your wishlist is empty.'));
          }

          final wishlistData = snapshot.data!.data() as Map<String, dynamic>;
          final wishlistBookIds =
              List<String>.from(wishlistData['bookIds'] ?? []);

          if (wishlistBookIds.isEmpty) {
            return const Center(child: Text('Your wishlist is empty.'));
          }

          return FutureBuilder<QuerySnapshot>(
            future: FirebaseFirestore.instance
                .collection('books')
                .where(FieldPath.documentId, whereIn: wishlistBookIds)
                .get(),
            builder: (context, bookSnapshot) {
              if (bookSnapshot.connectionState == ConnectionState.waiting) {
                return const ShimmerLoading();
              } else if (bookSnapshot.hasError) {
                return Center(child: Text('Error: ${bookSnapshot.error}'));
              }

              final books = bookSnapshot.data!.docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return Book.fromMap(data, doc.id);
              }).toList();

              return ListView.builder(
                itemCount: books.length,
                itemBuilder: (context, index) {
                  final book = books[index];

                  // Fetch the wishlist provider here within the ListTile's scope
                  final wishlistProvider =
                      Provider.of<WishlistProvider>(context, listen: false);

                  return Card(
                    margin: const EdgeInsets.all(10),
                    color: Colors.white70,
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(5.0),
                        child: CustomCachedImage(
                          imageUrl: book.imageUrl,
                          width: 50,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(book.title,
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      subtitle: Text(book.description,
                          maxLines: 2, overflow: TextOverflow.ellipsis),
                      trailing: IconButton(
                        onPressed: () async {
                          await wishlistProvider.toggleWishlistItem(book.id);
                        },
                        icon: Icon(
                          wishlistProvider.isWishlisted(book.id)
                              ? Iconsax.heart5
                              : Iconsax.heart,
                          color: wishlistProvider.isWishlisted(book.id)
                              ? Colors.deepPurpleAccent
                              : null,
                        ),
                      ),
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
                },
              );
            },
          );
        },
      ),
    );
  }
}
