import 'package:flutter/material.dart';
import 'package:nailo_mobile2/models/horario_trabalho.dart';
import 'package:nailo_mobile2/models/slot_dia.dart';
import 'package:nailo_mobile2/services/proprietaria_service.dart';
import 'package:nailo_mobile2/services/slot_dia_service.dart';
import 'package:nailo_mobile2/views/proprietaria/alterar_horarios_view.dart';

class HomeProprietariaView extends StatefulWidget {
  const HomeProprietariaView({super.key});

  @override
  State<HomeProprietariaView> createState() => _HomeProprietariaViewState();
}

class _HomeProprietariaViewState extends State<HomeProprietariaView> {
  final SlotDiaService slotService = SlotDiaService();
  final ProprietariaService proprietariaService = ProprietariaService();

  List<HorarioTrabalho> horarios = [];
  HorarioTrabalho? horarioSelecionado;

  List<SlotDia> slots = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    inicializar();
  }

  Future<void> inicializar() async {
    setState(() => loading = true);
    await proprietariaService.inicializarHorariosPadroes();
    await carregarHorarios();
    setState(() => loading = false);
  }

  Future<void> carregarHorarios() async {
    horarios = await proprietariaService.listarHorarios();

    final ordemSemana = [
      "segunda",
      "terca",
      "quarta",
      "quinta",
      "sexta",
      "sabado",
      "domingo",
    ];

    horarios.sort((a, b) {
      final aIndex = ordemSemana.indexOf(a.diaSemana.toLowerCase());
      final bIndex = ordemSemana.indexOf(b.diaSemana.toLowerCase());
      return aIndex.compareTo(bIndex);
    });

    final hoje = DateTime.now().weekday;
    horarioSelecionado = horarios.firstWhere(
      (h) => ordemSemana.indexOf(h.diaSemana.toLowerCase()) + 1 == hoje,
      orElse: () => horarios.first,
    );

    if (horarioSelecionado != null) {
      await carregarSlots();
    }
  }

  Future<void> carregarSlots() async {
    if (horarioSelecionado == null) return;
    setState(() => loading = true);
    slots = await slotService.gerarSlotsDoDia(horarioSelecionado!);
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFA7E8E4), // fundo principal
      appBar: AppBar(
        title: const Text("Painel da Proprietária 💅"),
        backgroundColor: const Color(0xFF48CFCB),
        foregroundColor: const Color(0xFF107A73),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.access_time),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AlterarHorariosView(
                    service: proprietariaService,
                    semana: horarios,
                  ),
                ),
              );
              await carregarHorarios();
            },
          )
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Column(
              children: [
                const SizedBox(height: 16),
                _buildSeletorDias(),
                const SizedBox(height: 16),
                Expanded(child: _buildTimeline()),
              ],
            ),
    );
  }

  Widget _buildSeletorDias() {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: horarios.length,
        itemBuilder: (context, index) {
          final h = horarios[index];
          final bool selected = h == horarioSelecionado;

          return GestureDetector(
            onTap: () async {
              setState(() => horarioSelecionado = h);
              await carregarSlots();
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: selected ? const Color(0xFF48CFCB) : const Color(0xFFFAFAFA),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFF7CAC9), width: 1.5),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  )
                ],
              ),
              child: Center(
                child: Text(
                  h.diaSemana.toUpperCase(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: selected ? const Color(0xFFFAFAFA) : const Color(0xFF107A73),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimeline() {
    if (slots.isEmpty) {
      return const Center(
        child: Text(
          "Nenhum horário configurado para este dia.",
          style: TextStyle(fontSize: 16, color: Color(0xFF107A73)),
        ),
      );
    }

    return ListView.builder(
      itemCount: slots.length,
      itemBuilder: (context, index) {
        final slot = slots[index];

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: slot.isLivre ? const Color(0xFFFAFAFA) : const Color(0xFFF7CAC9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: slot.isLivre ? const Color(0xFF48CFCB) : const Color(0xFF107A73),
              width: 1.5,
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              )
            ],
          ),
          child: Row(
            children: [
              Text(
                "${slot.time.hour.toString().padLeft(2, '0')}:${slot.time.minute.toString().padLeft(2, '0')}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF107A73),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: slot.isLivre
                    ? const Text(
                        "Disponível",
                        style: TextStyle(
                          color: Color(0xFF48CFCB),
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Agendado para: ${slot.agendamento!.idCliente}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text("Serviço: ${slot.agendamento!.idServico}"),
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
