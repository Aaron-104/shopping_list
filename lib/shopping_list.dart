import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shopping_list/loading.dart';

import 'decoration.dart';

class shopping_list extends StatefulWidget {
  dynamic argument;
  shopping_list({this.argument});

  @override
  _shopping_listState createState() => _shopping_listState();
}

class _shopping_listState extends State<shopping_list> {
  bool cb = false;
  String itemName;

  CollectionReference itemReference =
      FirebaseFirestore.instance.collection("MyLists");

  CollectionReference historyReference =
  FirebaseFirestore.instance.collection("HistoryList");

  addItem(String id, String shopList) async {
    //Map
    Map<String, dynamic> items = {
      "itemName": itemName,
      "created": FieldValue.serverTimestamp(),
      "checkValue": cb
    };
    await itemReference
        .doc(id)
        .collection("ShoppingItem")
        .add(items)
        .whenComplete(() {
      print("$itemName created");
    });
    await historyReference
        .doc(shopList)
        .collection("ShoppingItem")
        .add(items)
        .whenComplete(() {
      print("$itemName created");
    });
  }

  Future removeItem(String id1, id2) async {
    await itemReference
        .doc(id1)
        .collection("ShoppingItem")
        .doc(id2)
        .delete()
        .whenComplete(() {
      print("$id2 deleted");
    });
  }

  modifyItem(String id1, id2) async {
    await itemReference
        .doc(id1)
        .collection("ShoppingItem")
        .doc(id2)
        .update({"itemName": itemName});
  }

  checkValue(String id1, id2) async {
    await itemReference
        .doc(id1)
        .collection("ShoppingItem")
        .doc(id2)
        .update({"checkValue": cb});
  }

  @override
  Widget build(BuildContext context) {
    void _showSettingsPanel() {
      //to display setting form to appear from bottom
      showModalBottomSheet(
          context: context,
          builder: (context) {
            return Container(
              //set the height
              padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 80.0),
              child: Form(
                child: Column(
                  children: <Widget>[
                    Container(
                      child: Text(
                        'ADD NEW ITEM',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    SizedBox(height: 20.0, width: 20.0),
                    TextFormField(
                      decoration: textInputDecoration,
                      validator: (val) =>
                          val.isEmpty ? 'Enter a new item' : null,
                      onChanged: (val) => setState(() => itemName = val),
                    ),
                    Padding(
                      padding: EdgeInsets.all(30.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Colors.amber[600],
                        ),
                        child: Text('Add'),
                        onPressed: () {
                          addItem(widget.argument[0], widget.argument[1]);

                          Navigator.of(context).pop();
                          //will remove alert dialog after adding
                        },
                      ),
                    ),
                  ],
                ),
              ),
              //itemAdd(),
            );
          });
    }

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(widget.argument[1].toString()),
        backgroundColor: Colors.amber[600],
        elevation: 0.0,
        //list of widget to display in a row after title
        actions: <Widget>[
          TextButton.icon(
            label: Text("Add"),
            icon: const Icon(Icons.add),
            style: TextButton.styleFrom(primary: Colors.white),
            onPressed: () => _showSettingsPanel(),
          )
        ],
      ),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("MyLists")
              .doc(widget.argument[0])
              .collection("ShoppingItem")
              .orderBy("created")
              .snapshots(),
          builder: (context, snapshots) {
            if (snapshots.hasData && !snapshots.hasError) {
              print("yes");
              print(snapshots
                  .data.docs.length); //to view how many items via console

              return ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshots.data.docs
                      .length, //decides number of time itemBuilder called
                  itemBuilder: (context, index) {
                    bool isChecked = snapshots.data.docs[index]['checkValue'];
                    return Card(
                      color: Colors.amberAccent[100],
                      margin: EdgeInsets.all(2), //space between each tile
                      child: ListTile(
                        leading: Checkbox(
                          value: isChecked,
                          onChanged: (bool value) {
                            setState(() {
                              cb = value;
                              checkValue(widget.argument[0],
                                  snapshots.data.docs[index].id);
                            });
                          },
                        ),
                        title: Text(
                          snapshots.data.docs[index]['itemName'],
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            Icons.settings_applications_outlined,
                            color: Colors.black,
                          ),
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                    title: Text("Modify Item"),
                                    content: TextFormField(
                                      decoration: textInputDecoration,
                                      initialValue: snapshots.data.docs[index]
                                          ['itemName'],
                                      onChanged: (String value) {
                                        //After insert value
                                        itemName = value;
                                      },
                                    ),
                                    actions: <Widget>[
                                      ElevatedButton(
                                        onPressed: () {
                                          removeItem(widget.argument[0],
                                              snapshots.data.docs[index].id);
                                          Navigator.of(context).pop();
                                        },
                                        child: Text("Delete"),
                                        style: ElevatedButton.styleFrom(
                                          primary: Colors.red,
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          modifyItem(widget.argument[0],
                                              snapshots.data.docs[index].id);
                                          Navigator.of(context).pop();
                                          //will remove alert dialog after adding
                                        },
                                        child: Text("Done"),
                                        style: ElevatedButton.styleFrom(
                                          primary: Colors.amber[600],
                                        ),
                                      ),
                                    ],
                                  );
                                });
                          },
                        ),
                      ),
                    );
                  });
            } else {
              return Loading();
            }
          }),
    );
  }
}
