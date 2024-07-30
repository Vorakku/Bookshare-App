import 'dart:convert';

import 'package:bookshare/tests/models/book.dart';
import 'package:bookshare/tests/models/user.dart';
import 'package:bookshare/tests/screens/homepagetest.dart';
import 'package:bookshare/tests/screens/testbookdetail.dart';
import 'package:bookshare/tests/utils/api_service.dart';
import 'package:bookshare/tests/utils/user_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

// import 'dart:convert';

class TestAddBook extends StatefulWidget {
  const TestAddBook({super.key});

  @override
  State<TestAddBook> createState() => _TestAddBookState();
}

class _TestAddBookState extends State<TestAddBook> {
  final TextEditingController _searchController = TextEditingController();
  late Future<List<Book>> futureBooks;
  List<Book> _filteredBooks = [];

  Future<List<String>> fetchBookTitle(String query) async {
    final token = await storage.read(key: 'auth_token');
    final response = await http.get(
      Uri.parse('${dotenv.env['API_URL']}/get_books_title'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      List<String> titles = data.map((title) => title as String).toList();
      return titles
          .where((titles) => titles.toLowerCase().contains(query.toLowerCase()))
          .toList();
      // return data.map((title) => title as String).toList();
    } else {
      throw Exception('Failed to load book titles');
    }
  }

  @override
  void initState() {
    super.initState();
    futureBooks = fetchAllBooks(); // Assume this fetches all books initially
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
          return matchesQuery == query;
        }).toList();
      });
    });
  }

  // late Genre _selectGenre;
  Genre? _selectGenre;
  // = Genre.adventure;
  Language? _selectLanguage;
  // = Language.english;

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100));
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _publishdateController.text = DateFormat('MM/dd/yyyy').format(picked);
      });
    }
  }

  Future<void> addBook(Book book) async {
    final token = await storage.read(key: 'auth_token');

    // Create the multipart request
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('${dotenv.env['API_URL']}/addbooks'),
    );

    // Add headers
    request.headers.addAll({
      'Content-Type': 'multipart/form-data',
      'Authorization': 'Bearer $token'
    });

    // Add fields
    request.fields['title'] = book.title;
    request.fields['description'] = book.description;
    request.fields['isbn'] = book.isbn;
    request.fields['genre'] = book.genre.toString().split('.').last;
    request.fields['publisher'] = book.publisher;
    request.fields['publishdate'] =
        DateFormat('MM/dd/yyyy').format(book.publishdate);
    request.fields['number_of_pages'] = book.numberOfPages.toString();
    request.fields['language'] = book.language.toString().split('.').last;
    request.fields['status'] = book.status.toString();

    // Add file if present
    if (_image != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          _image!.path,
        ),
      );
    }

    // Send the request
    try {
      var response = await request.send();

      var responseBody = await response.stream.bytesToString();
      print('Response status: ${response.statusCode}');
      print('Response body: $responseBody');

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Book added successfully')));
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const MyHomePageTest()));
      } else if (response.statusCode == 422) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('The title or isbn has already been taken')));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Failed to add book')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error sending request: $e')));
    }
  }

  final _formKey = GlobalKey<FormState>();
  File? _image;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _isbnController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _publisherController = TextEditingController();
  final _publishdateController = TextEditingController();
  final _numberOfPagesController = TextEditingController();
  final int _status = 0;
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromARGB(255, 44, 59, 74), Color(0xFF000000)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            AppBar(
              automaticallyImplyLeading: false,
              iconTheme: const IconThemeData(color: Colors.white),
              backgroundColor: Color.fromARGB(0, 244, 240, 240),
              elevation: 0,
              title:
                  const Text(style: TextStyle(color: Colors.white), 'Add Book'),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //Image
                        Container(
                          width: double.infinity,
                          height: 180,
                          color: const Color.fromRGBO(77, 77, 97, 100),
                          child: InkWell(
                            onTap: _pickImage,
                            child: _image == null
                                ? const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Upload Book Cover',
                                        style: TextStyle(
                                            fontSize: 14, color: Colors.white),
                                      ),
                                      SizedBox(height: 12),
                                      Icon(
                                        Icons.add,
                                        color: Colors.white,
                                        size: 28,
                                      )
                                    ],
                                  )
                                : Image.file(
                                    _image!,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        //Image

                        //Book Title
                        const Text(
                          'Title',
                          style: TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        Container(
                            padding: const EdgeInsets.only(left: 12),
                            decoration: const BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              color: Color.fromRGBO(77, 77, 97, 100),
                            ),
                            child: 
                                Autocomplete<String>(
                  optionsBuilder: (TextEditingValue textEditingValue) async {
                    if (textEditingValue.text == '') {
                      return const Iterable<String>.empty();
                    }
                    // Fetch all books and filter based on the query
                    List<Book> books = await fetchAllBooks();
                    return books
                        .where((book) => book.title.toLowerCase().contains(textEditingValue.text.toLowerCase()))
                        .map((book) => book.title)
                        .toList();
                  },
                  onSelected: (String selection) async {
                    // Fetch all books to find the selected book
                    List<Book> books = await fetchAllBooks();
                    Book selectedBook = books.firstWhere((book) => book.title == selection);
                    // Navigate to the book detail page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Testbookdetail(book: selectedBook),
                      ),
                    );
                  },
                  fieldViewBuilder: (BuildContext context, TextEditingController textEditingController, FocusNode focusNode, VoidCallback onFieldSubmitted) {
                    return TextField(
                      controller: textEditingController,
                      focusNode: focusNode,
                      decoration: InputDecoration(
                        hintText: 'Search books...',
                        hintStyle: const TextStyle(color: Colors.grey),
                        prefixIcon: const Icon(Icons.search, color: Colors.grey),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    );
                  },
                  optionsViewBuilder: (BuildContext context, AutocompleteOnSelected<String> onSelected, Iterable<String> options) {
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Material(
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.8,
                          color: Colors.white,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(10.0),
                            itemCount: options.length,
                            itemBuilder: (BuildContext context, int index) {
                              final String option = options.elementAt(index);
                              return GestureDetector(
                                onTap: () {
                                  onSelected(option);
                                },
                                child: ListTile(
                                  title: Text(option),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                )  
              ),
                        

                        //Book Title

                        const SizedBox(height: 8),

                        //ISBN
                        const Text(
                          'ISBN (International Standard Book)',
                          style: TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.only(left: 12),
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            color: Color.fromRGBO(77, 77, 97, 100),
                          ),
                          child: TextFormField(
                            controller: _isbnController,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                                focusColor: Colors.white,
                                border: InputBorder.none,
                                hintText: 'Book isbn',
                                hintStyle: TextStyle(color: Colors.white70)),
                          ),
                        ),
                        //ISBN

                        const SizedBox(height: 8),

                        Row(
                          children: [
                            //Publisher
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Publisher',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.only(left: 12),
                                    decoration: const BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(10)),
                                      color: Color.fromRGBO(77, 77, 97, 100),
                                    ),
                                    child: TextFormField(
                                      controller: _publisherController,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter a publisher';
                                        }
                                        return null;
                                      },
                                      style:
                                          const TextStyle(color: Colors.white),
                                      decoration: const InputDecoration(
                                          focusColor: Colors.white,
                                          border: InputBorder.none,
                                          hintText: 'Author name',
                                          hintStyle:
                                              TextStyle(color: Colors.white70)),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                ],
                              ),
                            ),
                            //Publisher

                            const SizedBox(width: 24),

                            //Publish Date
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Publish Date',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.only(left: 12),
                                    decoration: const BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(10)),
                                      color: Color.fromRGBO(77, 77, 97, 100),
                                    ),
                                    child: TextFormField(
                                      controller: _publishdateController,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter a publish date';
                                        }
                                        return null;
                                      },
                                      style:
                                          const TextStyle(color: Colors.white),
                                      decoration: InputDecoration(
                                          suffixIcon: IconButton(
                                              onPressed: () =>
                                                  _selectDate(context),
                                              icon: const Icon(
                                                  Icons.calendar_today)),
                                          focusColor: Colors.white,
                                          border: InputBorder.none,
                                          hintText: 'MM/DD/YYYY',
                                          hintStyle: const TextStyle(
                                              color: Colors.white70)),
                                      keyboardType: TextInputType.datetime,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                ],
                              ),
                            ),
                            //Publish Date
                          ],
                        ),

                        Row(
                          children: [
                            //Genre
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Genre',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  Container(
                                    child: DropdownButtonFormField(
                                        dropdownColor: const Color.fromRGBO(
                                            77, 77, 97, 100),
                                        hint: const Text(
                                          'Select Genre',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        value: _selectGenre,
                                        items: Genre.values
                                            .map((genre) => DropdownMenuItem(
                                                value: genre,
                                                child: Text(
                                                  genre.name.toString(),
                                                  style: const TextStyle(
                                                      color: Colors.white),
                                                )))
                                            .toList(),
                                        decoration: const InputDecoration(
                                            filled: true,
                                            fillColor:
                                                Color.fromRGBO(77, 77, 97, 100),
                                            border: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(10)))),
                                        onChanged: (value) {
                                          if (value == null) {
                                            return;
                                          }
                                          setState(() {
                                            _selectGenre = value;
                                          });
                                        }),
                                  ),
                                ],
                              ),
                            ),
                            //Genre

                            const SizedBox(
                              width: 24,
                            ),

                            //Numner of pages
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Number of Pages',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.only(left: 12),
                                    decoration: const BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(10)),
                                      color: Color.fromRGBO(77, 77, 97, 100),
                                    ),
                                    child: TextFormField(
                                      controller: _numberOfPagesController,
                                      keyboardType: TextInputType.number,
                                      style:
                                          const TextStyle(color: Colors.white),
                                      decoration: const InputDecoration(
                                          focusColor: Colors.white,
                                          border: InputBorder.none,
                                          hintText: 'Number of Pages',
                                          hintStyle:
                                              TextStyle(color: Colors.white70)),
                                    ),
                                  ),
                                ],
                              ),
                            )
                            //Numner of pages
                          ],
                        ),

                        const SizedBox(height: 8),

                        //Language
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Language',
                              style: TextStyle(color: Colors.white),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField(
                                hint: const Text(
                                  "Select Language",
                                  style: TextStyle(color: Colors.white),
                                ),
                                dropdownColor:
                                    const Color.fromRGBO(77, 77, 97, 100),
                                value: _selectLanguage,
                                items: Language.values
                                    .map((language) => DropdownMenuItem(
                                        value: language,
                                        child: Text(
                                          language.name.toString(),
                                          style: const TextStyle(
                                              color: Colors.white),
                                        )))
                                    .toList(),
                                decoration: const InputDecoration(
                                    filled: true,
                                    fillColor: Color.fromRGBO(77, 77, 97, 100),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10)))),
                                onChanged: (value) {
                                  if (value == null) {
                                    return;
                                  }
                                  setState(() {
                                    _selectLanguage = value;
                                  });
                                }),
                          ],
                        ),
                        //Language

                        const SizedBox(height: 8),

                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Description and Summary',
                              style: TextStyle(color: Colors.white),
                            ),
                            const SizedBox(height: 3),
                            Container(
                              height: 100,
                              padding: const EdgeInsets.only(left: 12),
                              decoration: const BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                color: Color.fromRGBO(77, 77, 97, 100),
                              ),
                              child: TextFormField(
                                minLines: 1,
                                maxLines: 50,
                                controller: _descriptionController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please input some description related to the book';
                                  }
                                  return null;
                                },
                                style: const TextStyle(color: Colors.white),
                                decoration: const InputDecoration(
                                    focusColor: Colors.white,
                                    border: InputBorder.none,
                                    hintText:
                                        'Write description about the book',
                                    hintStyle:
                                        TextStyle(color: Colors.white70)),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                              child: Container(
                                decoration: const BoxDecoration(
                                    color: Colors.black,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 20),
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                            const SizedBox(width: 24),
                            InkWell(
                              onTap: () async {
                                if (_formKey.currentState!.validate()) {
                                  User? user = await getUser();
                                  if (user == null) {
                                    // Handle error: user not logged in
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content:
                                                Text('User not logged in')));
                                    return;
                                  }
                                  Book newBook = Book(
                                    // id: '',
                                    title: _titleController.text,
                                    description: _descriptionController.text,
                                    isbn: _isbnController.text,
                                    imageUrl: _imageUrlController.text,
                                    genre: _selectGenre!,
                                    publisher: _publisherController.text,
                                    publishdate: DateFormat('MM/dd/yyyy')
                                        .parse(_publishdateController.text),
                                    numberOfPages: int.parse(
                                        _numberOfPagesController.text),
                                    language: _selectLanguage!,
                                    status: _status,
                                    user: user, // Use non-nullable user here
                                  );

                                  try {
                                    await addBook(newBook);
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content:
                                                Text('Failed to add book')));
                                  }
                                }
                              },
                              child: Container(
                                decoration: const BoxDecoration(
                                    color: Color.fromRGBO(80, 136, 167, 100),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 20),
                                child: const Text(
                                  'Confirm',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 36,
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


                    // Autocomplete<Book>( 
                    //   optionsBuilder: (TextEditingValue textEditingValue) async {
                    //     if (textEditingValue.text == ''){
                    //       return const Iterable<Book>.empty();
                    //     }
                    //     return await fetchBookTitle(textEditingValue.text);
                    //   },
                    //   // onSelected: (String selection){
                    //   //   _titleController.text = selection;
                    //   // },
                    //     onSelected: (Book selection){
                    //       Navigator.of(context).push(MaterialPageRoute(builder: (context) => const Testbookdetail(book:)));            
                    //   },
                    //   fieldViewBuilder: (BuildContext context, TextEditingController textEditingController, FocusNode focusNode, VoidCallback onFieldSubmitted){
                    //     _titleController.addListener((){
                    //       textEditingController.value = _titleController.value;
                    //     });
                    //     return TextFormField(
                    //       controller: _titleController,
                    //       focusNode: focusNode,
                    //       onFieldSubmitted: (String value){
                    //         onFieldSubmitted();
                    //       },
                    //       decoration: const InputDecoration(
                    //         border: InputBorder.none,
                    //         hintText: 'Book Title',
                    //         hintStyle: TextStyle(color: Colors.white70),
                    //       ),
                    //       validator: (value) {
                    //         if (value == null || value.isEmpty) {
                    //           return 'Please enter a title';
                    //         }
                    //       return null;
                    //       },
                    //       style: const TextStyle(color: Colors.white),
                    //     );
                    //   },
                    //   optionsViewBuilder: (BuildContext context, AutocompleteOnSelected<String> onSelected, Iterable<String> options) {
                    //     return Align(
                    //       alignment: Alignment.topLeft,
                    //       child: Material(
                    //         child: Container(
                    //           width: MediaQuery.of(context).size.width * 0.8,
                    //           color: Colors.white,
                    //             child: ListView.builder(
                    //               padding: EdgeInsets.all(10.0),
                    //               itemCount: options.length,
                    //               itemBuilder: (BuildContext context, int index) {
                    //                 final String option = options.elementAt(index);
                    //                   return GestureDetector(
                    //                     onTap: () {
                    //                       onSelected(option);
                    //                     },
                    //                     child: ListTile(
                    //                       title: Text(option),
                    //                     ),
                    //                   );
                    //               }
                    //             )
                    //         ),
                    //       ),
                    //     );
                    //   },
          
                    // )