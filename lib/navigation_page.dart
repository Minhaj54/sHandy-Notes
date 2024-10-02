import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:notes_hub/pages/all_books_page.dart';
import 'package:notes_hub/pages/home_page/store_home_page.dart';
import 'package:notes_hub/pages/user_profile_page.dart';
import 'package:notes_hub/pages/whishlist_page.dart';


class NavigationBaar extends StatefulWidget {
  const NavigationBaar({super.key});

  @override
  State<NavigationBaar> createState() => _NavigationBaarState();
}

int _currentIndex = 0;
final _tabs = [
  const EbookStoreHomePage(),
  const BooksPage(),
  //const UploadPage(),
  const WishlistPage(),
  const ProfilePage(),
];

class _NavigationBaarState extends State<NavigationBaar> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        //backgroundColor: Colors.deepPurpleAccent,
        selectedFontSize: 13,
        unselectedFontSize: 12,
        selectedItemColor: Colors.deepPurpleAccent,
        iconSize: 24,
        currentIndex: _currentIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(
              Iconsax.home,
            ),
            label: "Home",
            // backgroundColor: Colors.deepPurpleAccent,
          ),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.book),
            label: "Notes",
            // backgroundColor: Colors.deepPurpleAccent
          ),
          // BottomNavigationBarItem(
          //     icon: Icon(
          //       Iconsax.add_square,
          //     ),
          //     label: "Upload",
          //     backgroundColor: Colors.deepPurpleAccent),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.heart),
            label: "Whishlist",
            //backgroundColor: Colors.deepPurpleAccent
          ),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.profile_circle),
            label: "Profile",
            //backgroundColor: Colors.deepPurpleAccent
          ),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
