import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_firebase_firestore_first/authentication/component/show_snackbar.dart';
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
  List<String> listFiles = [];

  final StorageService _storageService = StorageService();

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
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Column(
              children: List.generate(listFiles.length, (index) {
                String url = listFiles[index];
                return Image.network(url);
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
                  .upload(file: File(image.path), fileName: "user_photo")
                  .then(
                (urlDownload) {
                  setState(() {
                    urlPhoto = urlDownload;
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
    _storageService.getDownloadUrlByFileName(fileName: "user_photo").then(
      (urlDownload) {
        setState(
          () {
            urlPhoto = urlDownload;
          },
        );
      },
    );
  }
}
