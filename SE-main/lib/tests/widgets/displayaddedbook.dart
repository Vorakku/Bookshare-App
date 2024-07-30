import 'package:flutter/material.dart';
import 'package:bookshare/tests/models/book.dart';

class Displayaddedbook extends StatefulWidget {
  const Displayaddedbook({super.key, required this.book});

  final Book book;

  @override
  State<Displayaddedbook> createState() => _DisplayaddedbookState();
}

class _DisplayaddedbookState extends State<Displayaddedbook> {
  @override
  Widget build(BuildContext context) {
    return Column(
    children: [
       Image.network(
          height: 150, 
          width: 100,
          widget.book.imageUrl,
          errorBuilder: (context, error, stackTree){
            return const Text('Failed to load image');
          },
        ),
      const SizedBox(height: 12),
      Flexible(
        child: Text(
          widget.book.title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.white
          ),
        ),
      )
      ]
    );
  }
}

 // return Container(     
    //         height: 350,
    //         width: double.infinity,
    //         child: Column(
    //           crossAxisAlignment: CrossAxisAlignment.center,
    //           children: [
    //             Image.network(height: 150, width: 100, widget.book.imageUrl,
    //                 errorBuilder: (context, error, stackTrace) {
    //               return const Text('Failed to load Image');
    //             }),
    //             const SizedBox(height: 24),
    //             Text(widget.book.title, 
    //             textAlign: TextAlign.center,
    //             style: const TextStyle(
    //               color: Colors.white
    //             ),)
    //           ],
    //         ),
    //       );