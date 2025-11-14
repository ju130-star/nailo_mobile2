import 'package:flutter/material.dart';
import 'package:nailo_mobile2/services/proprietaria_service.dart';
import 'package:nailo_mobile2/views/proprietaria/agenda_proprietaria_view.dart';
import 'package:nailo_mobile2/views/proprietaria/controle_financeiro_view.dart';
import 'package:nailo_mobile2/views/proprietaria/home_proprietaria_view.dart';
import 'package:nailo_mobile2/views/proprietaria/perfil_proprietaria_view.dart';

class NavbarProprietaria extends StatefulWidget {
  const NavbarProprietaria({super.key});

  @override
  State<NavbarProprietaria> createState() => _NavbarProprietariaState();
}

class _NavbarProprietariaState extends State<NavbarProprietaria> {
  int _paginaAtual = 0;

  // Um único service para todas as telas
  final ProprietariaService _service = ProprietariaService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getPagina(_paginaAtual),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _paginaAtual,
        onTap: (index) {
          setState(() {
            _paginaAtual = index;
          });
        },
        backgroundColor: const Color(0xFF48CFCB),
        selectedItemColor: Colors.white,
        unselectedItemColor: const Color(0xFF107A73),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Início",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: "Agenda",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money),
            label: "Financeiro",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Perfil",
          ),
        ],
      ),
    );
  }

  // Páginas separadas, cada uma recebendo o mesmo service
  Widget _getPagina(int index) {
    switch (index) {
      case 0:
        return HomeProprietariaView(service: _service);
      case 1:
        return AgendaProprietariaView(service: _service);
      case 2:
        return ControleFinanceiroView(service: _service);
      case 3:
        // Aqui o Perfil PRECISA carregar os serviços antes de abrir a tela
        return FutureBuilder(
          future: _service.listarServicos(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            return PerfilProprietariaView(
              service: _service,
              servicos: snapshot.data!,
            );
          },
        );
      default:
        return const SizedBox();
    }
  }
}
