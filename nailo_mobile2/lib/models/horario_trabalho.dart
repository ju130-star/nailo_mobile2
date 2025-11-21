class HorarioTrabalho {
  final String? id;              // ID opcional (Firestore pode gerar)
  final String diaSemana;        // Ex: segunda, terca...
  final String horaInicio;       // Ex: "09:00"
  final String horaFim;          // Ex: "18:00"
  final String inicioAlmoco;     // Ex: "12:00"
  final String fimAlmoco;        // Ex: "13:30"
  final bool ativo;              // Se o dia está ativo

  HorarioTrabalho({
    this.id,
    required this.diaSemana,
    required this.horaInicio,
    required this.horaFim,
    required this.inicioAlmoco,
    required this.fimAlmoco,
    this.ativo = true,
  });

  // OBJ → MAP (Firestore)
  Map<String, dynamic> toMap() {
    return {
      "diaSemana": diaSemana,
      "horaInicio": horaInicio,
      "horaFim": horaFim,
      "inicioAlmoco": inicioAlmoco,
      "fimAlmoco": fimAlmoco,
      "ativo": ativo,
    };
  }

  // MAP → OBJ
  factory HorarioTrabalho.fromMap(Map<String, dynamic> map, String id) {
    return HorarioTrabalho(
      id: id,
      diaSemana: map["diaSemana"] ?? "",
      horaInicio: map["horaInicio"] ?? "",
      horaFim: map["horaFim"] ?? "",
      inicioAlmoco: map["inicioAlmoco"] ?? "",
      fimAlmoco: map["fimAlmoco"] ?? "",
      ativo: map["ativo"] ?? true,
    );
  }
}
