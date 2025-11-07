import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nailo_mobile2/models/agendamento.dart';

class AgendamentoService {
  // Referência à coleção no Firestore
  static final CollectionReference _agendamentos =
      FirebaseFirestore.instance.collection('agendamentos');

  // Método para adicionar um agendamento
  static Future<void> adicionarAgendamento(Agendamento agendamento) async {
    try {
      await _agendamentos.doc(agendamento.id).set(agendamento.toMap());
      print("Agendamento salvo com sucesso!");
    } catch (e) {
      print("Erro ao salvar agendamento: $e");
      rethrow;
    }
  }

  // Método para listar todos os agendamentos
  static Future<List<Agendamento>> listarAgendamentos() async {
    try {
      QuerySnapshot snapshot = await _agendamentos.get();
      List<Agendamento> lista = snapshot.docs.map((doc) {
        return Agendamento.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();

      return lista;
    } catch (e) {
      print("Erro ao listar agendamentos: $e");
      rethrow;
    }
  }

  // Buscar agendamento por ID
  static Future<Agendamento?> buscarAgendamentoPorId(String id) async {
    try {
      DocumentSnapshot doc = await _agendamentos.doc(id).get();
      if (doc.exists) {
        return Agendamento.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print("Erro ao buscar agendamento: $e");
      return null;
    }
  }

  // Atualizar agendamento
  static Future<void> atualizarAgendamento(Agendamento agendamento) async {
    try {
      await _agendamentos.doc(agendamento.id).update(agendamento.toMap());
      print("Agendamento atualizado com sucesso!");
    } catch (e) {
      print("Erro ao atualizar agendamento: $e");
    }
  }

  // Deletar agendamento
  static Future<void> deletarAgendamento(String id) async {
    try {
      await _agendamentos.doc(id).delete();
      print("Agendamento deletado com sucesso!");
    } catch (e) {
      print("Erro ao deletar agendamento: $e");
    }
  }
}
