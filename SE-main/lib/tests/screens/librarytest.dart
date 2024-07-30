// ignore_for_file: avoid_unnecessary_containers

import 'dart:math';

import 'package:bookshare/tests/models/book.dart';
import 'package:bookshare/tests/models/booklist.dart';
import 'package:bookshare/tests/models/library.dart';
import 'package:bookshare/tests/models/user.dart';
import 'package:bookshare/tests/screens/booklistbookscreen.dart';
import 'package:bookshare/tests/screens/homepagetest.dart';
import 'package:bookshare/tests/screens/testbookdetail.dart';
import 'package:bookshare/tests/utils/api_service.dart';
import 'package:bookshare/tests/utils/user_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class LibraryPageTest extends StatefulWidget {
  const LibraryPageTest({super.key});

  @override
  _LibraryPageTestState createState() => _LibraryPageTestState();
}

class _LibraryPageTestState extends State<LibraryPageTest> {
  var booklistName = ['Your Addeded', 'Books'];
  String getNewLineString() {
    StringBuffer sb = new StringBuffer();
    for (String line in booklistName) {
      sb.write(line + "\n");
    }
    return sb.toString();
  }

  int _selectedPageIndex = 0;
  final ApiService apiService = ApiService();
  late Future<List<Library>> libraries;
  late String userId;

  
  List<Library> selectedBooks = [];
  List<Library> allLibraries = [];
  List<Library> filteredLibraries = [];

  final TextEditingController _pageController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  
  final TextEditingController _booklistname = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<List<Booklist>>? booklists;

  Future<List<Book>>? AddededBooks; 

  bool _isPublic = true; 
  String dropdownValue = 'All Booklist';

  String? _libraryErrorMessage;
  Genre? _selectedGenre;

  void _handleBookRemoved(int bookId) {
    setState(() {
      selectedBooks.removeWhere((library) => library.book!.id == bookId);
    });
  }

  @override
  void initState() {
    super.initState();
    libraries = apiService.getLibrary();
    _initializeUser();
    _initializeBooklistUser();
    _initializeBookAdded();
    searchController.addListener(_filterBooks);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeUser(); // Reinitialize the user to refresh the state
  }

  Future<void> _initializeBooklistUser() async {
    User? user = await getUser();
    if (user != null) {
      try {
        List<Booklist> list = await apiService.fetchBooklists();
        setState(() {
          booklists = Future.value(list);
          _libraryErrorMessage = null; // Clear any previous error messages
        });
      } catch (error) {
        if (error is EmptyLibraryException) {
          print("The Library is Empty");
          setState(() {
            _libraryErrorMessage = error.message;
            booklists = Future.value([]); // Empty list if library is empty
          });
        } else {
          setState(() {
            booklists = Future.error(error);
          });
        }
      }
    } else {
      setState(() {
        booklists = Future.error('User Not found');
      });
    }
  }

  Future<void> _initializeBookAdded() async {
    User? user = await getUser();
    if (user != null) {
      String userId = user.id;
      print(userId);
      setState(() {
        AddededBooks = fetchBook();
      });
    } else {
      print('User not found');
      setState(() {
        AddededBooks = Future.error('User Not found');
        //Empty list
      });
    }
  }
  
  void refreshLibraries() {
  setState(() {
    // Create a new instance of the future to force update.
    libraries = apiService.getLibrary();
  });
  }

  Future<void> _initializeUser() async {
    User? user = await getUser();
    if (user != null) {
      setState(() {
        userId = user.id; 
        libraries = apiService.getLibrary();
        libraries.then((libList) {
          setState(() {
            allLibraries = libList;
            filteredLibraries = libList;
          });
        }).catchError((error) {
          if (error is EmptyLibraryException) {
            print("The library is emtpy");
            setState(() {
              _libraryErrorMessage = error.message;
            });
          }
        });
      });
    } else {
      print('User not found');
    }
  }

