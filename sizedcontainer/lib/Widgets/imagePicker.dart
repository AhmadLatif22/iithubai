import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerWidget extends StatefulWidget {
  const ImagePickerWidget({super.key});

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  final ImagePicker _picker = ImagePicker();
  XFile? file;
  List<XFile>? files;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Image Picker')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 300,
              width: double.infinity,
              color: Colors.grey.shade200,
              child: Center(
                child: file == null
                    ? const Text('Image not picked')
                    : Image.file(
                  File(file!.path),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final XFile? photo = await _picker.pickImage(source: ImageSource.gallery);
                if (photo != null) {
                  setState(() {
                    file = photo;
                  });
                  print('Image Picked: ${photo.path}');
                }
              },
              child: const Text('Pick Image'),
            ),
            ElevatedButton(
              onPressed: () async {
                final List<XFile> photos = await _picker.pickMultiImage();
                if (photos.isNotEmpty) {
                  setState(() {
                    files = photos;
                  });
                  print('Images Picked:');
                  for (int i = 0; i < files!.length; i++) {
                    print(files![i].path);
                  }
                }
              },
              child: const Text('Pick Images'),
            ),
          ],
        ),
      ),
    );
  }
}
