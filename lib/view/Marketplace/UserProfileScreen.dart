import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:utmletgo/constants/_constants.dart';
import 'package:utmletgo/model/_model.dart';
import 'package:utmletgo/shared/_shared.dart';
import 'package:utmletgo/view/Review/ReviewScreen.dart';
import 'package:utmletgo/viewmodel/UserProfileViewModel.dart';

class UserProfileScreen extends StatefulWidget {
  String userGuid;
  UserProfileScreen({super.key, required this.userGuid});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  int currentIndex = 0;
  ImageProvider showProfileImage(User data) {
    if (data.profilePicture.isNotEmpty) {
      return NetworkImage(data.profilePicture);
    } else {
      return AssetImage(data.gender == Gender.Male.name
          ? "assets/images/man profile icon.png"
          : "assets/images/lady profile icon.png");
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = getMediaQueryHeight(context);
    double width = getMediaQueryWidth(context);
    return ViewModelBuilder<UserProfileViewModel>.reactive(
        viewModelBuilder: () => UserProfileViewModel(userGuid: widget.userGuid),
        builder: (context, model, child) {
          if (!model.dataReady('user') || !model.dataReady('item')) {
            return Center(
                child: CircularProgressIndicator(
              color: kPrimaryColor,
            ));
          } else {
            User user = model.dataMap!['user'];
            List<Item> itemList = model.dataMap!['item'];
            itemList = itemList
                .where((element) => user.itemLink.contains(element.guid))
                .toList();
            return Scaffold(
              appBar: basicAppBar(
                height: getMediaQueryHeight(context),
                automaticallyImplyLeading: true,
                title: Text(
                  user.name,
                ),
              ),
              body: Column(
                children: [
                  SizedBox(
                    height: height * 0.02,
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(bottom: height * 0.01), //10
                          height: 140, //140
                          width: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 5, //8
                            ),
                            boxShadow: [
                              BoxShadow(
                                  spreadRadius: 2,
                                  blurRadius: 10,
                                  color: Colors.black.withOpacity(0.1),
                                  offset: const Offset(0, 10))
                            ],
                            image: DecorationImage(
                              fit: BoxFit.fill,
                              image: showProfileImage(user),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.yellow,
                              size: 30,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                              user.reviewsLink.averageRating.toStringAsFixed(1),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          Text(
                            itemList.length.toString(),
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            "Items",
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.normal),
                          ),
                        ],
                      ),
                      Container(
                        color: Colors.black54,
                        width: 1,
                        height: 15,
                        margin: EdgeInsets.symmetric(horizontal: 15),
                      ),
                      Column(
                        children: [
                          Text(
                            user.reviewsLink.reviewsCount.toString(),
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            "Reviews",
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.normal),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Container(
                    height: 45,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black12)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              currentIndex = 0;
                            });
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text('Listings'),
                              SizedBox(
                                height: 7,
                              ),
                              Container(
                                color: currentIndex == 0
                                    ? kPrimaryColor
                                    : Colors.transparent,
                                height: 2,
                                width: width * 0.2,
                              )
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              currentIndex = 1;
                            });
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text('Reviews'),
                              SizedBox(
                                height: 7,
                              ),
                              Container(
                                color: currentIndex == 1
                                    ? kPrimaryColor
                                    : Colors.transparent,
                                height: 2,
                                width: width * 0.2,
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  currentIndex == 0
                      ? Expanded(
                          child: GridView.builder(
                              shrinkWrap: true,
                              itemCount: itemList.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2, // number of columns
                                mainAxisSpacing: 10, // space between rows
                                crossAxisSpacing: 10, // space between columns
                                childAspectRatio:
                                    0.75, // width / height ratio of each item
                              ),
                              itemBuilder: (contex, index) => InkWell(
                                    onTap: () {
                                      model.navigateToItemDetailScreen(
                                          itemList[index].guid);
                                    },
                                    child: SizedBox(
                                      height: height * 0.2,
                                      child: GridTile(
                                        footer: GridTileBar(
                                          backgroundColor: Colors.black54,
                                          title: Text(itemList[index].title),
                                          subtitle: Text(
                                              'RM ${itemList[index].price.toStringAsFixed(2)}'),
                                        ),
                                        child: Container(
                                          decoration: BoxDecoration(
                                              image: DecorationImage(
                                            image: NetworkImage(
                                                itemList[index].coverImage),
                                            fit: BoxFit.contain,
                                          )),
                                        ),
                                      ),
                                    ),
                                  )),
                        )
                      : Expanded(
                          child: ReviewScreen(
                          sellerGuid: user.guid,
                          showAppBar: false,
                        ))
                ],
              ),
            );
          }
        });
  }
}
