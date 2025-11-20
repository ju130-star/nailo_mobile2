import 'package:flutter/material.dart';
import 'package:nailo_mobile2/models/servico.dart';
import 'package:nailo_mobile2/services/auth_service.dart';
import 'package:nailo_mobile2/services/servico_service.dart';
import 'package:nailo_mobile2/views/proprietaria/cadastro_servico_view.dart';

class PerfilProprietariaView extends StatefulWidget {
  final List<Servico> servicos;

  const PerfilProprietariaView({
    super.key,
    required this.servicos,
  });

  @override
  State<PerfilProprietariaView> createState() => _PerfilProprietariaViewState();
}

class _PerfilProprietariaViewState extends State<PerfilProprietariaView> {
  late List<Servico> servicos;

  @override
  void initState() {
    super.initState();
    servicos = widget.servicos;
  }

  Future<void> _logout() async {
    await AuthService.logoutUsuario();
    if (mounted) {
      Navigator.pushReplacementNamed(context, "/login");
    }
  }

  void _adicionarServico(Servico novoServico) {
    setState(() {
      servicos.add(novoServico);
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
            const Text(
              "Proprietária",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF107A73),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              "Conta Empresarial Nailo",
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 20),
            _infoTile(Icons.store, "Gerenciamento da Esmalteria"),
            const SizedBox(height: 10),
            _infoTile(Icons.design_services, "Tabela de serviços"),
            const SizedBox(height: 30),

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
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                "Cadastrar Novo Serviço",
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF48CFCB),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              ),
            ),

            const SizedBox(height: 30),

            // Lista de serviços
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
                      Text("${s.nome} - R\$ ${s.preco.toStringAsFixed(2)}"),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await ServicoService.deletarServico(s.id);
                          setState(() {
                            servicos.remove(s);
                          });
                        },
                      ),
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

  Widget _infoTile(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF48CFCB)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
