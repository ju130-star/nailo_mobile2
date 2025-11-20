import 'package:flutter/material.dart';
import 'package:nailo_mobile2/services/auth_service.dart';

class CadastroProprietariaView extends StatefulWidget {
  const CadastroProprietariaView({super.key});

  @override
  State<CadastroProprietariaView> createState() =>
      _CadastroProprietariaViewState();
}

class _CadastroProprietariaViewState
    extends State<CadastroProprietariaView> {

  final _nome = TextEditingController();
  final _email = TextEditingController();
  final _telefone = TextEditingController();
  final _senha = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cadastrar Proprietária")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nome,
              decoration: const InputDecoration(labelText: "Nome"),
            ),
            TextField(
              controller: _email,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: _telefone,
              decoration: const InputDecoration(labelText: "Telefone"),
            ),
            TextField(
              controller: _senha,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Senha"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                try {
                  await AuthService.cadastrarUsuario(
                    nome: _nome.text.trim(),
                    email: _email.text.trim(),
                    telefone: _telefone.text.trim(),
                    senha: _senha.text.trim(),
                    tipo: "proprietaria",
                  );

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Proprietária cadastrada com sucesso!"),
                      ),
                    );
                  }

                  // Limpar campos
                  _nome.clear();
                  _email.clear();
                  _telefone.clear();
                  _senha.clear();

                  Navigator.pop(context); // volta para o login
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Erro ao cadastrar: $e")),
                  );
                }
              },
              child: const Text("Cadastrar"),
            )
          ],
        ),
      ),
    );
  }
}
