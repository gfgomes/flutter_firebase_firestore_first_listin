import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_firebase_firestore_first/storage/models/image_custom_info.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  String pathService = FirebaseAuth.instance.currentUser!.uid;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  Future<String> upload({required File file, required String fileName}) async {
    await _firebaseStorage.ref("$pathService/$fileName.png").putFile(file);

    String url = await _firebaseStorage
        .ref("$pathService/$fileName.png")
        .getDownloadURL();
    await firebaseAuth.currentUser!.updatePhotoURL(url);
    return url;
  }

  Future<String> getDownloadUrlByFileName({required String fileName}) async {
    return await _firebaseStorage
        .ref("$pathService/$fileName.png")
        .getDownloadURL();
  }

  Future<void> deleteByReference(
      {required ImageCustomInfo imageCustomInfo}) async {
    if (firebaseAuth.currentUser!.photoURL != null) {
      if (firebaseAuth.currentUser!.photoURL! == imageCustomInfo.urlDownload) {
        await firebaseAuth.currentUser!.updatePhotoURL(null);
      }
    }

    return await imageCustomInfo.ref.delete();
  }

  // Future<List<String>> listAllFiles() async {
  //   ListResult listResult = await _firebaseStorage.ref(pathService).listAll();
  //   List<Reference> listReferences = listResult.items;
  //   List<String> listFiles = [];

  //   for (var reference in listReferences) {
  //     String url = await reference.getDownloadURL();
  //     listFiles.add(url);
  //   }
  //   return listFiles;
  // }

  Future<List<ImageCustomInfo>> listAllFiles() async {
    ListResult result = await _firebaseStorage.ref(pathService).listAll();
    List<Reference> listReferences = result.items;

    List<ImageCustomInfo> listFiles = [];

    for (Reference reference in listReferences) {
      String urlDownload = await reference.getDownloadURL();
      String name = reference.name;

      //Pega informações adicionais sobre o arquivo
      FullMetadata metadados = await reference.getMetadata();
      int? size = metadados.size;
      String sizeString = "Sem informações de tamanho";
      if (size != null) {
        sizeString = "${size / 1000} Kb";
      }

      listFiles.add(
        ImageCustomInfo(
          urlDownload: urlDownload,
          name: name,
          size: sizeString,
          ref: reference,
        ),
      );
    }

    return listFiles;
  }
}
