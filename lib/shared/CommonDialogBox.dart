import 'package:flutter/material.dart';
import 'package:utmletgo/shared/_shared.dart';

Future showIncompleteFieldsDialogBox(BuildContext context) async {
  await showDialog(
      context: context,
      builder: (BuildContext context) => const CustomDialogBox(
            title: "Incomplete Fields",
            content: "Please makesure all fields have been filled in",
          ));
}

Future showEmptyPriceFieldDialogBox(BuildContext context) async {
  await showDialog(
      context: context,
      builder: (BuildContext context) => const CustomDialogBox(
            title: "Empty Price Field",
            content: "Please makesure the price field is not empty",
          ));
}

Future<void> showCompleteUpdateDialogBox(BuildContext context) async {
  await showDialog(
      context: context,
      builder: (BuildContext context) => const CustomDialogBox(
            title: "Update Successfully",
            content: "You have updated successfully",
          ));
}

Future<void> showCompleteSubmissionDialogBox(BuildContext context) async {
  await showDialog(
      context: context,
      builder: (BuildContext context) => const CustomDialogBox(
            title: "Submitted Successfully",
            content: "You have submitted successfully",
          ));
}

Future<void> showCompleteGenerateLinkDialogBox(BuildContext context) async {
  await showDialog(
      context: context,
      builder: (BuildContext context) => const CustomDialogBox(
            title: "Link has been generated Successfully",
            content:
                "Open the link to proceed with your stripe account.\n**Note: This link can only be opened once**",
          ));
}

Future showCompleteRegistrationDialogBox(BuildContext context) async {
  await showDialog(
      context: context,
      builder: (BuildContext context) => const CustomDialogBox(
            title: "Register Successfully",
            content: "You have registered your account sucessfully",
          ));
}

Future showCompleteResetPassowrdDialogBox(BuildContext context) async {
  await showDialog(
      context: context,
      builder: (BuildContext context) => const CustomDialogBox(
            title: "Reset Password",
            content:
                'A reset password email has been sent to the email address provided',
          ));
}

Future showSwiperSelectionDialogBox(
    BuildContext context, String title, dynamic actions, Widget content) async {
  await showDialog(
      context: context,
      builder: (BuildContext context) => CustomDialogBox(
            title: title,
            otherContent: content,
            isOtherContent: true,
            actions: actions,
            isConfirm: true,
          ));
}
