// lib/services/auth_service.dart
//
// Serviço responsável por cadastrar, logar e deslogar usuários no Firebase Authentication.
// Também salva os dados adicionais do usuário no Firestore, usando o UsuarioService.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:nailo_mobile2/models/user.dart';
import 'usuario_service.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // ---------- CADASTRAR NOVO USUÁRIO ----------
  static Future<User?> cadastrarUsuario({
    required String email,
    required String senha,
    required String nome,
    required String telefone,
    required String tipo, // cliente ou proprietaria
  }) async {
    try {
      // 1️⃣ Cria o usuário no Authentication (Firebase cuida do email e senha)
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );

      User? user = cred.user;
      if (user == null) return null;

      // 2️⃣ Cria o objeto Usuario com os dados complementares
      Usuario novoUsuario = Usuario(
        id: user.uid, // UID gerado automaticamente pelo Firebase Auth
        nome: nome,
        email: email,
        telefone: telefone,
        tipo: tipo,
        dataCadastro: DateTime.now(),
      );

      // 3️⃣ Salva os dados do usuário no Firestore (chama o UsuarioService)
      await UsuarioService.adicionarUsuario(novoUsuario);

      print("Usuário cadastrado e salvo com sucesso!");
      return user;
    } on FirebaseAuthException catch (e) {
      print("Erro no cadastro: ${e.message}");
      rethrow;
    }
  }

  // ---------- LOGIN ----------
  static Future<User?> loginUsuario(String email, String senha) async {
    try {
      UserCredential cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: senha,
      );
      print("Login realizado com sucesso!");
      return cred.user;
    } on FirebaseAuthException catch (e) {
      print("Erro no login: ${e.message}");
      rethrow;
    }
  }

  // ---------- LOGOUT ----------
  static Future<void> logoutUsuario() async {
    try {
      await _auth.signOut();
      print("Usuário deslogado com sucesso!");
    } catch (e) {
      print("Erro ao deslogar: $e");
    }
  }

  // ---------- PEGAR USUÁRIO ATUAL ----------
  static User? get usuarioAtual {
    return _auth.currentUser;
  }

  // ---------- ESCUTAR ESTADO DE LOGIN EM TEMPO REAL ----------
  static Stream<User?> streamAuthState() {
    return _auth.authStateChanges();
  }
}
