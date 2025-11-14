import 'package:flutter/material.dart';
import 'package:nailo_mobile2/views/cliente/agenda_cliente_view.dart';
import 'package:nailo_mobile2/views/cliente/historico_cliente_view.dart';
import 'package:nailo_mobile2/views/cliente/home_cliente_view.dart';
import 'package:nailo_mobile2/views/cliente/perfil_cliente_view.dart';

class NavbarCliente extends StatefulWidget {
  final String userId; // <- UID do usuário logado

  const NavbarCliente({super.key, required this.userId});

  @override
  State<NavbarCliente> createState() => _NavbarClienteState();
}

class _NavbarClienteState extends State<NavbarCliente> {
  int _paginaAtual = 0;

  late final List<Widget> _paginas;

  @override
  void initState() {
    super.initState();
    // Inicializa as páginas passando o userId para cada uma
    _paginas = [
      HomeClienteView(userId: widget.userId),
      AgendaClienteView(userId: widget.userId),
      HistoricoClienteView(userId: widget.userId),
      PerfilClienteView(userId: widget.userId),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _paginas[_paginaAtual],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _paginaAtual,
        onTap: (index) => setState(() => _paginaAtual = index),
        backgroundColor: const Color(0xFF48CFCB),
        selectedItemColor: Colors.white,
        unselectedItemColor: const Color(0xFF107A73),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Início"),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: "Agenda"),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "Histórico"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Perfil"),
        ],
      ),
    );
  }
}
