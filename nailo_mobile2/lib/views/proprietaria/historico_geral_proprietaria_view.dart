import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nailo_mobile2/models/agendamento.dart';
import 'package:nailo_mobile2/services/agendamento_service.dart';

class HistoricoGeralProprietariaView extends StatefulWidget {
  final String userId; // ID da Proprietária

  const HistoricoGeralProprietariaView({super.key, required this.userId});

  @override
  State<HistoricoGeralProprietariaView> createState() => _HistoricoGeralProprietariaViewState();
}

class _HistoricoGeralProprietariaViewState extends State<HistoricoGeralProprietariaView> {
  List<Agendamento> _historicoCompleto = [];
  bool _carregando = true;
  String? _errorMessage; // Adicionado para exibir erros de forma amigável

  @override
  void initState() {
    super.initState();
    _carregarHistoricoGeral();
  }

  Future<void> _carregarHistoricoGeral() async {
    setState(() {
      _carregando = true;
      _errorMessage = null; // Limpa o erro anterior
    });
    try {
      // 🎯 CHAMADA CORRETA: Busca TODOS os agendamentos sem filtro de status ou data.
      print("DEBUG ID: ID de Proprietária sendo buscado: ${widget.userId}");
      final agendamentos = await AgendamentoService.listarTodosAgendamentosPorProprietaria(widget.userId);

      setState(() {
        _historicoCompleto = agendamentos;
      });
    } catch (e) {
      print("Erro ao carregar histórico geral: $e");
      // 💡 Tratamento de erro melhorado
      setState(() {
        _errorMessage = "Falha ao carregar o histórico completo. Tente novamente.";
      });
    } finally {
      setState(() {
        _carregando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFA7E8E4),
      appBar: AppBar(
        title: const Text("Histórico Geral de Agendamentos"),
        centerTitle: true,
        backgroundColor: const Color(0xFF48CFCB),
        foregroundColor: const Color(0xFF107A73), // Cor do texto/ícones
      ),
      body: _carregando
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF48CFCB)),
            )
          : _errorMessage != null
              ? Center( // Exibe o erro se houver
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    ),
                  ),
                )
              : _historicoCompleto.isEmpty
                  ? const Center(
                      child: Text(
                        "Nenhum agendamento encontrado no histórico.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF107A73),
                          fontSize: 16,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _historicoCompleto.length,
                      itemBuilder: (context, index) {
                        final ag = _historicoCompleto[index];
                        return _historicoCard(ag);
                      },
                    ),
    );
  }

  Widget _historicoCard(Agendamento ag) {
    final dataLocal = ag.data.toLocal();
    final dataFormatada = DateFormat("dd/MM/yyyy 'às' HH:mm").format(dataLocal);

    // Lógica de Status (Aprimorada para histórico geral)
    IconData statusIcon;
    Color statusColor;
    
    // 💡 TRATAMENTO DE STATUS VAZIO/NULO
    final status = (ag.status ?? '').toLowerCase(); 

    if (status == "cancelado") {
      statusIcon = Icons.cancel;
      statusColor = Colors.red;
    } else if (status == "concluido") {
      statusIcon = Icons.check_circle;
      statusColor = const Color(0xFF48CFCB); // Cor de sucesso
    } else if (dataLocal.isBefore(DateTime.now())) {
      // Passou da hora E não foi marcado como concluído ou cancelado
      statusIcon = Icons.error;
      statusColor = Colors.grey[700]!;
    } else {
      // Agendamento futuro ou 'ativo'
      statusIcon = Icons.schedule;
      statusColor = Colors.orange;
    }

    // Define o texto de status final (usando o status original se ele existir)
    String statusTexto = status.isEmpty ? 'Pendente/Status Desconhecido' : status[0].toUpperCase() + status.substring(1);

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
          ag.nomeServico, 
          style: const TextStyle(
            color: Color(0xFF107A73),
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Cliente: ${ag.nomeCliente ?? 'Nome indisponível'}",
              style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
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
            fontSize: 16,
            color: Color(0xFF107A73),
          ),
        ),
      ),
    );
  }
}