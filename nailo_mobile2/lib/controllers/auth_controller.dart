import 'package:firebase_auth/firebase_auth.dart';
import 'package:nailo_mobile2/models/user.dart';
import '../services/usuario_service.dart';

class AuthController {
  final _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  // Registrar usuário
  Future<void> registrar(String email, String senha, String nome, String telefone, String tipo) async {
    try {
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );

      // Criar o objeto Usuario já com o id do Auth
      final usuario = Usuario(
        id: cred.user!.uid,
        nome: nome,
        email: email,
        telefone: telefone,
        tipo: tipo
        // adiciona outros campos se houver
      );

      // Salvar no Firestore
      await UsuarioService.adicionarUsuario(usuario);

      print("Usuário registrado com sucesso!");
    } catch (e) {
      print("Erro ao registrar: $e");
      rethrow;
    }
  }

  // Login
  Future<void> login(String email, String senha) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: senha);
      print("Login realizado com sucesso!");
    } catch (e) {
      print("Erro ao fazer login: $e");
      rethrow;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _auth.signOut();
      print("Logout realizado com sucesso!");
    } catch (e) {
      print("Erro ao fazer logout: $e");
    }
  }
}
