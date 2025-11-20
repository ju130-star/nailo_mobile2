import 'package:flutter/material.dart';
import 'package:nailo_mobile2/models/horario_trabalho.dart';
import 'package:nailo_mobile2/services/proprietaria_service.dart';
import 'package:nailo_mobile2/views/proprietaria/alterar_horarios_view.dart';

class HomeProprietariaView extends StatelessWidget {
  final ProprietariaService service;

  const HomeProprietariaView({
    super.key,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Início da Proprietária")),
      body: FutureBuilder<List<HorarioTrabalho>>(
        future: service.listarHorarios(), // <-- agora o tipo combina
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final horarios = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --------------------------
                // Dias da Semana
                // --------------------------
                const Text(
                  "Dias de Trabalho",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                Wrap(
                  spacing: 8,
                  children: horarios
                      .map((h) => Chip(
                            label: Text(h.diaSemana),
                            backgroundColor: Colors.teal.shade200,
                          ))
                      .toList(),
                ),

                const SizedBox(height: 20),

                // --------------------------
                // Horários
                // --------------------------
                const Text(
                  "Horários Cadastrados",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 8),

                Wrap(
                  spacing: 8,
                  children: horarios
                      .map((h) => Chip(
                            label: Text("${h.horaInicio} - ${h.horaFim}"),
                            backgroundColor: Colors.teal.shade300,
                          ))
                      .toList(),
                ),

                const Spacer(),

                // --------------------------
                // Botão alterar
                // --------------------------
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AlterarHorariosView(
                            service: service,
                            semana: horarios,
                          ),
                        ),
                      );
                    },
                    child: const Text("Alterar Horários"),
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
