import 'package:nailo_mobile2/models/agendamento.dart';

import '../services/agendamento_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AgendamentoController {
  final _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  // Listar todos os agendamentos do usuário logado
  Future<List<Agendamento>> listarAgendamentos() async {
    if (currentUser == null) return [];
    return await AgendamentoService.listarAgendamentos(currentUser!.uid);
  }

  // Criar/agendar um horário
  Future<void> criarAgendamento(Agendamento agendamento) async {
    await AgendamentoService.adicionarAgendamento(agendamento);
  }

  // Deletar um agendamento pelo id
  Future<void> deletarAgendamento(String id) async {
    await AgendamentoService.deletarAgendamento(id);
  }
}
