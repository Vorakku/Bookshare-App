import 'package:bookshare/tests/models/book.dart';
import 'package:flutter/material.dart';

class BookRow extends StatelessWidget {
  const BookRow({super.key, required this.bookImage, required this.bookName});

  final String bookImage;
  final String bookName;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(
        color: Colors.grey,
        width: 1,
      )),
      width: double.infinity,
      child: Row( 
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 120,
            height: 170,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: DecorationImage(
                image: NetworkImage(bookImage),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            bookName,
            softWrap: true,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          )
        ],
      ),
    );
  }
}
