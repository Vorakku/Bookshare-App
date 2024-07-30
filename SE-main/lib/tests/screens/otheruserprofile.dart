import 'package:bookshare/tests/models/booklist.dart';
import 'package:bookshare/tests/models/user.dart';
import 'package:bookshare/tests/screens/booklistbookscreen.dart';
import 'package:bookshare/tests/screens/displaypublicbooklist.dart';
import 'package:bookshare/tests/utils/api_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class Otheruserprofile extends StatefulWidget {
  const Otheruserprofile({super.key, required this.userId});

  final String userId;

  @override
  State<Otheruserprofile> createState() => _OtheruserprofileState();
}

class _OtheruserprofileState extends State<Otheruserprofile> {
  late Future<List<Booklist>> futurePublicBooklists = Future.value([]);
  late Future<User> _userProfileFuture;
  final ApiService apiService = ApiService();

  final PageController _pageController = PageController();
  int currentPage = 1;
  final int booklistsPerPage = 6;

  @override
  void initState() {
    _userProfileFuture = apiService.getUserProfile(widget.userId);
    super.initState();
    futurePublicBooklists = apiService.fetchBooklistsByUserId(widget.userId);
  }

  Widget buildBooklistPage(List<Booklist> booklists, int pageIndex) {
    int start = pageIndex * booklistsPerPage;
    List<Booklist> booklistsToDisplay = booklists.sublist(
      start,
      start + booklistsPerPage <= booklists.length
          ? start + booklistsPerPage
          : booklists.length,
    );

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.75,
      ),
      itemCount: booklistsToDisplay.length,
      itemBuilder: (context, index) {
        Booklist booklist = booklistsToDisplay[index];
        return buildBooklistItem(booklist);
      },
    );
  }

  Widget buildBooklistItem(Booklist booklist) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => Displaypublicbooklist(
              booklistName: booklist.name,
              books: booklist.books,
              booklistId: booklist.id,
              isPublic: booklist.isPublic,
            ),
          ),
        );
      },
      child: Column(
        children: [
          Expanded(
            child: CachedNetworkImage(
              imageUrl: booklist.books.isNotEmpty
                  ? booklist.books[0].imageUrl
                  : "path/to/default/image",
              placeholder: (context, url) => const CircularProgressIndicator(),
              errorWidget: (context, url, error) => const Icon(Icons.error),
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            booklist.name,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2C3E50), Color(0xFF000000)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
          backgroundColor: Color.fromARGB(0, 255, 255, 255),
          appBar: AppBar(
            iconTheme: const IconThemeData(color: Colors.white),
            backgroundColor: Colors.transparent,
          ),
          body: FutureBuilder<User>(
              future: _userProfileFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text('User not found'));
                } else if (!snapshot.hasData) {
                  return const Center(child: Text('No User Available'));
                } else {
                  User user = snapshot.data!;
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Center(
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: user.profileImage == null ||
                                    user.profileImage!.isEmpty
                                ? Colors.black
                                : null,
                            backgroundImage: user.profileImage != null &&
                                    user.profileImage!.isNotEmpty
                                ? NetworkImage(user.profileImage!)
                                : null,
                            child: user.profileImage == null ||
                                    user.profileImage!.isEmpty
                                ? const Icon(
                                    Icons.person,
                                    size: 50,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          user.username,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8)),
                              color: Color(0xFF3A3A45)),
                          child: Text(
                            user.description?.isNotEmpty ?? false
                                ? user.description!
                                : 'No description added',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 36,
                        ),
                        Container(
                            width: double.infinity,
                            child: Text(
                              "${user.username}'s public booklist",
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 24),
                            )),
                        const SizedBox(height: 24),
                        FutureBuilder<List<Booklist>>(
                            future: futurePublicBooklists,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              } else if (snapshot.hasError) {
                                return Center(
                                    child: Text('Error: ${snapshot.error}'));
                              } else if (!snapshot.hasData ||
                                  snapshot.data!.isEmpty) {
                                return const Center(
                                    child:
                                        Text('No public booklists available'));
                              } else {
                                List<Booklist> booklists = snapshot.data!;
                                int totalPages =
                                    (booklists.length / booklistsPerPage)
                                        .ceil();
                                return Column(
                                  children: [
                                    Container(
                                      height: 300,
                                      child: PageView.builder(
                                        controller: _pageController,
                                        onPageChanged: (index) {
                                          setState(() {
                                            currentPage = index + 1;
                                          });
                                        },
                                        itemCount: totalPages,
                                        itemBuilder: (context, index) {
                                          return buildBooklistPage(
                                              booklists, index);
                                        },
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children:
                                          List.generate(totalPages, (index) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 4),
                                          child: Container(
                                            width: 10,
                                            height: 10,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: currentPage == index + 1
                                                  ? Colors.blue
                                                  : Colors.grey[300],
                                            ),
                                          ),
                                        );
                                      }),
                                    ),
                                  ],
                                );
                              }
                            })
                      ],
                    ),
                  );
                }
              })),
    );
  }
}


