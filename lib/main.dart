import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shopping_list/loading.dart';
import 'package:shopping_list/shopping_list.dart';
import 'decoration.dart';
import 'history.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    initialRoute: '/',
    routes: {
      '/': (context) => MyApp(),
      '/shopping_list': (context) =>
          shopping_list(argument: ModalRoute.of(context).settings.arguments),
      '/history': (context) => history(),
    },
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
        brightness: Brightness.light),
  ));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  String shoppingList;
  final _formKey = GlobalKey<FormState>();

  //Creating Collection Reference for each collection
  CollectionReference listReference =
      FirebaseFirestore.instance.collection("MyLists");

  CollectionReference historyReference =
      FirebaseFirestore.instance.collection("HistoryList");


  //method to add new shopping list database
  addShopList() async {
    //Map
    Map<String, dynamic> shopList = {
      "shoppingList": shoppingList,
      "created": FieldValue.serverTimestamp()
      //shopping list created time
    };
    await listReference.add(shopList).whenComplete(() {
      print("$shoppingList created");
      //printed in console
    });
  }

  //method to delete and move shopping list to history
  Future deleteShopList(String id, String listName) async {
    await historyReference.doc(id).set(
        {"shoppingList": listName, "created": FieldValue.serverTimestamp()});

    await listReference.doc(id).collection("ShoppingItem").get().then((value) {
      value.docs.forEach((element) async {
        await historyReference.doc(id).collection("ShoppingItem").add({
          'itemName': element['itemName'] ?? " ",
          'created': element['created'] ?? " ",
          'checkValue': false,
        });
        element.reference.delete();
      });
    });

    listReference.doc(id).delete().whenComplete(() {
      print("$id deleted");
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text("Shopping List"),
        backgroundColor: Colors.amber[600],
        actions: <Widget>[
          TextButton.icon(
            label: Text("History"),
            icon: const Icon(Icons.history),
            style: TextButton.styleFrom(primary: Colors.white),
            onPressed: () => Navigator.pushNamed(context, '/history'),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.amber[600],
          onPressed: () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return Form(
                    key: _formKey,
                    child: AlertDialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      title: Text("Add Shopping List"),
                      content: TextFormField(
                        decoration: textInputDecoration,
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'Please do not leave empty';
                          }
                          return null;
                        },
                        onChanged: (val) {
                          //After insert value
                          shoppingList = val;
                        },
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            if(_formKey.currentState.validate()){
                              addShopList();
                              Navigator.of(context).pop();
                              //will remove alert dialog after adding
                            }

                          },
                          child: Text(
                            "Add",
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                });
          },
          child: Icon(
            Icons.add,
            color: Colors.white,
          )),

      //use StreamBuilder to use Firestore instance
      body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("MyLists")
              .orderBy("created")
              .snapshots(),
          builder: (context, snapshots) {
            if (snapshots.hasData && !snapshots.hasError) {
              print(snapshots.data.docs.length);
              return ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshots.data.docs.length,
                  //decides number of time itemBuilder called
                  itemBuilder: (context, index) {

                    return Card(
                      color: Colors.amberAccent[100],
                      elevation: 4, //elevation of each tile
                      margin: EdgeInsets.all(8), //space between each tile
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      child: ListTile(
                        title: Text(snapshots.data.docs[index]["shoppingList"]),
                        trailing: IconButton(
                          icon: Icon(
                            Icons.delete,
                            color: Colors.amberAccent[700],
                          ),
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                    title: Text("Move to History?"),
                                    actions: <Widget>[
                                      ElevatedButton(
                                        onPressed: () async {
                                          await deleteShopList(
                                              snapshots.data.docs[index].id,
                                              snapshots.data.docs[index]
                                                  ["shoppingList"]);
                                          Navigator.of(context).pop();
                                        },
                                        child: Text(
                                            'Confirm'
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            primary: Colors.amber[600],
                                          ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          print('cancel');
                                          Navigator.of(context).pop();
                                        },
                                        child: Text("Cancel",
                                            style: TextStyle(
                                              color: Colors.black,
                                            )),
                                      )
                                    ],
                                  );
                                });
                          },
                        ),
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
