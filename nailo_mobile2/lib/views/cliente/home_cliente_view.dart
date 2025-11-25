import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nailo_mobile2/views/cliente/form_agendamento_view.dart';
import 'package:nailo_mobile2/views/cliente/visualizar_perfil_profissional.dart';

class HomeClienteView extends StatelessWidget {
  final String userId; // UID do cliente logado

  const HomeClienteView({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFA7E8E4),
      appBar: AppBar(
        title: const Text(
          "Nailo 💅",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF48CFCB),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Olá, seja bem-vinda! 🌸",
              style: TextStyle(
                color: Color(0xFF107A73),
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Escolha sua profissional favorita abaixo:",
              style: TextStyle(color: Color(0xFF107A73), fontSize: 16),
            ),
            const SizedBox(height: 20),

            Expanded(
              child: FutureBuilder<QuerySnapshot>(
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
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
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
            ),
          ],
        ),
      ),
    );
  }

  // 🔥 Versão correta: só envia o ID (como a View pede)
  Widget _profissionalCard(
    BuildContext context, {
    required String nome,
    required String foto,
    required String proprietariaId,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
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
          onTap: () {
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
