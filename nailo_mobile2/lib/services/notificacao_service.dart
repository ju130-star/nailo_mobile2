import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notificacao.dart'; // Assumindo que Notificacao tem os campos id, idUsuario, titulo, mensagem, dataEnvio, lida

class NotificacaoService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ============================================================
  // 1. ENVIAR NOTIFICAÇÃO (Usado pela lógica do lembrete de cliente)
  // ============================================================
  Future<void> enviarNotificacao({
    required String idUsuario,
    required String titulo, 
    required String mensagem,
  }) async {
    final id = _db.collection("notificacoes").doc().id;

    final notificacao = Notificacao(
      id: id,
      idUsuario: idUsuario,
      mensagem: mensagem,
      dataEnvio: DateTime.now(), // ⬅️ Data do momento em que o cliente abriu o app e o lembrete foi disparado
      lida: false,
    );

    await _db.collection("notificacoes").doc(id).set(notificacao.toMap());
  }

  // ============================================================
  // 2. MARCAR COMO LIDA
  // ============================================================
  Future<void> marcarComoLida(String idNotificacao) async {
    await _db.collection("notificacoes").doc(idNotificacao).update({
      "lida": true,
    });
  }

  // ============================================================
  // 3. MARCAR TODAS AS NOTIFICAÇÕES COMO LIDAS
  // ============================================================
  Future<void> marcarTodasComoLidas(String idUsuario) async {
    // Busca todas as não lidas do usuário
    final snapshot = await _db
        .collection("notificacoes")
        .where("idUsuario", isEqualTo: idUsuario)
        .where("lida", isEqualTo: false)
        .get();

    // Atualiza cada uma
    for (var doc in snapshot.docs) {
      await doc.reference.update({"lida": true});
    }
  }

  // ============================================================
  // 4. BUSCAR NOTIFICAÇÕES EM TEMPO REAL (STREAM)
  // ============================================================
  Stream<List<Notificacao>> streamNotificacoes(String idUsuario) {
    return _db
        .collection("notificacoes")
        .where("idUsuario", isEqualTo: idUsuario)
        .orderBy("dataEnvio", descending: true)
        .snapshots()
        .map((query) {
          return query.docs.map((doc) {
            // Garante que o ID do documento é repassado para o modelo
            final data = doc.data();
            data['id'] = doc.id; 
            return Notificacao.fromMap(data); 
          }).toList();
        });
  }

  // ============================================================
  // 5. BUSCAR NOTIFICAÇÕES NÃO LIDAS (contar)
  // (COM CORREÇÃO DO FILTRO DE DATA)
  // ============================================================
  Stream<int> streamContadorNaoLidas(String idUsuario) {
    return _db
        .collection("notificacoes")
        .where("idUsuario", isEqualTo: idUsuario)
        .where("lida", isEqualTo: false)
        // ✅ FILTRO CORRETO: Compara Timestamp (no Firestore) com DateTime (no Dart)
        .where("dataEnvio", isLessThanOrEqualTo: DateTime.now())
        .snapshots()
        .map((query) => query.docs.length);
  }

  // ============================================================
  // 6. DELETAR NOTIFICAÇÃO (opcional)
  // ============================================================
  Future<void> deletarNotificacao(String idNotificacao) async {
    await _db.collection("notificacoes").doc(idNotificacao).delete();
  }

  // ============================================================
  // 7. MARCAR AGENDAMENTO COMO "LEMBRETE ENVIADO" (NOVO)
  // (Essencial para a lógica de cliente para evitar repetição do pop-up)
  // ============================================================
  Future<void> marcarLembreteEnviado(String idAgendamento) async {
    // ⚠️ ATENÇÃO: Verifique se o nome da coleção é EXATAMENTE 'agendamentos'
    await _db.collection("agendamentos").doc(idAgendamento).update({
      "lembreteEnviado": true, // Novo campo no documento de agendamento
    });
  }
}