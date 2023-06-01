import 'package:flutter/material.dart';
import 'package:utmletgo/constants/_constants.dart';

class SearchBar extends StatelessWidget {
  const SearchBar(
      {Key? key,
      this.hintText = "Search product",
      this.onChanged,
      this.controller,
      this.onTap})
      : super(key: key);
  final String? hintText;
  final dynamic onChanged, onTap;
  final TextEditingController? controller;
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Container(
      height: height * 0.05,
      width: width * 0.8,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextFormField(
        controller: controller,
        onChanged: onChanged,
        onTap: onTap,
        decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(
                horizontal: getProportionateScreenWidth(20, width),
                vertical: getProportionateScreenWidth(6, height)),
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            hintText: hintText,
            prefixIcon: const Icon(Icons.search)),
      ),
    );
  }
}
