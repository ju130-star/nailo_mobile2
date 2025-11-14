import 'package:flutter/material.dart';
import 'package:nailo_mobile2/models/agendamento.dart';
import 'package:nailo_mobile2/services/agendamento_service.dart';

class AgendaClienteView extends StatefulWidget {
  final String userId; // <- recebe o UID da NavbarCliente

  const AgendaClienteView({super.key, required this.userId});

  @override
  State<AgendaClienteView> createState() => _AgendaClienteViewState();
}

class _AgendaClienteViewState extends State<AgendaClienteView> {
  List<Agendamento> _agendamentos = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarAgendamentos();
  }

  Future<void> _carregarAgendamentos() async {
    try {
      final agendamentos = await AgendamentoService.listarAgendamentos(widget.userId);

      setState(() {
        _agendamentos = agendamentos;
        _carregando = false;
      });
    } catch (e) {
      print("Erro ao carregar agendamentos: $e");
      setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFA7E8E4),
      appBar: AppBar(
        title: const Text("Minha Agenda 💅"),
        centerTitle: true,
        backgroundColor: const Color(0xFF48CFCB),
      ),
      body: _carregando
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF48CFCB)),
            )
          : _agendamentos.isEmpty
              ? const Center(
                  child: Text(
                    "Você ainda não tem agendamentos marcados 💅",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF107A73),
                      fontSize: 16,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _agendamentos.length,
                  itemBuilder: (context, index) {
                    final ag = _agendamentos[index];
                    return _agendamentoCard(ag);
                  },
                ),
    );
  }

  Widget _agendamentoCard(Agendamento ag) {
    return Card(
      color: const Color(0xFFFAFAFA),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: const Icon(Icons.schedule, color: Color(0xFF48CFCB), size: 30),
        title: Text(
          ag.idServico,
          style: const TextStyle(
            color: Color(0xFF107A73),
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          "${ag.data} às ${ag.data}",
          style: const TextStyle(color: Colors.black54),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.redAccent),
          onPressed: () async {
            await AgendamentoService.deletarAgendamento(ag.id);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Agendamento deletado com sucesso")),
            );
            _carregarAgendamentos();
          },
        ),
      ),
    );
  }
}
