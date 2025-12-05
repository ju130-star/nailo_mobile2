import 'package:flutter/material.dart';
import 'package:nailo_mobile2/models/agendamento.dart';
import 'package:nailo_mobile2/services/agendamento_service.dart';
import 'package:nailo_mobile2/views/cliente/form_agendamento_view.dart';
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
    _carregarAgendamentos();
    _selectedDay = _focusedDay;
  }

  // ------------------------------------------------------------------
  //  FUNÇÕES DE DADOS E LÓGICA
  // ------------------------------------------------------------------

  Future<void> _carregarAgendamentos() async {
    setState(() => _carregando = true);
    try {
      final agendamentos = await AgendamentoService.listarAgendamentosDoCliente(
        widget.userId,
      );
      print(
        "DEBUG: Carregados ${agendamentos.length} agendamentos para o ID: ${widget.userId}",
      );
      setState(() {
        _agendamentos = agendamentos;
        _carregando = false;
      });
    } catch (e) {
      print("Erro ao carregar agendamentos: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erro ao carregar seus agendamentos.")),
        );
      }
      setState(() => _carregando = false);
    }
  }

  // Lógica de filtragem local (Hora/UTC corrigida)
  List<Agendamento> _getAgendamentosDoDia(DateTime dia) {
    final diaSelecionado = DateTime(dia.year, dia.month, dia.day);
    return _agendamentos.where((a) {
      final dataAgendamentoLocal = a.data.toLocal();
      final dataAgendamentoComparavel = DateTime(
        dataAgendamentoLocal.year,
        dataAgendamentoLocal.month,
        dataAgendamentoLocal.day,
      );
      return dataAgendamentoComparavel.year == diaSelecionado.year &&
          dataAgendamentoComparavel.month == diaSelecionado.month &&
          dataAgendamentoComparavel.day == diaSelecionado.day;
    }).toList();
  }

  // ------------------------------------------------------------------
  //  FLUXO DE CANCELAMENTO E REMARCAÇÃO (CORRIGIDO)
  // ------------------------------------------------------------------

  // 💡 ETAPA 3: Pergunta se quer Remarcar após o Cancelamento.
  Future<void> _mostrarOpcaoRemarcar(String proprietariaId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Sucesso no Cancelamento!"),
          content: const Text(
            "Seu agendamento foi cancelado. Gostaria de remarcar agora?",
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("DEIXAR PRA DEPOIS"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                "REMARCAR AGORA",
                style: TextStyle(color: Color(0xFF107A73)),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      if (mounted) {
        // 🎯 CORREÇÃO: Adicionando 'await' para esperar o retorno da tela de remarcação
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => FormAgendamentoView(
              proprietariaId: proprietariaId, // Argumento REQUERIDO
            ),
          ),
        );
        // Recarrega os agendamentos APÓS o retorno
        _carregarAgendamentos();
      }
    }
  }

  // 💡 ETAPA 2: Confirmação e Execução (chamada diretamente pelo card)
  Future<void> _confirmarCancelamento(Agendamento agendamento) async {
    final isPast = agendamento.data.toLocal().isBefore(DateTime.now());

    // Não permite cancelar agendamentos passados
    if (isPast) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Agendamentos passados não podem ser cancelados.")),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirmar Cancelamento"),
          content: Text(
            'Tem certeza que deseja cancelar o agendamento de ${agendamento.nomeServico}? Esta ação não pode ser desfeita.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("MANTER"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                "CANCELAR",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        await AgendamentoService.deletarAgendamento(agendamento.id);

        if (!mounted) return;

        await _carregarAgendamentos();

        // Passando o ID da proprietária para a remarcação
        _mostrarOpcaoRemarcar(agendamento.idProprietaria);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("❌ Erro ao cancelar o agendamento: ${e.toString()}"),
          ),
        );
      }
    }
  }

  // A função _showOpcoesAgendamento foi removida.

  // ------------------------------------------------------------------
  //  WIDGETS
  // ------------------------------------------------------------------

  // 🎯 CORRIGIDO: O Card agora tem um IconButton no trailing para o cancelamento
  Widget _agendamentoCard(Agendamento ag) {
    final dataLocal = ag.data.toLocal();
    final hora =
        "${dataLocal.hour.toString().padLeft(2, '0')}:${dataLocal.minute.toString().padLeft(2, '0')}";
    final dataFormatada =
        "${dataLocal.day.toString().padLeft(2, '0')}/${dataLocal.month.toString().padLeft(2, '0')}/${dataLocal.year}";
    
    // Verifica se o agendamento é passado para desabilitar o botão de cancelamento
    final isPast = ag.data.toLocal().isBefore(DateTime.now());

    return Card(
      color: const Color(0xFFFAFAFA),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: const Icon(
          Icons.schedule,
          color: Color(0xFF48CFCB),
          size: 30,
        ),
        title: Text(
          ag.nomeServico,
          style: const TextStyle(
            color: Color(0xFF107A73),
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          "$dataFormatada às $hora. Profissional: ${ag.nomeProprietaria}",
          style: const TextStyle(color: Colors.black54),
        ),
        // Ícone de lixeira para iniciar o cancelamento
        trailing: IconButton(
          icon: Icon(
            Icons.delete, 
            color: isPast ? Colors.grey : Colors.redAccent,
          ),
          onPressed: isPast 
            ? null // Desabilita o botão se for passado
            : () => _confirmarCancelamento(ag), // Chama a confirmação diretamente
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final agendamentosDoDia = _selectedDay != null
        ? _getAgendamentosDoDia(_selectedDay!)
        : [];

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
                // --- Calendário ---
                Card(
                  margin: const EdgeInsets.all(8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
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
                      ? const Center(
                          child: Text("Nenhum agendamento para este dia"),
                        )
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
}