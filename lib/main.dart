import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shopping_list/loading.dart';
import 'package:shopping_list/shopping_list.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    initialRoute: '/',
    routes: {
      '/': (context) => MyApp(),
      '/shopping_list': (context) =>
          shopping_list(argument: ModalRoute.of(context).settings.arguments),
      //'/itemAdd' : (context) => itemAdd(),
    },
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.blue,
        accentColor: Colors.orange),
  ));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String shoppingList;

  CollectionReference todoReference =
      FirebaseFirestore.instance.collection("MyLists");

  createTodos() {
    //Map
    Map<String, dynamic> todos = {"shoppingList": shoppingList};
    todoReference.add(todos).whenComplete(() {
      print("$shoppingList created");
    });
  }

  Future deleteTodos(String id) async {
    await todoReference.doc(id).delete().whenComplete(() {
      print("$id deleted");
    });
  }
  //
  // @override
  // void initState() {
  //   super.initState();
  //   Firebase.initializeApp().whenComplete(() {
  //     print("completed");
  //     setState(() {});
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text("Shopping List"),
        backgroundColor: Colors.amber[600],
      ),
      floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.amber[600],
          onPressed: () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    title: Text("Add Shopping List"),
                    content: TextField(
                      onChanged: (String value) {
                        //After insert value
                        shoppingList = value;
                      },
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          createTodos();

                          Navigator.of(context).pop();
                          //will remove alert dialog after adding
                        },
                        child: Text("Add"),
                      ),
                    ],
                  );
                });
          },
          child: Icon(
            Icons.add,
            color: Colors.white,
          )),
      //NEED USE streambuilder to use firestore instance
      body: StreamBuilder(
          stream: FirebaseFirestore.instance.collection("MyLists")
              .orderBy("shoppingList").snapshots(),
          builder: (context, snapshots) {
            if (snapshots.hasData && !snapshots.hasError) {
              print("yes");
              print(snapshots.data.docs.length);
              return ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshots.data.docs.length,
                  itemBuilder: (context, index) {
                    //DocumentSnapshot documentSnapshot = snapshots.data.docs[index];
                    return Dismissible(
                      onDismissed: (direction) {
                        deleteTodos(snapshots.data.docs[index].id);
                      },
                      key: Key(index.toString()),
                      child: Card(
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
                                Icons.delete,
                                color: Colors.amberAccent[700],
                              ),
                              onPressed: () async {
                                await deleteTodos(
                                    snapshots.data.docs[index].id);
                              }),
                          onTap: () {
                            Navigator.pushNamed(context, '/shopping_list',
                                arguments: [
                                  snapshots.data.docs[index].id,
                                  snapshots.data.docs[index]["shoppingList"]
                                ]);
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
