import 'package:shopping_list/model/shopping_item.dart';
import 'package:flutter/material.dart';

class ShoppingItemWidget extends StatelessWidget {
  final ShoppingItem item;
  final Animation<double> animation;
  final VoidCallback onClicked;

  const ShoppingItemWidget({
    this.item,
    this.animation,
    this.onClicked,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => ScaleTransition(
    scale: animation,
    child: Container( //container for each item
      decoration: BoxDecoration(
        gradient: LinearGradient( //MIX MIX colors
            colors: [Color(0xabd542bf), Color(0xff51a8ff)],
            begin: FractionalOffset(0.5,1) //start from whr
        ),
      ),
      margin: EdgeInsets.all(8), //include spacing for each item
      // decoration: BoxDecoration(
      //   borderRadius: BorderRadius.circular(12),
      //   color: Colors.white,
      // ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        leading: CircleAvatar(
          radius: 32,
          backgroundImage: NetworkImage(item.urlImage),
        ),
        title: Text(item.title, style: TextStyle(fontSize: 20)),
        trailing: IconButton(
          icon: Icon(Icons.check_circle, color: Colors.white, size: 32),
          onPressed: onClicked,
        ),
      ),
    ),
  );
}


