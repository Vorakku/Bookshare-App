// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:bookshare/tests/models/comment.dart';
import 'package:bookshare/tests/models/user.dart';
import 'package:bookshare/tests/utils/user_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:bookshare/tests/models/book.dart';
import 'package:bookshare/tests/models/library.dart';
import 'package:bookshare/tests/models/booklist.dart';

Future<List<Book>> fetchAllBooks() async {
  final response = await http.get(
    Uri.parse('${dotenv.env['API_URL']}/getbooks'),
    headers: {
      'Content-Type': 'application/json',
    },
  );
  if (response.statusCode == 200) {
    try {
      List<dynamic> data = jsonDecode(response.body);
      return data
          .map((json) => Book.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error parsing JSON: $e');
      throw Exception('Failed to parse books');
    }
  } else {
    print('Failed to load books: ${response.statusCode}');
    throw Exception('Failed to load books');
  }
}

Future<User> fetchUser() async {
  final token = await storage.read(key: 'auth_token');

  final response = await http.get(
    Uri.parse('${dotenv.env['API_URL']}/users/user'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    },
  );
  if (response.statusCode == 200) {
    print('Response body: ${response.body}');
    try {
      return User.fromJson(jsonDecode(response.body));
    } catch (e) {
      print('Error parsing JSON: $e');
      throw Exception('Failed to parse user');
    }
  } else {
    print('Failed to load user: ${response.statusCode}');
    throw Exception('Failed to load user');
  }
}

Future<List<Book>> fetchBook() async {
  final token = await storage.read(key: 'auth_token');

  final response = await http.get(
    Uri.parse('${dotenv.env['API_URL']}/getbooks/user'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );
  if (response.statusCode == 200) {
    print('Response body: ${response.body}');
    try {
      List<dynamic> data = jsonDecode(response.body);
      print(data);
      return data
          .map((json) => Book.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error parsing JSON: $e');
      throw Exception('Failed to parse books');
    }
  } else {
    print('Failed to load books: ${response.statusCode}');
    throw Exception('Failed to load books');
  }
}

class EmptyLibraryException implements Exception {
  final String message;
  EmptyLibraryException(this.message);
  @override
  String toString() => message;
}

class ApiService {

  // Future<List<Booklist>> fetchPublicBooklistsByUserId(String userId) async {
  //   final token = await storage.read(key: 'auth_token');
  //   final response = await http.get(
  //     Uri.parse('${dotenv.env['API_URL']}/view_booklists/$userId/public'),
  //     headers: {
  //       'Authorization': 'Bearer $token',
  //       'Content-Type': 'application/json',
  //     },
  //   );

  //   if (response.statusCode == 200) {
  //     List<dynamic> body = json.decode(response.body);
  //     return body.map((dynamic item) => Booklist.fromJson(item)).toList();
  //   } else {
  //     throw Exception('Failed to load public booklists');
  //   }
  // }

  Future<List<Booklist>> fetchBooklistsByUserId(String userId, {bool isPublic = true}) async {
  final token = await storage.read(key: 'auth_token');
  final String listType = isPublic ? "public" : "private";
  final response = await http.get(
    Uri.parse('${dotenv.env['API_URL']}/view_booklists/$userId/$listType'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    List<dynamic> body = json.decode(response.body);
    return body.map((dynamic item) => Booklist.fromJson(item)).toList();
  } else {
    throw Exception('Failed to load $listType booklists');
  }
}

  Future<void> saveBookmark(int bookId, int currentPage) async {
    final token = await storage.read(key: 'auth_token');
    final response = await http.post(
      Uri.parse('${dotenv.env['API_URL']}/library/$bookId/bookmark'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({'current_page': currentPage}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to save bookmark');
    }
  }

  Future<int?> fetchBookmark(int bookId) async {
  final token = await storage.read(key: 'auth_token');
  final response = await http.get(
    Uri.parse('${dotenv.env['API_URL']}/library/$bookId/bookmark'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return data['current_page'] as int?;
  } else if (response.statusCode == 404) {
    return null; // No bookmark found
  } else {
    throw Exception('Failed to fetch bookmark');
  }
}

  Future<void> deleteBooklist(String booklistId) async {
    final token = await storage.read(key: 'auth_token');
    final response = await http.delete(
      Uri.parse('${dotenv.env['API_URL']}/booklist/delete'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'booklist_id': booklistId,
      }),
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete booklist');
    }
  }

  Future<void> changeUsername(String newUsername) async {
    final token = await storage.read(key: 'auth_token');
    final response = await http.put(
      Uri.parse('${dotenv.env['API_URL']}/user/username'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'username': newUsername}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update username');
    }
  }

  Future<void> removeBookFromBooklist(String booklistId, int bookId) async {
    final token = await storage.read(key: 'auth_token');
    final response = await http.post(
      Uri.parse('${dotenv.env['API_URL']}/booklist/removeBook'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'booklist_id': booklistId,
        'book_id': bookId,
      }),
    );

    if (response.statusCode != 204) {
      print(response.statusCode);
      throw Exception('Failed to remove book from booklist');
    }
  }

  Future<User> getUserProfile(String userId) async {
    final token = await storage.read(key: 'auth_token');
    final response = await http.get(
      Uri.parse('${dotenv.env['API_URL']}/user/$userId'),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return User.fromJson(jsonData);
    } else {
      throw Exception('Failed to load user profile');
    }
  }

  Future<String> generateSharableLink(int booklistId) async {
    final token = await storage.read(key: 'auth_token');
    final response = await http.post(
        Uri.parse(
            '${dotenv.env['API_URL']}/booklist/generate-link/$booklistId'),
        headers: {'Authorization': 'Bearer $token'});

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['link'];
    } else {
      throw Exception('Failed to generate link');
    }
  }

  Future<List<Book>> getTopLikeBooks() async {
    final response = await http.get(
      Uri.parse('${dotenv.env['API_URL']}/books/top_like'),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      List<Book> books = (responseData['topBooks'] as List)
          .map((data) => Book.fromJson(data))
          .toList();
      return books;
    } else {
      throw Exception('Failed to load top liked books');
    }
  }

  Future<List<Book>> getRecentBooks() async {
    final token = await storage.read(key: 'auth_token');
    final response = await http.get(
        Uri.parse(
          '${dotenv.env['API_URL']}/books/recent',
        ),
        headers: {'Authorization': 'Bearer $token'});

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse
          .map((book) => Book.fromJson(book as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to load recent books');
    }
  }

  Future<void> likeBook(int bookId, String token) async {
    final response = await http.post(
        Uri.parse('${dotenv.env['API_URL']}/books/$bookId/like'),
        headers: {'Authorization': 'Bearer $token'});
    if (response.statusCode != 200) {
      throw Exception('Failed to like book');
    }
  }

  Future<void> unlikeBook(int bookId, String token) async {
    final response = await http.post(
        Uri.parse('${dotenv.env['API_URL']}/books/$bookId/unlike'),
        headers: {'Authorization': 'Bearer $token'});
    if (response.statusCode != 200) {
      throw Exception('Failed to unlike book');
    }
  }

  Future<Map<String, dynamic>> isBookLiked(int bookId, String token) async {
    final response = await http.get(
        Uri.parse('${dotenv.env['API_URL']}/books/$bookId/liked'),
        headers: {'Authorization': 'Bearer $token'});

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return {
        'hasLiked': responseData['hasLiked'],
        'totalLikes': responseData['totalLikes'],
      }; // Corrected the key name
    } else {
      throw Exception('Failed to check if book is liked');
    }
  }

  Future<List<Comment>> getComments(int bookId) async {
    final response = await http
        .get(Uri.parse('${dotenv.env['API_URL']}/books/$bookId/comments'));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => Comment.fromJson(item)).toList();
    } else {
      print('Failed to load comments: ${response.statusCode} ${response.body}');
      throw Exception('Failed to load comments');
    }
  }

  Future<void> addComment(int bookId, String comment) async {
    final token = await storage.read(key: 'auth_token');

    final response = await http.post(
      Uri.parse('${dotenv.env['API_URL']}/comments'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'book_id': bookId, 'comment': comment}),
    );

    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode != 201) {
      print('Failed to add comment: ${response.statusCode} ${response.body}');
      throw Exception('Failed to add comment');
    }
  }

  Future<bool> addDescription(String description) async {
    final token = await storage.read(key: 'auth_token');

    print(description);
    final response = await http.post(
      Uri.parse('${dotenv.env['API_URL']}/add_description/user'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode({
        'description': description,
      }),
    );
    if (response.statusCode == 200) {
      print('Response body: ${response.body}');
      return true;
    } else {
      return false;
    }
  }

  Future<List<Booklist>> fetchBooklists() async {
  final token = await storage.read(key: 'auth_token');
  try {
    final response = await http.get(
      Uri.parse('${dotenv.env['API_URL']}/view_booklists/user'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    print('Response Status: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((json) => Booklist.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load booklists Status code: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching booklists: $e');
    throw Exception('Failed to fetch booklists');
  }
}

  Future<List<Library>> getLibraries() async {
    final token = await storage.read(key: 'auth_token');
    final response =
        await http.get(Uri.parse("${dotenv.env['API_URL']}/library"), headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);

      final libraries = data.map((json) => Library.fromJson(json)).toList();
      return libraries;
      // return data.map((json) => Library.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load libraries');
    }
  }

  Future<List<Library>> getLibrary() async {
    final token = await storage.read(key: 'auth_token');

    final response = await http
        .get(Uri.parse("${dotenv.env['API_URL']}/library/user"), headers: {
      'Content-Type': 'application',
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      if (data.isEmpty) {
        throw 'Library is empty';
      }
      return data.map((json) => Library.fromJson(json)).toList();
    } else {
      throw EmptyLibraryException('No Books Available');
    }
  }

  Future<void> removeBookFromLibrary(int bookId, String s) async {
    final token = await storage.read(key: 'auth_token');

    final response = await http.delete(
      Uri.parse("${dotenv.env['API_URL']}/library/$bookId"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to remove book from library');
    }
  }

  Future<void> addBookToLibrary(int bookId, String s) async {
    final token = await storage.read(key: 'auth_token');

    final response = await http.post(
      Uri.parse("${dotenv.env['API_URL']}/add_book_to_library"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode(<String, String>{
        'book_id': bookId.toString(),
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add book to library');
    }
  }

  Future<void> addBookToBooklist(
      String booklistId, int bookId, String token) async {
    final response = await http.post(
      Uri.parse("${dotenv.env['API_URL']}/add_book_to_booklist"),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'booklist_id': booklistId,
        'book_id': bookId,
      }),
    );

    if (response.statusCode != 201) {
      print(
          'Failed to add book to booklist. Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Failed to add book to booklist');
    } else {
      print('Book added successfully to booklist');
    }
  }

  Future<void> createBooklist(String bookListName) async {
    final token = await storage.read(key: 'auth_token');

    print(bookListName);
    final response = await http.post(
      Uri.parse("${dotenv.env['API_URL']}/create_booklist"),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'name': bookListName,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create a booklist ${response.statusCode}');
    }
  }

  Future<List<Booklist>> fetchBooklist() async {
    final token = await storage.read(key: 'auth_token');
    final response = await http.get(
        Uri.parse("${dotenv.env['API_URL']}/view_booklists/user"),
        headers: {
          'Content-Type': 'application',
          'Authorization': 'Bearer $token',
        });

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Booklist.fromJson(json)).toList();
    } else {
      throw Exception('Failed to create a booklist');
    }
  }
  removeBookFromAllBooklists(int i, String s) {}
  getBooklists() {}
  getBooklistsWithBook(int bookId, String token) {}
}

  //   Future<bool> isBookLiked(int bookId, String token) async {
  //   final response = await http.get(
  //     Uri.parse('${dotenv.env['API_URL']}/books/$bookId/liked'),
  //     headers: {
  //       'Authorization': 'Bearer $token'
  //     }
  //   );
    
  //   if (response.statusCode == 200) {
  //     final responseData = jsonDecode(response.body);
  //     return responseData[
  //       'hasLiked'
  //       ]; // Corrected the key name
  //   } else {
  //     throw Exception('Failed to check if book is liked');
  //   }
  // }
    // Future<String?> getToken() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   return prefs.getString('auth_token');
  // }