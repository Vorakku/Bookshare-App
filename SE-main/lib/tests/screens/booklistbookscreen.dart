import 'package:bookshare/tests/models/book.dart';
import 'package:flutter/services.dart';
import 'package:bookshare/tests/widgets/bookinbooklist.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:bookshare/tests/utils/user_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Booklistbookscreen extends StatefulWidget {
  const Booklistbookscreen({
    super.key,
    required this.books,
    required this.booklistName,
    required this.booklistId,
    required this.isPublic,
    required this.onBookRemoved,
  });

  final List<Book> books;
  final String booklistName;
  final String booklistId;
  final bool isPublic;
  final ValueChanged<int> onBookRemoved;

  @override
  State<Booklistbookscreen> createState() => _BooklistbookscreenState();
}

class _BooklistbookscreenState extends State<Booklistbookscreen> {
  late List<Book> _books;
  late bool _isPublic;

  @override
  void initState() {
    super.initState();
    _books = List.from(widget.books);
    _isPublic = widget.isPublic;
  }

  // Future<void> _removeBookFromBooklist(String booklistId, int bookId) async {
  //   try {
  //     final response = await http.delete(
  //       Uri.parse('http://192.168.56.1:8000/api/booklists/$booklistId/books/$bookId'),
  //       headers: {
  //         'Authorization': 'Bearer ${await storage.read(key: 'auth_token')}',
  //       },
  //     );

  //     if (response.statusCode == 200) {
  //       setState(() {
  //         _books.removeWhere((book) => book.id == bookId);
  //       });
  //       widget.onBookRemoved(bookId);
  //       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
  //         content: Text('Book removed from booklist'),
  //       ));
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //         content: Text('Failed to remove book from booklist: ${response.reasonPhrase}'),
  //       ));
  //     }
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //       content: Text('Error: $e'),
  //     ));
  //   }
  // }
  Future<void> _removeBookFromBooklist(String booklistId, int bookId) async {
    try {
      final response = await http.post(
        Uri.parse('${dotenv.env['API_URL']}/booklist/removeBook'),
        headers: {
          'Authorization': 'Bearer ${await storage.read(key: 'auth_token')}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'booklist_id': booklistId,
          'book_id': bookId,
        }),
      );

      if (response.statusCode == 204) {
        setState(() {
          _books.removeWhere((book) => book.id == bookId);
        });
        widget.onBookRemoved(bookId);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Book removed from booklist'),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Failed to remove book from booklist: ${response.reasonPhrase}'),
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: $e'),
      ));
    }
  }

  Future<void> _updateBooklistPrivacy(bool isPublic) async {
    final token = await storage.read(key: 'auth_token');
    final url =
        '${dotenv.env['API_URL']}/booklists/${widget.booklistId}/status';

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'public': isPublic ? 1 : 0}),
      );
      if (response.statusCode == 200) {
        setState(() {
          _isPublic = isPublic;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              isPublic ? 'Booklist is now public' : 'Booklist is now private'),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Failed to update booklist privacy'),
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: $e'),
      ));
    }
  }

  Future<void> _shareBooklist() async {
    final token = await storage.read(key: 'auth_token');
    final url =
        '${dotenv.env['API_URL']}/booklist/generate-link/${widget.booklistId}';

    try {
      final response = await http
          .post(Uri.parse(url), headers: {'Authorization': 'Bearer $token'});
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final sharableLink = data['url'];
        _showSharableLink(sharableLink);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Failed to generate sharable link'),
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: $e'),
      ));
    }
  }

  void _showSharableLink(String link) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Sharable Link',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text(link,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: link));
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Link copied to clipboard'),
                      ));
                    },
                    child: const Text('Copy'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Close'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2C3E50), Color(0xFF000000)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.booklistName,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Switch(
                    value: _isPublic,
                    onChanged: (value) {
                      _updateBooklistPrivacy(value);
                    },
                    activeColor: Colors.white,
                    activeTrackColor: Colors.green[300],
                  ),
                  Text(
                    (_isPublic ? "( Public )" : "( Private )"),
                    style: const TextStyle(color: Colors.white),
                  ),
                  const Spacer(),
                  IconButton(
                      onPressed: _shareBooklist,
                      icon: const Icon(Icons.share, color: Colors.white)),
                ],
              ),
              const SizedBox(height: 24),
              for (final book in _books)
                Bookinbooklist(
                  book: book,
                  booklistId: widget.booklistId,
                  onRemove: _removeBookFromBooklist,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
