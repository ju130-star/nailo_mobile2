import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nailo_mobile2/views/cliente/form_agendamento_view.dart';

class VisualizarPerfilProfissionalView extends StatefulWidget {
  final String proprietariaId;

  const VisualizarPerfilProfissionalView({
    super.key,
    required this.proprietariaId,
  });

  @override
  State<VisualizarPerfilProfissionalView> createState() =>
      _VisualizarPerfilProfissionalViewState();
}

class _VisualizarPerfilProfissionalViewState
    extends State<VisualizarPerfilProfissionalView> {
  Map<String, dynamic>? proprietaria;
  List<Map<String, dynamic>> servicos = [];

  @override
  void initState() {
    super.initState();
    carregarDados();
  }

  Future<void> carregarDados() async {
    // Buscar dados da proprietária (profissional)
    final doc = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(widget.proprietariaId)
        .get();

    if (doc.exists) {
      proprietaria = doc.data();
    }

    // Buscar serviços da proprietária
    final snap = await FirebaseFirestore.instance
        .collection('servicos')
        .where('proprietariaId', isEqualTo: widget.proprietariaId)
        .get();

    servicos = snap.docs.map((d) => d.data() as Map<String, dynamic>).toList();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (proprietaria == null) {
      return Scaffold(
        appBar: AppBar(title: Text("Carregando Perfil...")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Color(0xFFA7E8E4),
      appBar: AppBar(
        backgroundColor: Color(0xFF48CFCB),
        title: Text("Perfil da Profissional"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // FOTO
            CircleAvatar(
              radius: 65,
              backgroundImage: proprietaria!["fotoUrl"] != null
                  ? NetworkImage(proprietaria!["fotoUrl"])
                  : null,
              child: proprietaria!["fotoUrl"] == null
                  ? Icon(Icons.person, size: 70)
                  : null,
            ),
            SizedBox(height: 20),

            // NOME
            Text(
              proprietaria!["nome"] ?? "Sem nome",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 10),

            // TELEFONE
            Text(
              proprietaria!["telefone"] ?? "Sem telefone cadastrado",
              style: TextStyle(fontSize: 18, color: Colors.black87),
            ),

            SizedBox(height: 30),

            // BOTÃO DE AGENDAMENTO
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FormAgendamentoView(
                        proprietariaId: widget.proprietariaId,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF48CFCB),
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  "Criar Agendamento",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),

            SizedBox(height: 30),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Tabela de Preços",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),

            SizedBox(height: 15),

            servicos.isEmpty
                ? Text(
                    "Nenhum serviço cadastrado.",
                    style: TextStyle(fontSize: 16),
                  )
                : Column(
                    children: servicos.map((s) {
                      return Card(
                        color: Color(0xFFFAFAFA),
                        margin: EdgeInsets.symmetric(vertical: 6),
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          title: Text(
                            s["nome"],
                            style: TextStyle(fontSize: 18),
                          ),
                          trailing: Text(
                            "R\$ ${s["preco"].toStringAsFixed(2)}",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
          ],
        ),
      ),
    );
  }
}
