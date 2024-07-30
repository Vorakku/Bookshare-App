import 'package:bookshare/tests/screens/testbookdetail.dart';
import 'package:bookshare/tests/utils/api_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../models/book.dart';

class Displaybook extends StatefulWidget {
  const Displaybook({super.key});

  @override
  State<Displaybook> createState() => _DisplaybookState();
}

class _DisplaybookState extends State<Displaybook> {
  final ApiService apiService = ApiService();
  late Future<List<Book>> topLikedBooks;

  @override
  void initState() {
    topLikedBooks = apiService.getTopLikeBooks();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Book>>(
      future: topLikedBooks,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Failed to load books'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No books available'));
        } else {
          return Row(
            children: [
              Flexible(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: snapshot.data!.length,
                  itemBuilder: (ctx, index) {
                    Book book = snapshot.data![index];
                    return InkWell(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => Testbookdetail(book: book),
                        ));
                      },
                      child: Container(
                        width: 150,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Center(
                          child: Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                clipBehavior: Clip.hardEdge,
                                child: CachedNetworkImage(
                                  height: 160,
                                  width: 115,
                                  imageUrl: book.imageUrl,
                                  placeholder: (context, url) =>
                                      const CircularProgressIndicator(),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                textAlign: TextAlign.center,
                                _trimTitle(book.title),
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 12),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }
      },
    );
  }

  String _trimTitle(String title) {
    if (title.length > 15) {
      return title.substring(0, 15) + '...';
    }
    return title;
  }
}
