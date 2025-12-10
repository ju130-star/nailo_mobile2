import 'package:flutter/material.dart';
// 1. 🎯 NOVO IMPORT NECESSÁRIO
import 'package:firebase_auth/firebase_auth.dart'; 

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

  // 2. 🎯 Obter o ID do usuário Logado
  // Assume que o usuário está logado neste ponto, caso contrário, 
  // esta página não deveria ser acessível.
  final String _proprietariaId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    // 🔥 Inicializa os horários padrões caso o banco esteja vazio
    _service.inicializarHorariosPadroes();
  }

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

  // Páginas separadas, cada uma recebendo o service e o ID, quando necessário
    Widget _getPagina(int index) {
    switch (index) {
      case 0:
        return HomeProprietariaView();
      case 1:
        // Aqui, se o AgendaProprietariaView precisar do ID, você deve passar:
        // AgendaProprietariaView(service: _service, proprietariaId: _proprietariaId);
        return AgendaProprietariaView(service: _service);
      case 2:
        // 3. 🎯 CORREÇÃO: Passando o ID real do usuário logado
        return ControleFinanceiroView(service: _service, proprietariaId: _proprietariaId);
      case 3:
        return const PerfilProprietariaView(); 
      default:
        return const SizedBox();
    }
  }
}