import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../pages/all_books_page.dart';

class SearchBox extends StatelessWidget {
  const SearchBox({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: GestureDetector(
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const BooksPage(),
            )),
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12), border: Border.all()),
          height: 60,
          width: double.infinity,
          child: const Row(
            children: [
              SizedBox(
                width: 10,
              ),
              Icon(Icons.search),
              SizedBox(
                width: 5,
              ),
              Text('Search Notes..'),
              Spacer(),
              Icon(Iconsax.arrow_circle_right4),
              SizedBox(
                width: 15,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
