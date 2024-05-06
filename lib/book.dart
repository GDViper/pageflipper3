class Book {
  final String title;
  final List<String> authors;
  final String genre;
  final double price;

  Book({required this.title, required this.authors, required this.genre, required this.price});

  factory Book.fromJson(Map<String, dynamic>? json) {
    return Book(
      title: json?['title'] ?? '',
      authors: List<String>.from(json?['authors'] ?? []),
      genre: json?['genre'] ?? '',
      price: (json?['price'] is String) ? double.parse(json?['price']) : json?['price'] ?? 0.0,
    );
  }
}