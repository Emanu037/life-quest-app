import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../viewmodels/app_viewmodel.dart';
import 'historico_tarefa_page.dart';

class TarefaPage extends StatefulWidget {
  final List<Map<String, dynamic>>? itensParaEditar;
  final int? indexHistorico;

  const TarefaPage({super.key, this.itensParaEditar, this.indexHistorico});

  @override
  State<TarefaPage> createState() => _TarefaPageState();
}

class _TarefaPageState extends State<TarefaPage> {
  final TextEditingController _controller = TextEditingController();
  late List<Map<String, dynamic>> _listaLocal;
  late String _dataHora;
  
  final Color marrom = const Color(0xFF5D4037);
  final Color rosa = const Color(0xFFF790B2);

  @override
  void initState() {
    super.initState();
    // Se for edição, carrega os itens do histórico, senão usa a lista global do ViewModel
    if (widget.itensParaEditar != null) {
      _listaLocal = List<Map<String, dynamic>>.from(widget.itensParaEditar!);
      _dataHora = context.read<AppViewModel>().historicoTarefas[widget.indexHistorico!]['data'];
    } else {
      _listaLocal = context.read<AppViewModel>().listaTarefas;
      _dataHora = DateFormat('dd/MM/yyyy - HH:mm').format(DateTime.now());
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.read<AppViewModel>();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            Text(widget.itensParaEditar != null ? "EDITAR TAREFAS" : "LISTA DE TAREFAS", 
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            Text(_dataHora, style: const TextStyle(color: Colors.white, fontSize: 12)),
          ],
        ),
        centerTitle: true,
        actions: [
          if (widget.itensParaEditar == null)
            IconButton(
              icon: const Icon(Icons.history, color: Colors.white),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HistoricoTarefaPage())),
            )
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(image: DecorationImage(image: AssetImage('assets/pagina_diario.jpg'), fit: BoxFit.cover)),
        child: SafeArea(
          child: Column(
            children: [
              // Campo Adicionar
              Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(25)),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          decoration: const InputDecoration(hintText: "Nova tarefa...", border: InputBorder.none),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.add_circle, color: rosa, size: 30),
                        onPressed: () {
                          if (_controller.text.isNotEmpty) {
                            setState(() {
                              if (widget.itensParaEditar != null) {
                                _listaLocal.add({'titulo': _controller.text, 'concluido': false});
                              } else {
                                vm.adicionarItemTarefa(_controller.text);
                              }
                            });
                            _controller.clear();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              // Lista
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.8), borderRadius: BorderRadius.circular(20)),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: widget.itensParaEditar != null ? _listaLocal.length : vm.listaTarefas.length,
                    itemBuilder: (context, index) {
                      final tarefa = widget.itensParaEditar != null ? _listaLocal[index] : vm.listaTarefas[index];
                      return ListTile(
                        leading: Checkbox(
                          value: tarefa['concluido'],
                          activeColor: rosa,
                          onChanged: (val) {
                            setState(() {
                              if (widget.itensParaEditar != null) {
                                tarefa['concluido'] = val;
                                vm.adicionarPontos(val! ? 5 : -5);
                              } else {
                                vm.alternarTarefa(index);
                              }
                            });
                          },
                        ),
                        title: Text(tarefa['titulo'], style: TextStyle(color: marrom, decoration: tarefa['concluido'] ? TextDecoration.lineThrough : null)),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                          onPressed: () {
                            setState(() {
                              if (widget.itensParaEditar != null) {
                                _listaLocal.removeAt(index);
                              } else {
                                vm.removerItemTarefa(index);
                              }
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
              // Botão Salvar
              Padding(
                padding: const EdgeInsets.all(20),
                child: ElevatedButton(
                  onPressed: () {
                    if (widget.itensParaEditar != null) {
                      vm.atualizarListaNoHistorico(widget.indexHistorico!, _listaLocal);
                    } else {
                      vm.salvarListaNoHistorico(_dataHora);
                    }
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white, minimumSize: const Size(double.infinity, 55), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))),
                  child: Text(widget.itensParaEditar != null ? "ATUALIZAR HISTÓRICO" : "CONCLUIR LISTA DO DIA", style: TextStyle(color: marrom, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}