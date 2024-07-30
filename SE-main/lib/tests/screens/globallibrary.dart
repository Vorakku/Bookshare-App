import 'package:bookshare/tests/screens/testaddbook.dart';
import 'package:bookshare/tests/screens/testbookdetail.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:bookshare/tests/models/book.dart';
import 'package:bookshare/tests/utils/api_service.dart';

enum Genre {
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

class GlobalLibrary extends StatefulWidget {
  const GlobalLibrary({super.key});

  @override
  _GlobalLibraryState createState() => _GlobalLibraryState();
}

class _GlobalLibraryState extends State<GlobalLibrary> {
  late Future<List<Book>> futureBooks;
  final TextEditingController _searchController = TextEditingController();
  List<Book> _filteredBooks = [];
  int _currentPage = 1;
  final int _booksPerPage = 10;
  Genre? _selectedGenre;

  @override
  void initState() {
    super.initState();
    futureBooks = fetchAllBooks();
    futureBooks.then((books) {
      setState(() {
        _filteredBooks = books;
      });
    });
    _searchController.addListener(_filterBooks);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterBooks);
    _searchController.dispose();
    super.dispose();
  }

  void _filterBooks() {
    final query = _searchController.text.toLowerCase();
    futureBooks.then((books) {
      setState(() {
        _filteredBooks = books.where((book) {
          final matchesQuery = book.title.toLowerCase().contains(query);
          final matchesGenre = _selectedGenre == null ||
              book.genre.toString().split('.').last ==
                  _selectedGenre.toString().split('.').last;
          return matchesQuery && matchesGenre;
        }).toList();
        _currentPage = 1;
      });
    });
  }

  void _changePage(int pageNumber) {
    setState(() {
      _currentPage = pageNumber;
    });
  }

  @override
  Widget build(BuildContext context) {
    int totalBooks = _filteredBooks.length;
    int totalPages = (totalBooks / _booksPerPage).ceil();
    List<Book> booksToDisplay = _filteredBooks
        .skip((_currentPage - 1) * _booksPerPage)
        .take(_booksPerPage)
        .toList();

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color.fromARGB(255, 44, 60, 76),
        title: const Text(
          'Global Library',
          style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          const Text(
            'Add New Book',
            style: TextStyle(color: Colors.white),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const TestAddBook()),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromARGB(255, 44, 59, 74), Color(0xFF000000)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(
            16.0), // Added padding to ensure content does not touch the corners
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search books...',
                        hintStyle: const TextStyle(color: Colors.grey),
                        prefixIcon:
                            const Icon(Icons.search, color: Colors.grey),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8.0),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              width: double.infinity,
              child: Row(
                children: [
                  InkWell(
                    onTap: (){
                      setState((){
                        _selectedGenre = null;
                        print(_selectedGenre);
                        _filterBooks();
                      });
                    } ,
                    child: const Row(
                      children: [
                         Text('Reset Filter', style: TextStyle(
                          color: Colors.white
                        ),
                        ),
                        SizedBox(width: 5,),
                        Icon(Icons.restart_alt_rounded, color: Colors.white,)
                      ],
                    ),
                  ),
                  const Spacer(),
                  DropdownButton<Genre>(
                    value: _selectedGenre,
                    hint: const Text('Select Genre',
                        style: TextStyle(color: Colors.white)),
                    dropdownColor: const Color(0xFF23232C),
                    items: Genre.values.map((Genre genre) {
                      return DropdownMenuItem<Genre>(
                        value: genre,
                        child: Text(
                          genre.toString().split('.').last,
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    }).toList(),
                    onChanged: (Genre? newValue) {
                      setState(() {
                        _selectedGenre = newValue;
                        _filterBooks();
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: FutureBuilder<List<Book>>(
                future: futureBooks,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (_filteredBooks.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Book doesn\'t exist.\nAdd the missing book?',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                          const SizedBox(height: 24),
                          InkWell(
                            child: Container(
                              padding: const EdgeInsets.all(32),
                              decoration: const BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20)),
                                color: Color.fromRGBO(77, 77, 97, 100),
                              ),
                              child: const Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 36,
                              ),
                            ),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (context) => const TestAddBook()),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  } else {
                    return Column(
                      children: [
                        Expanded(
                          child: GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              crossAxisCount: 2,
                              childAspectRatio:
                                  0.6, // Adjusted aspect ratio for smaller books
                            ),
                            itemCount: booksToDisplay.length,
                            itemBuilder: (context, index) {
                              final book = booksToDisplay[index];
                              return Container(
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            Testbookdetail(book: book),
                                      ),
                                    );
                                  },
                                  child: Column(
                                    children: [
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                              10.0), // Rounded corners
                                          child: Container(
                                            child: CachedNetworkImage(
                                              width: 160,
                                              // height: 150,
                                              imageUrl: book.imageUrl,
                                              placeholder: (context, url) =>
                                                  const CircularProgressIndicator(),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      const Icon(Icons.error,
                                                          color: Colors.white),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        height: 50,
                                        child: Text(
                                          book.title,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(totalPages, (index) {
                              int pageNumber = index + 1;
                              return InkWell(
                                onTap: () => _changePage(pageNumber),
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 4.0),
                                  padding: const EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                    color: _currentPage == pageNumber
                                        ? Colors.blue
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Text(
                                    pageNumber.toString(),
                                    style: TextStyle(
                                      color: _currentPage == pageNumber
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
