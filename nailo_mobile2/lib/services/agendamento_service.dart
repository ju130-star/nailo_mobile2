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
  static Future<List<Agendamento>> listarAgendamentos(String uidUsuario) async {
  try {
    QuerySnapshot snapshot = await _agendamentos
        .where('idUsuario', isEqualTo: uidUsuario)
        .get();

    List<Agendamento> lista = snapshot.docs.map((doc) {
      return Agendamento.fromMap(doc.data() as Map<String, dynamic>);
    }).toList();

    return lista;
  } catch (e) {
    print("Erro ao listar agendamentos: $e");
    rethrow;
  }
}

  static Future<List<Agendamento>> listarHistoricoConcluido(String uidUsuario) async {
    try {
      QuerySnapshot snapshot = await _agendamentos
          .where('idUsuario', isEqualTo: uidUsuario)
          .where('status', isEqualTo: 'concluido') // 🎯 FILTRO CRÍTICO
          .orderBy('data', descending: true) // Ordena do mais recente para o mais antigo
          .get();

      return snapshot.docs.map((doc) {
        return Agendamento.fromMap(doc.data() as Map<String, dynamic>); 
      }).toList();
    } catch (e) {
      print("Erro ao listar histórico concluído: $e");
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

  // Método para atualizar APENAS o status de um agendamento
  static Future<void> atualizarStatusAgendamento(String idAgendamento, String novoStatus) async {
    try {
      // Note que usamos um Map aqui para atualizar APENAS o campo 'status'
      await _agendamentos.doc(idAgendamento).update({
        'status': novoStatus, 
      });
      print("Status do agendamento $idAgendamento atualizado para '$novoStatus' com sucesso!");
    } catch (e) {
      print("Erro ao atualizar status do agendamento: $e");
      rethrow;
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
