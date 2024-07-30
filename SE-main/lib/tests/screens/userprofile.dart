import 'package:bookshare/tests/models/booklist.dart';
import 'package:bookshare/tests/screens/booklistbookscreen.dart';
import 'package:bookshare/tests/screens/previewimagepage.dart';
import 'package:bookshare/tests/screens/settingscreen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:bookshare/tests/models/user.dart';
import 'package:bookshare/tests/utils/api_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:bookshare/tests/utils/user_storage.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  late Future<List<Booklist>> futurePublicBooklists = Future.value([]);
  File? _image;
  late Future<User> futureUser;
  final _description = TextEditingController();
  final ApiService _apiService = ApiService();

  final PageController _pageController = PageController();
  int currentPage = 1;
  final int booklistsPerPage = 6;

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      Navigator.of(context).pop();
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) =>
              PreviewImagePage(imageFile: _image!, onSave: _saveProfileImage)));
    } else {
      print('No image selected.');
    }
  }

  Future<void> _saveProfileImage(File imageFile) async {
    try {
      final token = await storage.read(key: 'auth_token');

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${dotenv.env['API_URL']}/add_profile/user'),
      );

      request.headers['Authorization'] = 'Bearer $token';

      request.files.add(await http.MultipartFile.fromPath(
        'profile_image',
        imageFile.path,
      ));

      var response = await request.send();

      if (response.statusCode == 200) {
        print('Profile image uploaded successfully');
        setState(() {
          futureUser = fetchUser();
        });
      } else {
        print('Failed to upload profiles image: ${response.statusCode}');
        print('Response body: ${await response.stream.bytesToString()}');
        throw Exception('Failed to upload profile image');
      }
    } on Exception catch (e) {
      print('Error: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    futureUser = fetchUser();
    _initializeUser();
  }

  void _showImageMessenger() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('No image Cover'),
            actions: [
              TextButton(
                  onPressed: _pickImage,
                  child: const Text('Upload Profile Image')),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Close'),
              ),
            ],
          );
        });
  }

  Future<void> _initializeUser() async {
    User? user = await getUser();
    if (user != null) {
      String userId = user.id;
      setState(() {
        futureUser = fetchUser();
        futurePublicBooklists = _apiService.fetchBooklistsByUserId(userId);
      });
    } else {
      print('User not found');
      setState(() {
        futureUser = Future.error('User Not found');
      });
    }
  }

  void _showDescriptionEdit() {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2C3E50), Color(0xFF000000)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            alignment: Alignment.topCenter,
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.only(top: 80),
                  child: const Text(
                    'Edit Your Description',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _description,
                  maxLength: 2000,
                  maxLines: 20,
                  minLines: 1,
                  decoration: const InputDecoration(
                    hintStyle: TextStyle(color: Colors.white54),
                    hintText: 'Enter your description here',
                    border: OutlineInputBorder(),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.end, // Align buttons to the right
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.black, // Dark color for 'Cancel'
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8), // Adjust padding
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(30), // Rounded corners
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 10), // Space between buttons
                    ElevatedButton(
                      onPressed: () async {
                        if (_description.text.isNotEmpty) {
                          User? user = await getUser();
                          if (user != null) {
                            bool success = await _apiService
                                .addDescription(_description.text);
                            if (success) {
                              setState(() {
                                futureUser = fetchUser();
                              });
                            }
                          }
                        }
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Confirm',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(80, 100, 141,
                            167), // Light blue color for 'Confirm'
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8), // Adjust padding
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(30), // Rounded corners
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          );
        });
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
            builder: (context) => Booklistbookscreen(
              booklistName: booklist.name,
              books: booklist.books,
              booklistId: booklist.id,
              isPublic: booklist.isPublic,
              onBookRemoved: (int value) {},
            ),
          ),
        ).then((_) {
          setState((){
            _initializeUser();
          });
        });
      },
      child: Column(
        children: [
          Expanded(
            child: booklist.books.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: booklist.books.isNotEmpty
                        ? booklist.books[0].imageUrl
                        : "path/to/default/image",
                    placeholder: (context, url) =>
                        const CircularProgressIndicator(),
                    fit: BoxFit.cover,
                  )
                : Container(
                    height: 120,
                    width: 120,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white),
                    child: const Center(
                        child: Text(
                      'No books in booklist',
                      textAlign: TextAlign.center,
                    )),
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
        backgroundColor: const Color.fromARGB(0, 255, 255, 255),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.settings, color: Colors.white),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const Settingscreen()));
              },
            ),
          ],
        ),
        body: FutureBuilder<User>(
          future: futureUser,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData) {
              return const Center(child: Text('No user available'));
            } else {
              User user = snapshot.data!;
              print('Profile Picture: ${user.profileImage}');
              return SingleChildScrollView(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    InkWell(
                      onTap: () {
                        if (user.profileImage != null &&
                            user.profileImage!.isNotEmpty) {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return Dialog(
                                  backgroundColor: Colors.transparent,
                                  child: Stack(
                                    children: [
                                      Center(
                                        child: Image.network(
                                          user.profileImage!,
                                          width: 300,
                                          height: 300,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Positioned(
                                        top: 20,
                                        right: 20,
                                        child: IconButton(
                                          icon: const Icon(
                                            Icons.close,
                                            color: Colors.white,
                                            size: 30,
                                          ),
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 90,
                                        right: 50,
                                        left: 50,
                                        child: InkWell(
                                          onTap: _pickImage,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 4),
                                            decoration: const BoxDecoration(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(20)),
                                                color: Colors.white),
                                            child: const Text(
                                              "Change Profile Picture",
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              });
                        } else {
                          _showImageMessenger();
                        }
                      },
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
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          color: Color(0xFF3A3A45)),
                      child: Text(
                        user.description?.isNotEmpty ?? false
                            ? user.description!
                            : 'No description added',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color.fromARGB(179, 255, 255, 255),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                            onTap: _showDescriptionEdit,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color.fromRGBO(80, 136, 167, 100),
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: const Text(
                                "Edit Description",
                                style: TextStyle(color: Colors.white),
                              ),
                            )),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Container(
                        width: double.infinity,
                        alignment: Alignment.center,
                        child: const Text(
                          'Your Public Booklists',
                          style: TextStyle(color: Colors.white, fontSize: 24),
                        )),
                    const SizedBox(height: 32),
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
                          } else if (snapshot.hasError ||
                              !snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return const Center(
                                child: Text('No public booklists available'));
                          } else {
                            List<Booklist> booklists = snapshot.data!;
                            int totalPages =
                                (booklists.length / booklistsPerPage).ceil();
                            return Column(
                              children: [
                                Container(
                                  height: 350,
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
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(totalPages, (index) {
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
                        }),
                        const SizedBox(height: 20),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}

//  Container(
//                                 height: 800,
//                                 child: GridView.builder(
//                                   physics: const NeverScrollableScrollPhysics(),
//                                     gridDelegate:
//                                         const SliverGridDelegateWithFixedCrossAxisCount(
//                                       crossAxisSpacing: 16,
//                                       mainAxisSpacing: 16,
//                                       crossAxisCount: 3,
//                                       childAspectRatio: 0.75,
//                                     ),
//                                     itemCount: booklists.length,
//                                     itemBuilder: (context, index) {
//                                       Booklist booklist = snapshot.data![index];
//                                       if (booklist.books.isEmpty) {
//                                         return InkWell(
//                                           child: Container(
//                                               child: Column(
//                                             children: [
//                                               Container(
//                                                 height: 120,
//                                                 width: 120,
//                                                 decoration: BoxDecoration(
//                                                     borderRadius:
//                                                         BorderRadius.circular(
//                                                             10),
//                                                     color: Colors.white),
//                                                 child: const Center(
//                                                     child: Text(
//                                                   'No books in booklist',
//                                                   textAlign: TextAlign.center,
//                                                 )),
//                                               ),
//                                               const SizedBox(
//                                                 height: 8,
//                                               ),
//                                               Text(
//                                                 booklist.name,
//                                                 overflow:TextOverflow.ellipsis,maxLines: 1,
//                                                 style: const TextStyle(
//                                                     color: Colors.white),
//                                               )
//                                             ],
//                                           )),
//                                         );
//                                       } else {
//                                         return InkWell(
//                                           onTap: () {
//                                             Navigator.of(context)
//                                                 .push(
//                                               MaterialPageRoute(
//                                                 builder: (context) =>
//                                                     Booklistbookscreen(
//                                                   booklistName: booklist.name,
//                                                   books: booklist.books
//                                                       .map((book) => book)
//                                                       .toList(),
//                                                   booklistId: booklist.id,
//                                                   isPublic: booklist
//                                                       .isPublic, // Ensure this line is included
//                                                   onBookRemoved: (int value) {},
//                                                 ),
//                                               ),
//                                             )
//                                                 .then((_) {
//                                               _initializeUser();
//                                             });
//                                           },
//                                           child: Container(
//                                             child: Flexible(
//                                               child: Column(
//                                                 children: [
//                                                   Container(
//                                                     width: 120,
//                                                     height: 120,
//                                                     child: CachedNetworkImage(
//                                                       imageUrl: booklist
//                                                           .books[0].imageUrl,
//                                                       placeholder: (context,
//                                                               url) =>
//                                                           const CircularProgressIndicator(),
//                                                       errorWidget: (context,
//                                                               url, error) =>
//                                                           const Icon(
//                                                         Icons.error,
//                                                         color: Colors.white,
//                                                       ),
//                                                       fit: BoxFit.cover,
//                                                     ),
//                                                   ),
//                                                   const SizedBox(
//                                                     height: 8,
//                                                   ),
//                                                   Text(
//                                                     booklist.name,
//                                                     overflow:TextOverflow.ellipsis,
//                                                     maxLines: 1,
//                                                     style: const TextStyle(
//                                                         color: Colors.white),
//                                                   )
//                                                 ],
//                                               ),
//                                             ),
//                                           ),
//                                         );
//                                       }
//                                     }));