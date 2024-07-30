// import 'package:bookshare/widget/reportform.dart';
// import 'package:bookshare/savebookto.dart';
// import 'package:flutter/material.dart';

// class ViewBook extends StatelessWidget {
//   final String title;
//   final String imageUrl;
//   final String genre;
//   final String publisher;
//   final int numberOfPages;
//   final String language;

//   const ViewBook({
//     required this.title,
//     required this.imageUrl,
//     required this.genre,
//     required this.publisher,
//     required this.numberOfPages,
//     required this.language,
//     Key? key,
//   }) : super(key: key);

//   void _saveBook(BuildContext context) {
//    showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       builder: (context) => Padding(
//         padding: EdgeInsets.only(
//           bottom: MediaQuery.of(context).viewInsets.bottom,
//         ),
//         child: SaveBookTo(),
//       ),
//     );
//   }

//    void _reportBook(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       builder: (context) => Padding(
//         padding: EdgeInsets.only(
//           bottom: MediaQuery.of(context).viewInsets.bottom,
//         ),
//         child: ReportForm(),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//         backgroundColor: const Color(0xFF23232C), // Ensure AppBar matches the theme
//         elevation: 0,
//       ),
//       backgroundColor: const Color(0xFF23232C), // Set a dark background for the entire page
//       body: SingleChildScrollView(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Image.asset('img/image.png', height: 300, fit: BoxFit.cover), // Make sure your image path is correct and image is appropriate
//             Container(
//               padding: const EdgeInsets.all(16.0),
//               color: const Color(0xFF23232C), // Ensure container uses theme color
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
//                   const SizedBox(height: 8),
//                   Text('Genre: $genre', style: TextStyle(fontSize: 14, color: Colors.grey[400])),
//                   Text('Publisher: $publisher', style: TextStyle(fontSize: 14, color: Colors.grey[400])),
//                   Text('Publication Date: N/A', style: TextStyle(fontSize: 14, color: Colors.grey[400])),
//                   Text('Number of Pages: $numberOfPages', style: TextStyle(fontSize: 14, color: Colors.grey[400])),
//                   Text('Language: $language', style: TextStyle(fontSize: 14, color: Colors.grey[400])),
//                   const SizedBox(height: 16),
//                   Text('Uploaded by:', style: TextStyle(color: Colors.grey[400])),
//                   Text('Username_01', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[400])),
//                   const SizedBox(height: 16),
//                   const Text('Description and summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
//                   Text('Lorem ipsum dolor sit amet, consectetur adipiscing elit...', style: TextStyle(fontSize: 14, color: Colors.grey[400])),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 20),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 IconButton(
//                   onPressed: () => _saveBook(context),
//                   icon: const Icon(Icons.bookmark, color: Colors.white),
//                 ),
//                 IconButton(
//                   onPressed: () => _reportBook(context),
//                   icon: const Icon(Icons.report, color: Colors.red),
//                 ),
//               ],
//             ),
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
//               child: const Text('Comments', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
//             ),
//             ListView.builder(
//               physics: const NeverScrollableScrollPhysics(),
//               shrinkWrap: true,
//               itemCount: 5,
//               itemBuilder: (context, index) {
//                 return ListTile(
//                   title: const Text('Username', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
//                   subtitle: Text('Comment text here', style: TextStyle(color: Colors.grey[400])),
//                   trailing: const Icon(Icons.thumb_up, color: Colors.grey),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
