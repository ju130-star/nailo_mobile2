class Agendamento {
  //atributos
  final String id;              // ID do agendamento
  final String idCliente;       // ID do usuário cliente
  final String idProprietaria;  // ID da proprietária
  final String idServico;       // ID do serviço escolhido
  final DateTime data;          // Data e hora do agendamento
  final String status;          // "agendado", "cancelado", "concluido"
  final String? observacao;     // Observações opcionais
  final DateTime criadoEm;      // Data de criação
  final DateTime atualizadoEm;  // Última modificação
  final double preco;           // Valor do serviço

  //construtor
  Agendamento({
    required this.id,
    required this.idCliente,
    required this.idProprietaria,
    required this.idServico,
    required this.data,
    this.status = "agendado",
    this.observacao,
    required this.criadoEm,
    required this.atualizadoEm,
    required this.preco,
  });

  //método para converter OBJ => JSON (toMap)
  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "idCliente": idCliente,
      "idProprietaria": idProprietaria,
      "idServico": idServico,
      "data": data.toIso8601String(),
      "status": status,
      "observacao": observacao,
      "criadoEm": criadoEm.toIso8601String(),
      "atualizadoEm": atualizadoEm.toIso8601String(),
      "preco": preco,
    };
  }

  //método para converter JSON => OBJ (fromMap)
  factory Agendamento.fromMap(Map<String, dynamic> map) {
    return Agendamento(
      id: map["id"] ?? '',
      idCliente: map["idCliente"] ?? '',
      idProprietaria: map["idProprietaria"] ?? '',
      idServico: map["idServico"] ?? '',
      data: DateTime.tryParse(map["data"] ?? '') ?? DateTime.now(),
      status: map["status"] ?? "agendado",
      observacao: map["observacao"],
      criadoEm: DateTime.tryParse(map["criadoEm"] ?? '') ?? DateTime.now(),
      atualizadoEm: DateTime.tryParse(map["atualizadoEm"] ?? '') ?? DateTime.now(),
      preco: (map["preco"] ?? 0).toDouble(),
    );
  }
}
