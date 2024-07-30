import 'dart:convert';
import 'package:bookshare/tests/models/book.dart';
import 'package:bookshare/tests/models/user.dart';

class Booklist {
  final String id;
  final String name;
  final List<Book> books;
  final User user;
  bool isPublic;


  Booklist({
    required this.id, 
    required this.name,
    required this.user, 
    required this.books,
    this.isPublic = false,
  });

    factory Booklist.fromJson(Map<String, dynamic> json) {
    var booksFromJson = json['books'] as List;
    List<Book> booksList = booksFromJson.map((book) => Book.fromJson(book)).toList();

    return Booklist(
      id: json['id']?.toString() ?? '',
      name: json['name'],
      books: booksList,
      user: User.fromJson(json['user']),
      isPublic: json['public'] == 1
    );
  }


  //Added code
  Map<String, dynamic> toJson(){
    return {
      'id': id,
      'name': name,
      'books': books.map((book) => book.toJson()).toList(),
      'user': user.toJson(),
      'public': isPublic ? 1 : 0
    };
  }
}