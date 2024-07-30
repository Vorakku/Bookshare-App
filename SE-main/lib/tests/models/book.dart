import 'package:bookshare/tests/models/user.dart';
import 'package:intl/intl.dart';

enum Genre  {
  fiction,
  nonfiction,
  fantasy,
  sciencefiction,
  mystery,
  romance,
  historical,
  horror,
  biography,
  selfhelp,
  poetry,
  youngadult,
  comics,
  travel,
  cookbooks,
  drama,
  adventure, 
  humor,
  memoir,
}

enum Language {
  english, khmer, japanese, korean
}

class Book { 
  Book({
    required this.title,
    required this.description,
    required this.isbn,
    required this.imageUrl,
    required this.genre,
    required this.publisher,
    required this.publishdate,
    required this.numberOfPages,
    required this.language,
    required this.status,
    this.liked = false,
    this.id,
    required this.user,

  });
  final bool liked;
  final int? id;
  final String title;
  final String description;
  final String isbn;
  final String imageUrl;
  final Genre genre;
  final String publisher;
  final DateTime publishdate;
  final int numberOfPages;
  final Language language;
  final int status;
  final User user;

    factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] ?? 'No Id',
      title: json['title'] ?? 'No Title',
      description: json['description'] ?? 'No Description',
      isbn: json['isbn'] ?? 'No ISBN',
      imageUrl: json['image_url'] ?? '',
      // genre: Genre.values.firstWhere((e) => e.toString().split('.').last.toLowerCase() == json['genre'], orElse: () => Genre.adventure),
      genre: Genre.values.firstWhere((e) => e.toString().split('.').last == json['genre'].toString().toLowerCase(),orElse: () => Genre.adventure,
    ),
      publisher: json['publisher'] ?? 'Unknown Publisher',
      publishdate: DateTime.parse(json['publishdate'] ?? '0000-00-00'),
      numberOfPages: json['number_of_pages'] ?? 0,
      language: Language.values.firstWhere((e) => e.toString().split('.').last == json['language'], orElse: () => Language.english),
      status: json['status'] ?? 0,
      user: User.fromJson(json['user'] ?? {}),
      liked: json['liked'] ?? false, 
    );
  }

//Testing Purpose
// int? get id => null;

  Map<String, dynamic> toJson() {
    final dateFormatter = DateFormat('MM/dd/yyyy');
    return {
      'id': id,
      'title': title,
      'isbn': isbn,
      'image_url': imageUrl,
      'genre': genre.toString().split(' ').last,
      'publisher': publisher,
      'publishdate': publishdate.toIso8601String,
      // 'publishdate': dateFormatter.format(publishdate),
      'number_of_pages': numberOfPages,
      'language': language.toString().split(' ').last,
      'status': status,
      'user' : user.toJson(),
      'liked': liked,
    };
  }

  @override
  String toString() {
    return 'Book{id: $id, title: $title, description: $description, isbn: $isbn, imageUrl: $imageUrl, genre: $genre, publisher: $publisher, publishdate: $publishdate, numberOfPages: $numberOfPages, language: $language, status: $status, liked: $liked, user: $user}';
  }
}

  //Newly added Function
  // factory Book.fromJson(Map<String, dynamic> json) {
  //   return Book(
  //     // id: json['id'].toString(),
  //     title: json['title'],
  //     description: json['description'], 
  //     isbn: json['isbn'],
  //     imageUrl: json['image_url'],
  //     genre: Genre.values.firstWhere((e) => e.toString().split('.').last == json['genre']),
  //     publisher: json['publisher'],
  //     publishdate: json['publishdate'],
  //     numberOfPages: json['number_of_pages'],
  //     language: Language.values.firstWhere((e) => e.toString().split('.').last == json['language']),
  //     status: json['status'],
  //     user: User.fromJson(json['user']), 
  //   );
  // }