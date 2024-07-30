import 'package:bookshare/tests/screens/testbookdetail.dart';
import 'package:bookshare/tests/utils/api_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../models/book.dart';

class DisplayRecommendBook extends StatefulWidget {
  const DisplayRecommendBook({super.key});

  @override
  State<DisplayRecommendBook> createState() => _DisplayRecommendBookState();
}

class _DisplayRecommendBookState extends State<DisplayRecommendBook> {
  final ApiService apiService = ApiService();
  late Future<List<Book>> recentBooks;
  int currentPage = 1;
  final int booksPerPage = 6;
  final PageController _pageController = PageController();

  @override
  void initState() {
    recentBooks = apiService.getRecentBooks();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Book>>(
      future: recentBooks,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('No recent books found'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No recent books found'));
        } else {
          List<Book> books = snapshot.data!;
          int totalPages = (books.length / booksPerPage).ceil();
          List<Book> booksToDisplay = books.skip((currentPage - 1) * booksPerPage).take(booksPerPage).toList();
          return Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      currentPage = index + 1;
                    });
                  },
                  itemCount: totalPages,
                  itemBuilder: (context, pageIndex) {
                    List<Book> booksToDisplay = books.skip(pageIndex * booksPerPage).take(booksPerPage).toList();
                    return GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.52,
                      ),
                      itemCount: booksToDisplay.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Testbookdetail(book: booksToDisplay[index]),
                              ),
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: CachedNetworkImage(
                                    imageUrl: booksToDisplay[index].imageUrl,
                                    placeholder: (context, url) => const CircularProgressIndicator(),
                                    errorWidget: (context, url, error) => const Icon(
                                      Icons.error,
                                      color: Colors.white,
                                    ),
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                height: 50,
                                width: double.infinity,
                                child: Text(
                                  booksToDisplay[index].title,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 8), // Add some space between the grid and the indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(totalPages, (index) {
                  return Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          currentPage = index + 1;
                          _pageController.jumpToPage(index);
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: currentPage == index + 1 ? Colors.blue : Colors.white,
                        ),
                        width: 10,
                        height: 10,
                      ),
                    ),
                  );
                }),
              ),
            ],
          );
        }
      },
    );
  }
}
