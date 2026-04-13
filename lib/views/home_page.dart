import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/app_viewmodel.dart';
import 'login_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AppViewModel>();

    const Color miniPink = Color(0xFFF9D0DE);      
    const Color lavenderPink = Color(0xFFF8B0C8); 
    const Color tickleMePink = Color(0xFFF790B2); 
    const Color beaver = Color(0xFFAF7F73);       

    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/homepage_fundo.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 30, bottom: 20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: lavenderPink.withOpacity(0.5),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        )
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/peixe.png',
                          width: 35,
                          height: 35,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          "${vm.pontos} Peixinhos",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: beaver,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    children: [
                      _botaoMenu(
                        titulo: "Escrever no Diário",
                        subtitulo: "Recompensa: 10 peixinhos",
                        icone: Icons.auto_stories_outlined,
                        corFundo: Colors.white.withOpacity(0.9), // Leve transparência para combinar
                        corConteudo: beaver,
                        aoClicar: () {
                          print("Navegando para Diário...");
                        },
                      ),
                      _botaoMenu(
                        titulo: "Missões Diárias",
                        subtitulo: "Recompensa: 5 peixinhos p/ tarefa",
                        icone: Icons.assignment_outlined,
                        corFundo: Colors.white.withOpacity(0.9),
                        corConteudo: beaver,
                        aoClicar: () {
                          print("Navegando para Missões...");
                        },
                      ),
                      _botaoMenu(
                        titulo: "Ver meu Gatinho",
                        subtitulo: "Acesse e cuide do seu pet",
                        icone: Icons.pets_outlined,
                        corFundo: tickleMePink.withOpacity(0.95), // Botão de destaque do mascote
                        corConteudo: Colors.white,
                        aoClicar: () {
                          print("Navegando para o Pet...");
                        },
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(bottom: 25),
                  child: TextButton.icon(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginPage()),
                      );
                    },
                    icon: const Icon(Icons.logout, color: beaver, size: 20),
                    label: const Text(
                      "Sair do App",
                      style: TextStyle(
                        color: beaver,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _botaoMenu({
    required String titulo,
    required String subtitulo,
    required IconData icone,
    required Color corFundo,
    required Color corConteudo,
    required VoidCallback aoClicar,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: InkWell(
        onTap: aoClicar,
        borderRadius: BorderRadius.circular(25),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: corFundo,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: corConteudo.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icone, color: corConteudo, size: 30),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: corConteudo,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitulo,
                      style: TextStyle(
                        fontSize: 13,
                        color: corConteudo.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: corConteudo.withOpacity(0.2), size: 16),
            ],
          ),
        ),
      ),
    );
  }
}