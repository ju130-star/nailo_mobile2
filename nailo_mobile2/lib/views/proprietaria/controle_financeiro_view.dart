import 'package:flutter/material.dart';
import '../../services/proprietaria_service.dart';
import '../../models/agendamento.dart';

class ControleFinanceiroView extends StatelessWidget {
  final ProprietariaService service;

  ControleFinanceiroView({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Controle Financeiro"),
      ),
      body: FutureBuilder<List<Agendamento>>(
        future: service.listarAgendamentos(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final agendamentos = snapshot.data!;
          double totalRecebido = 0;
          for (var a in agendamentos) {
            totalRecebido += a.preco;
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Total de Agendamentos: ${agendamentos.length}", style: const TextStyle(fontSize: 18)),
                Text("Total Recebido: R\$ ${totalRecebido.toStringAsFixed(2)}", style: const TextStyle(fontSize: 18)),
              ],
            ),
          );
        },
      ),
    );
  }
}
