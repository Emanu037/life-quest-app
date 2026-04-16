import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../viewmodels/app_viewmodel.dart';
import 'historico_page.dart';

class DiarioPage extends StatefulWidget {
  final Map<String, dynamic>? registroParaEditar;
  final int? indexParaEditar;

  const DiarioPage({super.key, this.registroParaEditar, this.indexParaEditar});

  @override
  State<DiarioPage> createState() => _DiarioPageState();
}

class _DiarioPageState extends State<DiarioPage> {
  late TextEditingController _textoController;
  late TextEditingController _palavraDiaController;
  String? _humorSelecionado;
  late String _dataHora;

  // CORES
  final Color marromLeitura = const Color(0xFF5D4037);
  final Color tickleMePink = const Color(0xFFF790B2);
  final Color beaver = const Color(0xFFAF7F73);

  final List<Map<String, String>> _humores = [
    {'emoji': 'assets/feliz.png', 'label': 'Feliz'},
    {'emoji': 'assets/animado.png', 'label': 'Animado(a)'},
    {'emoji': 'assets/relax.png', 'label': 'Relax'},
    {'emoji': 'assets/entediado.png', 'label': 'Entediado(a)'},
    {'emoji': 'assets/tonto.png', 'label': 'Doidinho(a)'}, // Corrigido nome do asset
    {'emoji': 'assets/triste.png', 'label': 'Triste'},
    {'emoji': 'assets/style.png', 'label': 'Style'},
    {'emoji': 'assets/irritado.png', 'label': 'Irritado(a)'},
  ];

  @override
  void initState() {
    super.initState();
    _textoController = TextEditingController(text: widget.registroParaEditar?['texto'] ?? "");
    _palavraDiaController = TextEditingController(text: widget.registroParaEditar?['palavraDia'] ?? "");
    _humorSelecionado = widget.registroParaEditar?['humor'];
    _dataHora = widget.registroParaEditar?['data'] ?? DateFormat('dd/MM/yyyy - HH:mm').format(DateTime.now());
  }

  // LÓGICA PARA SALVAR/ATUALIZAR
  void _tentarSalvar() {
    if (_humorSelecionado == null || 
        _textoController.text.trim().isEmpty || 
        _palavraDiaController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor, preencha todos os campos e selecione seu humor! 🐾")),
      );
      return;
    }

    final vm = context.read<AppViewModel>();

    if (widget.registroParaEditar != null) {
      // MODO EDIÇÃO
      vm.atualizarRegistro(
        widget.indexParaEditar!,
        humor: _humorSelecionado!,
        palavraDia: _palavraDiaController.text,
        texto: _textoController.text,
      );
    } else {
      // MODO NOVO REGISTRO
      vm.adicionarRegistroDiario(
        data: _dataHora,
        humor: _humorSelecionado!,
        palavraDia: _palavraDiaController.text,
        texto: _textoController.text,
      );
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (widget.registroParaEditar == null)
            IconButton(
              icon: const Icon(Icons.history, color: Colors.white),
              // CORREÇÃO: Removido o 'const' antes de MaterialPageRoute
              onPressed: () => Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => const HistoricoPage()),
              ),
            )
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(image: AssetImage('assets/pagina_diario.jpg'), fit: BoxFit.cover),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(25),
            child: Column(
              children: [
                Text(_dataHora, style: TextStyle(color: marromLeitura, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                // Seletor de Humores
                SizedBox(
                  height: 95,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _humores.length,
                    itemBuilder: (context, index) {
                      final h = _humores[index];
                      bool sel = _humorSelecionado == h['label'];
                      return GestureDetector(
                        onTap: () => setState(() => _humorSelecionado = h['label']),
                        child: Container(
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: sel ? Colors.white : Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: sel ? tickleMePink : Colors.transparent, width: 2),
                          ),
                          child: Column(
                            children: [
                              Image.asset(h['emoji']!, width: 40, height: 40),
                              Text(h['label']!, style: TextStyle(fontSize: 10, color: marromLeitura)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 25),
                // Campo de Texto Principal
                Container(
                  constraints: const BoxConstraints(minHeight: 300),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(20)),
                  child: TextField(
                    controller: _textoController,
                    maxLines: null,
                    style: TextStyle(color: marromLeitura),
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.all(20), 
                      border: InputBorder.none, 
                      hintText: "Escreva aqui seu dia...",
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Palavra do dia
                Container(
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(15)),
                  child: TextField(
                    controller: _palavraDiaController,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      labelText: "  PALAVRA DO DIA", 
                      labelStyle: TextStyle(color: beaver), 
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                // Botão Salvar
                ElevatedButton(
                  onPressed: _tentarSalvar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 60),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                  child: Text(
                    widget.registroParaEditar != null ? "ATUALIZAR REGISTRO" : "SALVAR NO DIÁRIO",
                    style: TextStyle(color: marromLeitura, fontWeight: FontWeight.bold),
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