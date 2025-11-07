import 'package:nailo_mobile2/models/user.dart';

import '../services/usuario_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UsuarioController {
  final _auth = FirebaseAuth.instance;

  // Retorna o usuário logado
  User? get currentUser => _auth.currentUser;

  // Buscar dados do usuário logado
  Future<Usuario?> getUsuarioLogado() async {
    if (currentUser == null) return null;
    return await UsuarioService.buscarUsuarioPorId(currentUser!.uid);
  }

  // Atualizar dados do usuário
  Future<void> atualizarUsuario(Usuario usuario) async {
    await UsuarioService.atualizarUsuario(usuario);
  }

  // Deletar usuário
  Future<void> deletarUsuario(String id) async {
    await UsuarioService.deletarUsuario(id);
  }
}
