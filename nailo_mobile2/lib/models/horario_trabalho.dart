// classe de modelagem do OBJ HorarioTrabalho
// receber os dados do Firebase -> enviar os dados para o Firestore
// usado pela proprietária para definir os dias e horários de atendimento

class HorarioTrabalho {
  //atributos
  final String id;          // ID do horário
  final String diaSemana;   // Ex: Segunda, Terça, Quarta...
  final String horaInicio;  // Ex: "09:00"
  final String horaFim;     // Ex: "18:00"
  final bool ativo;         // Se o dia está ativo para agendamento

  //construtor
  HorarioTrabalho({
    required this.id,
    required this.diaSemana,
    required this.horaInicio,
    required this.horaFim,
    this.ativo = true,
  });

  //método para converter OBJ => JSON (toMap)
  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "diaSemana": diaSemana,
      "horaInicio": horaInicio,
      "horaFim": horaFim,
      "ativo": ativo,
    };
  }

  //método para converter JSON => OBJ (fromMap)
  factory HorarioTrabalho.fromMap(Map<String, dynamic> map) {
    return HorarioTrabalho(
      id: map["id"] ?? '',
      diaSemana: map["diaSemana"] ?? '',
      horaInicio: map["horaInicio"] ?? '',
      horaFim: map["horaFim"] ?? '',
      ativo: map["ativo"] ?? true,
    );
  }
}
