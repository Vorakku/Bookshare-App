import 'package:bookshare/tests/models/user.dart';
import 'package:bookshare/tests/utils/api_service.dart';
import 'package:bookshare/tests/utils/user_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:bookshare/tests/screens/globallibrary.dart';
import 'package:bookshare/tests/widgets/displaybook.dart';
import 'package:bookshare/tests/widgets/displayrecommendbook.dart';
import 'package:bookshare/tests/screens/librarytest.dart';
import 'package:bookshare/tests/screens/userprofile.dart';

class MyHomePageTest extends StatefulWidget {
  final int initialIndex;
  const MyHomePageTest({super.key, this.initialIndex = 0});

  @override
  _MyHomePageTestState createState() => _MyHomePageTestState();
}

class _MyHomePageTestState extends State<MyHomePageTest> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();
  late Future<User> futureUser;

  @override
  void initState() {
    super.initState();
    futureUser = _initializeUser();
  }

  Future<User> _initializeUser() async {
    User? user = await getUser();
    if (user != null) {
      return fetchUser();
    } else {
      throw Exception('User not found');
    }
  }

  final List<Widget> _widgetOptions = <Widget>[
    const HomeScreen(),
    const LibraryPageTest(),
    const GlobalLibrary(),
    const UserProfile(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.jumpToPage(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2C3E50), Color(0xFF000000)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: _widgetOptions,
          onPageChanged: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF23232C),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white60,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books),
            label: 'Your Collection',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_sharp),
            label: 'Find Book',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2C3E50), Color(0xFF000000)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 80, left: 12, right: 12), // Adjust top padding for spacing
          child: FutureBuilder<User>(
            future: (context.findAncestorStateOfType<_MyHomePageTestState>()?.futureUser),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData) {
                return const Center(child: Text('No user available'));
              } else {
                User user = snapshot.data!;
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Welcome Back, \n${user.username}!',
                                  maxLines: 2,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const Spacer(),
                                InkWell(
                                  onTap: () {},
                                  child: CircleAvatar(
                                    radius: 25,
                                    backgroundColor: user.profileImage == null || user.profileImage!.isEmpty ? Colors.black : null,
                                    backgroundImage: user.profileImage != null && user.profileImage!.isNotEmpty ? NetworkImage(user.profileImage!) : null,
                                    child: user.profileImage == null || user.profileImage!.isEmpty ? const Icon(Icons.person, size: 25, color: Colors.white) : null,
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        width: double.infinity,
                        child: const Text(
                          'Recently Added Books',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        height: 480,
                        child: const DisplayRecommendBook(),
                      ),
                      const SizedBox(height: 8), // Adjusted spacing for pagination dots
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            child: Text(
                              'Popular Books',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.only(top: 10),
                            height: 265,
                            child: const Displaybook(),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
