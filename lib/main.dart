import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_firebase_firestore_first/firestore/presentation/home_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
      //const Directionality(textDirection: TextDirection.ltr, child: MyApp()),
      const MyApp());

  // FirebaseFirestore firestore = FirebaseFirestore.instance;
  // firestore.collection("Só para testar").doc("Estou testando").set({
  //   "funcionou": true,
  // });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        useMaterial3: false,
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}
