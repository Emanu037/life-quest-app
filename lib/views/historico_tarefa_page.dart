import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/app_viewmodel.dart';
import 'tarefa_page.dart'; 

class HistoricoTarefaPage extends StatelessWidget {
  const HistoricoTarefaPage({super.key});

  @override
  Widget build(BuildContext context) {
    
    final vm = context.watch<AppViewModel>();
    final historico = vm.historicoTarefas;
    
    const Color marrom = Color(0xFF5D4037);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "HISTÓRICO DE MISSÕES", 
          style: TextStyle(color: marrom, fontWeight: FontWeight.bold, fontSize: 18)
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: marrom),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: historico.isEmpty
          ? const Center(
              child: Text(
                "Nenhuma missão salva ainda... 🐾",
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: historico.length,
              itemBuilder: (context, index) {
                final lista = historico[index];
                
                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    title: Text(
                      lista['data'], // Mostra a data e hora
                      style: const TextStyle(fontWeight: FontWeight.bold, color: marrom),
                    ),
                    subtitle: Text(
                      "${(lista['itens'] as List).length} tarefas registradas",
                      style: const TextStyle(color: Colors.grey),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                    
                    
                    onTap: () {
                      
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TarefaPage(
                            itensParaEditar: lista['itens'],
                            indexHistorico: index,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}