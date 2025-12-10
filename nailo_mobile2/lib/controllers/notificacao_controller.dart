import 'package:firebase_auth/firebase_auth.dart';
import 'package:nailo_mobile2/models/notificacao.dart';
import 'package:nailo_mobile2/services/notificacao_service.dart';

class NotificacaoController {
  final NotificacaoService _notificacaoService = NotificacaoService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Obtém o ID do usuário logado atualmente (cliente ou proprietária)
  String? getIdUsuarioLogado() {
    return _auth.currentUser?.uid;
  }

  // Stream para obter todas as notificações do usuário logado (CORRIGIDO: Renomeado e aceita ID)
  Stream<List<Notificacao>> streamNotificacoes(String idUsuario) { // ⬅️ Nome do método corrigido
    // A View deve garantir que idUsuario não é nulo antes de chamar.
    return _notificacaoService.streamNotificacoes(idUsuario);
  }
  
  // Stream para obter a contagem de notificações não lidas
  Stream<int> streamContadorNaoLidas() {
    final idUsuario = getIdUsuarioLogado();
    if (idUsuario == null) {
      return Stream.value(0);
    }
    // Assumimos que NotificacaoService tem streamNotificacoesNaoLidas
    return _notificacaoService.streamContadorNaoLidas(idUsuario); 
  }

  // Marca uma notificação específica como lida
  Future<void> marcarComoLida(String idNotificacao) async {
    await _notificacaoService.marcarComoLida(idNotificacao);
  }

  // Marca todas as notificações do usuário logado como lidas
  Future<void> marcarTodasComoLidas() async {
    final idUsuario = getIdUsuarioLogado();
    if (idUsuario != null) {
      await _notificacaoService.marcarTodasComoLidas(idUsuario);
    }
  }
}