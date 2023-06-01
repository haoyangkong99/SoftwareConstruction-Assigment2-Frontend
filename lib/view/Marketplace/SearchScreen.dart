import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:utmletgo/constants/constants.dart';
import 'package:utmletgo/constants/enum_constants.dart';
import 'package:utmletgo/model/_model.dart';
import 'package:utmletgo/shared/ItemCard.dart';
import 'package:utmletgo/viewmodel/_viewmodel.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  String selectedPeriod = "";
  String selectedCategory = "";
  String selectedPrice = "";

  List<Item> searchResults = [];

  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: SafeArea(
          top: true,
          bottom: false,
          child: Scaffold(
              body: ViewModelBuilder<MarketplaceViewModel>.reactive(
            viewModelBuilder: () => MarketplaceViewModel(),
            builder: (context, model, child) {
              if (model.dataReady('item') && model.dataReady('currentUser')) {
                List<Item> itemList = model.dataMap!['item'];
                User currentUser = model.dataMap!['currentUser'];

                itemList = itemList
                    .where((element) =>
                        element.visibility == VisibilityType.allow.name &&
                        element.status == ItemStatus.to_start.name &&
                        !currentUser.itemLink.contains(element.guid))
                    .toList();
                return Container(
                  margin: const EdgeInsets.only(top: kToolbarHeight),
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            const Text(
                              'Search',
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 22,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const CloseButton()
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16.0),
                        decoration: const BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                                    color: kPrimaryColor, width: 1))),
                        child: TextField(
                          controller: searchController,
                          onChanged: (value) {
                            if (value.isNotEmpty) {
                              List<Item> tempList = [];
                              itemList.forEach((item) {
                                if (item.title.toLowerCase().contains(value)) {
                                  tempList.add(item);
                                }
                              });
                              setState(() {
                                searchResults.clear();
                                searchResults.addAll(tempList);
                              });
                            } else {
                              setState(() {
                                searchResults.clear();
                                searchResults.addAll(itemList.map((e) => e));
                              });
                            }
                          },
                          cursorColor: Colors.grey,
                          decoration: InputDecoration(
                            focusedBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            border: InputBorder.none,
                            prefixIcon: const Icon(
                              Icons.search,
                              color: Colors.black,
                              size: 30,
                            ),
                            suffix: TextButton(
                              onPressed: () {
                                searchController.clear();
                                searchResults.clear();
                              },
                              child: const Text(
                                'Clear',
                                style: TextStyle(color: kPrimaryColor),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        child: Container(
                          color: Colors.orange[50],
                          child: ListView.builder(
                              itemCount: searchResults.length,
                              itemBuilder: (_, index) => ItemCard(
                                    img: searchResults[index].coverImage,
                                    title: searchResults[index].title,
                                    price: searchResults[index].price,
                                    quantity: searchResults[index].quantity,
                                    onTap: () {
                                      model.navigateToItemDetailScreen(
                                          searchResults[index].guid);
                                    },
                                  )),
                        ),
                      )
                    ],
                  ),
                );
              } else {
                return const Center(
                  child: CircularProgressIndicator(
                    color: kPrimaryColor,
                  ),
                );
              }
            },
          ))),
    );
  }
}
