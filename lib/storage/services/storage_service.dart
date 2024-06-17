import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  String pathService = "images";
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  Future<String> upload({required File file, required String fileName}) async {
    await _firebaseStorage.ref("$pathService/$fileName.png").putFile(file);
    return await _firebaseStorage
        .ref("$pathService/$fileName.png")
        .getDownloadURL();
  }

  Future<String> getDownloadUrlByFileName({required String fileName}) async {
    return await _firebaseStorage
        .ref("$pathService/$fileName.png")
        .getDownloadURL();
  }

  Future<List<String>> listAllFiles() async {
    ListResult listResult = await _firebaseStorage.ref(pathService).listAll();
    List<Reference> listReferences = listResult.items;
    List<String> listFiles = [];

    for (var reference in listReferences) {
      String url = await reference.getDownloadURL();
      listFiles.add(url);
    }
    return listFiles;
  }
}
