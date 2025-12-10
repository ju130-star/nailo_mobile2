import 'package:flutter/material.dart';
import 'package:nailo_mobile2/models/user.dart';
import 'package:nailo_mobile2/controllers/usuario_controller.dart';

class EditarPerfilClienteView extends StatefulWidget {
  const EditarPerfilClienteView({super.key});

  @override
  State<EditarPerfilClienteView> createState() =>
      _EditarPerfilClienteViewState();
}

class _EditarPerfilClienteViewState extends State<EditarPerfilClienteView> {
  final UsuarioController usuarioController = UsuarioController();

  final TextEditingController _nome = TextEditingController();
  final TextEditingController _telefone = TextEditingController(); // CAMPO TELEFONE REINCLUÍDO

  Usuario? _usuario;
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  @override
  void dispose() {
    _nome.dispose();
    _telefone.dispose(); // DISPOSE REINCLUÍDO
    super.dispose();
  }

  Future<void> _carregarDados() async {
    final usuario = await usuarioController.getUsuarioLogado();

    if (usuario != null) {
      setState(() {
        _usuario = usuario;
        _nome.text = usuario.nome;
        _telefone.text = usuario.telefone ?? ""; // Carregar Telefone
        _carregando = false;
      });
    } else {
      setState(() {
        _carregando = false;
      });
    }
  }

  Future<void> _salvarPerfil() async {
    if (_usuario == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erro: Usuário não carregado.")),
      );
      return;
    }

    // Apenas Nome e Telefone são atualizados. Email, Tipo e Foto URL são mantidos.
    Usuario atualizado = Usuario(
      id: _usuario!.id,
      nome: _nome.text,
      email: _usuario!.email, // Email mantido
      telefone: _telefone.text, // Telefone atualizado
      tipo: _usuario!.tipo,
      fotoUrl: _usuario!.fotoUrl,
      ativo: _usuario!.ativo,
    );

    try {
      await usuarioController.atualizarUsuario(atualizado);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Perfil atualizado com sucesso!")),
        );
        Navigator.pop(context, true); 
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao salvar: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Cores originais mantidas
    const Color primaryColor = Color(0xFF48CFCB);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Editar Meu Perfil"),
        backgroundColor: primaryColor,
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : _usuario == null
              ? const Center(child: Text("Não foi possível carregar o perfil."))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // FOTO
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: primaryColor,
                        backgroundImage: _usuario!.fotoUrl != null
                            ? NetworkImage(_usuario!.fotoUrl!)
                            : null,
                        child: _usuario!.fotoUrl == null
                            ? const Icon(Icons.person, size: 60, color: Colors.white)
                            : null,
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
                      
                      // O campo de Email (readOnly) foi removido daqui, conforme solicitado.
                      
                      const SizedBox(height: 40),

                      // SALVAR
                      ElevatedButton.icon(
                        onPressed: _salvarPerfil,
                        icon: const Icon(Icons.save, color: Colors.white),
                        label: const Text(
                          "Salvar Alterações",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}