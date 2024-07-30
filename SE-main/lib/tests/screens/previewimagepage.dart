import 'package:flutter/material.dart';
import 'dart:io';

class PreviewImagePage extends StatelessWidget {
  final File imageFile;
  final Function(File) onSave;

  const PreviewImagePage(
      {required this.imageFile, required this.onSave, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preview Image'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.file(height: 500, imageFile, fit: BoxFit.cover),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                print(imageFile.path);
                onSave(imageFile);
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
