import 'package:bookshare/tests/models/booklist.dart';
import 'package:bookshare/tests/models/user.dart';
import 'package:bookshare/tests/screens/booklistbookscreen.dart';
import 'package:bookshare/tests/utils/api_service.dart';
import 'package:bookshare/tests/utils/user_storage.dart';
import 'package:flutter/material.dart';

class BooklistScreen extends StatefulWidget {
  const BooklistScreen({super.key});

  @override
  State<BooklistScreen> createState() => _BooklistScreenState();
}

class _BooklistScreenState extends State<BooklistScreen> {
  final ApiService apiService = ApiService();
  late Future<List<Booklist>>? booklists;

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    User? user = await getUser();
    if (user != null) {
      String userId = user.id;
      // int userId = int.tryParse(user.id) ?? 0;
      print(userId);
      setState(() {
        booklists = apiService.fetchBooklist();
      });
    } else {
      print('User not found');
      setState(() {
        booklists = Future.error('User Not found'); // Empty list
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return  FutureBuilder(
            future: booklists,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('No booklists found', style: TextStyle(color: Colors.white),));
              } else {
                return GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      Booklist booklist = snapshot.data![index];
                      if (booklist.books.isEmpty) {
                        return const Card(
                          child: Center(child: Text('No books in booklist')),
                        );
                      } else {
                        return InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => Booklistbookscreen(
                              booklistName: booklist.name,
                              books: booklist.books.map((book) => book).toList(),
                              booklistId: booklist.id,
                              isPublic: booklist.isPublic, // Ensure this line is included
                              onBookRemoved: (int value) {},
                            ),
                          ),
                        );
                      },
                          child: Card(
                            child: Container(
                              decoration: BoxDecoration(
                                boxShadow:  const [
                                  BoxShadow(
                                    color: Colors.grey,
                                    offset: Offset(0.0, 1.0), //(x,y)
                                    blurRadius: 6.0,
                                  ),
                                ],
                                borderRadius: const BorderRadius.all(Radius.circular(10)),
                                image: DecorationImage(
                                  image:
                                      NetworkImage(booklist.books[0].imageUrl),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              child: Center(child: Text(booklist.name)),
                            ),
                          ),
                        );
                      }
                    });
              }
            }
          );
      
  }
}
// print(booklist.name);
// subtitle: Text(booklist.books.map((book) => book.title).join('. ')),
             // ListView.builder(
                //   itemCount: snapshot.data!.length,
                //   itemBuilder: (context, index) {
                //     Booklist booklist = snapshot.data![index];
                //     return ListTile(
                //       title: Text(booklist.name),

                //     );
                //   },
                // )