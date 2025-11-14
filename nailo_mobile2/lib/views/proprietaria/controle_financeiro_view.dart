import 'package:flutter/material.dart';
import '../../services/proprietaria_service.dart';
import '../../models/agendamento.dart';

class ControleFinanceiroView extends StatelessWidget {
  final ProprietariaService service;

  ControleFinanceiroView({super.key, required this.service});

  // Função para filtrar os agendamentos da semana atual
  List<Agendamento> filtrarSemana(List<Agendamento> agendamentos) {
    final now = DateTime.now();
    final inicioSemana = now.subtract(Duration(days: now.weekday - 1)); // segunda-feira
    final fimSemana = inicioSemana.add(const Duration(days: 7));

    return agendamentos.where((a) {
      return a.data.isAfter(inicioSemana.subtract(const Duration(seconds: 1))) &&
             a.data.isBefore(fimSemana);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Controle Financeiro Semanal")),
      body: FutureBuilder<List<Agendamento>>(
        future: service.listarAgendamentos(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final semana = filtrarSemana(snapshot.data!);
          final totalClientes = semana.map((a) => a.idCliente).toSet().length;
          final totalSaldo = semana.fold(0.0, (sum, a) => sum + a.preco);

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // --- Cards no topo ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _cardInfo("Clientes Atendidos", totalClientes.toString()),
                    _cardInfo("Saldo Recebido", "R\$ ${totalSaldo.toStringAsFixed(2)}"),
                  ],
                ),
                const SizedBox(height: 20),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Histórico de Atendimentos", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                const SizedBox(height: 8),
                // --- Lista de atendimentos ---
                Expanded(
                  child: ListView.builder(
                    itemCount: semana.length,
                    itemBuilder: (context, index) {
                      final a = semana[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          title: Text(a.idServico),
                          subtitle: Text("Cliente: ${a.idCliente}\nData: ${a.data.toLocal()}"),
                          trailing: Text("R\$ ${a.preco.toStringAsFixed(2)}"),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Widget auxiliar para os cards do topo
  Widget _cardInfo(String titulo, String valor) {
    return Card(
      elevation: 2,
      child: Container(
        width: 150,
        height: 80,
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(valor, style: const TextStyle(fontSize: 16, color: Colors.blue)),
          ],
        ),
      ),
    );
  }
}
