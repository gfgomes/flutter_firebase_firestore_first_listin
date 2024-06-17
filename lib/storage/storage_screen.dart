import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_firestore_first/authentication/component/show_snackbar.dart';
import 'package:flutter_firebase_firestore_first/storage/models/image_custom_info.dart';
import 'package:flutter_firebase_firestore_first/storage/services/storage_service.dart';
import 'package:flutter_firebase_firestore_first/storage/widgets/source_modal_widget.dart';
import 'package:image_picker/image_picker.dart';

class StorageScreen extends StatefulWidget {
  const StorageScreen({super.key});

  @override
  State<StorageScreen> createState() => _StorageScreenState();
}

class _StorageScreenState extends State<StorageScreen> {
  String? urlPhoto;
  List<ImageCustomInfo> listFiles = [];

  final StorageService _storageService = StorageService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  void initState() {
    reload();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Foto de Perfil"),
        actions: [
          IconButton(
            onPressed: () {
              uploadImage();
            },
            icon: const Icon(Icons.upload),
          ),
          IconButton(
            onPressed: () {
              reload();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            (urlPhoto != null)
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(64),
                    child: Image.network(
                      urlPhoto!,
                      height: 128,
                      width: 128,
                      fit: BoxFit.cover,
                    ),
                  )
                : const CircleAvatar(
                    radius: 64,
                    child: Icon(Icons.person),
                  ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Divider(
                color: Colors.black,
              ),
            ),
            const Text(
              "Histórico de imagens",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            Column(
              children: List.generate(listFiles.length, (index) {
                ImageCustomInfo imageCustomInfo = listFiles[index];
                return ListTile(
                  onTap: () {
                    selectImage(imageCustomInfo);
                  },
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.network(
                      imageCustomInfo.urlDownload,
                      height: 48,
                      width: 48,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(imageCustomInfo.name),
                  subtitle: Text(imageCustomInfo.size),
                  trailing: IconButton(
                    onPressed: () {
                      deleteImage(imageCustomInfo);
                    },
                    icon: const Icon(Icons.delete, color: Colors.red),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  uploadImage() {
    ImagePicker imagePicker = ImagePicker();
    showSourceModalWidget(context: context).then((bool? isGalery) {
      ImageSource source = ImageSource.gallery;
      if (isGalery != null) {
        if (!isGalery) {
          source = ImageSource.camera;
        }
        imagePicker
            .pickImage(
          source: source,
          maxHeight: 2000,
          maxWidth: 2000,
          imageQuality: 50,
        )
            .then(
          (XFile? image) {
            if (image != null) {
              //showSnackBar(context: context, message: image.path, isError: false);

              _storageService
                  .upload(
                      file: File(image.path),
                      fileName: "user_photo_${DateTime.now().toString()}")
                  .then(
                (urlDownload) {
                  setState(() {
                    urlPhoto = urlDownload;
                    reload();
                  });
                },
              );
            } else {
              showSnackBar(
                  context: context, message: "Nenhuma imagem selecionada");
            }
          },
        );
      }
    });
  }

  reload() {
    setState(() {
      urlPhoto = _firebaseAuth.currentUser!.photoURL;
    });

    _storageService.listAllFiles().then(
      (List<ImageCustomInfo> listFilesInfo) {
        setState(() {
          listFiles = listFilesInfo;
        });
      },
    );
  }

  void selectImage(ImageCustomInfo imageCustomInfo) {
    //Não precisa do await por que a imagem já está localmente
    _firebaseAuth.currentUser!.updatePhotoURL(imageCustomInfo.urlDownload);
    setState(() {
      urlPhoto = imageCustomInfo.urlDownload;
    });
  }

  void deleteImage(ImageCustomInfo imageCustomInfo) {
    _storageService.deleteByReference(imageCustomInfo: imageCustomInfo).then(
      (value) {
        if (urlPhoto == imageCustomInfo.urlDownload) {
          setState(() {
            urlPhoto = null;
          });
        }
        reload();
      },
    );
  }
}
