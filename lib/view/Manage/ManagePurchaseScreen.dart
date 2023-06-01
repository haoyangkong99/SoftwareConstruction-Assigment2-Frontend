import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:utmletgo/constants/_constants.dart';
import 'package:utmletgo/model/_model.dart';
import 'package:utmletgo/shared/_shared.dart';
import 'package:utmletgo/viewmodel/_viewmodel.dart';

class ManagePurchaseScreen extends StatefulWidget {
  const ManagePurchaseScreen({super.key});

  @override
  State<ManagePurchaseScreen> createState() => _ManagePurchaseScreenState();
}

class _ManagePurchaseScreenState extends State<ManagePurchaseScreen>
    with SingleTickerProviderStateMixin {
  TabController? controller;
  @override
  void initState() {
    super.initState();
    controller = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double height = getMediaQueryHeight(context);
    return Scaffold(
        appBar: basicAppBar(
          automaticallyImplyLeading: true,
          height: height,
          title: const Text(
            "Manage Purchases",
          ),
          bottom: TabBar(
              controller: controller,
              unselectedLabelColor: Colors.black,
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorColor: Colors.white,
              indicatorWeight: 4,
              tabs: const [
                Tab(
                  child: Text(
                    "In Progress",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Tab(
                    child: Text(
                  "Completed",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                )),
                Tab(
                    child: Text(
                  "Cancelled",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ))
              ]),
        ),
        body: ViewModelBuilder<ManagePurchaseViewModel>.reactive(
          viewModelBuilder: () => ManagePurchaseViewModel(),
          builder: (context, model, child) {
            if (model.dataReady('item') && model.dataReady('order')) {
              List<Order> orderList = model.dataMap!['order'] ?? [];
              List<Item> itemList = model.dataMap!['item'];
              Set<String> orderedItemList =
                  orderList.map((e) => e.itemGuid).toSet();
              itemList = itemList
                  .where((element) => orderedItemList.contains(element.guid))
                  .toList();

              List<Item> inProgressItemList = itemList
                  .where((element) =>
                      element.status == ItemStatus.in_progress.name)
                  .toList();
              List<Item> completedItemList = itemList
                  .where(
                      (element) => element.status == ItemStatus.completed.name)
                  .toList();
              List<Item> cancelledItemList = itemList
                  .where((element) => orderList
                      .where(
                          (order) => order.status == OrderStatus.cancelled.name)
                      .map((e) => e.itemGuid)
                      .contains(element.guid))
                  .toList();
              return TabBarView(
                controller: controller,
                children: [
                  showItemList(inProgressItemList, model),
                  showItemList(completedItemList, model),
                  showItemList(cancelledItemList, model),
                ],
              );
            } else {
              return const Center(
                  child: CircularProgressIndicator(
                color: kPrimaryColor,
              ));
            }
          },
        ));
  }

  Widget showItemList(List<Item>? data, ManagePurchaseViewModel model) {
    return data!.isEmpty
        ? Container(
            decoration: const BoxDecoration(
                image: DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage('assets/images/No item posted.png'))),
          )
        : ListView(
            children: <Widget>[
              ListView.builder(
                primary: false,
                shrinkWrap: true,
                itemCount: data.length,
                itemBuilder: (BuildContext context, int index) {
                  return ItemCard(
                    onTap: () {
                      model.navigateToMyPurchaseScreen(
                          data[index].guid, controller!.index);
                    },
                    img: data[index].coverImage,
                    title: data[index].title,
                    price: data[index].price,
                    quantity: data[index].quantity,
                  );
                },
              ),
            ],
          );
  }
}
