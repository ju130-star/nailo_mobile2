import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:nailo_mobile2/views/auth/cadastro_view.dart';
import 'package:nailo_mobile2/views/auth/cadastro_proprietaria_view.dart';

import 'package:nailo_mobile2/views/components/navbar_cliente.dart';
import 'package:nailo_mobile2/views/components/navbar_proprietaria.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final _emailField = TextEditingController();
  final _senhaField = TextEditingController();
  bool _ocultarSenha = true;

  // LOGIN
  void _signIn() async {
    try {
      UserCredential cred = await _auth.signInWithEmailAndPassword(
        email: _emailField.text.trim(),
        password: _senhaField.text,
      );

      final user = cred.user;
      if (user == null) return;

      final snap = await FirebaseFirestore.instance
          .collection("usuarios")
          .doc(user.uid)
          .get();

      final data = snap.data();
      if (data == null) {
        throw Exception("Usuário sem dados no Firestore!");
      }

      final tipo = data["tipo"]; // cliente ou proprietaria

      // Redirecionar automaticamente
      if (tipo == "proprietaria") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const NavbarProprietaria(),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => NavbarCliente(
              userId: user.uid,
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Falha ao fazer login: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFA7E8E4), // Verde água suave
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(24),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFFAFAFA), // Off White
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // LOGO / TÍTULO
                const Text(
                  "Nailo",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF107A73), // Verde escuro
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Bem-vinda! Faça seu login.",
                  style: TextStyle(
                    color: Color(0xFF107A73),
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 30),

                // EMAIL
                TextField(
                  controller: _emailField,
                  decoration: InputDecoration(
                    labelText: "Email",
                    labelStyle: const TextStyle(color: Color(0xFF107A73)),
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: const Icon(Icons.email, color: Color(0xFF107A73)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                // SENHA
                TextField(
                  controller: _senhaField,
                  decoration: InputDecoration(
                    labelText: "Senha",
                    labelStyle: const TextStyle(color: Color(0xFF107A73)),
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: const Icon(Icons.lock, color: Color(0xFF107A73)),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _ocultarSenha = !_ocultarSenha;
                        });
                      },
                      icon: Icon(
                        _ocultarSenha ? Icons.visibility : Icons.visibility_off,
                        color: const Color(0xFF107A73),
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  obscureText: _ocultarSenha,
                ),

                const SizedBox(height: 24),

                // BOTÃO LOGIN
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _signIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF48CFCB), // Verde jade
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Entrar",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // BOTÃO PROPRIETÁRIA
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CadastroProprietariaView(),
                      ),
                    );
                  },
                  child: const Text(
                    "É proprietária? Cadastre-se aqui",
                    style: TextStyle(
                      color: Color(0xFF107A73),
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),

                // BOTÃO CLIENTE
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CadastroView()),
                    );
                  },
                  child: const Text(
                    "Não tem uma conta? Registre-se Aqui",
                    style: TextStyle(
                      color: Color(0xFF107A73),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
