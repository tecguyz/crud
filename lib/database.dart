import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class Database {
  late FirebaseFirestore firestore;

  initiliase() {
    firestore = FirebaseFirestore.instance;
  }

  Future<bool> signIn(String email, String password) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> register(String email, String password) async {
    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
      return false;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<void> create(String name, String code) async {
    CollectionReference users =
        FirebaseFirestore.instance.collection('countries');
    FirebaseAuth auth = FirebaseAuth.instance;
    String uid = auth.currentUser!.uid.toString();
    try {
      await users.add({
        'uid': uid,
        'name': name,
        'code': code,
        'timestamp': FieldValue.serverTimestamp()
      });
    } catch (e) {
      print(e);
    }
  }

  Future<List?> read() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    String? uid = auth.currentUser?.uid.toString();
    QuerySnapshot querySnapshot;
    List docs = [];
    try {
      querySnapshot = FirebaseFirestore.instance
          .collection('countries')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .snapshots() as QuerySnapshot<Object?>;
      if (querySnapshot.docs.isNotEmpty) {
        for (var doc in querySnapshot.docs.toList()) {
          Map a = {
            "id": doc.id,
            'name': doc['name'],
            'code': doc['code'],
          };
          docs.add(a);
        }
        return docs;
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> delete(String id) async {
    try {
      await firestore.collection("countries").doc(id).delete();
    } catch (e) {
      print(e);
    }
  }

  Future<void> update(String id, String name, String code) async {
    try {
      await firestore
          .collection("countries")
          .doc(id)
          .update({'name': name, 'code': code});
    } catch (e) {
      print(e);
    }
  }
}
