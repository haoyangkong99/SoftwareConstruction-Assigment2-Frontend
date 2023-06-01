import 'dart:io';

import 'package:card_swiper/card_swiper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stacked/stacked.dart';
import 'package:utmletgo/constants/_constants.dart';
import 'package:utmletgo/model/_model.dart';
import 'package:utmletgo/shared/_shared.dart';
import 'package:utmletgo/view/Manage/PhotoContainer.dart';
import 'package:utmletgo/view/PaymentAccount/PaymentAccountScreen.dart';
import 'package:utmletgo/viewmodel/_viewmodel.dart';

class EditItemScreen extends StatefulWidget {
  const EditItemScreen({super.key});

  @override
  State<EditItemScreen> createState() => _EditItemScreenState();
}

class _EditItemScreenState extends State<EditItemScreen> {
  XFile? _selectedCoverPhoto;
  final List<XFile?> _selectedOtherPhoto = [];
  bool selected = false, initial = true;
  int currentPage = 1;
  int selectedFirstIndex = 0;
  int selectedSecondIndex = 0;
  String? categoryChosen = '', subcategoryChosen = '', condition = '';
  Validation validator = Validation();
  final TextEditingController _title = TextEditingController();
  final TextEditingController _description = TextEditingController();
  final TextEditingController _price = TextEditingController();
  final TextEditingController _quantity = TextEditingController();
  String _location = locationOptionsWithoutWholeMalaysia[0];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  List<String>? paymentMethods = [];
  bool isLoading = false;
  List<Widget> photoList = [];
  Item item = Item();
  bool haveEmptyPhotoContainer = false;
  List<String> allImageUrls = [];

  getImage(
    ImageSource source,
    double width,
    double height,
    int index,
  ) async {
    XFile? image = await _picker.pickImage(source: source);

    if (image != null) {
      if (index == 0) {
        _selectedCoverPhoto = image;
        allImageUrls.removeAt(0);
        allImageUrls.insert(0, _selectedCoverPhoto!.path);
      } else {
        _selectedOtherPhoto.add(image);
        allImageUrls.add(image.path);
      }
      setState(() {});
    }
  }

  ImageProvider showImage(XFile file) {
    return FileImage(File(file.path));
  }

