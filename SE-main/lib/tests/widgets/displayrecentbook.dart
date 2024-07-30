import 'package:flutter/material.dart';
import '../models/book.dart';

class DisplayRecentbook extends StatefulWidget {
  const DisplayRecentbook({super.key, required this.books});

  final Book books;

  @override
  State<DisplayRecentbook> createState() => _DisplayRecentbookState();
}

  int status = 1;

class _DisplayRecentbookState extends State<DisplayRecentbook> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12,),
      height: 150,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(height: 150, width: 100, widget.books.imageUrl,
              errorBuilder: (context, error, stackTrace) {
            return const Text('Failed to load Image');
          }),
          const SizedBox(
            width: 12,
          ),
          Container(  
            width: MediaQuery.of(context).size.width * 0.6, //Static for now, will make dynamic later.
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Title: ${widget.books.title}',
                    style: const TextStyle(color: Colors.white, fontSize: 18)),
                const SizedBox(height: 12),
                Text('Total Page Read: 60/${widget.books.numberOfPages}',
                    style: const TextStyle(color: Colors.white)),
                // const SizedBox(height: 50),
                const Spacer(),
                Row(
                  children: [
                    const Text(
                      'Status: ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: widget.books.status == 1 ? const Color.fromARGB(255, 232, 15, 0) : const Color.fromARGB(255, 35, 232, 0),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: const Text(
                        'INCOMPLETE',
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
