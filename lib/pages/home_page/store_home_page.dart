import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
// Add this import

import '../../../Admin Panel/modals/upload_pdf_modal.dart';
import '../../helper_class/custom_image_widget.dart';
import '../../helper_class/search_box.dart';
import '../book_detailed_page.dart';
import '../categroy_page.dart';
import '../notificans_page.dart';

class EbookStoreHomePage extends StatefulWidget {
  const EbookStoreHomePage({super.key});

  @override
  _EbookStoreHomePageState createState() => _EbookStoreHomePageState();
}

class _EbookStoreHomePageState extends State<EbookStoreHomePage> {
  late Stream<List<Book>> _books;
  bool _isConnected = true;

  @override
  void initState() {
    super.initState();
    _checkInternetConnection();
    _books = fetchBooks();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Handle notification when app is in the foreground
      if (message.notification != null) {
        // Parse and store the notification
        String title = message.notification!.title!;
        String description = message.notification!.body!;
        String imageUrl = message.data['imageUrl'] ?? '';

        // Save this data to show in the user's notification list
        FirebaseFirestore.instance.collection('user_notifications').add({
          'title': title,
          'description': description,
          'imageUrl': imageUrl,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    });
  }

  Stream<List<Book>> fetchBooks() {
    return FirebaseFirestore.instance.collection('books').snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => Book.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<void> _checkInternetConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      _isConnected = connectivityResult != ConnectivityResult.none;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Home',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Iconsax.notification),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationsPage()),
              );
            },
          ),
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  final Uri _url = Uri.parse('https://forms.gle/Nf6ib9AMbgt3HPCF9');

                  Future<void> _launchUrl() async {
  if (!await launchUrl(_url)) {
    throw Exception('Could not launch $_url');
  }
}
                  return AlertDialog(
                    title: const Text("Notes Request!!"),
                    content: const Text(
                        "If you want any particular notes that is not available right now so you can request us by filling the form below, feel free to provide the details below as per your requirement!!"),
                    actions: <Widget>[
                      TextButton(
                        child: const Text("OK"),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                       ElevatedButton(
                        
              onPressed: _launchUrl,
              child: Text('Open Form'),
            ),
                      
                       
                    ],
                  );
                },
              );
            },
            icon: const Icon(
              Iconsax.more_circle5,
            ),
          ),
        ],
      ),
      drawer: Drawer(
        shape: const LinearBorder(),
        child: ListView(
          padding: const EdgeInsets.all(0),
          children: [
            UserAccountsDrawerHeader(
                decoration: const BoxDecoration(color: Colors.deepPurpleAccent),
                accountName: Text(
                  '',
                  style: GoogleFonts.kalam(
                    color: Colors.greenAccent,
                    textStyle: const TextStyle(
                      fontSize: 28.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                accountEmail: Padding(
                  padding: const EdgeInsets.only(bottom: 18.0),
                  child: Text(
                    'sHandy Notes',
                    style: GoogleFonts.kalam(
                      color: Colors.cyanAccent,
                      textStyle: const TextStyle(
                        fontSize: 28.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                currentAccountPicture: const CircleAvatar(
                  backgroundColor: Colors.deepPurpleAccent,
                  backgroundImage: AssetImage(
                    'assets/images/logo.jpg',
                  ),
                )),
            ListTile(
              leading: const Icon(Iconsax.login),
              title: const Text(' Share it  '),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: _isConnected
          ? StreamBuilder<List<Book>>(
              stream: _books,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildShimmerEffect();
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Comming Soon..'));
                }

                final books = snapshot.data!;
                final featuredBooks =
                    books.where((book) => book.featured).toList();
                final popularBooks =
                    books.where((book) => book.popular).toList();

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SearchBox(),
                      _buildSectionTitle(context, 'Featured Notes'),
                      _buildHorizontalBookList(
                        featuredBooks,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      _buildSectionTitle(context, 'Categories'),
                      _buildCategoriesSection(),
                      const SizedBox(
                        height: 10,
                      ),
                      _buildSectionTitle(context, 'Popular Notes'),
                      _buildHorizontalBookList(
                        popularBooks,
                      ),
                    ],
                  ),
                );
              },
            )
          : const Center(
              child: Text(
                'No Internet Connection',
                style: TextStyle(fontSize: 18, color: Colors.red),
              ),
            ),
    );
  }

  Widget _buildShimmerEffect() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        itemCount: 6,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: double.infinity,
              height: 150.0,
              color: Colors.white,
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black,
              overflow: TextOverflow.ellipsis,
            ),
      ),
    );
  }

  Widget _buildHorizontalBookList(
    List<Book> books,
  ) {
    // Shuffle the list to ensure it's in a different order each time the app reopens
    books.shuffle();
    // Ensure the most recently added book is at the front of the list
    // books.sort((a, b) => b.addedDate.compareTo(a.addedDate));
    // Limit the list to only show the first 7 books
    final limitedBooks = books.take(7).toList();
    return SizedBox(
      height: 297.0,
      child: ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: limitedBooks.length,
        itemBuilder: (context, index) {
          final book = limitedBooks[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BookDetailPage(book: book),
                ),
              );
            },
            child: _buildBookItem(book, horizontal: true),
          );
        },
      ),
    );
  }

  Widget _buildVerticalBookList(List<Book> books) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BookDetailPage(book: book),
              ),
            );
          },
          child: _buildBookItem(book, horizontal: true),
        );
      },
    );
  }

  Widget _buildBookItem(Book book, {bool horizontal = true}) {
    return Container(
      width: horizontal ? 175.0 : double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(5.0)),
            child: CustomCachedImage(
              imageUrl: book.imageUrl,
              fit: BoxFit.cover,
              height: horizontal ? 245.0 : 200.0,
              width: 175,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              book.title,
              style: const TextStyle(
                fontSize: 10.0,
                // fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesSection() {
    final categories = [
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
      'Others'
    ];
    return SizedBox(
      height: 60.0,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CategoryPage(
                    category: categories[index],
                  ),
                ),
              );
            },
            child: _buildCategoryItem(categories[index]),
          );
        },
      ),
    );
  }

  Widget _buildCategoryItem(String category) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: Colors.deepPurpleAccent,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Center(
        child: Text(
          category,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
