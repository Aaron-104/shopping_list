import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.brown[100],
        child: Center(
          //a type of loading animation form the flutter_spinkit package
            child: SpinKitDualRing(
          color: Colors.amber[600],
          size: 50.0,
        )));
  }
}
