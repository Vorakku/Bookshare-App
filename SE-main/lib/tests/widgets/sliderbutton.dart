import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Sliderbutton extends StatefulWidget {
  const Sliderbutton({super.key});

  @override
  State<Sliderbutton> createState() => _SliderbuttonState();
}

class _SliderbuttonState extends State<Sliderbutton> {
  int? _sliding = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CupertinoSlidingSegmentedControl<int>(
          thumbColor: Colors.blue,
          groupValue: _sliding,
          children: {
            0: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              child: const Text(
                'Book Details',
                style: TextStyle(color: Colors.white),
              ),
            ),
            1: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              child: const Text(
                'Description',
                style: TextStyle(color: Colors.white),
              ),
            ),
            2: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              child: const Text(
                'Discussions',
                style: TextStyle(color: Colors.white),
              ),
            ),
          },
          onValueChanged: (int? newValue) {
            setState(() {
              _sliding = newValue;
            });
          },
        ),
        IndexedStack(
          index: _sliding,
          children: [
            BookDetailsWidget(),
            DescriptionWidget(),
            DiscussionsWidget(),
          ],
        ),
      ],
    );
  }
}

class BookDetailsWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Book Details'),
    );
  }
}

class DescriptionWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Description'),
    );
  }
}

class DiscussionsWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Discussions'),
    );
  }
}
