import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'cadastro_usuario_page.dart';
import 'intro_page.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _nomeController = TextEditingController();
  final _senhaController = TextEditingController();
  
  final Color tickleMePink = const Color(0xFFF790B2);
  final Color beaver = const Color(0xFFAF7F73);

  // Função que gerencia o login e a persistência
  Future<void> _fazerLogin() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Verifica se já passou pela introdução antes
    bool isFirstTime = prefs.getBool('isFirstTime') ?? true;

    if (!mounted) return;

    if (isFirstTime) {
      // Se for a primeira vez, vai pra intro
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const IntroPage()),
      );
    } else {
      // Se não for a primeira vez, recupera o nome salvo e vai direto para a Home
      String nomeSalvo = prefs.getString('petName') ?? "Gatinho";
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage(nomeDoGato: nomeSalvo)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/cadastro_fundo.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                children: [
                  const Text(
                    "DearDiary",
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w300,
                      color: Colors.white,
                      shadows: [Shadow(color: Colors.black26, blurRadius: 10)],
                    ),
                  ),
                  const SizedBox(height: 60),
                  _campoLogin(controller: _nomeController, label: "Usuário", icon: Icons.person_outline),
                  const SizedBox(height: 20),
                  _campoLogin(controller: _senhaController, label: "Senha", icon: Icons.lock_outline, obscureText: true),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: tickleMePink,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    ),
                    onPressed: _fazerLogin, // Chama a função lógica acima
                    child: const Text("ENTRAR", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const CadastroUsuarioPage()));
                    },
                    child: const Text(
                      "Não tem uma conta? Cadastre-se",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _campoLogin({required TextEditingController controller, required String label, required IconData icon, bool obscureText = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: TextStyle(color: beaver),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: tickleMePink),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
      ),
    );
  }
}