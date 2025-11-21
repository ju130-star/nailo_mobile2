import 'package:flutter/material.dart';
import 'package:nailo_mobile2/models/horario_trabalho.dart';
import 'package:nailo_mobile2/services/proprietaria_service.dart';

class AlterarHorariosView extends StatefulWidget {
  final ProprietariaService service;
  final List<HorarioTrabalho> semana;

  const AlterarHorariosView({
    super.key,
    required this.service,
    required this.semana,
  });

  @override
  State<AlterarHorariosView> createState() => _AlterarHorariosViewState();
}

class _AlterarHorariosViewState extends State<AlterarHorariosView> {
  late List<Map<String, dynamic>> itens;

  @override
  void initState() {
    super.initState();

    itens = widget.semana.map((h) {
      return {
        "dia": h.diaSemana,
        "inicio": h.horaInicio,
        "fim": h.horaFim,
        "inicioAlmoco": h.inicioAlmoco,
        "fimAlmoco": h.fimAlmoco,
        "ativo": h.ativo,
        "id": h.id, // docId real do Firestore
      };
    }).toList();
  }

  Future<void> salvar() async {
    for (var item in itens) {
      await widget.service.atualizarHorario(
        item["id"],
        inicio: item["inicio"],
        fim: item["fim"],
        inicioAlmoco: item["inicioAlmoco"],
        fimAlmoco: item["fimAlmoco"],
        ativo: item["ativo"],
      );
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFA7E8E4), // fundo principal
      appBar: AppBar(
        backgroundColor: const Color(0xFF48CFCB), // botões e elementos ativos
        title: const Text("Alterar Horários 💅"),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: salvar,
          )
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: itens.length,
        itemBuilder: (context, index) {
          final item = itens[index];

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: const Color(0xFFFAFAFA), // fundo de cartões
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item["dia"].toString().toUpperCase(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF107A73), // texto em destaque
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Início / Fim
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: item["inicio"],
                          decoration: const InputDecoration(
                            labelText: "Início",
                            labelStyle: TextStyle(color: Color(0xFF107A73)),
                          ),
                          onChanged: (v) => item["inicio"] = v,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          initialValue: item["fim"],
                          decoration: const InputDecoration(
                            labelText: "Fim",
                            labelStyle: TextStyle(color: Color(0xFF107A73)),
                          ),
                          onChanged: (v) => item["fim"] = v,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Almoço
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: item["inicioAlmoco"],
                          decoration: const InputDecoration(
                            labelText: "Início almoço",
                            labelStyle: TextStyle(color: Color(0xFF107A73)),
                          ),
                          onChanged: (v) => item["inicioAlmoco"] = v,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          initialValue: item["fimAlmoco"],
                          decoration: const InputDecoration(
                            labelText: "Fim almoço",
                            labelStyle: TextStyle(color: Color(0xFF107A73)),
                          ),
                          onChanged: (v) => item["fimAlmoco"] = v,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Ativo
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Ativo",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF107A73),
                        ),
                      ),
                      Switch(
                        activeThumbColor: const Color(0xFF48CFCB),
                        value: item["ativo"],
                        onChanged: (v) => setState(() => item["ativo"] = v),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
