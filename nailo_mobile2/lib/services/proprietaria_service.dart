import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nailo_mobile2/models/agendamento.dart';
import 'package:nailo_mobile2/models/horario_trabalho.dart';
import 'package:nailo_mobile2/models/servico.dart';

class ProprietariaService {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  // --- Buscar todos os horários da semana ---
  Future<List<HorarioTrabalho>> listarHorarios() async {
    final snapshot = await db.collection('horarios').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return HorarioTrabalho(
        id: doc.id,                 
        diaSemana: data['dia'] ?? '',
        horaInicio: data['inicio'] ?? '09:00',
        horaFim: data['fim'] ?? '17:00',
        ativo: true,
      );
    }).toList();
  }

  // --- Alterar horário de um dia ---
  Future<void> atualizarHorario(String dia, String inicio, String fim) async {
    await db.collection('horarios').doc(dia).set({
      'dia': dia,
      'inicio': inicio,
      'fim': fim,
    });
  }

  // --- Horários disponíveis de um dia ---
  Future<List<String>> getHorariosDisponiveis(String dia) async {
    final doc = await db.collection('horarios').doc(dia).get();
    if (!doc.exists) return [];

    final data = doc.data()!;
    final inicio = int.parse((data['inicio'] as String).split(':')[0]);
    final fim = int.parse((data['fim'] as String).split(':')[0]);

    return [for (int i = inicio; i < fim; i++) '${i.toString().padLeft(2,'0')}:00'];
  }

  // --- Listar serviços da proprietária ---
  Future<List<Servico>> listarServicos() async {
  final snapshot = await db.collection('servicos').get();
  return snapshot.docs.map((doc) {
    final data = doc.data();
    return Servico(
      id: doc.id,
      nome: data['nome'] ?? '',
      descricao: data['descricao'] ?? '', // ← adiciona aqui
      preco: (data['preco'] ?? 0).toDouble(),
      duracao: (data['duracao'] ?? 60).toInt(),
    );
  }).toList();
}


  // --- Atualizar um serviço ---
  Future<void> atualizarServico(String id, String nome, double preco) async {
    await db.collection('servicos').doc(id).update({
      'nome': nome,
      'preco': preco,
    });
  }

  // --- Listar agendamentos ---
Future<List<Agendamento>> listarAgendamentos() async {
  final snapshot = await db.collection('agendamentos').get();
  return snapshot.docs.map((doc) {
    final data = doc.data();
    return Agendamento(
      id: doc.id,
      idCliente: data['idCliente'] ?? '',
      idProprietaria: data['idProprietaria'] ?? '',
      idServico: data['idServico'] ?? '',
      data: (data['data'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: data['status'] ?? 'agendado',
      observacao: data['observacao'],
      criadoEm: (data['criadoEm'] as Timestamp?)?.toDate() ?? DateTime.now(),
      atualizadoEm: (data['atualizadoEm'] as Timestamp?)?.toDate() ?? DateTime.now(),
      preco: (data['preco'] != null) ? (data['preco'] as num).toDouble() : 0.0,
    );
  }).toList();
}

}
