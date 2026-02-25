import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageService {
  final ImagePicker _picker = ImagePicker();

  Future<File?> pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        return File(pickedFile.path);
      }
    }
    catch (e) {
      debugPrint("Error picking image: $e");
    }
    return null;
  }

  void showImageOptions({
    required BuildContext context,
    required Function(File) onImageSelected,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a Photo'),
              onTap: () async {
                Navigator.pop(context);
                final file = await pickImage(ImageSource.camera);
                if (file != null) {
                  onImageSelected(file);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () async {
                Navigator.pop(context);
                final file = await pickImage(ImageSource.gallery);
                if (file != null) {
                  onImageSelected(file);
                }
              },
            )
          ],
        )
      )
    );
  }

  Future<String?> uploadProfileImage(String uid, File image) async {
    try {
      final storageReference = FirebaseStorage.instance.ref().child("profile_pics").child("$uid.jpg");
      await storageReference.putFile(image);
      String downloadURL = await storageReference.getDownloadURL();
      return downloadURL;
    }
    catch(e) {
      debugPrint("Error uploading image: $e");
      return null;
    }

  }

}