// lib/services/auth_service.dart
//
// Serviço responsável por cadastrar, logar e deslogar usuários no Firebase Authentication.
// Também salva os dados adicionais do usuário no Firestore, usando o UsuarioService.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:nailo_mobile2/models/user.dart';
import 'usuario_service.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // -Cadastrar novo Usuário
  static Future<User?> cadastrarUsuario({
    required String email,
    required String senha,
    required String nome,
    required String telefone,
    required String tipo, // cliente ou proprietaria
  }) async {
    try {
      // 1️Cria o usuário no Authentication (Firebase cuida do email e senha)
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );

      User? user = cred.user;
      if (user == null) return null;

      // 2Cria o objeto Usuario com os dados complementares
      Usuario novoUsuario = Usuario(
        id: user.uid, // UID gerado automaticamente pelo Firebase Auth
        nome: nome,
        email: email,
        telefone: telefone,
        tipo: tipo,
      );

      // Salva os dados do usuário no Firestore (chama o UsuarioService)
      await UsuarioService.adicionarUsuario(novoUsuario);

      print("Usuário cadastrado e salvo com sucesso!");
      return user;
    } on FirebaseAuthException catch (e) {
      print("Erro no cadastro: ${e.message}");
      rethrow;
    }
  }

  // Login
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

  // Logout 
  static Future<void> logoutUsuario() async {
    try {
      await _auth.signOut();
      print("Usuário deslogado com sucesso!");
    } catch (e) {
      print("Erro ao deslogar: $e");
    }
  }

  // Pegar Usuário Atual
  static User? get usuarioAtual {
    return _auth.currentUser;
  }

  // Escutar Estado de Login em Tempo Real
  static Stream<User?> streamAuthState() {
    return _auth.authStateChanges();
  }

  // Buscar o tipo do usuário no Firestore
  static Future<String?> getTipoUsuario(String uid) async {
  final usuario = await UsuarioService.buscarUsuarioPorId(uid);
  return usuario?.tipo;  
  }
}
