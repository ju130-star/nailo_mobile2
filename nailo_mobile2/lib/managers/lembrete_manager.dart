import 'package:intl/intl.dart';
import 'package:nailo_mobile2/services/notificacao_service.dart';
// Note: Você pode precisar ajustar o caminho de importação (nailo_mobile2/) 
// conforme a raiz do seu projeto.

class LembreteManager {
  // Use a mesma instância do serviço de notificação
  final NotificacaoService _notificacaoService = NotificacaoService();

  /// Cria as notificações IMEDIATAS para o cliente e a proprietária após um agendamento.
  /// 
  /// @param idCliente: O ID do usuário que agendou.
  /// @param idProprietaria: O ID da proprietária que receberá o aviso imediato.
  /// @param dataHoraAgendamento: A data e hora do serviço agendado.
  Future<void> criarNotificacoesAgendamento({
    required String idCliente,
    required String nomeCliente, // 💡 ADICIONE O NOME DO CLIENTE PARA A PROPRIETÁRIA
    required String idProprietaria,
    required DateTime dataHoraAgendamento,
  }) async {
    // Adicione esta linha no seu main() para garantir que o 'pt_BR' funcione
    // initializeDateFormatting('pt_BR', null); 
    
    final dataFormatadaCompleta = DateFormat('EEEE, dd/MM \à\s HH:mm', 'pt_BR').format(dataHoraAgendamento);
    final dataFormatadaCurta = DateFormat('dd/MM HH:mm').format(dataHoraAgendamento);

    // -----------------------------------------------------------------
    // 1. NOTIFICAÇÃO IMEDIATA: PARA A PROPRIETÁRIA (Aviso de novo agendamento)
    // -----------------------------------------------------------------
    await _notificacaoService.enviarNotificacao(
      idUsuario: idProprietaria,
      titulo: "✨ Novo Agendamento Recebido", // 💡 CAMPO TITULO ADICIONADO
      mensagem: "O cliente ${nomeCliente} agendou um serviço para $dataFormatadaCurta. Verifique a lista.",
    );

    // -----------------------------------------------------------------
    // 2. NOTIFICAÇÃO IMEDIATA: PARA O CLIENTE (Confirmação do agendamento)
    // -----------------------------------------------------------------
    final mensagemClienteConfirmacao = "SUCESSO! Seu serviço está confirmado para $dataFormatadaCompleta. Te esperamos! 💅";

    await _notificacaoService.enviarNotificacao(
      idUsuario: idCliente,
      titulo: "✅ Agendamento Confirmado", // 💡 CAMPO TITULO ADICIONADO
      mensagem: mensagemClienteConfirmacao,
    );
    
    // -----------------------------------------------------------------
    // 3. O LEMBRETE DE 24H: É tratado pela lógica no HomeClienteView.dart
    // Não criamos o lembrete aqui, pois ele é futuro!
    // -----------------------------------------------------------------
  }
}