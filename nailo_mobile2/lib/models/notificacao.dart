// classe de modelagem do OBJ Notificacao
// receber os dados do Firebase -> enviar os dados para o Firestore
// usada para enviar lembretes e avisos para o cliente

class Notificacao {
  //atributos
  final String id;            // ID da notificação
  final String idUsuario;     // ID do usuário que receberá a notificação
  final String mensagem;      // Texto da notificação
  final DateTime dataEnvio;   // Data e hora de envio
  final bool lida;            // Se o usuário já visualizou ou não

  //construtor
  Notificacao({
    required this.id,
    required this.idUsuario,
    required this.mensagem,
    required this.dataEnvio,
    this.lida = false,
  });

  //método para converter OBJ => JSON (toMap)
  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "idUsuario": idUsuario,
      "mensagem": mensagem,
      "dataEnvio": dataEnvio.toIso8601String(),
      "lida": lida,
    };
  }

  //método para converter JSON => OBJ (fromMap)
  factory Notificacao.fromMap(Map<String, dynamic> map) {
    return Notificacao(
      id: map["id"] ?? '',
      idUsuario: map["idUsuario"] ?? '',
      mensagem: map["mensagem"] ?? '',
      dataEnvio: DateTime.tryParse(map["dataEnvio"] ?? '') ?? DateTime.now(),
      lida: map["lida"] ?? false,
    );
  }
}
