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
      final agendamentos = await AgendamentoService.listarAgendamentos(widget.userId);

      // filtra somente os que já passaram ou estão concluídos/cancelados
      final historico = agendamentos.where((ag) {
        final agora = DateTime.now();
        return ag.data.isBefore(agora) || ag.status != "agendado";
      }).toList();

      setState(() {
        _historico = historico;
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
    final dataFormatada = DateFormat("dd/MM/yyyy 'às' HH:mm").format(ag.data);

    return Card(
      color: const Color(0xFFFAFAFA),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(
          ag.status == "cancelado" ? Icons.cancel : Icons.check_circle,
          color: ag.status == "cancelado" ? Colors.redAccent : const Color(0xFF48CFCB),
          size: 30,
        ),
        title: Text(
          "Serviço: ${ag.idServico}",
          style: const TextStyle(
            color: Color(0xFF107A73),
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          "Data: $dataFormatada\nStatus: ${ag.status}",
          style: const TextStyle(color: Colors.black54),
        ),
      ),
    );
  }
}
