import 'package:flutter/material.dart';
import 'package:nailo_mobile2/models/agendamento.dart';

/// Classe de modelagem do OBJ SlotDia
/// Representa um horário específico do dia
/// Pode estar livre ou já ocupado por um agendamento
class SlotDia {
  final TimeOfDay time;        // Horário do slot (ex: 09:00)
  final Agendamento? agendamento; // Se tiver agendamento, ocupa o slot

  // Construtor
  SlotDia({
    required this.time,
    this.agendamento,
  });

  // Indica se o slot está livre
  bool get isLivre => agendamento == null;

  // Converte OBJ => JSON
  Map<String, dynamic> toMap() {
    return {
      "hora": "${time.hour.toString().padLeft(2,'0')}:${time.minute.toString().padLeft(2,'0')}",
      "agendamento": agendamento?.toMap(),
    };
  }

  // Converte JSON => OBJ
  factory SlotDia.fromMap(Map<String, dynamic> map) {
    final horaParts = (map["hora"] as String?)?.split(':') ?? ['00','00'];
    final hour = int.parse(horaParts[0]);
    final minute = int.parse(horaParts[1]);

    return SlotDia(
      time: TimeOfDay(hour: hour, minute: minute),
      agendamento: map["agendamento"] != null
          ? Agendamento.fromMap(Map<String, dynamic>.from(map["agendamento"]))
          : null,
    );
  }
}