  void _filterBooks() {
    setState(() {
      filteredLibraries = allLibraries
          .where((library) =>
              library.book!.title
                  .toLowerCase()
                  .contains(searchController.text.toLowerCase()) &&
              (_selectedGenre == null || library.book!.genre == _selectedGenre))
          .toList();
    });
  }


  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  void _toggleSelection(Library library) {
    setState(() {
      if (selectedBooks.contains(library)) {
        selectedBooks.remove(library);
      } else {
        selectedBooks.add(library);
      }
    });
  }

  void _showBooklistDialog() async {
    List<Booklist> booklists = await apiService.fetchBooklist();
    List<String> selectedBooklistIds = [];

    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 24,
              ),
              child: Container(
                width: double.infinity,
                child: Column(
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Save book to?',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Flexible(
                      child: ListView.builder(
                          itemCount: booklists.length,
                          itemBuilder: (context, index) {
                            return CheckboxListTile(
                              title: Text(booklists[index].name),
                              value: selectedBooklistIds
                                  .contains(booklists[index].id),
                              onChanged: (bool? value) {
                                setState(() {
                                  if (value == true) {
                                    selectedBooklistIds.add(booklists[index].id);
                                  } else {
                                    selectedBooklistIds.remove(booklists[index].id);
                                  }
                                });
                              },
                            );
                          }),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.black,
                          ),
                          child: const Text('Cancel',
                              style: TextStyle(color: Colors.white)),
                        ),
                        ElevatedButton(
                          onPressed: selectedBooklistIds.isNotEmpty
                              ? () {
                                  for (String booklistId
                                      in selectedBooklistIds) {
                                    _saveBooksToBooklist(booklistId);
                                  }
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                          ),
                          child: const Text('Confirm',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          });
        });
  }

  void _saveBooksToBooklist(String booklistId) async {
    try {
      final token = await storage.read(key: 'auth_token');
      for (Library library in selectedBooks) {
        print(
            'Adding book with ID: ${library.book!.id} to booklist ID: $booklistId');
        await apiService.addBookToBooklist(
            booklistId, library.book!.id!, token!);
      }
      setState(() {
        selectedBooks.clear();
        _initializeBooklistUser();
      });
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Books added to booklist')));
      Navigator.of(context).pop();
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add books to booklist ')));
    }
  }

  Future<void> _saveBookmark(
      int bookId, int currentPage, int totalPages) async {
    if (currentPage > totalPages) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Current page exceeds total pages of the book')),
      );
      return;
    }

    try {
      await apiService.saveBookmark(bookId, currentPage);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bookmark saved')),
      );
      setState(() {});
    } catch (e) {
      print('Failed to save bookmark: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save bookmark')),
      );
    }
  }

  Future<int?> _fetchBookmark(int bookId) async {
    try {
      final currentPage = await apiService.fetchBookmark(bookId);
      return currentPage;
    } catch (e) {
      print('Failed to load bookmark: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget activePage = _libraryErrorMessage != null
        ? Container(
            height: 600,
            child: const Center(
              child: Text(
                "You haven't save any books yet.",
                style: TextStyle(color: Colors.white),
              ),
            ),
          )
        : Column(
            children: [
              const Padding(
                padding:
                     EdgeInsets.symmetric(horizontal: 14, vertical: 24),
                child: Row(
                  children: [
                     Text(
                      'Saved Books',
                      textAlign: TextAlign.start,
                      style: TextStyle(color: Colors.white, fontSize: 24),
                    ),
                     Spacer(), // This will push the button to the right
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Search for save books...',
                    hintStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                width: double.infinity,
                child: Row(
                  children: [
                    InkWell(
                      onTap: () {
                        setState(() {
                          _selectedGenre = null;
                          print(_selectedGenre);
                          _filterBooks();
                        });
                      },
                      child: const Row(
                        children: [
                          Text(
                            'Reset Filter',
                            style: TextStyle(color: Colors.white),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Icon(
                            Icons.restart_alt_rounded,
                            color: Colors.white,
                          )
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
              FutureBuilder<List<Library>>(
                  future: libraries,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Text('Error ${snapshot.error}');
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No books available'));
                    } else if (filteredLibraries.isEmpty) {
                      return const Center(
                          child: Center(
                              child: Padding(
                        padding: EdgeInsets.only(top: 200),
                        child: Text(
                          'No books match your search',
                          style: TextStyle(color: Colors.white),
                        ),
                      )));
                    } else {
                      return Container(
                        padding: const EdgeInsets.only(left: 12, bottom: 54),
                        constraints: const BoxConstraints(
                          maxHeight: 500,
                        ),
                        child: ListView.builder(
                            itemCount: filteredLibraries.length,
                            itemBuilder: (ctx, index) => Padding(
                                  padding: const EdgeInsets.only(bottom: 30),
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  Testbookdetail(
                                                      book: filteredLibraries[index].book!)
                                                          )
                                                      ).then((_) {
                                                          print("Back from details page, refetching libraries");
                                                          refreshLibraries();
                                                          });
                                    },
                                    child: Container(
                                      height: 100,
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 75,
                                            height: double.infinity,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(2),
                                            ),
                                            clipBehavior: Clip.hardEdge,
                                            child: CachedNetworkImage(
                                              imageUrl: filteredLibraries[index]
                                                  .book!
                                                  .imageUrl,
                                              fit: BoxFit.cover,
                                              placeholder: (context, url) =>
                                                  const CircularProgressIndicator(),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      const Icon(Icons.error),
                                              height: 300,
                                              width: 200,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Flexible(
                                            child: Container(
                                              height: double.infinity,
                                              width: double.infinity,
                                              padding: const EdgeInsets.only(
                                                  bottom:
                                                      8.0), // Add more padding to the bottom
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets
                                                        .only(
                                                        bottom: 8.0,
                                                        right:
                                                            2), // Add padding to create space below the title
                                                    child: Text(
                                                      snapshot.data![index]
                                                          .book!.title,
                                                      style: const TextStyle(
                                                          fontSize: 16,
                                                          color: Colors.white),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines:
                                                          1, // Allow up to two lines
                                                    ),
                                                  ),
                                                  Text(
                                                    'Author: ${snapshot.data![index].book!.publisher}', // Correctly display the author's name
                                                    softWrap: true,
                                                    style: const TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.white),
                                                  ),
                                                  const Spacer(),
                                                  FutureBuilder<int?>(
                                                    future: _fetchBookmark(
                                                        snapshot.data![index]
                                                            .book!.id!),
                                                    builder: (context,
                                                        bookmarkSnapshot) {
                                                      if (bookmarkSnapshot
                                                              .connectionState ==
                                                          ConnectionState
                                                              .waiting) {
                                                        return const CircularProgressIndicator();
                                                      } else if (bookmarkSnapshot
                                                          .hasError) {
                                                        return const Text(
                                                          'Error',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 18),
                                                        );
                                                      } else {
                                                        int currentPage =
                                                            bookmarkSnapshot
                                                                    .data ??
                                                                0;
                                                        return Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  vertical: 4,
                                                                  horizontal:
                                                                      8),
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                            color: currentPage ==
                                                                    snapshot
                                                                        .data![
                                                                            index]
                                                                        .book!
                                                                        .numberOfPages
                                                                ? Colors
                                                                    .green[400]
                                                                : Colors
                                                                    .red[400],
                                                          ),
                                                          child: Text(
                                                            style:
                                                                const TextStyle(
                                                                    color: Colors
                                                                        .white),
                                                            currentPage ==
                                                                    snapshot
                                                                        .data![
                                                                            index]
                                                                        .book!
                                                                        .numberOfPages
                                                                ? 'Completed'
                                                                : 'Incomplete',
                                                          ),
                                                        );
                                                      }
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 24,),
                                          InkWell(
                                            onTap: () {
                                              int bookId = snapshot
                                                  .data![index].book!.id!;
                                              int totalPages = snapshot
                                                  .data![index]
                                                  .book!
                                                  .numberOfPages;
                                              showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return Theme(
                                                    data: Theme.of(context)
                                                        .copyWith(
                                                      dialogBackgroundColor:
                                                          const Color.fromARGB(
                                                              255,
                                                              42,
                                                              75,
                                                              102), // Set the dialog background color
                                                    ),
                                                    child: AlertDialog(
                                                      title: const Text(
                                                        'Update Bookmark',
                                                        style: TextStyle(
                                                            color: Colors
                                                                .white), // Set title text color to white
                                                      ),
                                                      content: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        8.0),
                                                            child: TextField(
                                                              controller:
                                                                  _pageController,
                                                              keyboardType:
                                                                  TextInputType
                                                                      .number,
                                                              decoration:
                                                                  InputDecoration(
                                                                hintText:
                                                                    'Enter current page',
                                                                hintStyle: const TextStyle(
                                                                    color: Colors
                                                                        .grey), // Set hint text color to grey
                                                                filled: true,
                                                                fillColor: const Color
                                                                    .fromARGB(
                                                                    255,
                                                                    42,
                                                                    75,
                                                                    102), // Match the dialog's background color
                                                                border:
                                                                    OutlineInputBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8.0),
                                                                  borderSide:
                                                                      BorderSide
                                                                          .none,
                                                                ),
                                                              ),
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .white), // Set the text color to white
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.of(
                                                                      context)
                                                                  .pop(),
                                                          child: const Text(
                                                            'Cancel',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white), // Set button text color to white
                                                          ),
                                                        ),
                                                        TextButton(
                                                          onPressed: () async {
                                                            int currentPage =
                                                                int.tryParse(
                                                                        _pageController
                                                                            .text) ??
                                                                    0;
                                                            await _saveBookmark(
                                                                bookId,
                                                                currentPage,
                                                                totalPages);
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                          child: const Text(
                                                            'Update Bookmark',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white), // Set button text color to white
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                            child: FutureBuilder<int?>(
                                              future: _fetchBookmark(snapshot
                                                  .data![index].book!.id!),
                                              builder:
                                                  (context, bookmarkSnapshot) {
                                                if (bookmarkSnapshot
                                                        .connectionState ==
                                                    ConnectionState.waiting) {
                                                  return const CircularProgressIndicator();
                                                } else if (bookmarkSnapshot
                                                    .hasError) {
                                                  return const Text(
                                                    'Error',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 18),
                                                  );
                                                } else {
                                                  int currentPage =
                                                      bookmarkSnapshot.data ??
                                                          0;
                                                  return Container(
                                                    width: 100,
                                                    height: 100,
                                                    child: Text(
                                                      "$currentPage / ${snapshot.data![index].book!.numberOfPages.toString()} \nPages",
                                                      style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 18),
                                                    ),
                                                  );
                                                }
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )),
                      );
                    }
                  })
            ],
          );

    if (_selectedPageIndex == 1) {
      activePage = Container(
        child: Column(
          children: [
              const Padding(
              padding:   EdgeInsets.only(left: 12, right: 32, top: 24),
              child: SizedBox(
                child: Row(
                  children: [
                      Text(
                      'Your Booklists',
                      style: TextStyle(color: Colors.white, fontSize: 24),
                    ),
                  ],
                ),
              ),
            ),
            FutureBuilder(
                future: booklists,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                        child: Container(
                            alignment: Alignment.center,
                            child: const Text(
                              'No booklists found',
                              style: TextStyle(color: Colors.white),
                            )));
                  } else {
                    return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        constraints: const BoxConstraints(
                          maxHeight: 580,
                        ),
                        child: GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              childAspectRatio: 1.1,
                              crossAxisCount: 2,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                            ),
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              Booklist booklist = snapshot.data![index];
                              if (booklist.books.isEmpty) {
                                return InkWell(
                                  onLongPress: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Delete Booklist'),
                                        content: const Text(
                                            'Are you sure you want to delete this booklist?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              await apiService
                                                  .deleteBooklist(booklist.id);
                                              _initializeBooklistUser();
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text('Delete'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  child: InkWell(
                                    onTap: () async {
                                    await Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                Booklistbookscreen(
                                                  onBookRemoved:_handleBookRemoved,
                                                  booklistName: booklist.name,
                                                  books: booklist.books.map((book) => book).toList(),
                                                  booklistId: booklist.id,
                                                  isPublic: booklist.isPublic,
                                                )));
                                        _initializeBooklistUser();
                                  },
                                    child: Container(
                                        child: Column(
                                      children: [
                                        Container(
                                          height: 120,
                                          width: 120,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              color: Colors.white),
                                          child: const Center(
                                              child: Text(
                                            'No books in booklist',
                                            textAlign: TextAlign.center,
                                          )),
                                        ),
                                        const SizedBox(
                                          height: 8,
                                        ),
                                        Text(
                                          maxLines: 1,
                                          overflow:TextOverflow.ellipsis,
                                          booklist.name,
                                          style: const TextStyle(
                                              color: Colors.white),
                                        )
                                      ],
                                    )),
                                  ),
                                );
                              } else {
                                return InkWell(
                                  onLongPress: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Delete Booklist'),
                                        content: const Text(
                                            'Are you sure you want to delete this booklist?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              await apiService
                                                  .deleteBooklist(booklist.id);
                                              _initializeBooklistUser();
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text('Delete'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  onTap: () async {
                                    await Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                Booklistbookscreen(
                                                  onBookRemoved:_handleBookRemoved,
                                                  booklistName: booklist.name,
                                                  books: booklist.books.map((book) => book).toList(),
                                                  booklistId: booklist.id,
                                                  isPublic: booklist.isPublic,
                                                )));
                                        _initializeBooklistUser();
                                  },
                                  child: Container(
                                      child: Column(
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            width: 120,
                                            height: 120,
                                            child: CachedNetworkImage(
                                                placeholder: (context, url) =>
                                                    const CircularProgressIndicator(),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        const Icon(
                                                          Icons.error,
                                                          color: Colors.white,
                                                        ),
                                                fit: BoxFit.cover,
                                                imageUrl:booklist.books[0].imageUrl),
                                          ),
                                          const SizedBox(
                                            height: 8,
                                          ),
                                          Container(
                                            child: Text(
                                              booklist.name,
                                              maxLines: 1,
                                              overflow:TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  color: Colors.white),
                                            ),
                                          )
                                        ],
                                      ),
                                    
                                  ),
                                );
                              }
                            }
                          )
                        );
                  }
                }
              )
          ],
        ),
      );
    }

    if (_selectedPageIndex == 2) {
      activePage = Column(
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 12, right: 12, top: 24),
            child: SizedBox(
              width: double.infinity,
              child: Text(
                'Books You Added',
                textAlign: TextAlign.start,
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
          ),
          FutureBuilder(
              future: AddededBooks,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text('Error ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                      child: Container(
                          alignment: Alignment.center,
                          height: 500,
                          child: const Text(
                            "User have not Addeded any books",
                            style: TextStyle(color: Colors.white),
                          )));
                } else {
                  return Container(
                    padding: const EdgeInsets.all(12),
                    constraints: const BoxConstraints(
                      maxHeight: 580,
                    ),
                    child: ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (ctx, index) => Padding(
                              padding: const EdgeInsets.only(bottom: 24),
                              child: InkWell(
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => Testbookdetail(
                                          book: snapshot.data![index])));
                                },
                                child: Container(
                                  height: 100,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 70,
                                        height: double.infinity,
                                        child: CachedNetworkImage(
                                          height: 80,
                                          fit: BoxFit.cover,
                                          imageUrl: snapshot.data![index].imageUrl,
                                          placeholder: (context, url) => const CircularProgressIndicator(),
                                          errorWidget: (context, url, error) => const Icon(
                                      Icons.error,
                                      color: Colors.white,
                                    ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Flexible(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Container(
                                              child: Text(
                                                  snapshot.data![index].title,
                                                  textAlign: TextAlign.start,
                                                  maxLines: 1,
                                                  style: const TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.white)),
                                            ),
                                            const SizedBox(
                                              height: 4,
                                            ),
                                            Container(
                                              child: Text(
                                                'Author: ${snapshot.data![index].publisher}',
                                                style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.white),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )),
                  );
                }
              })
        ],
      );
    }
    if (_selectedPageIndex == 3) {
      activePage = Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 12, right: 12, top: 24),
            child: SizedBox(
              width: double.infinity,
              child: Row(
                children: [
                  const Text(
                    'Add Books to \nBooklist',
                    textAlign: TextAlign.start,
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                  const Spacer(),
                  Opacity(
                    opacity: selectedBooks.isNotEmpty ? 1 : 0.5,
                    child: InkWell(
                      onTap: () {
                        if (selectedBooks.isNotEmpty) {
                          _showBooklistDialog();
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 6, horizontal: 12),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white),
                        child: const Text('Add to Booklist',
                            style: TextStyle(color: Colors.black)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          FutureBuilder(
              future: libraries,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text('Error ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No books available'));
                } else {
                  return Container(
                    padding: const EdgeInsets.all(12),
                    constraints: const BoxConstraints(
                      maxHeight: 500,
                    ),
                    child: ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (ctx, index) => Padding(
                              padding: const EdgeInsets.only(bottom: 30),
                              child: GestureDetector(
                                onTap: () {
                                  _toggleSelection(snapshot.data![index]);
                                },
                                child: Container(
                                  color: selectedBooks
                                          .contains(snapshot.data![index])
                                      ? Colors.blue.withOpacity(0.5)
                                      : const Color.fromARGB(0, 224, 224, 224),
                                  height: 100,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 75,
                                        height: double.infinity,
                                        child: CachedNetworkImage(
                                          imageUrl: snapshot
                                              .data![index].book!.imageUrl,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) =>
                                              const CircularProgressIndicator(),
                                          errorWidget: (context, url, error) =>
                                              const Icon(Icons.error),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Flexible(
                                        child: Container(
                                          height: double.infinity,
                                          width: double.infinity,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        snapshot.data![index]
                                                            .book!.title,
                                                        style: const TextStyle(
                                                            fontSize: 16,
                                                            color:
                                                                Colors.white),
                                                        maxLines:
                                                            1, // Limit to 2 lines
                                                        overflow: TextOverflow
                                                            .ellipsis, // Add ellipsis if text overflows
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 4,
                                              ),
                                              Text(
                                                'Author: ${snapshot.data![index].book!.publisher}',
                                                softWrap: true,
                                                style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.white),
                                                overflow: TextOverflow
                                                    .ellipsis, // Add ellipsis if text overflows
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )),
                  );
                }
              })
        ],
      );
    }
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2C3E50), Color(0xFF000000)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 64),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  padding:
                      const EdgeInsetsDirectional.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      const Text(
                        'Your Collection',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      const Text(
                        'Create New Booklist',
                        style: TextStyle(color: Colors.white),
                      ),
                      IconButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => Theme(
                              data: Theme.of(context).copyWith(
                                dialogBackgroundColor:
                                    Color.fromARGB(255, 44, 71, 94),
                              ),
                              child: AlertDialog(
                                title: const Text(
                                  'Create a Booklist',
                                  style: TextStyle(color: Colors.white),
                                ),
                                content: Form(
                                  key: _formKey,
                                  child: TextFormField(
                                    controller: _booklistname,
                                    decoration: const InputDecoration(
                                      hintText: 'Enter Booklist Name',
                                      hintStyle:
                                          TextStyle(color: Colors.white54),
                                    ),
                                    style: const TextStyle(color: Colors.white),
                                    validator: (value) {
                                      if (value == null || value.isEmpty ) {
                                        return 'Please enter a name';
                                      } else if (value.length > 24)
                                      { 
                                        return "Boolist name shouldn't be more tha 24 characters";
                                      } else {
                                      return null;
                                      }
                                    },
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text(
                                      'Cancel',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      if (_formKey.currentState!.validate()) {
                                        await apiService.createBooklist(_booklistname.text);
                                        await _initializeBooklistUser();
                                        Navigator.of(context).pop();
                                      } else {
                                        print('User Not Found');
                                      }
                                    },
                                    child: const Text(
                                      'Create',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.add,
                          size: 32,
                        ),
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () {
                          _selectPage(_selectedPageIndex == 0 ? 1 : 0);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 6, horizontal: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: _selectedPageIndex == 1
                                ? Colors.white
                                : Colors.black,
                          ),
                          child: Text('Booklist',
                              style: TextStyle(
                                  color: _selectedPageIndex == 1
                                      ? Colors.black
                                      : Colors.white)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      InkWell(
                        onTap: () {
                          _selectPage(_selectedPageIndex == 0 ? 2 : 0);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 6, horizontal: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: _selectedPageIndex == 2
                                ? Colors.white
                                : Colors.black,
                          ),
                          child: Text('Book You Added',
                              style: TextStyle(
                                  color: _selectedPageIndex == 2
                                      ? Colors.black
                                      : Colors.white)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      InkWell(
                        onTap: () {
                          _selectPage(_selectedPageIndex == 0 ? 3 : 0);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 6, horizontal: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: _selectedPageIndex == 3
                                ? Colors.white
                                : Colors.black,
                          ),
                          child: Text('Select Book',
                              style: TextStyle(
                                  color: _selectedPageIndex == 3
                                      ? Colors.black
                                      : Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
                activePage,
              ],
            ),
          ),
        ),
      ),
    );
  }
}


  // void _togglePublicPrivate() {
  //   setState(() {
  //     _isPublic = !_isPublic;
  //     booklists = apiService.fetchBooklistsByUserId(userId, isPublic: _isPublic);
  //   });
  // }
  // void _updateBooklistVisibility(String newValue) {
  //   setState(() {
  //     dropdownValue = newValue;
  //     _isPublic = newValue == 'Public';
  //     if (userId.isNotEmpty) {
  //       if (newValue == 'All Booklist') {
  //         booklists = 
  //       }
  //       booklists = apiService.fetchBooklistsByUserId(userId, isPublic: _isPublic);
  //     }
  //   });
  // }
// Future<void> _initializeBooklistUser() async {
  //   User? user = await getUser();
  //   if (user != null) {
  //     setState(() {
  //       booklists = apiService.fetchBooklists();
  //       booklists!.then((list) {}).catchError((error) {
  //         if (error is EmptyLibraryException) {
  //           print("The Library is Empty");
  //           setState(() {
  //             _libraryErrorMessage = error.message;
  //           });
  //         }
  //       });
  //     });
  //   } else {
  //     setState(() {
  //       booklists = Future.error('User Not found');
  //     });
  //   }
  // }
  // DropdownButton<String>(
                    //   value: dropdownValue,
                    //   onChanged: (String? newValue) {
                    //     if (newValue != null) {
                    //       _updateBooklistVisibility(newValue);
                    //     }
                    //   },
                    //   items: <String>['All Booklist','Public', 'Private']
                    //       .map<DropdownMenuItem<String>>((String value) {
                    //     return DropdownMenuItem<String>(
                    //       value: value,
                    //       child: Text(value),
                    //     );
                    //   }).toList(),
                    // ),
                    // InkWell(
                    //   onTap: _togglePublicPrivate,
                    //   child: Container(
                    //     decoration: BoxDecoration(
                    //       borderRadius: BorderRadius.circular(20),
                    //       color: Colors.black,
                    //     ),
                    //     padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                    //     child: Row(
                    //       children: [
                    //         Text(_isPublic ? 'Public' : 'Private', style: const TextStyle(
                    //           color: Colors.white
                    //         ),),
                    //         const SizedBox(width: 4,),
                    //         Icon(_isPublic ? Icons.roundabout_right_rounded : Icons.lock, color: Colors.white,)
                    //       ],
                    //     ),
                    //   ),
                    // ),