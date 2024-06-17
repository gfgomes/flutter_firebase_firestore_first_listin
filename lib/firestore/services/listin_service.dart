import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_firebase_firestore_first/firestore/models/listin.dart';

class ListinService {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  String uid = FirebaseAuth.instance.currentUser!.uid;

  Future<List<Listin>> lerListins() async {
    List<Listin> temp = [];

    // listListins = (await firestore.collection("listins").get())
    //     .docs
    //     .map((doc) => Listin.fromMap(doc.data()))
    //     .toList();
    QuerySnapshot<Map<String, dynamic>> snapshot =
        await firestore.collection(uid).get();

    for (var doc in snapshot.docs) {
      temp.add(Listin.fromMap(doc.data()));
    }

    return temp;
  }

  Future<void> adicionarListin(Listin listin) async {
    await firestore.collection(uid).doc(listin.id).set(
          listin.toMap(),
        );
  }

  Future<void> removeListin(Listin model) async {
    await firestore.collection(uid).doc(model.id).delete();
  }
}
