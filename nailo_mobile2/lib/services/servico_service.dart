import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nailo_mobile2/models/servico.dart';

class ServicoService {
  // Referência à coleção no Firestore
  static final CollectionReference _services =
      FirebaseFirestore.instance.collection('services');

  // Método para adicionar um serviço no Firestore
  static Future<void> adicionarServico(Servico service) async {
    try {
      await _services.doc(service.id).set(service.toMap());
      print("Serviço salvo com sucesso!");
    } catch (e) {
      print("Erro ao salvar serviço: $e");
      rethrow;
    }
  }

  // Método para listar todos os serviços
  static Future<List<Servico>> listarServicos() async {
    try {
      QuerySnapshot snapshot = await _services.get();
      List<Servico> lista = snapshot.docs.map((doc) {
        return Servico.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();

      return lista;
    } catch (e) {
      print("Erro ao listar serviços: $e");
      rethrow;
    }
  }

  // Método para buscar um serviço pelo ID
  static Future<Servico?> buscarServicoPorId(String id) async {
    try {
      DocumentSnapshot doc = await _services.doc(id).get();
      if (doc.exists) {
        return Servico.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print("Erro ao buscar serviço: $e");
      return null;
    }
  }

  // Método para atualizar serviço
  static Future<void> atualizarServico(Servico service) async {
    try {
      await _services.doc(service.id).update(service.toMap());
      print("Serviço atualizado com sucesso!");
    } catch (e) {
      print("Erro ao atualizar serviço: $e");
    }
  }

  // Método para deletar serviço
  static Future<void> deletarServico(String id) async {
    try {
      await _services.doc(id).delete();
      print("Serviço deletado com sucesso!");
    } catch (e) {
      print("Erro ao deletar serviço: $e");
    }
  }
}
