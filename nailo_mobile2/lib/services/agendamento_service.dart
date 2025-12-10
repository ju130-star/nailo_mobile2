import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nailo_mobile2/models/agendamento.dart';

class AgendamentoService {
  // Referência à coleção no Firestore
  static final CollectionReference _agendamentos =
      FirebaseFirestore.instance.collection('agendamentos');

  // Função auxiliar que inclui o ID do documento antes de criar o modelo Agendamento
  static Agendamento _agendamentoFromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    data['id'] = doc.id; // Garante que o ID do documento esteja no mapa
    return Agendamento.fromMap(data);
  }

// ------------------------------------------------------------------
//  CRUD BÁSICO
// ------------------------------------------------------------------

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

  // Buscar agendamento por ID
  static Future<Agendamento?> buscarAgendamentoPorId(String id) async {
    try {
      DocumentSnapshot doc = await _agendamentos.doc(id).get();
      if (doc.exists) {
        // Usando a função auxiliar
        return _agendamentoFromSnapshot(doc);
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
      rethrow; 
    }
  }

  // Método para atualizar APENAS o status de um agendamento
  static Future<void> atualizarStatusAgendamento(String idAgendamento, String novoStatus) async {
    try {
      await _agendamentos.doc(idAgendamento).update({
        'status': novoStatus, 
        'atualizadoEm': DateTime.now().toUtc(),
      });
      print("Status do agendamento $idAgendamento atualizado para '$novoStatus' com sucesso!");
    } catch (e) {
      print("Erro ao atualizar status do agendamento: $e");
      rethrow;
    }
  }
  
  // AÇÃO FINAL DE CANCELAMENTO PARA O CLIENTE (REMOVE O REGISTRO)
  static Future<void> deletarAgendamento(String id) async {
    try {
      await _agendamentos.doc(id).delete();
      print("Agendamento deletado com sucesso!");
    } catch (e) {
      print("Erro ao deletar agendamento: $e");
      rethrow;
    }
  }
  

// ------------------------------------------------------------------
//  MÉTODOS DE LISTAGEM (SEU CÓDIGO ORIGINAL - APENAS ADICIONEI _agendamentoFromSnapshot)
// ------------------------------------------------------------------

  // Método para listar todos os agendamentos (genérico)
  static Future<List<Agendamento>> listarAgendamentos(String uidUsuario) async {
    // ESTE MÉTODO PARECE SER USADO PELA PROPRIETÁRIA (Controle de Agenda Ativa)
    try {
      QuerySnapshot snapshot = await _agendamentos
          .where('idUsuario', isEqualTo: uidUsuario) // Supondo que 'idUsuario' é o campo para o proprietário
          .where('status', isNotEqualTo: 'concluido') // Filtra status não-concluído
          .where('status', isNotEqualTo: 'cancelado') // Filtra status não-cancelado
          .get();

      return snapshot.docs.map((doc) => _agendamentoFromSnapshot(doc)).toList();

    } catch (e) {
      print("Erro ao listar agendamentos: $e");
      rethrow;
    }
  }

  // LISTA AGENDAMENTOS ESPECIFICAMENTE PARA O CLIENTE (FUTUROS/ATIVOS)
  static Future<List<Agendamento>> listarAgendamentosDoCliente(String idCliente) async {
      try {
         QuerySnapshot snapshot = await _agendamentos
               .where('idCliente', isEqualTo: idCliente) 
               .get();

         return snapshot.docs.map((doc) => _agendamentoFromSnapshot(doc)).toList();

      } catch (e) {
         print("Erro ao listar agendamentos do cliente: $e");
         rethrow;
      }
   }

  // LISTA HISTÓRICO CONCLUÍDO (USADO PELO CLIENTE)
  static Future<List<Agendamento>> listarHistoricoConcluido(String uidUsuario) async {
      try {
        QuerySnapshot snapshot = await _agendamentos 
            .where('idCliente', isEqualTo: uidUsuario) 
            .where('status', isEqualTo: 'concluido') 
            .orderBy('data', descending: true)
            .get();

        return snapshot.docs.map((doc) => _agendamentoFromSnapshot(doc)).toList();
        
      } catch (e) {
        print("Erro ao listar histórico concluído: $e");
        rethrow;
      }
  }

// ------------------------------------------------------------------
//  MÉTODO NOVO (PARA HISTÓRICO GERAL DA PROPRIETÁRIA)
// ------------------------------------------------------------------

  // 🚀 NOVO: LISTA TODOS OS AGENDAMENTOS DA PROPRIETÁRIA (Histórico Completo)
  static Future<List<Agendamento>> listarTodosAgendamentosPorProprietaria(String idProprietaria) async {
    try {
      QuerySnapshot snapshot = await _agendamentos
          .where('idProprietaria', isEqualTo: idProprietaria)
          .orderBy('data', descending: true)
          // 🎯 NOVO: Define a busca apenas no servidor para ignorar o cache local
          .get(const GetOptions(source: Source.server));

      return snapshot.docs.map((doc) => _agendamentoFromSnapshot(doc)).toList();
    } catch (e) {
      print("Erro ao listar histórico geral da proprietária: $e");
      rethrow;
    }
  }

}