import 'package:firebase_auth/firebase_auth.dart';
import 'package:nailo_mobile2/models/user.dart';
import '../services/usuario_service.dart';

class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  // Registrar usuário
  Future<Usuario?> registrar(
    String email,
    String senha,
    String nome,
    String telefone,
    String tipo,
  ) async {
    try {
      // Criação no FirebaseAuth
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );

      final uid = cred.user!.uid;

      final usuario = Usuario(
        id: uid,
        nome: nome,
        email: email,
        telefone: telefone,
        tipo: tipo, // cliente ou proprietaria
      );

      // Salva no Firestore
      await UsuarioService.adicionarUsuario(usuario);

      print("Usuário registrado com sucesso!");
      return usuario;

    } catch (e) {
      print("Erro ao registrar: $e");
      rethrow;
    }
  }

  // Login + retorna tipo do usuário
  Future<String?> login(String email, String senha) async {
    try {
      UserCredential cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: senha,
      );

      print("Login realizado com sucesso!");

      // Buscar dados no Firestore
      final usuario =
          await UsuarioService.buscarUsuarioPorId(cred.user!.uid);

      if (usuario == null) {
        print("ERRO: Usuário existe no Auth mas não no Firestore!");
        return null;
      }

      // Retorna "cliente" ou "proprietaria"
      return usuario.tipo;

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
