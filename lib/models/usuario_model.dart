class Usuario {
  int? id; // O ID é opcional (?) porque ele não existe antes de salvar no banco
  String nome;
  String senha;

  Usuario({this.id, required this.nome, required this.senha});

  // Converte para salvar no SQLite
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id, // Só adiciona no mapa se o ID já existir
      'nome': nome,
      'senha': senha,
    };
  }

  // Cria um objeto a partir do banco de dados
  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      id: map['id'] as int?, // Pega o ID que veio do banco
      nome: map['nome'] ?? '',
      senha: map['senha'] ?? '',
    );
  }
}