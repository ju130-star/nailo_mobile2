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
      // debugPrint("Erro ao carregar usuário: $e");
      setState(() => _carregando = false);
    }
  }

  Future<void> _logout() async {
    await AuthService.logoutUsuario(); 
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
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
    // Componente auxiliar para as informações (igual ao _infoTile original, mas com Card)
    Widget _infoCard(IconData icon, String title, String subtitle) {
      return Card(
        margin: const EdgeInsets.only(bottom: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 1, // Sombra suave
        color: Colors.white,
        child: ListTile(
          leading: Icon(icon, color: const Color(0xFF48CFCB)),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Text(subtitle, style: const TextStyle(fontSize: 14)),
        ),
      );
    }
    
    // Garantir que a foto e o nome fiquem centralizados
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center, // Centraliza os itens de largura menor
        children: [
          // FOTO / ÍCONE
          CircleAvatar(
            radius: 60,
            backgroundColor: const Color(0xFF48CFCB),
            backgroundImage:
                _usuario!.fotoUrl != null ? NetworkImage(_usuario!.fotoUrl!) : null,
            child: _usuario!.fotoUrl == null
                ? const Icon(Icons.person, size: 60, color: Colors.white)
                : null,
          ),
          const SizedBox(height: 16),

          // NOME
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              _usuario!.nome,
              textAlign: TextAlign.center, // Garante que o nome centralize
              style: const TextStyle(
                fontSize: 24, // Aumentei um pouco para destaque
                fontWeight: FontWeight.bold,
                color: Color(0xFF107A73),
              ),
            ),
          ),
          
          const SizedBox(height: 30),

          // BLOCO DE INFORMAÇÕES DE CONTATO
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Informações de Contato",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF107A73),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // EMAIL
          _infoCard(
            Icons.email, 
            "Email", 
            _usuario!.email
          ),

          // TELEFONE
          _infoCard(
            Icons.phone, 
            "Telefone", 
            _usuario!.telefone.isEmpty ? "Não informado" : _usuario!.telefone
          ),
          
          const SizedBox(height: 30),

          // BOTÃO DE LOGOUT
          SizedBox(
            width: double.infinity, // Aproveita a largura máxima para o botão
            child: ElevatedButton.icon(
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
          ),
          
          const SizedBox(height: 40), 
        ],
      ),
    );
  }
}