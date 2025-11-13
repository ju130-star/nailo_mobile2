import 'package:flutter/material.dart';
import 'package:nailo_mobile2/models/horario_trabalho.dart';
import 'package:nailo_mobile2/services/proprietaria_service.dart';

class AlterarHorariosView extends StatefulWidget {
  final ProprietariaService service;
  final List<HorarioTrabalho> semana;

  const AlterarHorariosView({super.key, required this.service, required this.semana});

  @override
  State<AlterarHorariosView> createState() => _AlterarHorariosViewState();
}

class _AlterarHorariosViewState extends State<AlterarHorariosView> {
  final Map<String, TextEditingController> inicioControllers = {};
  final Map<String, TextEditingController> fimControllers = {};

  @override
  void initState() {
    super.initState();
    for (var h in widget.semana) {
      inicioControllers[h.diaSemana] = TextEditingController(text: h.horaInicio);
      fimControllers[h.diaSemana] = TextEditingController(text: h.horaFim);
    }
  }

  @override
  void dispose() {
    for (var c in inicioControllers.values) c.dispose();
    for (var c in fimControllers.values) c.dispose();
    super.dispose();
  }

  void salvar() async {
    for (var h in widget.semana) {
      await widget.service.atualizarHorario(
        h.diaSemana, // aqui você pode usar o docId real do Firestore
        inicioControllers[h.diaSemana]!.text,
        fimControllers[h.diaSemana]!.text,
      );
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Alterar Horários"),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: salvar,
          )
        ],
      ),
      body: ListView.builder(
        itemCount: widget.semana.length,
        itemBuilder: (context, index) {
          final h = widget.semana[index];
          return ListTile(
            title: Text(h.diaSemana),
            subtitle: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: inicioControllers[h.diaSemana],
                    decoration: const InputDecoration(labelText: "Início"),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: fimControllers[h.diaSemana],
                    decoration: const InputDecoration(labelText: "Fim"),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
