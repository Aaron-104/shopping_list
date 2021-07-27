import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String uid;
  DatabaseService({this.uid}); //constructor

  //collection reference to items
  final CollectionReference listCollection =
  FirebaseFirestore.instance.collection('items'); //if collection not exist, firestore will create`

  //***************
  Future createTitle(String itemN) async {
    return await listCollection.add({
      'itemN' : itemN,
    });
  }

  /*//brew list from snapshot
  //returns an iterable, so need convert to list
  //to work with it to output data in UI
  List<Brew> _brewListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      //cycle through snapshot and map to single property
      return Brew(
        name: doc.get('name') ?? " ", //if no data then return default
        strength: doc.get('strength') ?? 0,
        sugars: doc.get('sugars') ?? '0',
      );
    }).toList();
  }

  //userdata from snapshot
  UserData _userDataFromSnapshot(DocumentSnapshot snapshot) {
    return UserData(
      uid: uid,
      name: snapshot['name'],
      sugars: snapshot['sugars'],
      strength: snapshot['strength'],
    );
  }

  //GET brews streams
  Stream<List<Brew>>
  get brews //snapshot of the firestore collection at moment of time
  {
    return brewCollection.snapshots().map(_brewListFromSnapshot);
  }

//get user doc stream

  //map to a stream to return userdata object
  Stream<UserData> get userData{
    return brewCollection.doc(uid).snapshots()
        .map(_userDataFromSnapshot);
  }*/
}
