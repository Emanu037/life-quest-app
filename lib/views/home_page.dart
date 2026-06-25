import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/app_viewmodel.dart';
import 'login_page.dart';
import 'diario_page.dart';
import 'tarefa_page.dart';
import 'personagem_page.dart'; // Import obrigatório para abrir o pet

class HomePage extends StatefulWidget {
  final String nomeDoGato;

  const HomePage({super.key, required this.nomeDoGato});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Dispara a requisição HTTP para a API externa assim que a interface é desenhada
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppViewModel>().buscarFraseDiaria();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AppViewModel>();

    const Color tickleMePink = Color(0xFFF790B2);
    const Color beaver = Color(0xFFAF7F73);

    return Scaffold(
      body: Stack(
        children: [
          // Fundo
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
                // Placar de Peixinhos
                Padding(
                  padding: const EdgeInsets.only(top: 30, bottom: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))
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

                // INTEGRAÇÃO COM API EXTERNA: Balão de Frases Motivacionais
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: tickleMePink.withOpacity(0.3)),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3))
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.chat_bubble_outline, color: tickleMePink, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: vm.carregandoFrase
                            ? const Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: tickleMePink),
                                ),
                              )
                            : Text(
                                vm.fraseMotivacional,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.black87,
                                ),
                              ),
                      ),
                      if (!vm.carregandoFrase)
                        IconButton(
                          icon: const Icon(Icons.refresh, size: 18, color: beaver),
                          onPressed: () => vm.buscarFraseDiaria(),
                          tooltip: "Mudar frase",
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 5),

                // Menu de Opções
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    children: [
                      _botaoMenu(
                        titulo: "Escrever no Diário",
                        subtitulo: "Recompensa: 10 peixinhos",
                        icone: Icons.auto_stories_outlined,
                        corFundo: Colors.white.withOpacity(0.9),
                        corConteudo: beaver,
                        aoClicar: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const DiarioPage()),
                          );
                        },
                      ),
                      _botaoMenu(
                        titulo: "Missões Diárias",
                        subtitulo: "Recompensa: 5 peixinhos p/ tarefa",
                        icone: Icons.assignment_outlined,
                        corFundo: Colors.white.withOpacity(0.9),
                        corConteudo: beaver,
                        aoClicar: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const TarefaPage()),
                          );
                        },
                      ),
                      _botaoMenu(
                        titulo: "Ver ${widget.nomeDoGato}", 
                        subtitulo: "Acesse e cuide do seu pet",
                        icone: Icons.pets_outlined,
                        corFundo: tickleMePink.withOpacity(0.95),
                        corConteudo: Colors.white,
                        aoClicar: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const PersonagemPage()),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // Botão Sair
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
                      style: TextStyle(color: beaver, fontWeight: FontWeight.bold, fontSize: 16),
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
              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))
            ],
          ),
          child: Row(
            children: [
              Icon(icone, color: corConteudo, size: 30),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(titulo, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: corConteudo)),
                    const SizedBox(height: 4),
                    Text(subtitulo, style: TextStyle(fontSize: 13, color: corConteudo.withOpacity(0.7))),
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