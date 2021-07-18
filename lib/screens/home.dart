import 'package:flutter/material.dart';
import 'model/shopping_item.dart';

class Home extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient( //MIX MIX colors
            colors: [Color(0xabd542bf), Color(0xff51a8ff)],
            begin: FractionalOffset(0.5,1) //start from whr
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent, // Allow gradient to come through
        //backgroundColor: Colors.greenAccent[700],
        appBar: AppBar(
          title: Text("shopping list"),
        ),
        body: Column(

          children: [
            Expanded(
              child: AnimatedList(
                //item stored in animated list
                key: key,
                initialItemCount:
                items.length, //initial item count, later need update
                itemBuilder: (context, index, animation) =>
                    buildItem(items[index], index, animation),
              ),
            ),
            Container(
              // decoration: BoxDecoration(
              //   gradient: LinearGradient(
              //       //MIX MIX colors
              //       colors: [Color(0xabd542bf), Color(0xff51a8ff)],
              //       begin: FractionalOffset(0.5, 1) //start from whr
              //       ),
              // ),
              padding: EdgeInsets.all(16),
              child: InsertButton2(), //create insert button
            ),
          ],
        ),
      ),
    );

  }
  Widget InsertButton2() => Container(

    padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 18.0),
    decoration: BoxDecoration(
      color: Colors.black26,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20.0),
        topRight: Radius.circular(20.0),
      ),
    ),
    child: Row(
      children: [
        Expanded(
          child: TextField(
            //controller: inputController,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: "Type a new Task",
            ),
          ),
        ),
        SizedBox(
          width: 15.0,
        ),
        FlatButton.icon(
          icon: Icon(Icons.add, color: Colors.black),
          label: Text("Add Task"),
          color: Colors.yellow,
          shape: StadiumBorder(),
          textColor: Colors.black,
          onPressed: () {},
        )
      ],
    ),
  );

  Widget buildItem(item, int index, Animation<double> animation) =>
      ShoppingItemWidget(
        item: item,
        animation: animation,
        onClicked: () =>
            removeItem(index), //call method to remove item from list
      );

  Widget buildInsertButton() => RaisedButton(
    child: Text(
      'Insert item',
      style: TextStyle(fontSize: 20),
    ),
    shape: RoundedRectangleBorder(
      //for circular button
      borderRadius: BorderRadius.circular(18.0),
    ),
    color: Colors.white,
    onPressed: () => insertItem(0, Data.shoppingList.elementAt(2)),
    //insert at pos 0, means insert at the top/first
  );

  void insertItem(int index, ShoppingItem item) {
    //((insert position), item included)
    items.insert(index, item);
    key.currentState.insertItem(index);
  }

  void removeItem(int index) {
    //method to remove item from list
    //1. delete from item list
    final item = items.removeAt(index);

    //2. delete from animated list
    key.currentState.removeItem(
      index,
          (context, animation) => buildItem(item, index, animation),
    );
  }
}
