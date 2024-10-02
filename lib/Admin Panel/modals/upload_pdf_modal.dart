class Book {
  final String id;
  final String title;
  final String author;
  final String description;
  final String category;
  final String imageUrl;
  final String pdfUrl;
  final int pageCount;
  final double size;
  final bool isLiked;
  final bool featured;
  final bool popular;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
    required this.category,
    required this.imageUrl,
    required this.pdfUrl,
    required this.pageCount,
    required this.size,
    required this.isLiked,
    required this.featured,
    required this.popular,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'description': description,
      'category': category,
      'imageUrl': imageUrl,
      'pdfUrl': pdfUrl,
      'pageCount': pageCount,
      'sizeInMB': size, // Update the key to match the one in Firebase
      'isLiked': isLiked,
      'featured': featured,
      'popular': popular,
    };
  }

  factory Book.fromMap(Map<String, dynamic> map, String id) {
    return Book(
      id: id,
      title: map['title'] ?? '',
      author: map['author'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      pdfUrl: map['pdfUrl'] ?? '',
      pageCount: map['pageCount'] ?? 0,
      size: map['sizeInMB'] ?? 0.0, // Correctly map the 'sizeInMB' field from Firebase
      isLiked: map['isLiked'] ?? false,
      featured: map['featured'] ?? false,
      popular: map['popular'] ?? false,
    );
  }

}
