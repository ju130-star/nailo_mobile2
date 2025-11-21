import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nailo_mobile2/models/agendamento.dart';
import 'package:nailo_mobile2/models/horario_trabalho.dart';
import 'package:nailo_mobile2/models/slot_dia.dart';

class SlotDiaService {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  // --- Gerar slots do dia com base no horário, horário de almoço e agendamentos ---
  Future<List<SlotDia>> gerarSlotsDoDia(HorarioTrabalho horario) async {
    // Calcula a data real do dia da semana atual
    final dataDoDia = _obterDataDoDiaSemana(horario.diaSemana);

    // Buscar todos os agendamentos do dia específico
    final agendamentosDoDia = await _buscarAgendamentosDoDia(dataDoDia);

    List<SlotDia> slots = [];

    if (horario.horaInicio.isEmpty || horario.horaFim.isEmpty) return slots;

    final partsInicio = horario.horaInicio.split(':');
    final partsFim = horario.horaFim.split(':');

    int hour = int.parse(partsInicio[0]);
    int minute = int.parse(partsInicio[1]);
    final fimHour = int.parse(partsFim[0]);
    final fimMinute = int.parse(partsFim[1]);

    int? almocoIni = horario.inicioAlmoco.isNotEmpty
        ? int.parse(horario.inicioAlmoco.split(":")[0])
        : null;
    int? almocoFim = horario.fimAlmoco.isNotEmpty
        ? int.parse(horario.fimAlmoco.split(":")[0])
        : null;

    while (hour < fimHour || (hour == fimHour && minute < fimMinute)) {
      // Pula horário de almoço
      if (almocoIni != null && almocoFim != null && hour >= almocoIni && hour < almocoFim) {
        hour = almocoFim;
        minute = 0;
        continue;
      }

      final slotTime = TimeOfDay(hour: hour, minute: minute);

      // Verifica se há agendamento para este horário
      Agendamento? agendamento;
      try {
        agendamento = agendamentosDoDia.firstWhere(
          (a) =>
              a.data.hour == slotTime.hour &&
              a.data.minute == slotTime.minute,
        );
      } catch (e) {
        agendamento = null;
      }

      slots.add(SlotDia(time: slotTime, agendamento: agendamento));

      // Incrementa 30 minutos
      minute += 30;
      if (minute >= 60) {
        minute = 0;
        hour += 1;
      }
    }

    return slots;
  }

  // --- Buscar agendamentos de uma data específica ---
  Future<List<Agendamento>> _buscarAgendamentosDoDia(DateTime data) async {
    try {
      final inicioDia = DateTime(data.year, data.month, data.day, 0, 0, 0);
      final fimDia = DateTime(data.year, data.month, data.day, 23, 59, 59);

      final snapshot = await db
          .collection('agendamentos')
          .where('data', isGreaterThanOrEqualTo: inicioDia)
          .where('data', isLessThanOrEqualTo: fimDia)
          .get();

      return snapshot.docs.map((doc) {
        final dataMap = doc.data();
        return Agendamento(
          id: doc.id,
          idCliente: dataMap['idCliente'] ?? '',
          idProprietaria: dataMap['idProprietaria'] ?? '',
          idServico: dataMap['idServico'] ?? '',
          data: (dataMap['data'] as Timestamp?)?.toDate() ?? DateTime.now(),
          status: dataMap['status'] ?? 'agendado',
          observacao: dataMap['observacao'],
          criadoEm: (dataMap['criadoEm'] as Timestamp?)?.toDate() ?? DateTime.now(),
          atualizadoEm: (dataMap['atualizadoEm'] as Timestamp?)?.toDate() ?? DateTime.now(),
          preco: (dataMap['preco'] != null) ? (dataMap['preco'] as num).toDouble() : 0.0,
        );
      }).toList();
    } catch (e) {
      print("Erro ao buscar agendamentos do dia ${data.toIso8601String()}: $e");
      return [];
    }
  }

  // --- Retorna a data real do dia da semana atual ---
  DateTime _obterDataDoDiaSemana(String diaSemana) {
    final hoje = DateTime.now();
    const ordemSemana = [
      "segunda",
      "terca",
      "quarta",
      "quinta",
      "sexta",
      "sabado",
      "domingo",
    ];

    final indexDia = ordemSemana.indexOf(diaSemana.toLowerCase());
    final diaAtualSemana = hoje.weekday - 1; // 0 = segunda
    int diferencaDias = indexDia - diaAtualSemana;

    // Se o dia já passou nesta semana, pega o mesmo dia na próxima semana
    if (diferencaDias < 0) {
      diferencaDias += 7;
    }

    return hoje.add(Duration(days: diferencaDias));
  }
}
