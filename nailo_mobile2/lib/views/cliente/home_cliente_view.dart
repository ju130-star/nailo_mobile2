import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nailo_mobile2/views/cliente/form_agendamento_view.dart';

class HomeClienteView extends StatelessWidget {
  final String userId; // UID do cliente logado

  const HomeClienteView({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFA7E8E4),
      appBar: AppBar(
        title: const Text("Nailo 💅", style: TextStyle(fontWeight: FontWeight.bold)),
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

            // Lista dinâmica com os dois profissionais ativos
            Expanded(
              child: FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance
                    .collection('profissionais')
                    .where('ativo', isEqualTo: true)
                    .limit(2)
                    .get(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data!.docs;
                  if (docs.isEmpty) {
                    return const Center(child: Text("Nenhuma profissional cadastrada"));
                  }

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      return _profissionalCard(
                        context,
                        nome: data['nome'] ?? 'Sem nome',
                        especialidade: data['especialidade'] ?? '',
                        foto: data['fotoUrl'] ?? '',
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF48CFCB),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FormAgendamentoView()),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _profissionalCard(BuildContext context,
      {required String nome, required String especialidade, required String foto}) {
    return Card(
      color: const Color(0xFFFAFAFA),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: CircleAvatar(radius: 28, backgroundImage: NetworkImage(foto)),
        title: Text(nome, style: const TextStyle(color: Color(0xFF107A73), fontWeight: FontWeight.bold)),
        subtitle: Text(especialidade, style: const TextStyle(color: Colors.black54)),
        trailing: const Icon(Icons.arrow_forward_ios, color: Color(0xFF48CFCB)),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Abrindo perfil de $nome...")),
          );
        },
      ),
    );
  }
}
