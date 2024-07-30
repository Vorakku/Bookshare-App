import 'package:bookshare/tests/models/book.dart';
import 'package:bookshare/tests/screens/testbookdetail.dart';
import 'package:bookshare/tests/utils/api_service.dart';
import 'package:bookshare/tests/widgets/sliderbutton.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class PublicBookInBooklist extends StatefulWidget {
  const PublicBookInBooklist({
    super.key,
    required this.book,
    required this.booklistId,
  });
  final Book book;
  final String booklistId;

  @override
  State<PublicBookInBooklist> createState() => _PublicBookInBooklistState();
}

ApiService apiService = ApiService();

class _PublicBookInBooklistState extends State<PublicBookInBooklist> {


  @override
  Widget build(BuildContext context) {
    return Container(
      margin:  EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => Testbookdetail(book: widget.book)));
            },
            child: Container(
              width: 70,
              child: CachedNetworkImage(
                imageUrl: widget.book.imageUrl,
                placeholder: (context, url) => const CircularProgressIndicator(),
                errorWidget: (context, url, error) => 
                  const Icon(Icons.error,color: Colors.white,),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.book.title,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
                Text(
                  'Author: ${widget.book.publisher}',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
