import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notificacao.dart';

class NotificacaoService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ============================================================
  // 1. ENVIAR NOTIFICAÇÃO
  // ============================================================
  Future<void> enviarNotificacao({
    required String idUsuario,
    required String mensagem,
  }) async {
    final id = _db.collection("notificacoes").doc().id;

    final notificacao = Notificacao(
      id: id,
      idUsuario: idUsuario,
      mensagem: mensagem,
      dataEnvio: DateTime.now(),
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
    final snapshot = await _db
        .collection("notificacoes")
        .where("idUsuario", isEqualTo: idUsuario)
        .where("lida", isEqualTo: false)
        .get();

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
        return Notificacao.fromMap(doc.data());
      }).toList();
    });
  }

  // ============================================================
  // 5. BUSCAR NOTIFICAÇÕES NÃO LIDAS (contar)
  // ============================================================
  Stream<int> streamNotificacoesNaoLidas(String idUsuario) {
    return _db
        .collection("notificacoes")
        .where("idUsuario", isEqualTo: idUsuario)
        .where("lida", isEqualTo: false)
        .snapshots()
        .map((snap) => snap.size);
  }

  // ============================================================
  // 6. DELETAR NOTIFICAÇÃO (opcional)
  // ============================================================
  Future<void> deletarNotificacao(String idNotificacao) async {
    await _db.collection("notificacoes").doc(idNotificacao).delete();
  }
}