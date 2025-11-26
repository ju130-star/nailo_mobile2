import 'package:flutter/material.dart';
import 'package:nailo_mobile2/views/cliente/agenda_cliente_view.dart';
import 'package:nailo_mobile2/views/cliente/historico_cliente_view.dart';
import 'package:nailo_mobile2/views/cliente/home_cliente_view.dart'; // Certifique-se desta linha
import 'package:nailo_mobile2/views/cliente/perfil_cliente_view.dart';

class NavbarCliente extends StatefulWidget {
  final String userId; // <- UID do usuário logado

  const NavbarCliente({super.key, required this.userId});

  @override
  State<NavbarCliente> createState() => _NavbarClienteState();
}

class _NavbarClienteState extends State<NavbarCliente> {
  int _paginaAtual = 0;

  // Usa List<Widget> para armazenar as páginas.
  late final List<Widget> _paginas;

  @override
  void initState() {
    super.initState();
    // Inicializa as páginas garantindo a chamada correta do construtor:
    _paginas = [
      // Aqui, garantimos que HomeClienteView está sendo instanciada como um Widget, não chamada como método.
      HomeClienteView(userId: widget.userId),
      AgendaClienteView(userId: widget.userId),
      HistoricoClienteView(userId: widget.userId),
      PerfilClienteView(userId: widget.userId),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _paginaAtual = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _paginas[_paginaAtual],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _paginaAtual,
        onTap: _onItemTapped,
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