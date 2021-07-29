import 'package:flutter/material.dart';

const textInputDecoration = InputDecoration(
  fillColor: Colors.white,
  filled: true,
  enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.black, width: 2.0)),
  //when pressed
  focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.amberAccent, width: 2.0)),
);
