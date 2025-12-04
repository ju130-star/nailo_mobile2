import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nailo_mobile2/models/agendamento.dart';
import 'package:nailo_mobile2/services/agendamento_service.dart';

class HistoricoClienteView extends StatefulWidget {
  final String userId; // <- recebe o UID da NavbarCliente

  const HistoricoClienteView({super.key, required this.userId});

  @override
  State<HistoricoClienteView> createState() => _HistoricoClienteViewState();
}

class _HistoricoClienteViewState extends State<HistoricoClienteView> {
  List<Agendamento> _historico = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarHistorico();
  }

  Future<void> _carregarHistorico() async {
    try {
      // 🎯 CORREÇÃO 1: Usar o método que filtra AGENDAMENTOS CONCLUÍDOS/PASSADOS
      // O método listarHistoricoConcluido já está ajustado para usar 'idCliente' e 'concluido'
      final agendamentos = await AgendamentoService.listarHistoricoConcluido(widget.userId);

      // 🛑 REMOVIDA LÓGICA DE FILTRO MANUAL: 
      // Agora o serviço já traz os concluídos. Se você quiser todos (passados, concluídos E cancelados), 
      // o filtro abaixo está incompleto.
      // Manteremos apenas os que vieram do listarHistoricoConcluido, assumindo que
      // o status "concluido" é o foco principal.

      setState(() {
        _historico = agendamentos; // Usa a lista filtrada pelo serviço
        _carregando = false;
      });
    } catch (e) {
      print("Erro ao carregar histórico: $e");
      setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFA7E8E4),
      appBar: AppBar(
        title: const Text("Histórico de Agendamentos 💅"),
        centerTitle: true,
        backgroundColor: const Color(0xFF48CFCB),
      ),
      body: _carregando
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF48CFCB)),
            )
          : _historico.isEmpty
              ? const Center(
                  child: Text(
                    "Você ainda não possui histórico de agendamentos 💅",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF107A73),
                      fontSize: 16,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _historico.length,
                  itemBuilder: (context, index) {
                    final ag = _historico[index];
                    return _historicoCard(ag);
                  },
                ),
    );
  }

  Widget _historicoCard(Agendamento ag) {
    // 🎯 CORREÇÃO 3: Converte para Local Time para exibir a data/hora correta
    final dataLocal = ag.data.toLocal(); 
    final dataFormatada = DateFormat("dd/MM/yyyy 'às' HH:mm").format(dataLocal);

    // Determina o ícone e a cor com base no status (e assume concluído se a data passou)
    IconData statusIcon;
    Color statusColor;
    String statusTexto = ag.status;
    
    // Simplifica a lógica de status
    if (ag.status == "cancelado") {
      statusIcon = Icons.cancel;
      statusColor = Colors.redAccent;
    } else if (ag.status == "concluido" || ag.data.toLocal().isBefore(DateTime.now())) {
      statusIcon = Icons.check_circle;
      statusColor = const Color(0xFF48CFCB);
      if (ag.status != "cancelado") {
        statusTexto = "Concluído";
      }
    } else {
      statusIcon = Icons.schedule;
      statusColor = Colors.orange;
    }

    return Card(
      color: const Color(0xFFFAFAFA),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(
          statusIcon,
          color: statusColor,
          size: 30,
        ),
        title: Text(
          // 🎯 CORREÇÃO 2: Exibir o nome do serviço
          "Serviço: ${ag.nomeServico}", 
          style: const TextStyle(
            color: Color(0xFF107A73),
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Profissional: ${ag.nomeProprietaria}",
              style: const TextStyle(color: Colors.black54),
            ),
            Text(
              "Data: $dataFormatada",
              style: const TextStyle(color: Colors.black54),
            ),
            Text(
              "Status: $statusTexto",
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        trailing: Text(
          "R\$ ${ag.preco.toStringAsFixed(2)}",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF107A73),
          ),
        ),
      ),
    );
  }
}