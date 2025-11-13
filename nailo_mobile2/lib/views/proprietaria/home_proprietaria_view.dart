import 'package:flutter/material.dart';
import 'package:nailo_mobile2/models/horario_trabalho.dart';
import 'package:nailo_mobile2/services/proprietaria_service.dart';
import 'package:nailo_mobile2/views/proprietaria/alterar_horarios_view.dart';

class TelaInicialProprietaria extends StatefulWidget {
  const TelaInicialProprietaria({super.key});

  @override
  State<TelaInicialProprietaria> createState() =>
      _TelaInicialProprietariaState();
}

class _TelaInicialProprietariaState extends State<TelaInicialProprietaria> {
  final ProprietariaService service = ProprietariaService();

  List<HorarioTrabalho> semana = [];
  String diaSelecionado = '';

  @override
  void initState() {
    super.initState();
    carregarHorarios();
  }

  void carregarHorarios() async {
    final horarios = await service.listarHorarios();
    setState(() {
      semana = horarios;
      if (horarios.isNotEmpty) diaSelecionado = horarios.first.diaSemana;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Agenda da Proprietária"),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AlterarHorariosView(
                    service: service,  // ← o service que você já tem na tela
                    semana: semana,    // ← a lista de horários carregada
                  ),
                ),
              );
            },
          )
        ],
      ),
      body: Column(
        children: [
          // --- Semana com horários ---
          Container(
            height: 80,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: semana.length,
              itemBuilder: (context, index) {
                final h = semana[index];
                final selecionado = h.diaSemana == diaSelecionado;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      diaSelecionado = h.diaSemana;
                    });
                  },
                  child: Container(
                    width: 100,
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: selecionado ? Colors.blue : Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          h.diaSemana,
                          style: TextStyle(
                            color: selecionado ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${h.horaInicio} - ${h.horaFim}',
                          style: TextStyle(
                            color: selecionado ? Colors.white : Colors.black,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const Divider(),

          // --- Agenda do dia selecionado ---
          Expanded(
            child: FutureBuilder<List<String>>(
              future: service.getHorariosDisponiveis(diaSelecionado),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final horariosDisponiveis = snapshot.data!;
                if (horariosDisponiveis.isEmpty) {
                  return const Center(child: Text("Nenhum horário disponível"));
                }
                return ListView.builder(
                  itemCount: horariosDisponiveis.length,
                  itemBuilder: (context, index) {
                    final horario = horariosDisponiveis[index];
                    return ListTile(
                      title: Text(horario),
                      subtitle: const Text("Agendamento se houver"),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
