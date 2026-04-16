import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/app_viewmodel.dart';
import '../widgets/personagem_widget.dart';

class PersonagemPage extends StatefulWidget {
  const PersonagemPage({super.key});

  @override
  State<PersonagemPage> createState() => _PersonagemPageState();
}

class _PersonagemPageState extends State<PersonagemPage> {
  bool mostrarLoja = true;

  
  final Map<String, int> itensLoja = {
    'roupa 2': 50,
    'roupa 4': 50,
  };

  @override
  Widget build(BuildContext context) {
    // Escutando as mudanças no ViewModel (pontos, guarda-roupa, nome do pet, etc)
    final vm = context.watch<AppViewModel>();

    return Scaffold(
      
      body: Container(
        
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/fundo_mascote.jpg'),
            fit: BoxFit.cover, 
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, color: Colors.brown),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9), 
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                      ),
                      child: Row(
                        children: [
                          Image.asset('assets/peixe.png', width: 24, height: 24),
                          const SizedBox(width: 8),
                          Text(
                            "${vm.pontos}",
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.brown),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 
              Text(
                
                vm.nomePet.toUpperCase(), 
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.brown, letterSpacing: 2),
              ),

              
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    
                    PersonagemWidget(
                      roupaAtiva: vm.roupaAtual,
                      tamanho: 320, 
                    ),

                    
                    Positioned(
                      right: 10, 
                      child: Column(
                        children: [
                          _botaoCircular(
                            Icons.store, 
                            "Loja", 
                            mostrarLoja, 
                            () => setState(() => mostrarLoja = true)
                          ),
                          const SizedBox(height: 20),
                          _botaoCircular(
                            Icons.checkroom, 
                            "Roupas", 
                            !mostrarLoja, 
                            () => setState(() => mostrarLoja = false)
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              
              Container(
                height: 250,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 2)],
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 15),
                    Text(
                      mostrarLoja ? "LOJA DISPONÍVEL" : "MEUS ITENS",
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.brown, fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        children: mostrarLoja ? _buildLoja(vm) : _buildGuardaRoupa(vm),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- LÓGICA DA VITRINE DA LOJA ---
  List<Widget> _buildLoja(AppViewModel vm) {
    return itensLoja.entries.map((item) {
      bool jaPossui = vm.guardaRoupa.contains(item.key);
      return _cardItem(
        item.key, 
        jaPossui ? "COMPRADO" : "${item.value}", 
        jaPossui,
        () {
          if (!jaPossui) {
            _dialogCompra(vm, item.key, item.value);
          }
        },
        mostrarMoeda: !jaPossui,
      );
    }).toList();
  }

  // --- LÓGICA DO GUARDA-ROUPA ---
  List<Widget> _buildGuardaRoupa(AppViewModel vm) {
    if (vm.guardaRoupa.isEmpty) {
      return [const Center(child: Text("Você ainda não tem roupas. Vá à loja!"))];
    }
    return vm.guardaRoupa.map((item) {
      bool estaVestido = vm.roupaAtual == item;
      return _cardItem(
        item, 
        estaVestido ? "VESTIDO" : "USAR", 
        estaVestido,
        () => vm.vestirRoupa(item)
      );
    }).toList();
  }

  // --- WIDGET DE CADA CARD DE ITEM ---
  Widget _cardItem(String nomeImagem, String rotulo, bool selecionado, VoidCallback acao, {bool mostrarMoeda = false}) {
    return GestureDetector(
      onTap: acao,
      child: Container(
        width: 130,
        margin: const EdgeInsets.only(right: 15, bottom: 10, top: 5),
        decoration: BoxDecoration(
          color: selecionado ? Colors.brown.withOpacity(0.05) : Colors.grey[50],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selecionado ? Colors.brown : Colors.brown.withOpacity(0.1),
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Image.asset(
                  'assets/$nomeImagem.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 40),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: selecionado ? Colors.brown : Colors.brown[400],
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(17)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    rotulo,
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  if (mostrarMoeda) ...[
                    const SizedBox(width: 4),
                    Image.asset('assets/peixe.png', width: 12, height: 12),
                  ]
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- POPUP DE CONFIRMAÇÃO DE COMPRA ---
  void _dialogCompra(AppViewModel vm, String nome, int preco) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Confirmar Compra"),
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Removido 'const' para aceitar a variável $preco (Correção da imagem 926f07)
            Text("Deseja gastar $preco "), 
            Image.asset('assets/peixe.png', width: 18, height: 18),
            Text(" na $nome?"),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Ainda não")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.brown, foregroundColor: Colors.white),
            onPressed: () {
              vm.comprarRoupa(nome, preco);
              Navigator.pop(context);
            },
            child: const Text("Comprar"),
          ),
        ],
      ),
    );
  }

  // --- ESTILO DOS BOTÕES LATERAIS ---
  Widget _botaoCircular(IconData icone, String label, bool ativo, VoidCallback acao) {
    return Column(
      children: [
        SizedBox(
          height: 60,
          width: 60,
          child: FloatingActionButton(
            heroTag: label,
            onPressed: acao,
            elevation: ativo ? 0 : 4,
            backgroundColor: ativo ? Colors.brown : Colors.white,
            shape: const CircleBorder(),
            child: Icon(icone, color: ativo ? Colors.white : Colors.brown),
          ),
        ),
        const SizedBox(height: 5),
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.brown)),
      ],
    );
  }
}