import 'package:cloud_firestore/cloud_firestore.dart'; 

class Agendamento {
  // atributos
  final String id;              // ID do agendamento
  final String idCliente;       // ID do usuário cliente
  final String idProprietaria; // ID da proprietária
  final String idServico;       // ID do serviço escolhido
  
  // NOVOS: Campos legíveis para exibição rápida na UI
  final String nomeCliente;     // Nome legível da cliente
  final String nomeServico;     // Nome legível do serviço

  final DateTime data;          // Data e hora do agendamento
  final String status;          // "agendado", "cancelado", "concluido"
  final String? observacao;     // Observações opcionais
  final DateTime criadoEm;      // Data de criação
  final DateTime atualizadoEm;  // Última modificação
  final double preco;           // Valor do serviço

  // construtor
  Agendamento({
    required this.id,
    required this.idCliente,
    required this.idProprietaria,
    required this.idServico,
    required this.nomeCliente, 
    required this.nomeServico, 
    
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
    
    DateTime _parseDate(dynamic date) {
      if (date is Timestamp) {
        return date.toDate();
      } else if (date is String) {
        return DateTime.tryParse(date) ?? DateTime.now();
      }
      return DateTime.now();
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

      data: _parseDate(map["data"]), 
      
      status: map["status"] ?? "agendado",
      observacao: map["observacao"],
      
      criadoEm: _parseDate(map["criadoEm"]),
      atualizadoEm: _parseDate(map["atualizadoEm"]),
      
      preco: _parsePrice(map["preco"]),
    );
  }
}