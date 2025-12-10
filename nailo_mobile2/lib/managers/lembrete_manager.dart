import 'package:intl/intl.dart';
import 'package:nailo_mobile2/services/notificacao_service.dart';
// Note: Você pode precisar ajustar o caminho de importação (nailo_mobile2/) 
// conforme a raiz do seu projeto.

class LembreteManager {
  final NotificacaoService _notificacaoService = NotificacaoService();

  /// Cria as notificações de lembrete e aviso para o cliente e a proprietária.
  /// 
  /// @param idCliente: O ID do usuário que agendou.
  /// @param idProprietaria: O ID da proprietária que receberá o aviso imediato.
  /// @param dataHoraAgendamento: A data e hora do serviço agendado.
  Future<void> criarNotificacoesAgendamento({
    required String idCliente,
    required String idProprietaria,
    required DateTime dataHoraAgendamento,
  }) async {
    // A formatação 'EEEE' requer que você tenha o pacote 'intl' instalado 
    // e o locale 'pt_BR' configurado no seu MaterialApp.
    final dataFormatadaCompleta = DateFormat('EEEE, dd/MM \à\s HH:mm', 'pt_BR').format(dataHoraAgendamento);
    final dataFormatadaCurta = DateFormat('dd/MM HH:mm').format(dataHoraAgendamento);

    // -----------------------------------------------------------------
    // 1. NOTIFICAÇÃO IMEDIATA: PARA A PROPRIETÁRIA (Aviso de novo agendamento)
    // -----------------------------------------------------------------
    await _notificacaoService.enviarNotificacao(
      idUsuario: idProprietaria,
      mensagem: "Novo agendamento em $dataFormatadaCurta. Verifique a lista de reservas.",
      dataAgendada: DateTime.now(), // Envio Imediato (aparece agora)
    );

    // -----------------------------------------------------------------
    // 2. NOTIFICAÇÃO AGENDADA: PARA O CLIENTE (Lembrete 24h antes)
    // -----------------------------------------------------------------
    
    // Calcular a data e hora exata 24 horas antes do agendamento
    final dataLembrete = dataHoraAgendamento.subtract(const Duration(hours: 24));
    
    final mensagemCliente = "LEMBRETE: Seu agendamento de unhas está marcado para $dataFormatadaCompleta. Te esperamos! 💅";

    // Salvar no Firestore com a data FUTURA. O cliente só verá o lembrete 
    // quando a dataLembrete for atingida e ele abrir a tela de notificações.
    await _notificacaoService.enviarNotificacao(
      idUsuario: idCliente,
      mensagem: mensagemCliente,
      dataAgendada: dataLembrete, // Envio Agendado (aparece 24h antes)
    );
  }
}