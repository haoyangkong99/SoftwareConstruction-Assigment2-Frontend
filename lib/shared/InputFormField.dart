import 'package:flutter/material.dart';

Container inputTextFormField({
  obscureText,
  onSaved,
  onChanged,
  validator,
  String? labelText,
  required String hintText,
  controller,
  suffixIcon,
  keybordType,
  floatingLabelBehavior,
  double? width,
  double? height,
  double radius = 0,
  inputFormatters,
}) {
  return Container(
    width: width,
    height: height,
    decoration: const BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(5)),
      color: Colors.white,
    ),
    child: TextFormField(
      inputFormatters: inputFormatters,
      controller: controller,
      keyboardType: keybordType,
      obscureText: obscureText,
      onSaved: onSaved,
      onChanged: onChanged,
      validator: validator,
      decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          floatingLabelBehavior: floatingLabelBehavior,
          suffixIcon: suffixIcon,
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(radius))),
    ),
  );
}
