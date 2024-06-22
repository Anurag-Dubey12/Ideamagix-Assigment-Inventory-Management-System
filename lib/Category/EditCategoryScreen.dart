import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';

import '../repo/InventoryProvider.dart';

class EditCategoryScreen extends StatefulWidget {
  static const routeName = '/edit-category';

  final String docId;

  EditCategoryScreen({required this.docId});

  @override
  _EditCategoryScreenState createState() => _EditCategoryScreenState();
}

class _EditCategoryScreenState extends State<EditCategoryScreen> {
  late TextEditingController _categoryTitleController;
  late TextEditingController _categoryDescriptionController;
  XFile? _categoryImage;
  String? _currentImageUrl;

  @override
  void initState() {
    super.initState();
    _categoryTitleController = TextEditingController();
    _categoryDescriptionController = TextEditingController();
    _loadCategoryDetails();
  }

  void _loadCategoryDetails() async {
    final categorySnapshot = await FirebaseFirestore.instance
        .collection('categories')
        .doc(widget.docId)
        .get();
    if (categorySnapshot.exists) {
      setState(() {
        _categoryTitleController.text = categorySnapshot['name'];
        _categoryDescriptionController.text = categorySnapshot['description'];
        _currentImageUrl = categorySnapshot['imageUrl'];
      });
    }
  }

  @override
  void dispose() {
    _categoryTitleController.dispose();
    _categoryDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InventoryProvider>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Edit Category'),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _categoryTitleController,
              decoration: InputDecoration(labelText: 'Category Title'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _categoryDescriptionController,
              decoration: InputDecoration(labelText: 'Category Description'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                  EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
                ),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              onPressed: () async {
                final pickedFile =
                await ImagePicker().pickImage(source: ImageSource.gallery);
                if (pickedFile != null) {
                  setState(() {
                    _categoryImage = XFile(pickedFile.path);
                  });
                }
              },
              child: Text('Pick Image'),
            ),
            SizedBox(height: 10),
            if (_currentImageUrl != null)
              Center(
                child: Image.network(
                  _currentImageUrl!,
                  height: 200,
                  width: 200,
                  fit: BoxFit.cover,
                ),
              ),
            if (_categoryImage != null)
              Center(
                child: Image.file(
                  File(_categoryImage!.path),
                  height: 200,
                  width: 200,
                  fit: BoxFit.cover,
                ),
              ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                  foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                  padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                    EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
                  ),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
                onPressed: () async {
                  if (_categoryTitleController.text.isNotEmpty &&
                      _categoryDescriptionController.text.isNotEmpty) {
                    Map<String, dynamic> updatedData = {
                      'name': _categoryTitleController.text,
                      'description': _categoryDescriptionController.text,
                    };
                    if (_categoryImage != null) {
                      final imageUrl =
                      await provider.uploadCategoryImage(_categoryImage!);
                      updatedData['imageUrl'] = imageUrl;
                    }

                    await provider.updateCategory(widget.docId, updatedData);
                    Navigator.pop(context);
                  } else {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Error'),
                        content: Text(
                            'Please fill all fields and select an image.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('OK'),
                          ),
                        ],
                      ),
                    );
                  }
                },
                child: Text('Update Category'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
