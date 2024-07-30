import 'package:bookshare/tests/models/book.dart';
import 'package:bookshare/tests/widgets/publicbookinbooklist.dart';
import 'package:flutter/services.dart';
import 'package:bookshare/tests/widgets/bookinbooklist.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:bookshare/tests/utils/user_storage.dart';

class Displaypublicbooklist extends StatefulWidget {
  const Displaypublicbooklist({
    super.key,
    required this.books,
    required this.booklistName,
    required this.booklistId,
    required this.isPublic,
  });

  final List<Book> books;
  final String booklistName;
  final String booklistId;
  final bool isPublic;

  @override
  State<Displaypublicbooklist> createState() => _DisplaypublicbooklistState();
}

class _DisplaypublicbooklistState extends State<Displaypublicbooklist> {
  late List<Book> _books;
  late bool _isPublic;

  @override
  void initState() {
    super.initState();
    _books = List.from(widget.books);
    _isPublic = widget.isPublic;
  }

  Future<void> _removeBookFromBooklist(String booklistId, int bookId) async {
    try {
      final response = await http.delete(
        Uri.parse(
            'http://192.168.56.1:8000/api/booklists/$booklistId/books/$bookId'),
        headers: {
          'Authorization': 'Bearer ${await storage.read(key: 'auth_token')}',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _books.removeWhere((book) => book.id == bookId);
        });
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
        'http://192.168.56.1:8000/api/booklists/${widget.booklistId}/status';

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
        'http://192.168.56.1:8000/api/booklist/generate-link/${widget.booklistId}';

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
              Row(
                children: [
                  Text(widget.booklistName,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(
                height: 12,
              ),
              Text(
                (_isPublic ? "( Public )" : "( Private )"),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 24),
              for (final book in _books)
                PublicBookInBooklist(
                  book: book,
                  booklistId: widget.booklistId,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
