class TarefaModel {
  final int id;
  final String titulo;
  bool concluida;
  final int recompensaXp;

  TarefaModel({
    required this.id,
    required this.titulo,
    this.concluida = false,
    this.recompensaXp = 10,
  });
}
