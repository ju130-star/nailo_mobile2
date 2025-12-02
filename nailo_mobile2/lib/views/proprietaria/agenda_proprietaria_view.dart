import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart'; 
import '../../services/proprietaria_service.dart';
import '../../services/agendamento_service.dart'; // <--- AJUSTE O CAMINHO!
import '../../models/agendamento.dart'; // <--- AJUSTE O CAMINHO!

class AgendaProprietariaView extends StatefulWidget {
  final ProprietariaService service;

  const AgendaProprietariaView({super.key, required this.service});

  @override
  State<AgendaProprietariaView> createState() => _AgendaProprietariaViewState();
}

class _AgendaProprietariaViewState extends State<AgendaProprietariaView> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<Agendamento> _agendamentos = [];

  @override
  void initState() {
    super.initState();
    _loadAgendamentos();
    _selectedDay = _focusedDay;
  }

  Future<void> _loadAgendamentos() async {
    try {
        // Assume que 'listarAgendamentos' busca os dados do Firestore
        final all = await widget.service.listarAgendamentos();
        setState(() {
          _agendamentos = all;
        });
    } catch (e) {
        print("Erro ao carregar agendamentos: $e");
        setState(() {
          _agendamentos = [];
        });
    }
  }

  List<Agendamento> _getAgendamentosDoDia(DateTime dia) {
    return _agendamentos.where((a) {
      final dataLocal = a.data.toLocal(); 
      return dataLocal.year == dia.year &&
             dataLocal.month == dia.month &&
             dataLocal.day == dia.day;
    }).toList();
  }
  
  String _getIniciais(String nomeCliente) {
    if (nomeCliente.isNotEmpty) {
      return nomeCliente.length >= 2
          ? nomeCliente.substring(0, 2).toUpperCase()
          : nomeCliente.toUpperCase(); 
    }
    return '??'; 
  }

  // MÉTODO COM A LÓGICA DE TOGGLE (CONCLUIR / DESFAZER CONCLUSÃO)
  Future<void> _toggleAgendamentoStatus(String agendamentoId, String currentStatus) async {
    try {
      if (agendamentoId.isEmpty) return;
      
      // Se o status atual é 'concluido', o novo status deve ser 'agendado'.
      // Caso contrário (se for 'agendado' ou outro), o novo status será 'concluido'.
      final newStatus = currentStatus == 'concluido' ? 'agendado' : 'concluido';
      final actionText = newStatus == 'concluido' ? "concluído" : "revertido para agendado";
      
      // Chamada que PRECISA da classe AgendamentoService
      await AgendamentoService.atualizarStatusAgendamento(agendamentoId, newStatus);
      
      await _loadAgendamentos(); 

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("✅ Atendimento $actionText com sucesso!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❌ Erro ao atualizar status. Tente novamente.")),
      );
      await _loadAgendamentos();
    }
  }

  // Função para exibir o diálogo de conclusão/detalhes
  void _showConcluirDialog(BuildContext context, Agendamento agendamento) {
    final bool isConcluido = agendamento.status == 'concluido';
    
    // Define o texto e a cor da ação com base no status atual
    final String actionText = isConcluido ? "DESFAZER CONCLUSÃO" : "MARCAR COMO CONCLUÍDO";
    final Color actionColor = isConcluido ? Colors.orange.shade800 : Colors.green.shade600;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Detalhes do Agendamento"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text("Cliente: ${agendamento.nomeCliente}", style: const TextStyle(fontWeight: FontWeight.bold)),
                Text("Serviço: ${agendamento.nomeServico}"),
                Text("Horário: ${DateFormat('dd/MM/yyyy HH:mm').format(agendamento.data.toLocal())}"), 
                Text("Preço: R\$ ${agendamento.preco.toStringAsFixed(2)}"), 
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Text("Status Atual: ", style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                      agendamento.status?.toUpperCase() ?? 'PENDENTE',
                      style: TextStyle(
                        color: isConcluido ? Colors.green : Colors.blue, 
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          actions: <Widget>[
            // Botão de Ação (Concluir ou Desfazer)
            TextButton(
              style: TextButton.styleFrom(foregroundColor: actionColor),
              onPressed: () async {
                  Navigator.of(dialogContext).pop(); 
                  // Chama a função de toggle
                  await _toggleAgendamentoStatus(agendamento.id!, agendamento.status!); 
                },
              child: Text(actionText),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text("FECHAR"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final agendamentosDoDia = _selectedDay != null ? _getAgendamentosDoDia(_selectedDay!) : [];

    return Scaffold(
      appBar: AppBar(title: const Text("Agenda da Proprietária")),
      body: Column(
        children: [
          // Barra horizontal de perfis
          SizedBox(
            height: 80,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: _agendamentos.map((a) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 25,
                        child: Text(_getIniciais(a.nomeCliente)), 
                      ),
                      const SizedBox(height: 4),
                      Text(a.nomeCliente, style: const TextStyle(fontSize: 12)), 
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

          const Divider(),

          // Calendário
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, day, events) {
                final diaAgendamentos = _getAgendamentosDoDia(day);
                if (diaAgendamentos.isNotEmpty) {
                  final agendamentosNaoCancelados = diaAgendamentos.where((a) => a.status != 'cancelado').toList();
                  
                  if (agendamentosNaoCancelados.isEmpty) return null;

                  final markerColor = agendamentosNaoCancelados.every((a) => a.status == 'concluido') 
                      ? Colors.green 
                      : Colors.blue;

                  return Positioned(
                    right: 1,
                    bottom: 1,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: markerColor, 
                      ),
                    ),
                  );
                }
                return null;
              },
            ),
          ),

          const SizedBox(height: 16),

          // Cards de atendimentos do dia selecionado
          Expanded(
            child: agendamentosDoDia.isEmpty
                ? const Center(child: Text("Nenhum atendimento para este dia"))
                : ListView.builder(
                    itemCount: agendamentosDoDia.length,
                    itemBuilder: (context, index) {
                      final agendamento = agendamentosDoDia[index];
                      final horaFormatada = DateFormat('HH:mm').format(agendamento.data.toLocal()); 
                      
                      final isConcluido = agendamento.status == 'concluido';
                      final cardColor = isConcluido ? Colors.green.shade50 : Colors.white; 
                      final statusDisplay = agendamento.status?.toUpperCase() ?? 'PENDENTE';

                      return InkWell(
                        onTap: () => _showConcluirDialog(context, agendamento), 
                        
                        child: Card(
                          color: cardColor,
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 25,
                                  child: Text(_getIniciais(agendamento.nomeCliente)), 
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        agendamento.nomeServico, 
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "${agendamento.nomeCliente} (R\$${agendamento.preco.toStringAsFixed(2)})",
                                        style: TextStyle(
                                          decoration: isConcluido ? TextDecoration.lineThrough : null 
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        statusDisplay,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: isConcluido ? Colors.green.shade700 : Colors.blue,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Text(horaFormatada), 
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}