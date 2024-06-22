import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'EditCategoryScreen.dart';
import '../repo/InventoryProvider.dart';

class AddCategoryScreen extends StatefulWidget {
  static const routeName = '/add-category';

  @override
  _AddCategoryScreenState createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final TextEditingController _categoryNameController = TextEditingController();
  final TextEditingController _categoryDescriptionController = TextEditingController();
  XFile? _categoryImage;
  bool _isAddingCategory = false;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InventoryProvider>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Add Category'),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _categoryNameController,
                decoration: InputDecoration(labelText: 'Category Name'),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _categoryDescriptionController,
                decoration: InputDecoration(labelText: 'Category Description'),
                maxLines: 3,
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
                    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
                    if (pickedFile != null) {
                      setState(() {
                        _categoryImage = XFile(pickedFile.path);
                      });
                    }
                  },
                  child: Text('Pick Image'),
                ),
              ),
              SizedBox(height: 10),
              if (_categoryImage != null)
                Image.file(
                  File(_categoryImage!.path),
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              SizedBox(height: 20),
              Center(
                child: _isAddingCategory
                    ? CircularProgressIndicator()
                    : ElevatedButton(
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
                    if (_categoryNameController.text.isNotEmpty &&
                        _categoryDescriptionController.text.isNotEmpty &&
                        _categoryImage != null) {
                      setState(() {
                        _isAddingCategory = true;
                      });
                      await provider.addCategory(
                        _categoryNameController.text,
                        _categoryDescriptionController.text,
                        _categoryImage!,
                      );
                      Navigator.pop(context);
                    } else {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Error'),
                          content: Text('Please fill all fields and select an image.'),
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
                    setState(() {
                      _isAddingCategory = false;
                    });
                  },
                  child: Text('Add Category'),
                ),
              ),
              SizedBox(height: 20),
              _buildCategoryList(provider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryList(InventoryProvider provider) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('categories').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No categories found.'));
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: snapshot.data!.docs.map((doc) {
            final docId = doc.id;
            final name = doc['name'] ?? '';
            final description = doc['description'] ?? '';
            final imageUrl = doc['imageUrl'];

            return Card(
              color: Colors.white,
              elevation: 5,
              margin: EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: imageUrl != null
                    ? CircleAvatar(
                  backgroundImage: NetworkImage(imageUrl),
                )
                    : Icon(Icons.category),
                title: Text(name),
                subtitle: Text(description),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => EditCategoryScreen(docId: docId)),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Delete Category'),
                            content: Text('Are you sure you want to delete this category?'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  provider.removeCategory(docId);
                                  Navigator.pop(context);
                                },
                                child: Text('Delete'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
