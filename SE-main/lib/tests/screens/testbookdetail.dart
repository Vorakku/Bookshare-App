import 'package:bookshare/tests/models/book.dart';
import 'package:bookshare/tests/models/booklist.dart';
import 'package:bookshare/tests/models/comment.dart';
import 'package:bookshare/tests/models/user.dart';
import 'package:bookshare/tests/utils/user_storage.dart';
import 'package:bookshare/tests/utils/api_service.dart';
import 'package:bookshare/tests/models/library.dart';
import 'package:bookshare/tests/widgets/commentbox.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Testbookdetail extends StatefulWidget {
  const Testbookdetail({super.key, required this.book});

  final Book book;

  @override
  State<Testbookdetail> createState() => _TestbookdetailState();
}

class _TestbookdetailState extends State<Testbookdetail> {
  bool isBookSaved = false;

  late Future<bool> isLikedFuture;
  final ApiService apiService = ApiService();

  late Future<List<Library>> libraries;

  late Future<List<Comment>> comments;

  late Future<User> _currentUser;

  final TextEditingController _commentController = TextEditingController();

  int _totalLikes = 0;

  @override
  void initState() {
    super.initState();
    libraries = apiService.getLibraries();
    comments = apiService.getComments(widget.book.id!);
    isLikedFuture = _checkIfLiked();
    _fetchTotalLikes();
    _checkIfBookIsSaved();
    _initializeUser();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkIfBookIsSaved();
  }

  Future<void> _initializeUser() async {
    User? user = await getUser();
    if (user != null) {
      setState(() {
        _currentUser = fetchUser();
      });
    } else {
      print('User not found');
      setState(() {
        _currentUser = Future.error('User Not found');
      });
    }
  }

  Future<void> _checkIfBookIsSaved() async {
    try {
      final token = await storage.read(key: 'auth_token');
      if (token != null) {
        final libraries = await apiService.getLibrary();
        setState(() {
          isBookSaved = libraries.any((library) => library.book?.id == widget.book.id);
          print(isBookSaved);
        });
        print('Initial isBookSaved: $isBookSaved');
      } else {
        print('User not found');
      }
    } catch (e) {
      print('Error checking if book is saved: $e');
    }
  }

  Future<void> _fetchTotalLikes() async {
    final token = await storage.read(key: 'auth_token');
    try {
      final response = await apiService.isBookLiked(widget.book.id!, token!);
      setState(() {
        _totalLikes = response['totalLikes'];
      });
    } catch (e) {
      print('Error fetching total likes: $e');
    }
  }

  String _enumToString(dynamic enumValue) {
    String value = enumValue.toString().split('.').last;
    return value[0].toUpperCase() + value.substring(1);
  }

  Future<bool> _checkIfLiked() async {
    final token = await storage.read(key: 'auth_token');
    print('Token: $token');
    try {
      final response = await apiService.isBookLiked(widget.book.id!, token!);
      final bool isLiked = response['hasLiked'];
      _totalLikes = response['totalLikes'];
      print('Is book liked: $isLiked');
      print('Total Likes: $_totalLikes');
      return isLiked;
    } catch (e) {
      print('Error checking if book is liked: $e');
      return false;
    }
  }

  Future<void> _toggleLike() async {
    final token = await storage.read(key: 'auth_token');
    try {
      bool currentLikedState = await isLikedFuture;
      print('Current liked state: $currentLikedState');
      if (currentLikedState) {
        await apiService.unlikeBook(widget.book.id!, token!);
        setState(() {
          _totalLikes--;
        });
      } else {
        await apiService.likeBook(widget.book.id!, token!);
        setState(() {
          _totalLikes++;
        });
      }
      setState(() {
        isLikedFuture = Future.value(!currentLikedState);
      });
      print('New liked state: ${!currentLikedState}');
    } catch (e) {
      print('Error toggling like: $e');
    }
  }

