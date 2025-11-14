class ProprietariaModel {
  String id;
  String nome;
  String email;
  String telefone;
  String? fotoUrl;
  List<dynamic>? horarios;   // lista de horários definidos pela proprietária
  List<dynamic>? servicos;  // lista de serviços cadastrados

  ProprietariaModel({
    required this.id,
    required this.nome,
    required this.email,
    required this.telefone,
    this.fotoUrl,
    this.horarios,
    this.servicos,
  });

  // converter para Map (salvar no Firestore)
  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "nome": nome,
      "email": email,
      "telefone": telefone,
      "fotoUrl": fotoUrl,
      "horarios": horarios ?? [],
      "servicos": servicos ?? [],
    };
  }

  // ler do Firestore
  factory ProprietariaModel.fromMap(Map<String, dynamic> map) {
    return ProprietariaModel(
      id: map["id"],
      nome: map["nome"],
      email: map["email"],
      telefone: map["telefone"],
      fotoUrl: map["fotoUrl"],
      horarios: map["horarios"] ?? [],
      servicos: map["servicos"] ?? [],
    );
  }
}
