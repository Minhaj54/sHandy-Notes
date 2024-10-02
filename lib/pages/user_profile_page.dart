import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:notes_hub/login/sign_up_page.dart';
import 'package:shimmer/shimmer.dart';

import '../../login/login_with _phoneNumber.dart';
import 'my_pdf_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final auth = FirebaseAuth.instance;
  late User? currentUser;
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    currentUser = auth.currentUser;
    if (currentUser != null) {
      fetchUserData();
    }
  }

  Future<void> fetchUserData() async {
    final userId = currentUser?.uid;
    if (userId != null) {
      final userDataSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (userDataSnapshot.exists) {
        setState(() {
          userData = userDataSnapshot.data();
        });
      }
    }
  }

  Future<void> signOut() async {
    await auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginWithPhoneNumber()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: currentUser != null
          ? userData != null
              ? Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (userData!['profilePicUrl'] != null)
                        CircleAvatar(
                            radius: 60,
                            backgroundImage: CachedNetworkImageProvider(
                                userData!['profilePicUrl'])),
                      const SizedBox(height: 20),
                      ListTile(
                        leading: const Icon(Iconsax.user),
                        title: Text(
                          'Name: ${userData!['name']}',
                          style: const TextStyle(),
                        ),
                        subtitle: Text(
                          'Profession: ${userData!['profession']}',
                          style: const TextStyle(),
                        ),
                      ),
                      ListTile(
                        leading: const Icon(Iconsax.call),
                        title: Text(
                          '${userData!['phoneNumber']}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      ListTile(
                        leading: const Icon(Iconsax.row_vertical),
                        title: const Text('More Apps'),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        leading: const Icon(Iconsax.share),
                        title: const Text('Share App'),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        leading: const Icon(Iconsax.star),
                        title: const Text('Rate Us'),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        leading: const Icon(Iconsax.lock),
                        title: const Text('Privacy Policy'),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        leading: const Icon(Iconsax.document_upload),
                        title: const Text('My PDFs'),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const MyPdfPage()));
                        },
                      ),
                      const Spacer(),
                      const SizedBox(height: 30),
                      OutlinedButton.icon(
                        onPressed: signOut,
                        icon: const Icon(Icons.logout),
                        label: const Text('Logout'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      )
                    ],
                  ),
                )
              : const ShimmerLoading()
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Iconsax.info_circle, size: 100, color: Colors.deepPurple),
                  const SizedBox(height: 10),
                  const Text('You are not signed in.'),
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 100.0),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SignUpWithPhoneNumber()),
                        );
                      },
                      child: const Text('Sign Up'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class ShimmerLoading extends StatelessWidget {
  const ShimmerLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 60,
              backgroundColor: Colors.white,
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Iconsax.user, color: Colors.white),
              title: Container(
                height: 20,
                color: Colors.white,
              ),
              subtitle: Container(
                height: 16,
                color: Colors.white,
              ),
            ),
            ListTile(
              leading: const Icon(Iconsax.call, color: Colors.white),
              title: Container(
                height: 20,
                color: Colors.white,
              ),
            ),
            ListTile(
              leading: const Icon(Iconsax.row_vertical, color: Colors.white),
              title: Container(
                height: 20,
                color: Colors.white,
              ),
            ),
            ListTile(
              leading: const Icon(Iconsax.share, color: Colors.white),
              title: Container(
                height: 20,
                color: Colors.white,
              ),
            ),
            ListTile(
              leading: const Icon(Iconsax.star, color: Colors.white),
              title: Container(
                height: 20,
                color: Colors.white,
              ),
            ),
            ListTile(
              leading: const Icon(Iconsax.lock, color: Colors.white),
              title: Container(
                height: 20,
                color: Colors.white,
              ),
            ),
            ListTile(
              leading: const Icon(Iconsax.document_upload, color: Colors.white),
              title: Container(
                height: 20,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            const SizedBox(height: 30),
            Container(
              width: double.infinity,
              height: 48,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
