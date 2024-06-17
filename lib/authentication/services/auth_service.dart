import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  entrarUsuario({required String email, required String senha}) {
    print("METODO ENTRAR USUARIO");
  }

//gabriel.fgomes@gmail.com - Sem display name
//12345@A!
//gabriel.fgomes2@gmail.com - Gabriel F Gomes
//12345@A!
  Future<String?> cadastrarUsuario({
    required String email,
    required String senha,
    required String nome,
  }) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: senha);
      await userCredential.user!.updateDisplayName(nome);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "email-already-in-use":
          return "O e-mail já está em uso.";
      }
      return e.code;
    }
    return null;
  }
}
