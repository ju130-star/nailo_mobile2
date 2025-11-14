import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../services/proprietaria_service.dart';
import '../../models/agendamento.dart';

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
  }

  Future<void> _loadAgendamentos() async {
    final all = await widget.service.listarAgendamentos();
    setState(() {
      _agendamentos = all;
    });
  }

  // Retorna os agendamentos de um dia específico
  List<Agendamento> _getAgendamentosDoDia(DateTime dia) {
    return _agendamentos.where((a) {
      return a.data.year == dia.year &&
             a.data.month == dia.month &&
             a.data.day == dia.day;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Agenda da Proprietária")),
      body: Column(
        children: [
          // --- Barra horizontal com perfis das clientes ---
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
                        child: Text(a.idCliente.substring(0, 2).toUpperCase()), // inicial do cliente
                      ),
                      const SizedBox(height: 4),
                      Text(a.idCliente, style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

          const Divider(),

          // --- Calendário com lembretes ---
          Expanded(
            child: TableCalendar(
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
                    return ListView(
                      shrinkWrap: true,
                      children: diaAgendamentos.map((a) => Container(
                        margin: const EdgeInsets.symmetric(vertical: 1),
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blue,
                        ),
                      )).toList(),
                    );
                  }
                  return null;
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