  List<Widget> getCategoryExpansionTiles() {
    return List<Widget>.generate(
        categoryList.length,
        (index) => ExpansionTile(
              title: Text(categoryList[index].name),
              children: [
                ListView.builder(
                    shrinkWrap: true,
                    itemCount: categoryList[index].subCategory.length,
                    itemBuilder: (context, secondindex) {
                      return InkWell(
                        onTap: () {
                          setState(() {
                            categoryChosen = categoryList[index].name;
                            subcategoryChosen =
                                categoryList[index].subCategory[secondindex];
                            if (selected) {
                              if (secondindex == selectedSecondIndex &&
                                  index == selectedFirstIndex) {
                                selected = false;
                                selectedFirstIndex = 0;
                                selectedSecondIndex = 0;
                              } else {
                                selectedFirstIndex = index;
                                selectedSecondIndex = secondindex;
                              }
                            } else {
                              selected = true;
                              selectedFirstIndex = index;
                              selectedSecondIndex = secondindex;
                            }
                          });
                        },
                        child: ListTile(
                          trailing: selected &&
                                  selectedSecondIndex == secondindex &&
                                  selectedFirstIndex == index
                              ? const Icon(
                                  Icons.radio_button_checked,
                                  color: Colors.blue,
                                )
                              : const Icon(Icons.radio_button_off),
                          title: Text(
                              categoryList[index].subCategory[secondindex]),
                        ),
                      );
                    })
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return ViewModelBuilder<ItemViewModel>.reactive(
        viewModelBuilder: () => ItemViewModel(),
        builder: (context, model, child) {
          if (model.dataReady('user') && model.dataReady('item')) {
            item = model.dataMap!['item'] as Item;
            StripeAccount? account =
                model.dataMap!['account'] as StripeAccount?;
            selected = true;

            if (condition!.isEmpty) {
              condition = item.condition;
            }
            if (categoryChosen!.isEmpty) {
              selectedFirstIndex = categoryList
                  .indexWhere((element) => element.name == item.category);
            }
            if (subcategoryChosen!.isEmpty) {
              selectedSecondIndex = categoryList[selectedFirstIndex]
                  .subCategory
                  .indexWhere((element) => element == item.subcategory);
            }
            if (initial) {
              _location = item.location;
              _title.text = item.title;
              _description.text = item.description;
              _quantity.text = item.quantity.toString();
              paymentMethods = item.paymentMethods;
              _price.text = item.price.toStringAsFixed(2);
              initial = false;
            }

            if (allImageUrls.isEmpty) {
              allImageUrls.add(_selectedCoverPhoto == null
                  ? item.coverImage
                  : _selectedCoverPhoto!.path);
              allImageUrls.addAll(item.images as Iterable<String>);
            } else {
              allImageUrls.removeAt(0);
              allImageUrls.insert(
                  0,
                  _selectedCoverPhoto == null
                      ? item.coverImage
                      : _selectedCoverPhoto!.path);
            }

            return Scaffold(
              resizeToAvoidBottomInset: false,
              appBar: basicAppBar(
                height: height,
                automaticallyImplyLeading: true,
                title: const Text(
                  "Edit Item",
                ),
                actions: [
                  IconButton(
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (context) => CustomDialogBox(
                                  title: 'Delete confirmation',
                                  content:
                                      'Are you sure to remove this item from your listing?',
                                  isOtherContent: false,
                                  isConfirm: true,
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text(
                                        "Cancel",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: kPrimaryColor),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        setState(() {
                                          isLoading = true;
                                        });
                                        await model
                                            .updateItemStatus(
                                                item.guid, ItemStatus.deleted)
                                            .whenComplete(() {
                                          setState(() {
                                            isLoading = false;
                                          });
                                          model
                                              .navigateToManageItemListingScreen();
                                        }).onError<Exception>((error,
                                                    stackTrace) =>
                                                showExceptionErrorDialogBox(
                                                    context,
                                                    error,
                                                    "Error Occured During Updating Status"));
                                      },
                                      child: const Text(
                                        "Confirm",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: kPrimaryColor),
                                      ),
                                    )
                                  ],
                                ));
                      },
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.white,
                      ))
                ],
              ),
              body: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        backgroundColor: kPrimaryColor,
                      ),
                    )
                  : Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: getProportionateScreenWidth(
                              20, MediaQuery.of(context).size.width)),
                      child: Form(
                        key: _formKey,
                        child: SingleChildScrollView(
                          child: currentPage == 1
                              ? Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Photos For Your Items",
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black),
                                        textAlign: TextAlign.left,
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      const Text(
                                          "Please provide images related to your images to help buyers in making purchase decision."),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      SizedBox(
                                        height: height * 0.4,
                                        child: Swiper(
                                          viewportFraction: 0.8,
                                          scale: 0.9,
                                          loop: false,
                                          indicatorLayout:
                                              PageIndicatorLayout.COLOR,
                                          itemCount: allImageUrls.length <= 4
                                              ? allImageUrls.length + 1
                                              : allImageUrls.length,
                                          itemBuilder: (context, idx) {
                                            if (allImageUrls.length <= 4 &&
                                                idx == allImageUrls.length) {
                                              return PhotoContainer(
                                                  onTap: () {
                                                    selectFileMethod(
                                                        context, idx);
                                                  },
                                                  url: '',
                                                  isCover: false,
                                                  isNetworkImage: false,
                                                  isEmpty: true);
                                            }
                                            return PhotoContainer(
                                                onDelete: () {
                                                  allImageUrls.removeAt(idx);
                                                  setState(() {});
                                                },
                                                onTap: () {
                                                  selectFileMethod(
                                                      context, idx);
                                                },
                                                url: allImageUrls[idx],
                                                isCover: idx == 0,
                                                isNetworkImage: Validation()
                                                    .isURL(allImageUrls[idx]),
                                                isEmpty: false);
                                          },
                                          pagination: const SwiperPagination(),
                                          control: const SwiperControl(),
                                        ),
                                      ),
                                      SizedBox(
                                        height: height * 0.1,
                                      ),
                                      Center(
                                        child: Btn(
                                            text: "Continue",
                                            textStyle: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 16),
                                            backgroundColor: kPrimaryColor,
                                            borderColor: kPrimaryColor,
                                            width: width * 0.75,
                                            height: height * 0.07,
                                            onPressed: () {
                                              if (allImageUrls.isEmpty) {
                                                validateCoverPhoto(context);
                                              } else {
                                                setState(() {
                                                  currentPage = 2;
                                                });
                                              }
                                            },
                                            isRound: false),
                                      )
                                    ],
                                  ),
                                )
                              : Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      const Text(
                                        "Describle About The Items You Are Selling",
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black),
                                        textAlign: TextAlign.start,
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      const Text(
                                          "Please provide related information of items in the fields provided."),
                                      ExpansionTile(
                                        subtitle: const Text(
                                            "Select your item category"),
                                        title: const Text(
                                          "Item Category",
                                          style: TextStyle(fontSize: 16),
                                        ),
                                        children: getCategoryExpansionTiles(),
                                      ),
                                      ExpansionTile(
                                        title: const Text("Item Condition"),
                                        children: [
                                          RadioListTile(
                                              title: const Text("New"),
                                              value: "New",
                                              groupValue: condition,
                                              onChanged: (String? value) {
                                                setState(() {
                                                  condition = value;
                                                });
                                              }),
                                          RadioListTile(
                                              title: const Text("Used"),
                                              value: "Used",
                                              groupValue: condition,
                                              onChanged: (String? value) {
                                                setState(() {
                                                  condition = value;
                                                });
                                              })
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      inputTextFormField(
                                        controller: _title,
                                        obscureText: false,
                                        validator: validator.validateEmpty,
                                        labelText: "Item Title",
                                        hintText:
                                            "Attractive title of your item",
                                        keybordType: TextInputType.text,
                                        floatingLabelBehavior:
                                            FloatingLabelBehavior.always,
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      TextFormField(
                                        maxLines: null,
                                        controller: _description,
                                        obscureText: false,
                                        validator: validator.validateEmpty,
                                        keyboardType: TextInputType.multiline,
                                        decoration: const InputDecoration(
                                          labelText: "Item Description",
                                          hintText:
                                              "Wirte something to describe about the item",
                                          floatingLabelBehavior:
                                              FloatingLabelBehavior.always,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      inputTextFormField(
                                        controller: _price,
                                        obscureText: false,
                                        validator: validator.validateEmpty,
                                        labelText: "Item Price",
                                        hintText: "Price",
                                        keybordType: const TextInputType
                                            .numberWithOptions(decimal: true),
                                        floatingLabelBehavior:
                                            FloatingLabelBehavior.always,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(
                                              RegExp(r'^\d+\.?\d{0,2}')),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      inputTextFormField(
                                        controller: _quantity,
                                        obscureText: false,
                                        validator: validator.validateEmpty,
                                        labelText: "Item Quantity",
                                        hintText: "Quantity",
                                        keybordType: const TextInputType
                                            .numberWithOptions(decimal: false),
                                        floatingLabelBehavior:
                                            FloatingLabelBehavior.always,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.digitsOnly
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      Container(
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 16.0),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16.0),
                                        decoration: const BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(5))),
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton(
                                            focusColor: kPrimaryColor,
                                            //   dropdownColor: Colors.lightBlue[100],
                                            borderRadius:
                                                BorderRadius.circular(25),
                                            items: locationOptions.map((val) {
                                              return DropdownMenuItem<String>(
                                                value: val,
                                                child: Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Text(
                                                      val,
                                                      maxLines: 2,
                                                      semanticsLabel: '...',
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    )),
                                              );
                                            }).toList(),
                                            onChanged: (newValue) {
                                              setState(() {
                                                _location = newValue.toString();
                                              });
                                            },
                                            value: _location,
                                            isExpanded: true,
                                            icon: const Icon(
                                                Icons.keyboard_arrow_down),
                                            elevation: 0,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      const SubTitleHeader(
                                          text: "Payment Methods"),
                                      FormBuilderFilterChip<String>(
                                        initialValue: paymentMethods,
                                        elevation: 5,
                                        labelStyle: const TextStyle(
                                            color: Colors.black),
                                        backgroundColor: Colors.grey[200],
                                        crossAxisAlignment:
                                            WrapCrossAlignment.center,
                                        alignment: WrapAlignment.spaceEvenly,
                                        decoration: const InputDecoration(
                                            enabledBorder: InputBorder.none),
                                        autovalidateMode:
                                            AutovalidateMode.onUserInteraction,
                                        name: 'condition filter',
                                        selectedColor: kPrimaryColor,
                                        options: account != null &&
                                                account.details_submitted
                                            ? [
                                                FormBuilderChipOption(
                                                  value:
                                                      'Cash On Delivery (COD)',
                                                ),
                                                FormBuilderChipOption(
                                                  value: 'Credit/Debit Card',
                                                ),
                                                FormBuilderChipOption(
                                                  value: 'Self-arrange',
                                                ),
                                              ]
                                            : [
                                                FormBuilderChipOption(
                                                  value:
                                                      'Cash On Delivery (COD)',
                                                ),
                                                FormBuilderChipOption(
                                                  value: 'Self-arrange',
                                                ),
                                              ],
                                        onChanged: (value) {
                                          paymentMethods = value;
                                        },
                                      ),
                                      account == null ||
                                              !account.details_submitted
                                          ? Chip(
                                              label: Text(
                                                'Credit/Debit Card',
                                                style: const TextStyle(
                                                    color: Colors.white),
                                              ),
                                              backgroundColor: Colors.grey,
                                            )
                                          : Center(),
                                      account == null ||
                                              !account.details_submitted
                                          ? TextButton(
                                              onPressed: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            PaymentAccountScreen()));
                                              },
                                              child: Text(
                                                'Note: Tap me to enable credit/debit card payment method by setting up or completing your payment account',
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color: Colors.red),
                                              ))
                                          : Center(),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      Center(
                                        child: Btn(
                                            text: "Save",
                                            textStyle: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 16),
                                            backgroundColor: kPrimaryColor,
                                            borderColor: kPrimaryColor,
                                            width: width * 0.75,
                                            height: height * 0.07,
                                            onPressed: () async {
                                              bool validate = model
                                                  .validateFields(_formKey);
                                              if (paymentMethods!.isEmpty) {
                                                validateFields(context);
                                              } else if (paymentMethods!
                                                      .isNotEmpty &&
                                                  validate) {
                                                setState(() {
                                                  isLoading = true;
                                                });
                                                await model
                                                    .updateItem(
                                                        item,
                                                        allImageUrls,
                                                        categoryList[
                                                                selectedFirstIndex]
                                                            .name,
                                                        categoryList[
                                                                    selectedFirstIndex]
                                                                .subCategory[
                                                            selectedSecondIndex],
                                                        condition,
                                                        _title.text,
                                                        _description.text,
                                                        _location,
                                                        paymentMethods,
                                                        double.parse(
                                                            _price.text),
                                                        int.parse(
                                                            _quantity.text))
                                                    .then((value) {
                                                      setState(() {
                                                        isLoading = false;
                                                      });
                                                    })
                                                    .then((value) =>
                                                        showCompleteUpdateDialogBox(
                                                            context))
                                                    .then((value) {
                                                      Navigator.pop(context);
                                                      return value;
                                                    })
                                                    .onError<
                                                        FirebaseException>((error,
                                                            stackTrace) =>
                                                        showFirebaseExceptionErrorDialogBox(
                                                            context, error));
                                              }
                                            },
                                            isRound: false),
                                      )
                                    ],
                                  ),
                                ),
                        ),
                      ),
                    ),
            );
          } else {
            return const Center(
                child: CircularProgressIndicator(
              color: kPrimaryColor,
            ));
          }
        });
  }

  Future<dynamic> validateCoverPhoto(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) => const CustomDialogBox(
              title: "Incomplete Cover Photo",
              content: 'Please makesure the cover photo is uploaded',
            ));
  }

  Future<dynamic> validateFields(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) => const CustomDialogBox(
              title: "Incomplete Fields",
              content:
                  'Please makesure \n\n1. At least one payment method is selected\n2. Both category and subcategory are selected',
            ));
  }

  Future<dynamic> selectFileMethod(BuildContext context, int idx) {
    return showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
              height: 80,
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      IconButton(
                          onPressed: () {
                            getImage(
                                ImageSource.camera,
                                getMediaQueryWidth(context),
                                getMediaQueryHeight(context),
                                idx);
                          },
                          icon: const Icon(
                            Icons.camera_alt,
                          )),
                      const Text('Choose From Camera')
                    ],
                  ),
                  Column(
                    children: [
                      IconButton(
                          onPressed: () {
                            getImage(
                                ImageSource.gallery,
                                getMediaQueryWidth(context),
                                getMediaQueryHeight(context),
                                idx);

                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.file_copy)),
                      const Text('Choose From Gallery')
                    ],
                  ),
                ],
              ));
        });
  }
}
