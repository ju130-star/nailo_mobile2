import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 
import '../../services/proprietaria_service.dart';
import '../../models/agendamento.dart';
// 1. 🎯 IMPORTAÇÃO NECESSÁRIA PARA A NAVEGAÇÃO
import 'historico_geral_proprietaria_view.dart'; // Ajuste o caminho conforme sua estrutura

class ControleFinanceiroView extends StatelessWidget {
  final ProprietariaService service;
  // 2. 🎯 NOVO CAMPO: ID DA PROPRIETÁRIA (Necessário para a navegação)
  final String proprietariaId;

  // 3. 🎯 CONSTRUTOR CORRIGIDO: Aceita o proprietariaId e remove o 'const'
  ControleFinanceiroView({
    super.key, 
    required this.service,
    required this.proprietariaId, // Agora o ID é obrigatório
  }); 

  // Formatador de data e hora (Mantido como final)
  final DateFormat formatter = DateFormat('dd/MM HH:mm');

  // Função para filtrar agendamentos CONCLUÍDOS ou PASSADOS da semana atual (Mantida)
  List<Agendamento> filtrarHistoricoSemanal(List<Agendamento> agendamentos) {
    final now = DateTime.now();
    
    // 1. Define o início e o fim da semana
    final inicioSemana = now.subtract(Duration(days: now.weekday - 1)).copyWith(hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0);
    final fimSemana = inicioSemana.add(const Duration(days: 7));

    // 2. Filtra agendamentos:
    return agendamentos.where((a) {
      final dataAgendamento = a.data.toLocal();
      
      // Condição A: Está dentro da semana
      final estaNaSemana = dataAgendamento.isAfter(inicioSemana.subtract(const Duration(seconds: 1))) &&
                           dataAgendamento.isBefore(fimSemana);
      
      // Condição B: O agendamento é concluído (relevante para o financeiro)
      final statusValido = a.status == 'concluido'; 
      
      return estaNaSemana && statusValido; 

    }).toList();
  }
  
  // Widget auxiliar para os cards do topo (Mantido)
  Widget _cardInfo(String titulo, String valor, {required Color color}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 150,
        height: 100,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color, width: 1),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              titulo, 
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, color: color)
            ),
            const SizedBox(height: 8),
            Text(
              valor, 
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: color)
            ),
          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Controle Financeiro Semanal"),
        backgroundColor: const Color(0xFF48CFCB),
        foregroundColor: const Color(0xFF107A73),
      ),
      body: FutureBuilder<List<Agendamento>>(
        future: service.listarAgendamentos(), // Assume que este lista todos para o proprietário
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF48CFCB)));
          }
          if (snapshot.hasError) {
             return Center(child: Text("Erro ao carregar dados: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Nenhum agendamento encontrado."));
          }

          final historicoSemanal = filtrarHistoricoSemanal(snapshot.data!);
          
          final totalClientes = historicoSemanal.map((a) => a.idCliente).toSet().length;
          final totalSaldo = historicoSemanal.fold(0.0, (sum, a) => sum + a.preco);

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Cards no topo ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _cardInfo("Clientes Atendidos", totalClientes.toString(), color: const Color(0xFF107A73)),
                    _cardInfo("Saldo Recebido", "R\$ ${totalSaldo.toStringAsFixed(2)}", color: const Color(0xFF48CFCB)),
                  ],
                ),
                const SizedBox(height: 20),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Histórico de Atendimentos Concluídos na Semana", 
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF107A73))
                  ),
                ),
                const SizedBox(height: 8),
                // --- Lista de atendimentos ---
                Expanded(
                  child: historicoSemanal.isEmpty
                      ? const Center(child: Text("Nenhum atendimento concluído esta semana."))
                      : ListView.builder(
                          itemCount: historicoSemanal.length,
                          itemBuilder: (context, index) {
                            final a = historicoSemanal[index];
                            return Card(
                              color: const Color(0xFFFAFAFA),
                              elevation: 2,
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              child: ListTile(
                                title: Text(
                                  a.nomeServico,
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF107A73)),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Cliente: ${a.nomeCliente ?? 'Nome indisponível'}"),
                                    Text("Data/Hora: ${formatter.format(a.data.toLocal())}"),
                                  ],
                                ),
                                trailing: Text(
                                  "R\$ ${a.preco.toStringAsFixed(2)}",
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF48CFCB)),
                                ),
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
      
      // 4. 🎯 IMPLEMENTAÇÃO DO BOTÃO FLUTUANTE DE NAVEGAÇÃO
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navega para a tela de Histórico Geral, passando o ID da Proprietária
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HistoricoGeralProprietariaView(userId: proprietariaId), // Usa o ID que foi passado no construtor
            ),
          );
        },
        label: const Text("Histórico Completo"),
        icon: const Icon(Icons.history),
        backgroundColor: const Color(0xFF107A73),
        foregroundColor: Colors.white,
      ),
    );
  }
}