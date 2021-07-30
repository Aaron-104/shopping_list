import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'loading.dart';

class history extends StatefulWidget {


  @override
  _historyState createState() => _historyState();
}

class _historyState extends State<history> {

  CollectionReference historyReference =
  FirebaseFirestore.instance.collection("HistoryList");

  CollectionReference listReference =
  FirebaseFirestore.instance.collection("MyLists");

  Future restoreShopList(String id, String listName) async {

    await listReference.doc(id).set(
        {"shoppingList": listName, "created": FieldValue.serverTimestamp()});

    await historyReference.doc(id).collection("ShoppingItem").get().then((value) {
      value.docs.forEach((element) async {
        await listReference.doc(id).collection("ShoppingItem").add({
          'itemName': element['itemName'] ?? " ",
          'created': element['created'] ?? " ",
          'checkValue': false,
        });
        element.reference.delete();
      });
    });

    historyReference.doc(id).delete().whenComplete(() {
      print("$id deleted");
    });
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text("List History"),
        backgroundColor: Colors.amber[600],
      ),

      body: StreamBuilder(
          stream: FirebaseFirestore.instance.collection("HistoryList").snapshots(),
          builder: (context, snapshots) {
            if (snapshots.hasData && !snapshots.hasError) {
              print("yes");
              print(snapshots.data.docs.length);
              return ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshots.data.docs.length,
                  itemBuilder: (context, index) {
                    return Card(
                      color: Colors.amberAccent[100],
                      elevation: 4, //elevation of each tile
                      margin: EdgeInsets.all(8), //space between each tile
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      child: ListTile(
                        title:
                        Text(snapshots.data.docs[index]["shoppingList"]),
                        trailing: IconButton(
                            icon: Icon(
                              Icons.restore_from_trash_outlined,
                              color: Colors.black,
                            ),
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              8)),
                                      title: Text(
                                          "Confirm Restore?"),
                                      actions: <Widget>[
                                        ElevatedButton(
                                          onPressed: () async {
                                            await restoreShopList(
                                                snapshots.data.docs[index].id,
                                                snapshots.data
                                                    .docs[index]["shoppingList"]);
                                            Navigator.of(context).pop();
                                          },
                                          //will remove alert dialog after adding

                                          child: Text("Confirm"),
                                            style: ElevatedButton.styleFrom(
                                              primary: Colors.amber[600],
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () => print('cancel'),
                                          child: Text(
                                              "Cancel",
                                            style: TextStyle(
                                              color: Colors.black,
                                            )
                                          ),
                                        )
                                      ],
                                    );
                                  });
                            }

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

