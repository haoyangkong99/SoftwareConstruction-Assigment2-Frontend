import 'package:flutter/material.dart';
import 'package:utmletgo/shared/_shared.dart';
import 'package:utmletgo/view/Manage/ManageItemListingScreen.dart';
import 'package:utmletgo/view/Manage/ManagePurchaseScreen.dart';

class ManageScreen extends StatefulWidget {
  const ManageScreen({Key? key}) : super(key: key);

  @override
  State<ManageScreen> createState() => _ManageScreenState();
}

class _ManageScreenState extends State<ManageScreen> {
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: basicAppBar(
        height: height,
        title: const Text(
          "Manage",
          // style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          MenuOptions(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ManagePurchaseScreen()));
              },
              icon: const Icon(Icons.shopping_cart),
              text: "Purchase"),
          MenuOptions(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ManageItemListingScreen()));
              },
              icon: const Icon(Icons.sell),
              text: "Item Listing")
        ],
      ),
    );
  }
}
