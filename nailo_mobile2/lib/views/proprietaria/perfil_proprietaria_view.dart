import 'package:flutter/material.dart';
import 'package:nailo_mobile2/models/servico.dart';
import 'package:nailo_mobile2/models/user.dart';
import 'package:nailo_mobile2/controllers/usuario_controller.dart';
import 'package:nailo_mobile2/services/servico_service.dart';
import 'package:nailo_mobile2/services/auth_service.dart';
import 'package:nailo_mobile2/views/proprietaria/editar_perfil_proprietaria_view.dart';

class PerfilProprietariaView extends StatefulWidget {
  const PerfilProprietariaView({super.key});

  @override
  State<PerfilProprietariaView> createState() => _PerfilProprietariaViewState();
}

class _PerfilProprietariaViewState extends State<PerfilProprietariaView> {
  List<Servico> servicos = [];
  Usuario? usuario;
  bool loading = true;

  final UsuarioController usuarioController = UsuarioController(); // ADICIONADO

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    setState(() => loading = true);

    // AGORA BUSCA DO Firestore CORRETAMENTE
    usuario = await usuarioController.getUsuarioLogado();

    // Serviços
    servicos = await ServicoService.listarServicos();

    setState(() => loading = false);
  }

  Future<void> _logout() async {
    await AuthService.logoutUsuario();
    if (mounted) {
      Navigator.pushReplacementNamed(context, "/login");
    }
  }

  void _editarPerfil() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const EditarPerfilProprietariaView(),
      ),
    ).then((_) {
      _carregarDados();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFA7E8E4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF48CFCB),
        title: const Text("Meu Perfil 💅"),
        centerTitle: true,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : SingleChildScrollView(
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

                  // NOME FIRESTORE
                  Text(
                    usuario?.nome ?? "—",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF107A73),
                    ),
                  ),

                  const SizedBox(height: 4),

                  // EMAIL
                  Text(
                    usuario?.email ?? "—",
                    style: const TextStyle(fontSize: 16, color: Colors.black54),
                  ),

                  const SizedBox(height: 4),

                  // TELEFONE
                  Text(
                    usuario?.telefone ?? "—",
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),

                  const SizedBox(height: 16),

                  // EDITAR PERFIL
                  ElevatedButton.icon(
                    onPressed: _editarPerfil,
                    icon: const Icon(Icons.edit, color: Colors.white),
                    label: const Text("Editar Perfil", style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF48CFCB),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // TABELA DE PREÇOS
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Tabela de Preços",
                      style: const TextStyle(
                        fontSize: 20,
                        color: Color(0xFF107A73),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  ...servicos.map((s) => Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAFAFA),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(color: Colors.black26, blurRadius: 4),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(s.nome),
                            Text("R\$ ${s.preco.toStringAsFixed(2)}"),
                          ],
                        ),
                      )),

                  const SizedBox(height: 30),

                  // LOGOUT
                  ElevatedButton.icon(
                    onPressed: _logout,
                    icon: const Icon(Icons.logout, color: Colors.white),
                    label: const Text("Sair da Conta", style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF48CFCB),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }
}
