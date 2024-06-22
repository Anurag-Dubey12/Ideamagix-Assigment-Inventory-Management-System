import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:idea_assignment/Auth/SignUp.dart';
import 'package:idea_assignment/repo/InventoryProvider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'Category/EditCategoryScreen.dart';
import 'History/HistoryScreen.dart';
import 'HomeScreen.dart';
import 'Product/AddProductScreen.dart';
import 'Product/EditProductScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: "AIzaSyA4MkV9EJ8Jpz6oQb8TJqigfDW4nOvTDoY",
          authDomain: "give4good-90ed5.firebaseapp.com",
          databaseURL: "https://give4good-90ed5-default-rtdb.firebaseio.com",
          projectId: "give4good-90ed5",
          storageBucket: "give4good-90ed5.appspot.com",
          messagingSenderId: "742348535375",
          appId: "1:742348535375:web:8d42666b0746b488511c3a",
          measurementId: "G-TLL1WK7X5H"
      )
  );
  SharedPreferences prefs = await SharedPreferences.getInstance();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => InventoryProvider(),

      child: MaterialApp(
        title: 'Inventory Management System',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: user != null ? HomeScreen() : Signup(),
        routes: {
          AddProductScreen.routeName: (context) => AddProductScreen(),
          EditProductScreen.routeName: (context) => EditProductScreen(),
          EditCategoryScreen.routeName: (context) => EditCategoryScreen(docId: '',),


        },
      ),
    );
  }
}