// Container(
//                                     height: 800,
//                                     child: GridView.builder(
//                                         physics: const NeverScrollableScrollPhysics(),
//                                         gridDelegate:
//                                             const SliverGridDelegateWithFixedCrossAxisCount(
//                                           crossAxisSpacing: 16,
//                                           mainAxisSpacing: 16,
//                                           crossAxisCount: 3,
//                                           childAspectRatio: 0.75,
//                                         ),
//                                         itemCount: booklists.length,
//                                         itemBuilder: (context, index) {
//                                           Booklist booklist =
//                                               snapshot.data![index];
//                                           if (booklist.books.isEmpty) {
//                                             return InkWell(
//                                               child: Container(
//                                                   child: Column(
//                                                 children: [
//                                                   Container(
//                                                     height: 120,
//                                                     width: 120,
//                                                     decoration: BoxDecoration(
//                                                         borderRadius:
//                                                             BorderRadius
//                                                                 .circular(10),
//                                                         color: Colors.white),
//                                                     child: const Center(
//                                                         child: Text(
//                                                       'No books booklist',
//                                                       textAlign:
//                                                           TextAlign.center,
//                                                     )),
//                                                   ),
//                                                   const SizedBox(
//                                                     height: 8,
//                                                   ),
//                                                   Text(
//                                                     booklist.name,
//                                                     style: const TextStyle(
//                                                         color: Colors.white),
//                                                   )
//                                                 ],
//                                               )),
//                                             );
//                                           } else {
//                                             return InkWell(
//                                               onTap: () {
//                                                 Navigator.of(context).push(
//                                                   MaterialPageRoute(
//                                                     builder: (context) =>
//                                                         Displaypublicbooklist(
//                                                       booklistName:
//                                                           booklist.name,
//                                                       books: booklist.books
//                                                           .map((book) => book)
//                                                           .toList(),
//                                                       booklistId: booklist.id,
//                                                       isPublic: booklist
//                                                           .isPublic, // Ensure this line is included
//                                                     ),
//                                                   ),
//                                                 );
//                                               },
//                                               child: Container(
//                                                 decoration: BoxDecoration(
//                                                   borderRadius:
//                                                       BorderRadius.circular(10),
//                                                 ),
//                                                 child: Flexible(
//                                                   child: Column(
//                                                     children: [
//                                                       Container(
//                                                         width: 120,
//                                                         height: 120,
//                                                         child:
//                                                             CachedNetworkImage(
//                                                           imageUrl: booklist
//                                                               .books[0]
//                                                               .imageUrl,
//                                                           placeholder: (context,
//                                                                   url) =>
//                                                               const CircularProgressIndicator(),
//                                                           errorWidget: (context,
//                                                                   url, error) =>
//                                                               const Icon(
//                                                             Icons.error,
//                                                             color: Colors.white,
//                                                           ),
//                                                           fit: BoxFit.cover,
//                                                         ),
//                                                       ),
//                                                       const SizedBox(
//                                                         height: 8,
//                                                       ),
//                                                       Text(
//                                                         overflow:TextOverflow.ellipsis,
//                                                     maxLines: 1,
//                                                         booklist.name,
//                                                         style: const TextStyle(
//                                                             color:
//                                                                 Colors.white),
//                                                       )
//                                                     ],
//                                                   ),
//                                                 ),
//                                               ),
//                                             );
//                                           }
//                                         }));

// InkWell(
//                     onTap: () {
//                       if (user.profileImage != null &&
//                           user.profileImage!.isNotEmpty) {
//                         showDialog(
//                             context: context,
//                             builder: (BuildContext context) {
//                               return Dialog(
//                                 backgroundColor: Colors.transparent,
//                                 child: Stack(
//                                   children: [
                                    
//                                     Positioned(
//                                       top: 20,
//                                       right: 20,
//                                       child: IconButton(
//                                         icon: const Icon(
//                                           Icons.close,
//                                           color: Colors.white,
//                                           size: 30,
//                                         ),
//                                         onPressed: () {
//                                           Navigator.pop(context);
//                                         },
//                                       ),
//                                     ),
//                                     Positioned(
//                                       bottom: 90,
//                                       right: 50,
//                                       left: 50,
//                                       child: InkWell(
//                                         onTap: _pickImage,
//                                         child: Container(
//                                           padding: const EdgeInsets.symmetric(
//                                               vertical: 4),
//                                           decoration: const BoxDecoration(
//                                               borderRadius: BorderRadius.all(
//                                                   Radius.circular(20)),
//                                               color: Colors.white),
//                                           child: const Text(
//                                             "Change Profile Picture",
//                                             textAlign: TextAlign.center,
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               );
//                             });
//                       } else {
//                         _showImageMessenger();
//                       }
//                     },
//                     child: CircleAvatar(
//                       radius: 50,
//                       backgroundColor: user.profileImage == null ||
//                               user.profileImage!.isEmpty
//                           ? Colors.black
//                           : null,
//                       backgroundImage: user.profileImage != null &&
//                               user.profileImage!.isNotEmpty
//                           ? NetworkImage(user.profileImage!)
//                           : null,
//                       child: user.profileImage == null ||
//                               user.profileImage!.isEmpty
//                           ? const Icon(
//                               Icons.person,
//                               size: 50,
//                               color: Colors.white,
//                             )
//                           : null,
//                     ),
//                   ),