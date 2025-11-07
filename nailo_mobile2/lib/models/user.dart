// classe de modelagem do OBJ Usuario
// receber os dados do Firebase -> enviar os dados para o Firestore
// usada tanto para Cliente quanto para Proprietária

class Usuario {
  //atributos
  final String id;           // ID gerado pelo Firebase Auth
  final String nome;         // Nome completo do usuário
  final String email;        // Email de login
  final String telefone;     // Telefone de contato
  final String tipo;         // "cliente" ou "proprietaria"
  final String? fotoUrl;     // URL da foto de perfil (opcional)
  final bool ativo;          // Usuário ativo ou não
  final DateTime dataCadastro; // Data de criação no sistema

  //construtor
  Usuario({
    required this.id,
    required this.nome,
    required this.email,
    required this.telefone,
    required this.tipo,
    this.fotoUrl,
    this.ativo = true,
    required this.dataCadastro,
  });

  //método para converter OBJ => JSON (toMap)
  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "nome": nome,
      "email": email,
      "telefone": telefone,
      "tipo": tipo,
      "fotoUrl": fotoUrl,
      "ativo": ativo,
      "dataCadastro": dataCadastro.toIso8601String(),
    };
  }

  //método para converter JSON => OBJ (fromMap)
  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      id: map["id"] ?? '',
      nome: map["nome"] ?? '',
      email: map["email"] ?? '',
      telefone: map["telefone"] ?? '',
      tipo: map["tipo"] ?? '',
      fotoUrl: map["fotoUrl"],
      ativo: map["ativo"] ?? true,
      dataCadastro: DateTime.tryParse(map["dataCadastro"] ?? '') ?? DateTime.now(),
    );
  }
}
