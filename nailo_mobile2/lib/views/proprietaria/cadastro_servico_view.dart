import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nailo_mobile2/models/servico.dart';
import 'package:nailo_mobile2/services/servico_service.dart';

class CadastroServicoView extends StatefulWidget {
  const CadastroServicoView({super.key});

  @override
  State<CadastroServicoView> createState() => _CadastroServicoViewState();
}

class _CadastroServicoViewState extends State<CadastroServicoView> {
  final _nome = TextEditingController();
  final _descricao = TextEditingController();
  final _preco = TextEditingController();
  final _duracao = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  void _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final id = FirebaseFirestore.instance.collection("services").doc().id;

      final servico = Servico(
        id: id,
        nome: _nome.text.trim(),
        descricao: _descricao.text.trim(),
        preco: double.parse(_preco.text),
        duracao: int.parse(_duracao.text),
      );

      await ServicoService.adicionarServico(servico);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Serviço cadastrado com sucesso!")),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao cadastrar serviço: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cadastrar Serviço")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nome,
                decoration: const InputDecoration(labelText: "Nome do serviço"),
                validator: (v) => v!.isEmpty ? "Informe o nome" : null,
              ),
              TextFormField(
                controller: _descricao,
                decoration: const InputDecoration(labelText: "Descrição"),
                maxLines: 2,
              ),
              TextFormField(
                controller: _preco,
                decoration: const InputDecoration(labelText: "Preço (R\$)"),
                keyboardType: TextInputType.number,
                validator: (v) =>
                    double.tryParse(v ?? "") == null ? "Informe um valor válido" : null,
              ),
              TextFormField(
                controller: _duracao,
                decoration: const InputDecoration(labelText: "Duração (minutos)"),
                keyboardType: TextInputType.number,
                validator: (v) =>
                    int.tryParse(v ?? "") == null ? "Informe um número válido" : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _salvar,
                child: const Text("Salvar"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
