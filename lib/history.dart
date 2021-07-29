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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text("List History"),
        backgroundColor: Colors.amber[600],
      ),
      //NEED USE streambuilder to use firestore instance
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
                    //DocumentSnapshot documentSnapshot = snapshots.data.docs[index];
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
                              Icons.keyboard_return_outlined,
                              color: Colors.amberAccent[700],
                            ),
                            onPressed: () async {

                            }),
                        onTap: () {
                          Navigator.pushNamed(context, '/shopping_list',
                              arguments: [
                                snapshots.data.docs[index].id,
                                snapshots.data.docs[index]["shoppingList"]
                              ]);
                        },
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

