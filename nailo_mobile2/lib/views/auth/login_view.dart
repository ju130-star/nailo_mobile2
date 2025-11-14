import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nailo_mobile2/views/auth/cadastro_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  //atributos
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _emailField = TextEditingController();
  final _senhaField = TextEditingController();
  bool _ocultarSenha = true;

  //método para fazer login
  void _signIn() async {
  try {
    // 1) Login
    UserCredential cred = await _auth.signInWithEmailAndPassword(
      email: _emailField.text.trim(),
      password: _senhaField.text,
    );

    final user = cred.user;
    if (user == null) return;

    // 2) Buscar usuário no Firestore
    final snap = await FirebaseFirestore.instance
        .collection("usuarios")
        .doc(user.uid)
        .get();

    final data = snap.data();
    if (data == null) {
      throw Exception("Usuário sem dados no Firestore!");
    }

    final tipo = data["tipo"]; // cliente ou proprietaria

    // 3) Redirecionar conforme tipo
    if (tipo == "proprietaria") {
      Navigator.pushReplacementNamed(context, "/homeProprietaria");
    } else {
      Navigator.pushReplacementNamed(context, "/homeCliente");
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
      appBar: AppBar(title: Text("Login")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Card(
          color: const Color.fromARGB(255, 0, 0, 0),
          child: Column(
            children: [
              TextField(
                controller: _emailField,
                decoration: InputDecoration(labelText: "Email"),
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: _senhaField,
                decoration: InputDecoration(labelText: "Senha",
                suffixIcon: IconButton(
                  onPressed: ()=> setState(() {
                    _ocultarSenha = !_ocultarSenha;
                  }),
                  icon: Icon(_ocultarSenha ? Icons.visibility : Icons.visibility_off))),
                  obscureText: _ocultarSenha,
              ),
              SizedBox(height: 20),
              ElevatedButton(onPressed: _signIn, child: Text("Entrar", style: TextStyle(color: Colors.white),),),
              TextButton(
                onPressed: ()=> Navigator.push(context, MaterialPageRoute(builder: (context)=> CadastroView())), 
                child: Text("Não tem uma conta? Registre-se Aqui"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}