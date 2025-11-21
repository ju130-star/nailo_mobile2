import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nailo_mobile2/models/agendamento.dart';
import 'package:nailo_mobile2/models/horario_trabalho.dart';
import 'package:nailo_mobile2/models/servico.dart';

class ProprietariaService {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  ProprietariaService() {
    inicializarHorariosPadroes();
  }

  // ----------------------------------------------------------
  // CRIA OS 7 DIAS PADRÕES COM IDs FIXOS
  // ----------------------------------------------------------
  Future<void> inicializarHorariosPadroes() async {
    final horariosRef = db.collection('horarios_trabalho');

    final horariosPadroes = [
      HorarioTrabalho(
        id: 'segunda',
        diaSemana: 'segunda',
        horaInicio: '08:00',
        horaFim: '18:00',
        inicioAlmoco: '12:00',
        fimAlmoco: '13:30',
        ativo: true,
      ),
      HorarioTrabalho(
        id: 'terca',
        diaSemana: 'terca',
        horaInicio: '08:00',
        horaFim: '18:00',
        inicioAlmoco: '12:00',
        fimAlmoco: '13:30',
        ativo: true,
      ),
      HorarioTrabalho(
        id: 'quarta',
        diaSemana: 'quarta',
        horaInicio: '08:00',
        horaFim: '18:00',
        inicioAlmoco: '12:00',
        fimAlmoco: '13:30',
        ativo: true,
      ),
      HorarioTrabalho(
        id: 'quinta',
        diaSemana: 'quinta',
        horaInicio: '08:00',
        horaFim: '18:00',
        inicioAlmoco: '12:00',
        fimAlmoco: '13:30',
        ativo: true,
      ),
      HorarioTrabalho(
        id: 'sexta',
        diaSemana: 'sexta',
        horaInicio: '08:00',
        horaFim: '18:00',
        inicioAlmoco: '12:00',
        fimAlmoco: '13:30',
        ativo: true,
      ),
      HorarioTrabalho(
        id: 'sabado',
        diaSemana: 'sabado',
        horaInicio: '09:00',
        horaFim: '14:00',
        inicioAlmoco: '',
        fimAlmoco: '',
        ativo: true,
      ),
      HorarioTrabalho(
        id: 'domingo',
        diaSemana: 'domingo',
        horaInicio: '',
        horaFim: '',
        inicioAlmoco: '',
        fimAlmoco: '',
        ativo: false,
      ),
    ];

    // Cria ou atualiza cada dia
    for (var h in horariosPadroes) {
      await horariosRef.doc(h.id).set(h.toMap());
    }
  }

  // ----------------------------------------------------------
  // LISTAR HORÁRIOS NA ORDEM FIXA
  // ----------------------------------------------------------
  Future<List<HorarioTrabalho>> listarHorarios() async {
    final snap = await db.collection('horarios_trabalho').get();

    List<HorarioTrabalho> lista = snap.docs.map((d) {
      return HorarioTrabalho.fromMap(d.data(), d.id);
    }).toList();

    const ordemSemana = [
      'segunda',
      'terca',
      'quarta',
      'quinta',
      'sexta',
      'sabado',
      'domingo',
    ];

    lista.sort((a, b) {
      return ordemSemana.indexOf(a.diaSemana.toLowerCase())
          .compareTo(ordemSemana.indexOf(b.diaSemana.toLowerCase()));
    });

    return lista;
  }

  // ----------------------------------------------------------
  // ATUALIZAR HORÁRIO
  // ----------------------------------------------------------
  Future<void> atualizarHorario(
    String id, {
    required String inicio,
    required String fim,
    required String inicioAlmoco,
    required String fimAlmoco,
    required bool ativo,
  }) async {
    await db.collection('horarios_trabalho').doc(id).update({
      'horaInicio': inicio,
      'horaFim': fim,
      'inicioAlmoco': inicioAlmoco,
      'fimAlmoco': fimAlmoco,
      'ativo': ativo,
    });
  }

  // ----------------------------------------------------------
  // LISTA HORÁRIOS DISPONÍVEIS
  // ----------------------------------------------------------
  Future<List<String>> getHorariosDisponiveis(String idDia) async {
    final doc = await db.collection('horarios_trabalho').doc(idDia).get();
    if (!doc.exists) return [];

    final h = HorarioTrabalho.fromMap(doc.data()!, doc.id);
    if (!h.ativo) return [];

    final horarios = <String>[];
    final inicio = int.parse(h.horaInicio.split(':')[0]);
    final fim = int.parse(h.horaFim.split(':')[0]);
    int? almocoIni = h.inicioAlmoco.isNotEmpty
        ? int.parse(h.inicioAlmoco.split(':')[0])
        : null;
    int? almocoFim = h.fimAlmoco.isNotEmpty
        ? int.parse(h.fimAlmoco.split(':')[0])
        : null;

    for (int i = inicio; i < fim; i++) {
      if (almocoIni != null && almocoFim != null && i >= almocoIni && i < almocoFim) {
        continue;
      }
      horarios.add('${i.toString().padLeft(2, '0')}:00');
    }

    return horarios;
  }

  // ----------------------------------------------------------
  // SERVIÇOS
  // ----------------------------------------------------------
  Future<List<Servico>> listarServicos() async {
    final snapshot = await db.collection('servicos').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Servico(
        id: doc.id,
        nome: data['nome'] ?? '',
        descricao: data['descricao'] ?? '',
        preco: (data['preco'] ?? 0).toDouble(),
        duracao: (data['duracao'] ?? 60).toInt(),
      );
    }).toList();
  }

  Future<void> atualizarServico(String id, String nome, double preco) async {
    await db.collection('servicos').doc(id).update({
      'nome': nome,
      'preco': preco,
    });
  }

  // ----------------------------------------------------------
  // AGENDAMENTOS
  // ----------------------------------------------------------
  Future<List<Agendamento>> listarAgendamentos() async {
    final snapshot = await db.collection('agendamentos').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Agendamento(
        id: doc.id,
        idCliente: data['idCliente'] ?? '',
        idProprietaria: data['idProprietaria'] ?? '',
        idServico: data['idServico'] ?? '',
        data: (data['data'] as Timestamp?)?.toDate() ?? DateTime.now(),
        status: data['status'] ?? 'agendado',
        observacao: data['observacao'],
        criadoEm: (data['criadoEm'] as Timestamp?)?.toDate() ?? DateTime.now(),
        atualizadoEm:
            (data['atualizadoEm'] as Timestamp?)?.toDate() ?? DateTime.now(),
        preco: data['preco'] != null ? (data['preco'] as num).toDouble() : 0.0,
      );
    }).toList();
  }
}
