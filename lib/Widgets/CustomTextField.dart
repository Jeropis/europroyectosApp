import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget CustomTextField(String text, TextEditingController textUserController,Icon icon) {
  return Container(
    padding: EdgeInsets.all(10),
    child: Form(
        child: Column(
      children: [
        const Padding(padding: EdgeInsets.only(top: 8.0)),
         Text(
          text,
          style: TextStyle(color: Colors.black54),
        ),
        const Padding(padding: EdgeInsets.only(bottom: 16.0)),
        TextFormField(
          decoration:  InputDecoration(
              prefixIcon: icon,
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(width: 2, color: Colors.lightBlue),
                borderRadius: BorderRadius.all(Radius.circular(25.0)),
              ),
              border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25.0)))),
          controller: textUserController,
        ),
      ],
    )),
  );
}
