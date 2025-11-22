import 'package:flutter/material.dart';
import 'package:nailo_mobile2/models/servico.dart';
import 'package:nailo_mobile2/models/user.dart';
import 'package:nailo_mobile2/controllers/usuario_controller.dart';
import 'package:nailo_mobile2/services/servico_service.dart';
import 'package:nailo_mobile2/views/proprietaria/cadastro_servico_view.dart';

class EditarPerfilProprietariaView extends StatefulWidget {
  const EditarPerfilProprietariaView({super.key});

  @override
  State<EditarPerfilProprietariaView> createState() =>
      _EditarPerfilProprietariaViewState();
}

class _EditarPerfilProprietariaViewState
    extends State<EditarPerfilProprietariaView> {
  final UsuarioController usuarioController = UsuarioController();

  final TextEditingController _nome = TextEditingController();
  final TextEditingController _descricao = TextEditingController();
  final TextEditingController _telefone = TextEditingController();

  Usuario? _usuario;
  List<Servico> _servicos = [];

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    // CARREGAR USUÁRIO DO FIRESTORE
    final usuario = await usuarioController.getUsuarioLogado();

    setState(() {
      _usuario = usuario;
      _nome.text = usuario?.nome ?? "";
      _telefone.text = usuario?.telefone ?? "";
    });

    // CARREGAR SERVIÇOS
    final servicos = await ServicoService.listarServicos();
    setState(() {
      _servicos = servicos;
    });
  }

  void _adicionarServico(Servico novoServico) {
    setState(() {
      _servicos.add(novoServico);
    });
  }

  void _deletarServico(Servico servico) async {
    await ServicoService.deletarServico(servico.id);
    setState(() {
      _servicos.remove(servico);
    });
  }

  Future<void> _salvarPerfil() async {
  if (_usuario == null) return;

  Usuario atualizado = Usuario(
    id: _usuario!.id,
    nome: _nome.text,
    email: _usuario!.email,
    telefone: _telefone.text,
    tipo: _usuario!.tipo,        // mantém o tipo original (proprietaria / cliente)
    fotoUrl: _usuario!.fotoUrl,  // mantém foto se tiver
    ativo: _usuario!.ativo,      // mantém status
  );

  await usuarioController.atualizarUsuario(atualizado);

  if (mounted) Navigator.pop(context);
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Editar Perfil"),
        backgroundColor: const Color(0xFF48CFCB),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // FOTO
            CircleAvatar(
              radius: 60,
              backgroundColor: const Color(0xFF48CFCB),
              child: const Icon(Icons.person, size: 60, color: Colors.white),
            ),
            const SizedBox(height: 16),

            // NOME
            TextField(
              controller: _nome,
              decoration: const InputDecoration(
                labelText: "Nome",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),

            // TELEFONE
            TextField(
              controller: _telefone,
              decoration: const InputDecoration(
                labelText: "Telefone",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20),

            // Botão ADICIONAR SERVIÇO
            ElevatedButton.icon(
              onPressed: () async {
                final novoServico = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CadastroServicoView(),
                  ),
                );

                if (novoServico != null && novoServico is Servico) {
                  _adicionarServico(novoServico);
                }
              },
              icon: const Icon(Icons.add),
              label: const Text("Adicionar Serviço"),
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF48CFCB)),
            ),
            const SizedBox(height: 20),

            // Tabela
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Tabela de Preços",
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),

            ..._servicos.map((s) => Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAFAFA),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(color: Colors.black26, blurRadius: 4)
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("${s.nome} - R\$ ${s.preco.toStringAsFixed(2)}"),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deletarServico(s),
                      ),
                    ],
                  ),
                )),

            const SizedBox(height: 30),

            // SALVAR
            ElevatedButton(
              onPressed: _salvarPerfil,
              child: const Text("Salvar Alterações"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF48CFCB),
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
