// Adicione a importação de Servico
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nailo_mobile2/models/agendamento.dart';
import 'package:nailo_mobile2/models/horario_trabalho.dart';
import 'package:nailo_mobile2/models/servico.dart';
import 'package:nailo_mobile2/models/slot_dia.dart';

class SlotDiaService {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  // Função auxiliar para buscar a duração de um serviço
  Future<int> _buscarDuracaoServico(String idServico) async {
    try {
      final doc = await db.collection('servicos').doc(idServico).get();
      if (doc.exists) {
        // Assume que 'duracao' é um campo inteiro em 'servicos'
        return (doc.data()?['duracao'] as num?)?.toInt() ?? 60;
      }
      return 60; // Duração padrão de 60 minutos se não encontrar
    } catch (e) {
      print("Erro ao buscar duração do serviço: $e");
      return 60;
    }
  }

  // --- Gerar slots do dia com base no horário, horário de almoço e agendamentos ---
  Future<List<SlotDia>> gerarSlotsDoDia(HorarioTrabalho horario) async {
    // Calcula a data real do dia da semana atual
    final dataDoDia = _obterDataDoDiaSemana(horario.diaSemana);

    // Buscar todos os agendamentos do dia específico
    final agendamentosDoDia = await _buscarAgendamentosDoDia(dataDoDia);

    // Lista para armazenar a duração de cada agendamento
    final Map<String, int> duracoesAgendamento = {};
    for (var ag in agendamentosDoDia) {
      duracoesAgendamento[ag.id!] = await _buscarDuracaoServico(ag.idServico);
    }
    
    // Configuração do slot
    const int duracaoDoSlot = 30; // Slots de 30 em 30 minutos

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

    // Constrói a data base para o dia correto.
    final DateTime hoje = DateTime.now();
    final DateTime dataBase = DateTime(dataDoDia.year, dataDoDia.month, dataDoDia.day);


    while (hour < fimHour || (hour == fimHour && minute < fimMinute)) {
      // Pula horário de almoço
      if (almocoIni != null && almocoFim != null && hour >= almocoIni && hour < almocoFim) {
        hour = almocoFim;
        minute = 0;
        continue;
      }

      final slotTime = TimeOfDay(hour: hour, minute: minute);
      
      // Cria a data e hora exata do slot que está sendo verificado
      final DateTime slotStart = DateTime(dataBase.year, dataBase.month, dataBase.day, slotTime.hour, slotTime.minute);
      final DateTime slotEnd = slotStart.add(const Duration(minutes: duracaoDoSlot));

      Agendamento? agendamentoOcupandoSlot;
      
      // 🚀 NOVO CÓDIGO: VERIFICAÇÃO DE SOBREPOSIÇÃO DE INTERVALO
      for (var ag in agendamentosDoDia) {
        final agStart = ag.data;
        final duracao = duracoesAgendamento[ag.id!] ?? 60;
        final agEnd = agStart.add(Duration(minutes: duracao));

        // Checagem de sobreposição de intervalos: 
        // O agendamento começa antes do slot terminar E o agendamento termina depois do slot começar.
        final bool isOverlapping = agStart.isBefore(slotEnd) && agEnd.isAfter(slotStart);
        
        if (isOverlapping) {
            agendamentoOcupandoSlot = ag;
            break; // Encontrou um conflito, pode parar a checagem
        }
      }

      slots.add(SlotDia(time: slotTime, agendamento: agendamentoOcupandoSlot));

      // Incrementa 30 minutos
      minute += duracaoDoSlot;
      if (minute >= 60) {
        minute = 0;
        hour += 1;
      }
    }

    return slots;
  }
  
  // --- Buscar agendamentos de uma data específica ---
  Future<List<Agendamento>> _buscarAgendamentosDoDia(DateTime data) async {
    // ... (o corpo desta função não mudou, apenas movido para baixo para manter a ordem)
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
          nomeCliente: dataMap['nomeCliente'] ?? '',
          nomeServico: dataMap['nomeServico'] ?? '',
          nomeProprietaria: dataMap['nomeProprietaria'] ?? '',
          data: (dataMap['data'] as Timestamp?)?.toDate() ?? DateTime.now(),
          status: dataMap['status'] ?? 'agendado',
          observacao: dataMap['observacao'],
          criadoEm: (dataMap['criadoEm'] as Timestamp?)?.toDate() ?? DateTime.now(),
          atualizadoEm: (dataMap['atualizadoEm'] as Timestamp?)?.toDate() ?? DateTime.now(),
          preco: (dataMap['preco'] != null) ? (dataMap['preco'] as num).toDouble() : 0.0,
          // 💡 IMPORTANTE: Você precisa garantir que o Agendamento tenha um ID para a busca de duração
        );
      }).toList();
    } catch (e) {
      print("Erro ao buscar agendamentos do dia ${data.toIso8601String()}: $e");
      return [];
    }
  }

  // --- Retorna a data real do dia da semana atual ---
  DateTime _obterDataDoDiaSemana(String diaSemana) {
    // ... (o corpo desta função não mudou)
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