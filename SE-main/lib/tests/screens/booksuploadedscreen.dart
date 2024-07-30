import 'package:bookshare/tests/models/book.dart';
import 'package:bookshare/tests/models/user.dart';
import 'package:bookshare/tests/screens/testbookdetail.dart';
import 'package:bookshare/tests/utils/api_service.dart';
import 'package:bookshare/tests/utils/user_storage.dart';
import 'package:flutter/material.dart';

class Booksuploadedscreen extends StatefulWidget {
  const Booksuploadedscreen({super.key});

  @override
  State<Booksuploadedscreen> createState() => _BooksuploadedscreenState();
}

class _BooksuploadedscreenState extends State<Booksuploadedscreen> {
late Future<List<Book>> futureBooks;


  @override
  void initState() { 
    super.initState();
    _initializeUser();
    // futureBooks = fetchBook();
  }

    Future<void> _initializeUser() async {
    User? user = await getUser();
    if (user != null) {
      String userId = user.id;
      print(userId);
      setState(() {
        futureBooks = fetchBook();
      });
    } else {
      print('User not found');
      setState(() {
        futureBooks = Future.error('User Not found'); 
        //Empty list
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Books Uploaded'),
      ),
      body: FutureBuilder<List<Book>>(
        future: futureBooks,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No books available'));
          } else {
            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisSpacing: 50,
                crossAxisCount: 2,
                childAspectRatio: 2 / 3,
              ),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final book = snapshot.data![index];
                return  InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Testbookdetail(book: book),
                      ),
                    );
                  },
                  child:  Column(
                    children: [
                      Expanded(
                        child: Container(
                          height: 200,
                          width: 200	,
                          child: Image.network(
                            book.imageUrl,
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4,),
                      Text(
                        book.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        book.id.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}