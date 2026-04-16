import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  final TextEditingController _nomeGatinhoController = TextEditingController();
  final Color beaver = const Color(0xFFAF7F73);
  final Color tickleMePink = const Color(0xFFF790B2);

  // Função para salvar os dados e ir para a Home
  Future<void> _finalizarIntro() async {
    String nome = _nomeGatinhoController.text.trim();
    
    if (nome.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      
      // Salva que o usuário já passou pela intro e o nome do pet
      await prefs.setBool('isFirstTime', false);
      await prefs.setString('petName', nome);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage(nomeDoGato: nome)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Dê um nome para o seu gatinho! 🐾"), backgroundColor: Colors.pinkAccent),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/cadastro_fundo.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(35),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Bem-vindo ao\nSoft Life Quest", 
                      textAlign: TextAlign.center, 
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: beaver)),
                    const SizedBox(height: 25),
                    _itemIntro(Icons.check_circle_outline, "Organize suas tarefas"),
                    _itemIntro(Icons.auto_stories_outlined, "Escreva no seu diário"),
                    _itemIntro(Icons.phishing, "Acumule peixinhos"),
                    _itemIntro(Icons.pets, "Personalize seu pet"),
                    const SizedBox(height: 30),
                    const Divider(),
                    const SizedBox(height: 20),
                    Text("Como seu gatinho vai se chamar?", 
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: beaver)),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _nomeGatinhoController,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        hintText: "Ex: Pipoca",
                        filled: true,
                        fillColor: Colors.pink[50],
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _finalizarIntro,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: tickleMePink,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      ),
                      child: const Text("COMEÇAR JORNADA", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemIntro(IconData icone, String texto) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icone, color: tickleMePink, size: 22),
          const SizedBox(width: 15),
          Text(texto, style: TextStyle(fontSize: 16, color: beaver.withOpacity(0.9))),
        ],
      ),
    );
  }
}