// classe de modelagem do OBJ Servico
// receber os dados do Firebase -> enviar os dados para o Firestore
// usado pela proprietária para cadastrar serviços da esmalteria

class Servico {
  //atributos
  final String id;          // ID do serviço
  final String nome;        // Nome do serviço (ex: Manicure, Alongamento)
  final String descricao;   // Descrição do serviço
  final double preco;       // Preço em reais
  final int duracao;        // Duração em minutos
  final String idProprietaria; // <-- NOVO CAMPO: ID da proprietária que criou o serviço

  //construtor
  Servico({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.preco,
    required this.duracao,
    required this.idProprietaria, // <-- ADICIONADO AO CONSTRUTOR
  });

  //método para converter OBJ => JSON (toMap)
  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "nome": nome,
      "descricao": descricao,
      "preco": preco,
      "duracao": duracao,
      "idProprietaria": idProprietaria, // <-- ADICIONADO AO toMap
    };
  }

  //método para converter JSON => OBJ (fromMap)
  factory Servico.fromMap(Map<String, dynamic> map) {
    return Servico(
      id: map["id"] ?? '',
      nome: map["nome"] ?? '',
      descricao: map["descricao"] ?? '',
      preco: (map["preco"] as num?)?.toDouble() ?? 0.0,
      duracao: map["duracao"] ?? 0,
      idProprietaria: map["idProprietaria"] ?? '', // <-- ADICIONADO AO fromMap
    );
  }
}