import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class InventoryProvider with ChangeNotifier {
  int _categoriesCount = 0;
  int _productsCount = 0;
  int _usersCount = 0;
  List<String> _categories = [];
  List<XFile>? _images = [];
  int get categoriesCount => _categoriesCount;
  int get productsCount => _productsCount;
  int get usersCount => _usersCount;
  List<String> get categories => _categories;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  InventoryProvider() {
    _fetchData();
  }

  Future<void> _fetchData() async {
    final categorySnapshot =
    await FirebaseFirestore.instance.collection('categories').get();
    final productSnapshot =
    await FirebaseFirestore.instance.collection('products').get();
    final userSnapshot =
    await FirebaseFirestore.instance.collection('users').get();

    _categoriesCount = categorySnapshot.size;
    _productsCount = productSnapshot.size;
    _usersCount = userSnapshot.size;
    _categories =
        categorySnapshot.docs.map((doc) => doc['name'] as String).toList();

    notifyListeners();
  }

  Future<void> addCategory(
      String name,
      String description,
      XFile image,
      ) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception("User not authenticated");
    }

    final imageUrl = await uploadCategoryImage(image);
    final categoryData = {
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'user': user.displayName ?? user.email,
      'userId': user.uid,
      'timestamp': Timestamp.now(),
    };

    final categoryRef =
    await FirebaseFirestore.instance.collection('categories').add(categoryData);

    await FirebaseFirestore.instance.collection('history').add({
      'action': 'Added category: $name',
      'details': categoryData,
      'timestamp': Timestamp.now(),
    });

    _fetchData();
  }

  Future<String> uploadCategoryImage(XFile image) async {
    final imageUrl = await _uploadImage(image, 'category_images');
    return imageUrl;
  }

  Future<String> _uploadImage(XFile image, String folder) async {
    if (image == null) throw Exception("Image file is null");
    final ref = FirebaseStorage.instance.ref().child('$folder/${image.name}');
    await ref.putFile(File(image.path));
    return await ref.getDownloadURL();
  }

  Future<void> addProduct(
      String name,
      String category,
      String description,
      String sku,
      int quantity,
      double weight,
      String dimensions,
      List<XFile> images,
      ) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception("User not authenticated");
    }

    final List<String> imageUrls = await _uploadAdditionalImages(images);

    final productData = {
      'name': name,
      'category': category,
      'description': description,
      'sku': sku,
      'quantity': quantity,
      'weight': weight,
      'dimensions': dimensions,
      'imageUrls': imageUrls,
      'user': user.displayName ?? user.email,
      'userId': user.uid,
      'timestamp': Timestamp.now(),
    };

    final productRef =
    await FirebaseFirestore.instance.collection('products').add(productData);

    await FirebaseFirestore.instance.collection('history').add({
      'action': 'Added product: $name',
      'details': productData,
      'timestamp': Timestamp.now(),
    });

    _fetchData();
  }

  Future<Map<String, dynamic>?> getProductById(String productId) async {
    final doc =
    await FirebaseFirestore.instance.collection('products').doc(productId).get();
    if (doc.exists) {
      return doc.data();
    }
    return null;
  }

  Future<bool> checkUniqueSKU(String sku) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('products')
          .where('sku', isEqualTo: int.parse(sku))
          .limit(1)
          .get();
      return querySnapshot.docs.isEmpty;
    } catch (e) {
      print('Error checking SKU uniqueness: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> getCategoryById(String categoryId) async {
    final doc = await FirebaseFirestore.instance
        .collection('categories')
        .doc(categoryId)
        .get();
    if (doc.exists) {
      return doc.data();
    }
    return null;
  }

  Future<void> updateProduct(
      String productId,
      Map<String, dynamic> updatedData,
      ) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception("User not authenticated");
    }

    final productRef =
    await FirebaseFirestore.instance.collection('products').doc(productId).get();

    if (productRef.exists) {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .update(updatedData);

      await FirebaseFirestore.instance.collection('history').add({
        'action': 'Updated product: ${productRef['name']}',
        'details': updatedData,
        'timestamp': Timestamp.now(),
      });

      _fetchData();
    }
  }

  Future<void> updateCategory(
      String categoryId,
      Map<String, dynamic> updatedData,
      ) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception("User not authenticated");
    }

    final categoryRef = await FirebaseFirestore.instance
        .collection('categories')
        .doc(categoryId)
        .get();

    if (categoryRef.exists) {
      await FirebaseFirestore.instance
          .collection('categories')
          .doc(categoryId)
          .update(updatedData);

      await FirebaseFirestore.instance.collection('history').add({
        'action': 'Updated category: ${categoryRef['name']}',
        'details': updatedData,
        'timestamp': Timestamp.now(),
      });

      _fetchData();
    }
  }

  Future<List<String>> _uploadAdditionalImages(List<XFile> images) async {
    List<String> urls = [];
    for (var image in images) {
      final ref =
      FirebaseStorage.instance.ref().child('product_images/${image.name}');
      await ref.putFile(File(image.path));
      final url = await ref.getDownloadURL();
      urls.add(url);
    }
    return urls;
  }

  Future<void> removeCategory(String id) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception("User not authenticated");
    }

    final categoryRef =
    await FirebaseFirestore.instance.collection('categories').doc(id).get();

    if (categoryRef.exists) {
      await FirebaseFirestore.instance.collection('categories').doc(id).delete();

      await FirebaseFirestore.instance.collection('history').add({
        'action': 'Removed category: ${categoryRef['name']}',
        'details': categoryRef.data(),
        'timestamp': Timestamp.now(),
      });

      _fetchData();
    }
  }

  Future<void> removeProduct(String id) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception("User not authenticated");
    }
    final productRef =
    await FirebaseFirestore.instance.collection('products').doc(id).get();

    if (productRef.exists) {
      await FirebaseFirestore.instance.collection('products').doc(id).delete();

      await FirebaseFirestore.instance.collection('history').add({
        'action': 'Removed product: ${productRef['name']}',
        'details': productRef.data(),
        'timestamp': Timestamp.now(),
      });

      _fetchData();
    }
  }

  Future<List<Map<String, dynamic>>> getUserHistory(String userId) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('history')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .get();

    return querySnapshot.docs.map((doc) => doc.data()).toList();
  }
}
