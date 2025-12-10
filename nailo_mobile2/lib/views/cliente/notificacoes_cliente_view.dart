import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nailo_mobile2/controllers/notificacao_controller.dart';
import 'package:nailo_mobile2/models/notificacao.dart';

class NotificacoesClienteView extends StatefulWidget {
  const NotificacoesClienteView({super.key});

  @override
  State<NotificacoesClienteView> createState() => _NotificacoesClienteViewState();
}

class _NotificacoesClienteViewState extends State<NotificacoesClienteView> {
  final NotificacaoController _controller = NotificacaoController();
  final String? _idCliente = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    // Você pode chamar aqui uma função para buscar o nome do cliente 
    // se precisar de um título personalizado, mas vamos manter simples por agora.
  }

  @override
  Widget build(BuildContext context) {
    if (_idCliente == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Notificações"),
          backgroundColor: const Color(0xFF48CFCB),
        ),
        body: const Center(
          child: Text("Usuário não logado. Impossível carregar notificações."),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Suas Notificações"),
        centerTitle: true,
        backgroundColor: const Color(0xFF48CFCB),
      ),
      body: StreamBuilder<List<Notificacao>>(
        // 1. OBTÉM O STREAM DO CONTROLLER
        stream: _controller.streamNotificacoes(_idCliente!), 
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF48CFCB)),
            );
          }

          if (snapshot.hasError) {
            print("Erro ao carregar notificações: ${snapshot.error}");
            return Center(
              child: Text("Erro ao carregar dados: ${snapshot.error}"),
            );
          }

          final notificacoes = snapshot.data ?? [];

          // 2. FILTRAGEM DE DATA PARA LEMBRETES
          // Filtra para exibir apenas notificações cuja dataEnvio JÁ PASSOU.
          // Isso garante que o lembrete de 24h só apareça no momento agendado.
          final notificacoesExibir = notificacoes.where((n) => 
            n.dataEnvio.isBefore(DateTime.now()) || 
            n.dataEnvio.isAtSameMomentAs(DateTime.now())
          ).toList();

          if (notificacoesExibir.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined, size: 60, color: Colors.grey),
                  SizedBox(height: 10),
                  Text(
                    "Nenhuma notificação por enquanto.",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }
          
          // 3. EXIBIÇÃO DA LISTA FILTRADA
          return ListView.builder(
            itemCount: notificacoesExibir.length,
            itemBuilder: (context, index) {
              final notificacao = notificacoesExibir[index];
              final String dataFormatada = DateFormat('dd/MM, HH:mm').format(notificacao.dataEnvio.toLocal());

              return Card(
                color: notificacao.lida ? Colors.white : const Color(0xFFE0F7FA), // Cor para não lidas
                elevation: notificacao.lida ? 0.5 : 2,
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                child: ListTile(
                  leading: Icon(
                    notificacao.lida ? Icons.mail_outline : Icons.mark_email_unread,
                    color: notificacao.lida ? Colors.grey : const Color(0xFF107A73),
                  ),
                  title: Text(
                    notificacao.mensagem,
                    style: TextStyle(
                      fontWeight: notificacao.lida ? FontWeight.normal : FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  subtitle: Text(
                    "Recebido em: $dataFormatada",
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  onTap: () {
                    if (!notificacao.lida) {
                      // Marcar como lida ao tocar
                      _controller.marcarComoLida(notificacao.id);
                      // Você pode adicionar navegação ou ações aqui se a notificação tiver um link
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}