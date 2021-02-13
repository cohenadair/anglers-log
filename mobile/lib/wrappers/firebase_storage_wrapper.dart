import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_manager.dart';

class FirebaseStorageWrapper {
  static FirebaseStorageWrapper of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).firebaseStorageWrapper;

  Reference ref([String path]) => FirebaseStorage.instance.ref(path);
}
