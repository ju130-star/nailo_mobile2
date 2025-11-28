import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:nailo_mobile2/views/cliente/form_agendamento_view.dart';
import 'package:nailo_mobile2/views/cliente/visualizar_perfil_profissional.dart';

// MANTIDO O CÓDIGO STATEFULWIDGET
class HomeClienteView extends StatefulWidget {
  final String userId;

  const HomeClienteView({super.key, required this.userId});

  @override
  State<HomeClienteView> createState() => _HomeClienteViewState();
}

class _HomeClienteViewState extends State<HomeClienteView> {
  String _nomeCliente = "Cliente";
  List<Map<String, dynamic>> _proximosAgendamentos = [];
  bool _carregandoNome = true;

  @override
  void initState() {
    super.initState();
    _carregarNomeCliente();
  }

  String _getSaudacao() {
    final hora = DateTime.now().hour;
    if (hora >= 5 && hora < 12) {
      return "Bom dia";
    } else if (hora >= 12 && hora < 18) {
      return "Boa tarde";
    } else {
      return "Boa noite";
    }
  }

  Future<void> _carregarNomeCliente() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(widget.userId)
          .get();
      if (userDoc.exists) {
        _nomeCliente = userDoc.data()?['nome'] ?? "Cliente";
      }
    } catch (e) {
      print("Erro ao carregar nome do cliente: $e");
    } finally {
      setState(() {
        _carregandoNome = false;
      });
    }
  }

  Future<List<Map<String, dynamic>>> _carregarProximosAgendamentos() async {
    // Mantendo a busca simplificada para evitar o erro de índice
    try {
      final now = Timestamp.fromDate(DateTime.now());
      final agendamentosSnap = await FirebaseFirestore.instance
          .collection('agendamentos')
          .where('idCliente', isEqualTo: widget.userId)
          .get();

      final List<Map<String, dynamic>> agendamentosBrutos = agendamentosSnap
          .docs
          .map((d) {
            var data = d.data() as Map<String, dynamic>;
            data['id'] = d.id;
            return data;
          })
          .toList();

      final agendamentosFuturos = agendamentosBrutos.where((ag) {
        final dataAgendamento = ag['data'] as Timestamp?;
        return dataAgendamento != null && dataAgendamento.compareTo(now) >= 0;
      }).toList();

      agendamentosFuturos.sort((a, b) {
        final dataA = a['data'] as Timestamp;
        final dataB = b['data'] as Timestamp;
        return dataA.compareTo(dataB);
      });

      return agendamentosFuturos.take(2).toList();
    } catch (e) {
      print("Erro ao carregar agendamentos (busca simplificada): $e");
      return [];
    }
  }

  final List<Color> _cardColors = [
    const Color(0xFFFFB6C1),
    const Color(0xFFFFECB3),
  ];

  @override
  Widget build(BuildContext context) {
    final String dataAtual = DateFormat('dd/MM/yyyy').format(DateTime.now());
    final String primeiroNome = _nomeCliente.split(' ').first;

    return Scaffold(
      backgroundColor: const Color(0xFFA7E8E4),

      body: SingleChildScrollView(
        // Adicionando AlwaysScrollableScrollPhysics para garantir que o scroll funcione
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. ÁREA SUPERIOR (HEADER) ---
            Container(
              height: MediaQuery.of(context).size.height * 0.45,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFF48CFCB),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 50, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _carregandoNome
                              ? "Carregando..."
                              : "${_getSaudacao()}, $primeiroNome",
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.notifications,
                            color: Colors.white,
                            size: 30,
                          ),
                          onPressed: () {},
                        ),
                      ],
                    ),
                    Text(
                      dataAtual,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 30),

                    const Text(
                      "Seus Agendamentos",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 15),

                    FutureBuilder<List<Map<String, dynamic>>>(
                      future: _carregarProximosAgendamentos(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          );
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Text(
                            "Nenhum agendamento futuro.",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          );
                        }

                        final agendamentos = snapshot.data!;

                        return SizedBox(
                          height: 160,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: agendamentos.length,
                            itemBuilder: (context, index) {
                              return _buildAgendamentoCard(
                                agendamentos[index],
                                _cardColors[index % _cardColors.length],
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // --- 2. SEÇÃO DE PROFISSIONAIS ---
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Escolha sua profissional favorita:",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF107A73),
                    ),
                  ),
                  const SizedBox(height: 15),

                  FutureBuilder<QuerySnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('usuarios')
                        .where('tipo', isEqualTo: 'proprietaria')
                        .where('ativo', isEqualTo: true)
                        .get(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final docs = snapshot.data!.docs;
                      if (docs.isEmpty) {
                        return const Center(
                          child: Text("Nenhuma profissional cadastrada"),
                        );
                      }

                      return ListView.builder(
                        // PROPRIEDADES DE LAYOUT REFORÇADAS:
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final data =
                              docs[index].data() as Map<String, dynamic>;
                          final id = docs[index].id;

                          return _profissionalCard(
                            context,
                            nome: data['nome'] ?? 'Sem nome',
                            foto: data['fotoUrl'] ?? '',
                            proprietariaId: id,
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS AUXILIARES ---

  Widget _buildAgendamentoCard(Map<String, dynamic> ag, Color cardColor) {
    // ... (Mantido o código do card de agendamento)
    final dataTimestamp = ag['data'] as Timestamp?;
    final data = dataTimestamp?.toDate();
    final dataFormatada = data != null
        ? DateFormat('dd/MM').format(data)
        : '??/??';
    final hora = data != null ? DateFormat('HH:mm').format(data) : '??:??';
    final nomeServico = ag['idServico'] ?? 'Serviço';
    final idProfissional = ag['idProprietaria'] ?? 'Profissional';

    return Container(
      width: 250,
      margin: const EdgeInsets.only(right: 15),
      child: Card(
        color: cardColor,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                dataFormatada,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.black87,
                ),
              ),
              Text(
                hora,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              Text(
                nomeServico,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Com: $idProfissional",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const Icon(
                    Icons.person_outline,
                    size: 24,
                    color: Colors.black87,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Card de Profissional (Lista Vertical)
  Widget _profissionalCard(
    BuildContext context, {
    required String nome,
    required String foto,
    required String proprietariaId,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Card(
        color: const Color(0xFFFAFAFA),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          leading: CircleAvatar(
            radius: 28,
            backgroundColor: Colors.grey[300],
            backgroundImage: foto.isNotEmpty ? NetworkImage(foto) : null,
            child: foto.isEmpty ? const Icon(Icons.person, size: 30) : null,
          ),
          title: Text(
            nome,
            style: const TextStyle(
              color: Color(0xFF107A73),
              fontWeight: FontWeight.bold,
            ),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            color: Color(0xFF48CFCB),
          ),
          // AÇÃO DE CLIQUE:
          onTap: () {
            // DEBUG: Verifique no console se esta mensagem aparece ao clicar
            print('✅ CLIQUE REGISTRADO: Profissional ID $proprietariaId');

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => VisualizarPerfilProfissionalView(
                  proprietariaId: proprietariaId,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
