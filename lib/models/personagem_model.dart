class PersonagemModel {
  final int id;
  final String nome;
  final String imagemPath;
  int nivel;
  int xp;
  int vida;
  int vidaMaxima;

  PersonagemModel({
    required this.id,
    required this.nome,
    required this.imagemPath,
    this.nivel = 1,
    this.xp = 0,
    this.vida = 100,
    this.vidaMaxima = 100,
  });

  bool get estaVivo => vida > 0;

  double get porcentagemVida => vida / vidaMaxima;
}
