import 'package:flutter/material.dart';
import 'package:nailo_mobile2/models/servico.dart';
import '../../services/proprietaria_service.dart';

// ignore: prefer_const_constructors_in_immutables
class PerfilProprietariaView extends StatelessWidget {
  final ProprietariaService service;
  final List<Servico> servicos;

  PerfilProprietariaView({
    super.key,
    required this.service,
    required this.servicos,
  });

  @override
  Widget build(BuildContext context) {
    // Map para armazenar temporariamente os valores digitados
    final Map<String, String> nomeMap = {};
    final Map<String, String> precoMap = {};

    for (var s in servicos) {
      nomeMap[s.id] = s.nome;
      precoMap[s.id] = s.preco.toStringAsFixed(2);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Perfil da Proprietária"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ...servicos.map((s) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.nome,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextField(
                  decoration: const InputDecoration(labelText: "Nome"),
                  controller: TextEditingController(text: nomeMap[s.id]),
                  onChanged: (val) => nomeMap[s.id] = val,
                ),
                TextField(
                  decoration: const InputDecoration(labelText: "Preço"),
                  keyboardType: TextInputType.number,
                  controller: TextEditingController(text: precoMap[s.id]),
                  onChanged: (val) => precoMap[s.id] = val,
                ),
                const SizedBox(height: 16),
              ],
            );
          }).toList(),
          ElevatedButton(
            onPressed: () async {
              for (var s in servicos) {
                final preco = double.tryParse(precoMap[s.id]!) ?? s.preco;
                await service.atualizarServico(s.id, nomeMap[s.id]!, preco);
              }
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Serviços atualizados!")),
              );
            },
            child: const Text("Salvar"),
          ),
        ],
      ),
    );
  }
}
