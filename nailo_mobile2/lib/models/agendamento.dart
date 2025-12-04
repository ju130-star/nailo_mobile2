import 'package:cloud_firestore/cloud_firestore.dart'; 

class Agendamento {
  // atributos
  final String id; 
  final String idCliente; 
  final String idProprietaria; 
  final String idServico; 

  // Campos legíveis para exibição rápida na UI
  final String nomeCliente; 
  final String nomeServico; 
  final String nomeProprietaria; // NOVO: Nome legível da proprietária

  final DateTime data; 
  final String status; 
  final String? observacao; 
  final DateTime criadoEm; 
  final DateTime atualizadoEm; 
  final double preco; 

  // construtor
  Agendamento({
    required this.id,
    required this.idCliente,
    required this.idProprietaria,
    required this.idServico,
    required this.nomeCliente,
    required this.nomeServico,
    required this.nomeProprietaria,

    required this.data,
    this.status = "agendado",
    this.observacao,
    required this.criadoEm,
    required this.atualizadoEm,
    required this.preco,
  });

  // método para converter OBJ => JSON (toMap)
  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "idCliente": idCliente,
      "idProprietaria": idProprietaria,
      "idServico": idServico,
      "nomeCliente": nomeCliente,
      "nomeServico": nomeServico,
      "nomeProprietaria": nomeProprietaria,
      "data": data,
      "status": status,
      "observacao": observacao,
      "criadoEm": criadoEm,
      "atualizadoEm": atualizadoEm,
      "preco": preco,
    };
  }

  // método para converter JSON => OBJ (fromMap)
  factory Agendamento.fromMap(Map<String, dynamic> map) {
    
    // ✅ CORREÇÃO FUSO HORÁRIO
    DateTime _parseDate(dynamic date) {
      if (date is Timestamp) {
        return date.toDate().toUtc(); // Leitura em UTC
      } else if (date is String) {
        return DateTime.tryParse(date)?.toUtc() ?? DateTime.now().toUtc();
      }
      return DateTime.now().toUtc();
    }

    double _parsePrice(dynamic price) {
      if (price is int) {
        return price.toDouble();
      }
      return (price ?? 0.0).toDouble();
    }

    return Agendamento(
      id: map["id"] ?? '',
      idCliente: map["idCliente"] ?? '',
      idProprietaria: map["idProprietaria"] ?? '',
      idServico: map["idServico"] ?? '',

      nomeCliente: map["nomeCliente"] ?? 'Cliente (S/N)',
      nomeServico: map["nomeServico"] ?? 'Serviço (S/N)',
      nomeProprietaria: map["nomeProprietaria"] ?? 'Profissional (S/N)', // NOVO CAMPO

      data: _parseDate(map["data"]),

      status: map["status"] ?? "agendado",
      observacao: map["observacao"],

      criadoEm: _parseDate(map["criadoEm"]),
      atualizadoEm: _parseDate(map["atualizadoEm"]),

      preco: _parsePrice(map["preco"]),
    );
  }
}