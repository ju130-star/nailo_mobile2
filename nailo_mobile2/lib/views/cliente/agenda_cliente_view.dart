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
    // 1. Inicia o carregamento de dados
    _carregarAgendamentos(); 
    _selectedDay = _focusedDay; // Seleciona o dia atual por padrão
  }

  // 💡 CORREÇÃO 1: Função única de carregamento, usando o método correto do Service.
  Future<void> _carregarAgendamentos() async {
  try {
    // 🎯 ISSO É CRÍTICO: Deve chamar o método de filtro do cliente!
    final agendamentos = await AgendamentoService.listarAgendamentosDoCliente(widget.userId);

    // Linha de DEBUG FINAL
    print("DEBUG: Carregados ${agendamentos.length} agendamentos para o ID: ${widget.userId}");

    setState(() {
      _agendamentos = agendamentos;
      _carregando = false;
    });
  } catch (e) {
    print("Erro ao carregar agendamentos: $e");
    setState(() => _carregando = false);
  }
}

  // 💡 CORREÇÃO 2: Lógica de filtragem de data (Hora/UTC corrigida)
  // Retorna os agendamentos de um dia específico (Filtro local)
  List<Agendamento> _getAgendamentosDoDia(DateTime dia) {
  // 1. Normaliza o dia selecionado (ignora a hora do calendário)
  final diaSelecionado = DateTime(dia.year, dia.month, dia.day);

  return _agendamentos.where((a) {
    // 2. Converte a data do Agendamento (que está em UTC no modelo) para o fuso horário local do usuário.
    final dataAgendamentoLocal = a.data.toLocal();
    
    // 3. Normaliza a data do agendamento (ignora a hora)
    final dataAgendamentoComparavel = DateTime(
      dataAgendamentoLocal.year, 
      dataAgendamentoLocal.month, 
      dataAgendamentoLocal.day
    );
    
    // 4. Compara se os componentes de data (Ano, Mês, Dia) são estritamente iguais.
    return dataAgendamentoComparavel.year == diaSelecionado.year &&
           dataAgendamentoComparavel.month == diaSelecionado.month &&
           dataAgendamentoComparavel.day == diaSelecionado.day;

  }).toList();
}


  @override
  Widget build(BuildContext context) {
    // 💡 CORREÇÃO 3: Chama a função de FILTRO LOCAL (não a de carregamento!)
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
                // --- Calendário com lembretes ---
                Card( 
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
                    // eventLoader deve apontar para o filtro local
                    eventLoader: _getAgendamentosDoDia,
                    calendarBuilders: CalendarBuilders(
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

                // --- Lista de Agendamentos do Dia Selecionado ---
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

  // Widget _agendamentoCard (inalterado)
  Widget _agendamentoCard(Agendamento ag) {
      // Usa .toLocal() para garantir que a hora exibida seja a hora local, já que a data no Firestore é UTC
      final dataLocal = ag.data.toLocal(); 
      final hora = "${dataLocal.hour.toString().padLeft(2, '0')}:${dataLocal.minute.toString().padLeft(2, '0')}";
      final dataFormatada = "${dataLocal.day.toString().padLeft(2, '0')}/${dataLocal.month.toString().padLeft(2, '0')}/${dataLocal.year}";
      
      return Card(
        color: const Color(0xFFFAFAFA),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: ListTile(
          leading: const Icon(Icons.schedule, color: Color(0xFF48CFCB), size: 30),
          title: Text(
            ag.nomeServico, // Usando nomeServico do modelo corrigido
            style: const TextStyle(
              color: Color(0xFF107A73),
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            // Exibe a data e a hora formatada
            "$dataFormatada às $hora. Profissional: ${ag.nomeProprietaria}",
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
              // Recarrega a lista para remover o item da UI
              _carregarAgendamentos(); 
            },
          ),
        ),
      );
  }
}