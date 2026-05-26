import 'tarefa_model.dart';

class HistoricoModel {
  final int id;
  final String data;
  final List<TarefaModel> itens;

  HistoricoModel({
    required this.id,
    required this.data,
    required this.itens,
  });
}
