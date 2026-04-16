import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/app_viewmodel.dart';
import 'diario_page.dart';

class HistoricoPage extends StatelessWidget {
  const HistoricoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final historico = context.watch<AppViewModel>().historicoDiario;
    const Color marrom = Color(0xFF5D4037);

    return Scaffold(
      appBar: AppBar(
        title: const Text("MEU HISTÓRICO", style: TextStyle(color: marrom, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: marrom),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: historico.isEmpty
          ? const Center(child: Text("Nenhuma lembrança guardada ainda... 🐾"))
          : ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: historico.length,
              itemBuilder: (context, index) {
                final item = historico[index];

                return Dismissible(
                  key: UniqueKey(), 
                  direction: DismissDirection.endToStart, 
                  onDismissed: (direction) {
                    context.read<AppViewModel>().excluirRegistro(index);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Registro removido com sucesso!")),
                    );
                  },
                  background: Container(
                    padding: const EdgeInsets.only(right: 20),
                    alignment: Alignment.centerRight,
                    color: Colors.redAccent,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(15),
                      title: Text(
                        "${item['data']} - ${item['palavraDia']}",
                        style: const TextStyle(fontWeight: FontWeight.bold, color: marrom),
                      ),
                      subtitle: Text(item['texto'], maxLines: 1, overflow: TextOverflow.ellipsis),
                      trailing: const Icon(Icons.edit, size: 20),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DiarioPage(
                              registroParaEditar: item,
                              indexParaEditar: index,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}