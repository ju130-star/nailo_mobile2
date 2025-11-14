import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:nailo_mobile2/firebase_options.dart';
import 'package:nailo_mobile2/views/auth/login_view.dart';
import 'package:nailo_mobile2/views/components/navbar_cliente.dart';
import 'package:nailo_mobile2/views/components/navbar_proprietaria.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const NailoApp());
}

class NailoApp extends StatelessWidget {
  const NailoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Nailo 💅",
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFA7E8E4),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF48CFCB),
          foregroundColor: Colors.white,
        ),
        brightness: Brightness.light,
      ),
      home: const AuthStream(),
    );
  }
}

class AuthStream extends StatelessWidget {
  const AuthStream({super.key});

  Future<Widget> _carregarHome(User user) async {
    final snap = await FirebaseFirestore.instance
        .collection("usuarios")
        .doc(user.uid)
        .get();

    final tipo = snap.data()?["tipo"];

    if (tipo == "proprietaria") {
      return const NavbarProprietaria(); // pode passar userId se necessário
    } else {
      return NavbarCliente(userId: user.uid); // ← corrigido
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData) {
          return const LoginView();
        }

        final user = snapshot.data!;

        return FutureBuilder<Widget>(
          future: _carregarHome(user),
          builder: (context, snap) {
            if (!snap.hasData) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            return snap.data!;
          },
        );
      },
    );
  }
}
