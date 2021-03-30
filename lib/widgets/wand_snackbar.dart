import 'package:flutter/material.dart';

SnackBar buildSnackBar(BuildContext context, String text) {
  return SnackBar(
    content: Text("$text"),
    backgroundColor: Theme.of(context).primaryColor,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0)),
    ),
  );
}
