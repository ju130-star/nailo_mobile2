import 'package:flutter/material.dart';
import 'package:nailo_mobile2/models/agendamento.dart';
import 'package:nailo_mobile2/services/agendamento_service.dart';
import 'package:table_calendar/table_calendar.dart';

class AgendaClienteView extends StatefulWidget {
  final String userId; // <- recebe o UID da NavbarCliente

  const AgendaClienteView({super.key, required this.userId});

  @override
  State<AgendaClienteView> createState() => _AgendaClienteViewState();
}

class _AgendaClienteViewState extends State<AgendaClienteView> {
  // Variáveis de Estado
  List<Agendamento> _agendamentos = [];
  bool _carregando = true;

  // Variáveis do Calendário
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    // Fluxo de carregamento padrão, como o modelo da proprietária
    _carregarAgendamentos(); 
    _selectedDay = _focusedDay; // Seleciona o dia atual por padrão
  }

  Future<void> _carregarAgendamentos() async {
    try {
      // Lista agendamentos filtrados pelo idCliente (widget.userId)
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

  // Retorna os agendamentos de um dia específico
  List<Agendamento> _getAgendamentosDoDia(DateTime dia) {
    return _agendamentos.where((a) {
      // Compara apenas o dia, mês e ano
      return a.data.year == dia.year &&
             a.data.month == dia.month &&
             a.data.day == dia.day;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Filtra os agendamentos do dia selecionado
    final agendamentosDoDia = _selectedDay != null ? _getAgendamentosDoDia(_selectedDay!) : [];

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
          : Column(
              children: [
                // Não colocaremos a barra horizontal de perfis, pois na visão do cliente,
                // ela já tem o ID dela (widget.userId) e não precisa listar todos os clientes.
                
                // --- Calendário com lembretes ---
                Card( // Usando Card para dar um visual mais clean ao calendário
                  margin: const EdgeInsets.all(8.0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 3,
                  child: TableCalendar(
                    locale: 'pt_BR', 
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
                    eventLoader: _getAgendamentosDoDia,
                    calendarBuilders: CalendarBuilders(
                      // Modelando o markerBuilder para ser similar ao modelo
                      markerBuilder: (context, day, events) {
                        final diaAgendamentos = _getAgendamentosDoDia(day);
                        if (diaAgendamentos.isNotEmpty) {
                          return Positioned(
                            right: 1,
                            bottom: 1,
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Color(0xFF48CFCB),
                                shape: BoxShape.circle,
                              ),
                            ),
                          );
                        }
                        return null;
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                
                // --- Título Dinâmico de Agendamentos ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _selectedDay == null 
                          ? "Selecione um dia" 
                          : "Agendamentos para ${_selectedDay!.day.toString().padLeft(2, '0')}/${_selectedDay!.month.toString().padLeft(2, '0')}",
                      style: const TextStyle(
                        fontSize: 18, 
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF107A73),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 8),

                // --- Lista de Agendamentos do Dia Selecionado (Expanded para evitar Overflow) ---
                Expanded(
                  child: agendamentosDoDia.isEmpty
                      ? const Center(child: Text("Nenhum agendamento para este dia"))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: agendamentosDoDia.length,
                          itemBuilder: (context, index) {
                            final agendamento = agendamentosDoDia[index];
                            return _agendamentoCard(agendamento);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _agendamentoCard(Agendamento ag) {
     final hora = "${ag.data.hour.toString().padLeft(2, '0')}:${ag.data.minute.toString().padLeft(2, '0')}";
     final dataFormatada = "${ag.data.day.toString().padLeft(2, '0')}/${ag.data.month.toString().padLeft(2, '0')}/${ag.data.year}";
     
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
            // Exibe a data e a hora formatada
            "$dataFormatada às $hora. Profissional: ${ag.idProprietaria}",
            style: const TextStyle(color: Colors.black54),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: Colors.redAccent),
            onPressed: () async {
              await AgendamentoService.deletarAgendamento(ag.id);
              if (!mounted) return;
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