import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nailo_mobile2/models/user.dart';

class UsuarioService {
  // Referência à coleção no Firestore
  static final CollectionReference _usuarios =
      FirebaseFirestore.instance.collection('usuarios');

  // Método para adicionar um usuário no Firestore
  static Future<void> adicionarUsuario(Usuario usuario) async {
    try {
      await _usuarios.doc(usuario.id).set(usuario.toMap());
      print("Usuário salvo com sucesso!");
    } catch (e) {
      print("Erro ao salvar usuário: $e");
      rethrow;
    }
  }

  // Método para listar todos os usuários
  static Future<List<Usuario>> listarUsuarios() async {
    try {
      QuerySnapshot snapshot = await _usuarios.get();
      List<Usuario> lista = snapshot.docs.map((doc) {
        return Usuario.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();

      return lista;
    } catch (e) {
      print("Erro ao listar usuários: $e");
      rethrow;
    }
  }

  // Método para buscar um usuário pelo ID (UID do Auth)
  static Future<Usuario?> buscarUsuarioPorId(String id) async {
    try {
      DocumentSnapshot doc = await _usuarios.doc(id).get();
      if (doc.exists) {
        return Usuario.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print("Erro ao buscar usuário: $e");
      return null;
    }
  }

  // Método para atualizar usuário
  static Future<void> atualizarUsuario(Usuario usuario) async {
    try {
      await _usuarios.doc(usuario.id).update(usuario.toMap());
      print("Usuário atualizado com sucesso!");
    } catch (e) {
      print("Erro ao atualizar usuário: $e");
    }
  }

  // Método para deletar usuário
  static Future<void> deletarUsuario(String id) async {
    try {
      await _usuarios.doc(id).delete();
      print("Usuário deletado com sucesso!");
    } catch (e) {
      print("Erro ao deletar usuário: $e");
    }
  }
}
