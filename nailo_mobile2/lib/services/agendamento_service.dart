import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nailo_mobile2/models/agendamento.dart';

class AgendamentoService {
  // Referência à coleção no Firestore
  static final CollectionReference _agendamentos =
      FirebaseFirestore.instance.collection('agendamentos');

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
      rethrow; // Adicionado rethrow para melhor tratamento de erro na UI
    }
  }

  // Método para atualizar APENAS o status de um agendamento
  static Future<void> atualizarStatusAgendamento(String idAgendamento, String novoStatus) async {
    try {
      // Note que usamos um Map aqui para atualizar APENAS o campo 'status'
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
  
  // 🎯 AÇÃO FINAL DE CANCELAMENTO PARA O CLIENTE (REMOVE O REGISTRO)
  static Future<void> deletarAgendamento(String id) async {
    try {
      await _agendamentos.doc(id).delete();
      print("Agendamento deletado com sucesso!");
    } catch (e) {
      print("Erro ao deletar agendamento: $e");
      rethrow; // 💡 GARANTE QUE A UI RECEBA O ERRO PARA TRATAMENTO
    }
  }
  
  // Método para apenas mudar o status para 'cancelado'. Não utilizado no fluxo atual do cliente.
  /*
  static Future<void> cancelarAgendamento(String idAgendamento) async {
    try {
        await _agendamentos.doc(idAgendamento).update({
            'status': 'cancelado', 
            'atualizadoEm': DateTime.now().toUtc(),
        });
        print('Agendamento $idAgendamento cancelado com sucesso.');
    } catch (e) {
        print("Erro ao cancelar agendamento: $e");
        rethrow;
    }
  }
  */

// ------------------------------------------------------------------
//  MÉTODOS DE LISTAGEM (COM FILTROS DE STATUS)
// ------------------------------------------------------------------

  // Método para listar todos os agendamentos (genérico)
  static Future<List<Agendamento>> listarAgendamentos(String uidUsuario) async {
    // Este método lista agendamentos associados a um uidUsuario (que pode ser Proprietário ou Cliente,
    // dependendo da estrutura de dados)
    try {
      QuerySnapshot snapshot = await _agendamentos
          .where('idUsuario', isEqualTo: uidUsuario) // Supondo que 'idUsuario' é o campo para o proprietário
          .where('status', isNotEqualTo: 'concluido') // Filtra status não-concluído
          .where('status', isNotEqualTo: 'cancelado') // Filtra status não-cancelado
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

  // LISTA AGENDAMENTOS ESPECIFICAMENTE PARA O CLIENTE (FUTUROS/ATIVOS)
  static Future<List<Agendamento>> listarAgendamentosDoCliente(String idCliente) async {
      try {
         QuerySnapshot snapshot = await _agendamentos
               // Busca apenas pelo ID do Cliente
               .where('idCliente', isEqualTo: idCliente) 
          // 🛑 REMOVIDOS OS FILTROS DE STATUS PARA EVITAR SUMIÇO
               .get();

         List<Agendamento> lista = snapshot.docs.map((doc) {
            // É fundamental que o ID do documento seja incluído aqui para o Delete funcionar!
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; 
            return Agendamento.fromMap(data);
         }).toList();
         return lista;
      } catch (e) {
         print("Erro ao listar agendamentos do cliente: $e");
         rethrow;
      }
   }

  // LISTA HISTÓRICO CONCLUÍDO
  static Future<List<Agendamento>> listarHistoricoConcluido(String uidUsuario) async {
      try {
        QuerySnapshot snapshot = await _agendamentos 
            .where('idCliente', isEqualTo: uidUsuario) 
            .where('status', isEqualTo: 'concluido') 
            .orderBy('data', descending: true)
            .get();

        print("DEBUG: Encontrados ${snapshot.docs.length} agendamentos no histórico.");

        return snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          // Adicionar o ID do documento ao mapa (útil para referências futuras)
          data['id'] = doc.id; 
          return Agendamento.fromMap(data); 
        }).toList();
        
      } catch (e) {
        print("Erro ao listar histórico concluído: $e");
        rethrow;
      }
  }
}