  Future<void> _toggleSaveBook() async {
    final token = await storage.read(key: 'auth_token');
    User? user = await getUser();
    if (user != null && token != null) {
      try {
        int? bookId = widget.book.id;
        if (isBookSaved) {
          await apiService.removeBookFromLibrary(bookId!, token!);

          List<Booklist> booklists = await apiService.fetchBooklist();
          bool isInBooklist = false;
          for (Booklist booklist in booklists) {
            if (booklist.books.any((book) => book.id == bookId)) {
              isInBooklist = true;
              break;
            }
          }

          if (isInBooklist) {
            await _removeBookFromAllBooklists(bookId);
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(isInBooklist
                ? 'Book removed from library and booklists'
                : 'Book removed from library')),
          );

          setState(() {
            isBookSaved = false;
          });
        } else {
          await apiService.addBookToLibrary(bookId!, token!);
          setState(() {
            isBookSaved = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(duration: const Duration(seconds: 1), content: Text('Book added to library')));
        }
        print('Toggled isBookSaved: $isBookSaved');
      } catch (e) {
        print('Error toggling save state: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not found')));
    }
  }

  Future<void> _removeBookFromAllBooklists(int bookId) async {
    try {
      List<Booklist> booklists = await apiService.fetchBooklist();
      for (Booklist booklist in booklists) {
        if (booklist.books.any((book) => book.id == bookId)) {
          await apiService.removeBookFromBooklist(booklist.id, bookId);
        }
      }
    } catch (e) {
      print('Error removing book from booklists: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error removing book from booklists: $e')),
      );
    }
  }

  void _postComment() async {
    String commentText = _commentController.text;
    if (commentText.isEmpty) {
      return;
    }

    User? user = await getUser();
    final token = await storage.read(key: 'auth_token');
    if (user != null && token != null) {
      await apiService.addComment(widget.book.id!, commentText);
      _commentController.clear();
      setState(() {
        comments = apiService.getComments(widget.book.id!);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please log in to comment'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 0, 0, 0),
      appBar: AppBar(
        flexibleSpace: Container(),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Color.fromARGB(255, 44, 60, 76),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromARGB(255, 44, 59, 74), Color(0xFF000000)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 3),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Image.network(
                    widget.book.imageUrl,
                    height: 280,
                    width: 180,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 19),
                Container(
                  child: Text(
                    widget.book.title,
                    style: const TextStyle(
                      fontSize: 23,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    
                  ),
                ),
                // const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildIconButton(Icons.bookmark, 'Save', _toggleSaveBook, isBookSaved ? Colors.yellow : Colors.white, 26),
                    const SizedBox(width: 16),
                    FutureBuilder<bool>(
                      future: isLikedFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return const Icon(Icons.error, color: Colors.red);
                        } else {
                          bool isLiked = snapshot.data ?? false;
                          return _buildIconButton(
                            isLiked ? Icons.star : Icons.star_border,
                            'Rate',
                            _toggleLike,
                            isLiked ? Colors.yellow : Colors.white,
                            26,
                          );
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Description and summary',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.book.description,
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      _buildInfoText('Genre: ', _enumToString(widget.book.genre), const Color(0xFF67B5E1)),
                      _buildInfoText('Publisher: ', widget.book.publisher, const Color(0xFF67B5E1)),
                      _buildInfoText('Publication date: ', widget.book.publishdate != null ? DateFormat('yyyy-MM-dd').format(widget.book.publishdate) : 'N/A', const Color(0xFF67B5E1)),
                      _buildInfoText('Number of Pages: ', widget.book.numberOfPages.toString(), const Color(0xFF67B5E1)),
                      _buildInfoText('Language: ', _enumToString(widget.book.language), const Color(0xFF67B5E1)),
                      _buildInfoText('Likes: ', _totalLikes.toString(), const Color(0xFF67B5E1)),
                      const SizedBox(height: 24),
                      const Text(
                        'Comments',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _commentController,
                        decoration: InputDecoration(
                          hintText: 'Start a discussion...',
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          suffixIcon: IconButton(
                            onPressed: _postComment,
                            icon: const Icon(Icons.send, color: Colors.black),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      FutureBuilder<List<Comment>>(
                        future: comments,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return const Center(child: Text('Failed to load comments', style: TextStyle(color: Colors.white)));
                          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Center(child: Text('No comments yet', style: TextStyle(color: Colors.white)));
                          } else {
                            return FutureBuilder<User>(
                              future: _currentUser,
                              builder: (context, userSnapshot) {
                                if (userSnapshot.connectionState == ConnectionState.waiting) {
                                  return const CircularProgressIndicator();
                                } else if (userSnapshot.hasError) {
                                  return Text('Error: ${userSnapshot.error}');
                                } else {
                                  final currentUser = userSnapshot.data!;
                                  return Column(
                                    children: [
                                      for (final comment in snapshot.data!)
                                        Commentbox(
                                          userName: comment.user.username,
                                          comment: comment.comment,
                                          date: comment.createdAt,
                                          userProfile: comment.user.profileImage!,
                                          id: comment.user.id,
                                          currentUserId: currentUser.id,
                                          commentUserId: comment.user.id,
                                        ),
                                    ],
                                  );
                                }
                              },
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoText(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(text: label, style: TextStyle(color: Colors.white, fontSize: 16)),
            TextSpan(text: value, style: TextStyle(color: color, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon, String label, VoidCallback onPressed, Color color, double size) {
    return Column(
      children: [
        IconButton(
          onPressed: onPressed,
          icon: Icon(icon, color: color, size: size),
        ),
        Text(
          label,
          style: TextStyle(color: color, fontSize: 12),
        ),
      ],
    );
  }
}
