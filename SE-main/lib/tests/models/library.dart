import 'package:bookshare/tests/models/book.dart';

class Library {
  final int userId;
  final int bookId;
  // final Book book;
  final Book? book;

  Library({
    required this.userId, 
    required this.bookId, 
    required this.book});

  factory Library.fromJson(Map<String, dynamic> json) {
    return Library(
      userId: json['user_id'],
      bookId: json['book_id'],
      //Newly Added
      // book: Book.fromJson(json['book']),
      book: json['book'] != null ? Book.fromJson(json['book']) : null,
    );
  }
}
