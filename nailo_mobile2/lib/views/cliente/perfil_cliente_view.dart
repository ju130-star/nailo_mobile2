import 'package:flutter/material.dart';
import 'package:nailo_mobile2/services/auth_service.dart';
import 'package:nailo_mobile2/services/usuario_service.dart';
import 'package:nailo_mobile2/models/user.dart';

class PerfilClienteView extends StatefulWidget {
  final String userId;

  const PerfilClienteView({super.key, required this.userId});

  @override
  State<PerfilClienteView> createState() => _PerfilClienteViewState();
}

class _PerfilClienteViewState extends State<PerfilClienteView> {
  Usuario? _usuario;
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarUsuario();
  }

  Future<void> _carregarUsuario() async {
    try {
      final usuario = await UsuarioService.buscarUsuarioPorId(widget.userId);
      setState(() {
        _usuario = usuario;
        _carregando = false;
      });
    } catch (e) {
      print("Erro ao carregar usuário: $e");
      setState(() => _carregando = false);
    }
  }

  Future<void> _logout() async {
    await AuthService.logoutUsuario(); // <-- chama o logout do AuthService
    Navigator.pushReplacementNamed(context, '/login');
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
      body: _carregando
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF48CFCB)),
            )
          : _usuario == null
              ? const Center(
                  child: Text(
                    "Erro ao carregar perfil 😢",
                    style: TextStyle(color: Color(0xFF107A73)),
                  ),
                )
              : _perfilContent(),
    );
  }

  Widget _perfilContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: const Color(0xFF48CFCB),
            backgroundImage:
                _usuario!.fotoUrl != null ? NetworkImage(_usuario!.fotoUrl!) : null,
            child: _usuario!.fotoUrl == null
                ? const Icon(Icons.person, size: 60, color: Color(0xFFFAFAFA))
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            _usuario!.nome,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF107A73),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _usuario!.email,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 20),
          _infoTile(Icons.phone, _usuario!.telefone),
          const SizedBox(height: 10),
          _infoTile(Icons.badge, "Tipo: ${_usuario!.tipo}"),
          const SizedBox(height: 10),
          _infoTile(Icons.verified_user,
              _usuario!.ativo ? "Ativo ✅" : "Inativo ❌"),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: _logout,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF48CFCB),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            ),
            icon: const Icon(Icons.logout, color: Colors.white),
            label: const Text(
              "Sair da Conta",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF48CFCB)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
