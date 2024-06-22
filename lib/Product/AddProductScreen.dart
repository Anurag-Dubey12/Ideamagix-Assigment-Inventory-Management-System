import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../repo/InventoryProvider.dart';

class AddProductScreen extends StatefulWidget {
  static const routeName = '/add-product';

  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _productNameController = TextEditingController();
  final _productDescriptionController = TextEditingController();
  final _productSKUController = TextEditingController();
  final _productQuantityController = TextEditingController();
  final _productWeightController = TextEditingController();
  final _productDimensionsController = TextEditingController();
  List<XFile> _productImages = []; // Updated to list of images
  String? _selectedCategory;

  bool _isAddingProduct = false;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InventoryProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Add Product'),
        backgroundColor: Colors.white,
      ),
      body: _isAddingProduct
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        scrollDirection: Axis.vertical,
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _productNameController,
              decoration: InputDecoration(labelText: 'Product Name'),
            ),
            SizedBox(height: 10),
            Text("Category",style: TextStyle(
              color: Colors.black,fontSize: 16,fontWeight: FontWeight.bold
            ),),
            SizedBox(height: 10),
            Wrap(
              spacing: 8.0,
              children: provider.categories.map((category) {
                return ChoiceChip(
                  label: Text(category),
                  selected: _selectedCategory == category,
                  onSelected: (isSelected) {
                    setState(() {
                      _selectedCategory = isSelected ? category : null;
                    });
                  },
                );
              }).toList(),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _productDescriptionController,
              decoration: InputDecoration(labelText: 'Product Description'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _productSKUController,
              decoration: InputDecoration(labelText: 'Product SKU'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _productQuantityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Product Quantity'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _productWeightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Product Weight'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _productDimensionsController,
              decoration: InputDecoration(labelText: 'Product Dimensions'),
            ),
            SizedBox(height: 10),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  final pickedFile = await ImagePicker().pickImage(
                    source: ImageSource.gallery,
                  );
                  if (pickedFile != null) {
                    setState(() {
                      _productImages.add(XFile(pickedFile.path));
                    });
                  }
                },
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
                child: Text('Pick Image'),
              ),
            ),
            SizedBox(height: 10),
            _productImages.isEmpty
                ? Container()
                : SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _productImages.length,
                itemBuilder: (ctx, index) => Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Image.file(
                    File(_productImages[index].path),
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  await _addProduct(provider);
                },
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
                child: Text('Add Product'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addProduct(InventoryProvider provider) async {
    if (_productNameController.text.isEmpty ||
        _selectedCategory == null ||
        _productDescriptionController.text.isEmpty ||
        _productSKUController.text.isEmpty ||
        _productQuantityController.text.isEmpty ||
        _productWeightController.text.isEmpty ||
        _productDimensionsController.text.isEmpty ||
        _productImages.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Please fill all fields and select at least one image.'),
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
      return;
    }

    setState(() {
      _isAddingProduct = true;
    });

    try {
      await provider.addProduct(
        _productNameController.text,
        _selectedCategory!,
        _productDescriptionController.text,
        _productSKUController.text,
        int.parse(_productQuantityController.text),
        double.parse(_productWeightController.text),
        _productDimensionsController.text,
        _productImages,
      );
      Navigator.pop(context);
    } catch (error) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Failed to add product: $error'),
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
    } finally {
      setState(() {
        _isAddingProduct = false;
      });
    }
  }
}
