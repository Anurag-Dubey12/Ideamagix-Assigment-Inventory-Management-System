import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:idea_assignment/Auth/SignUp.dart';
import 'package:provider/provider.dart';
import 'Category/AddCategoryScreen.dart';
import 'Product/AddProductScreen.dart';
import 'Category/EditCategoryScreen.dart';
import 'repo/InventoryProvider.dart';
import 'History/HistoryScreen.dart';
import 'package:pie_chart/pie_chart.dart';

import 'Product/EditProductScreen.dart';


class HomeScreen extends StatelessWidget {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InventoryProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Inventory Management \nSystem'),
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HistoryScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.category_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddCategoryScreen()),
              );
            },
          ),

        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildDashboard(provider),
            _buildCategoryList(provider),
            SizedBox(height: 20),
            _buildSectionTitle('Products'),
            SizedBox(height: 10),
            _buildLimitedProductList(provider),
            SizedBox(height: 10),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () {
          Navigator.pushNamed(context, AddProductScreen.routeName);
        },
        child: Icon(Icons.add,color: Colors.white,),
      ),
    );
  }

  Widget _buildDashboard(InventoryProvider provider) {
    Map<String, double> dataMap = {
      'Categories': provider.categoriesCount.toDouble(),
      'Products': provider.productsCount.toDouble(),
    };
    List<Color> colorList = [
      Colors.blue,
      Colors.green,
    ];

    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Card(
                      color:Colors.white,
                      elevation: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Column(
                              children: [
                                Text("Categories:${provider.categoriesCount.toString()}", style: TextStyle(fontSize: 20)),
                                SizedBox(height: 10),
                                Text("Products:${provider.productsCount.toString()}", style: TextStyle(fontSize: 20)),
                                SizedBox(height: 10),
                                Text("Users:${provider.usersCount.toString()}", style: TextStyle(fontSize: 20)),
                                SizedBox(height: 10),
                              ],
                            ),
                            Container(
                              color: Colors.white,
                              height: 200,
                              child: PieChart(
                                dataMap: dataMap,
                                colorList: colorList,
                                chartRadius: 120,
                                chartType: ChartType.ring,
                                legendOptions: LegendOptions(
                                  showLegendsInRow: true,
                                  legendPosition: LegendPosition.bottom,
                                  showLegends: true,
                                ),
                                chartValuesOptions: ChartValuesOptions(
                                  showChartValues: true,
                                  showChartValuesInPercentage: true,
                                  showChartValuesOutside: false,
                                  decimalPlaces: 1,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

              ],
            ),
          ),
        ),

      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Categories',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                     Navigator.push(context, MaterialPageRoute(builder: (context)=>AddCategoryScreen()));
                    },
                    child: Text(
                      'See All',
                      style: TextStyle(fontSize: 16, color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            SizedBox(
              height: 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final doc = snapshot.data!.docs[index];
                  final docId = doc.id;
                  final name = doc['name'] ?? '';
                  final imageUrl = doc['imageUrl'];

                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: GestureDetector(
                      onTap: () {

                      },
                      child: Container(
                        width: 180,
                        margin: EdgeInsets.only(bottom: 16),
                        // Added bottom margin
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 1,
                              blurRadius: 3,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(8),
                                ),
                                image: DecorationImage(
                                  image: NetworkImage(imageUrl ?? ''),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.edit, size: 20),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    EditCategoryScreen(
                                                        docId: docId)),
                                          );
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete, size: 20),
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) =>
                                                AlertDialog(
                                                  title: Text(
                                                      'Delete Category'),
                                                  content: Text(
                                                      'Are you sure you want to delete this category?'),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      child: Text('Cancel'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        provider.removeCategory(
                                                            docId);
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
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLimitedProductList(InventoryProvider provider) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('products')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No products found.'));
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: snapshot.data!.docs.map((doc) {
            final name = doc['name'] ?? '';
            final productId = doc.id;
            final category = doc['category'] ?? '';
            final description = doc['description'] ?? '';
            final sku = doc['sku'] ?? '';
            final quantity = doc['quantity'] ?? '';
            final weight = doc['weight'] ?? '';
            final dimensions = doc['dimensions'] ?? '';

            return GestureDetector(
              onTap: () {
                _showProductDetailsBottomSheet(context, doc);
              },
              child: Card(
                color: Colors.white,
                elevation: 10,
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  leading: Icon(Icons.add),
                  title: Text(name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Category: $category'),
                      Text('Description: $description'),
                      Text('SKU: $sku'),
                      Text('Quantity: $quantity'),
                      Text('Weight: $weight'),
                      Text('Dimensions: $dimensions'),
                    ],
                  ),
                  trailing: _buildProductActions(context, provider, doc.id),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  void _showProductDetailsBottomSheet(BuildContext context, DocumentSnapshot doc) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Product Title
                Text(
                  doc['name'] ?? '',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                // Product Details
                _buildDetailRow('Category', doc['category']),
                _buildDetailRow('Description', doc['description']),
                _buildDetailRow('SKU', doc['sku']),
                _buildDetailRow('Quantity', doc['quantity']),
                _buildDetailRow('Weight', doc['weight']),
                _buildDetailRow('Dimensions', doc['dimensions']),
                SizedBox(height: 24),
                // Close Button
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Close', style: TextStyle(color: Colors.blue)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              value.toString() ?? 'Not specified',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildProductActions(BuildContext context, InventoryProvider provider,
      String docId) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.edit),
          onPressed: () {
            Navigator.pushNamed(
              context,
              EditProductScreen.routeName,
              arguments: docId,
            );
          },
        ),
        IconButton(
          icon: Icon(Icons.delete),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) =>
                  AlertDialog(
                    title: Text('Delete Product'),
                    content: Text(
                        'Are you sure you want to delete this product?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          provider.removeProduct(docId);
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
    );
  }

}

