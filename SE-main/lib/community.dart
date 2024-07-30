import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Community Page',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: CommunityPage(),
    );
  }
}

class CommunityPage extends StatefulWidget {
  @override
  _CommunityPageState createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _userList = ['Tonkatsu', 'Tonkatsu','Kanold', 'Gelly', 'Vorak','Sorya', 'Kanoldd'];
  List<String> _filteredUserList = [];

  @override
  void initState() {
    super.initState();
    _filteredUserList = _userList;
  }

  void _filterUsers(String query) {
    setState(() {
      _filteredUserList = _userList
          .where((user) => user.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF23232C),
      appBar: AppBar(
        title: Text(
          'Search People',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF23232C),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 16),
            TextField(
              controller: _searchController,
              onChanged: _filterUsers,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search, color: Color.fromARGB(255, 0, 0, 0)),
                hintText: 'Search...',
                hintStyle: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                filled: true,
                fillColor: Color.fromARGB(255, 249, 249, 249),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredUserList.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.grey,
                      child: Text(
                        _filteredUserList[index][0],
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      _filteredUserList[index],
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
