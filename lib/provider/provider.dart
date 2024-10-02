import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class WishlistProvider extends ChangeNotifier {
  final List<String> _wishlist = []; // Store book IDs for the logged-in user

  List<String> get wishlist => _wishlist;

  WishlistProvider() {
    _loadWishlistFromFirestore();
  }

  Future<void> _loadWishlistFromFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot = await FirebaseFirestore.instance.collection('wishlists').doc(user.uid).get();

    if (snapshot.exists && snapshot.data()!.containsKey('bookIds')) {
      final bookIds = List<String>.from(snapshot.data()!['bookIds']);
      _wishlist.addAll(bookIds);
    }
    notifyListeners();
  }

  Future<void> addToWishlist(String bookId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _wishlist.add(bookId);

    await FirebaseFirestore.instance.collection('wishlists').doc(user.uid).set({
      'bookIds': FieldValue.arrayUnion([bookId])
    }, SetOptions(merge: true));

    notifyListeners();
  }

  Future<void> removeFromWishlist(String bookId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _wishlist.remove(bookId);

    await FirebaseFirestore.instance.collection('wishlists').doc(user.uid).update({
      'bookIds': FieldValue.arrayRemove([bookId])
    });

    notifyListeners();
  }

  Future<void> toggleWishlistItem(String bookId) async {
    if (_wishlist.contains(bookId)) {
      await removeFromWishlist(bookId);
    } else {
      await addToWishlist(bookId);
    }
  }

  bool isWishlisted(String bookId) {
    return _wishlist.contains(bookId);
  }
}
