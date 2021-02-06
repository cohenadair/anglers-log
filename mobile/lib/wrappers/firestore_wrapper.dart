import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_manager.dart';

class FirestoreWrapper {
  static FirestoreWrapper of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).firestoreWrapper;

  CollectionReference collection(String path) =>
      FirebaseFirestore.instance.collection(path);

  DocumentReference doc(String path) => FirebaseFirestore.instance.doc(path);
}
