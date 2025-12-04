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

  // LISTA AGENDAMENTOS ESPECIFICAMENTE PARA O CLIENTE
  static Future<List<Agendamento>> listarAgendamentosDoCliente(String idCliente) async {
    try {
      QuerySnapshot snapshot = await _agendamentos
          // 🎯 CORRIGIDO: Busca pelo ID do Cliente
          .where('idCliente', isEqualTo: idCliente) 
          .get();

      List<Agendamento> lista = snapshot.docs.map((doc) {
        return Agendamento.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();

      return lista;
    } catch (e) {
      print("Erro ao listar agendamentos do cliente: $e");
      rethrow;
    }
  }

// DENTRO DE agendamento_service.dart

  static Future<List<Agendamento>> listarHistoricoConcluido(String uidUsuario) async {
      try {
        QuerySnapshot snapshot = await _agendamentos 
            // 🎯 CORREÇÃO FINAL: Usar o nome do campo EXATO 'idCliente'
            .where('idCliente', isEqualTo: uidUsuario) 
            
            // Confirmação: O status 'concluido' está correto
            .where('status', isEqualTo: 'concluido') 
            .orderBy('data', descending: true)
            .get();

        print("DEBUG: Encontrados ${snapshot.docs.length} agendamentos no histórico."); // Checar no console!

        return snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          return Agendamento.fromMap(data); 
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
        'atualizadoEm': DateTime.now().toUtc(),
      });
      print("Status do agendamento $idAgendamento atualizado para '$novoStatus' com sucesso!");
    } catch (e) {
      print("Erro ao atualizar status do agendamento: $e");
      rethrow;
    }
  }

  static Future<void> cancelarAgendamento(String idAgendamento) async {
    try {
        await _agendamentos.doc(idAgendamento).update({
            // 🎯 O status muda para 'cancelado'
            'status': 'cancelado', 
            'atualizadoEm': DateTime.now().toUtc(),
        });
        print('Agendamento $idAgendamento cancelado com sucesso.');
    } catch (e) {
        print("Erro ao cancelar agendamento: $e");
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
