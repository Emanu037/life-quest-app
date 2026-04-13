import 'package:flutter/material.dart';
import '../models/usuario_model.dart';

class AppViewModel extends ChangeNotifier {
  Usuario? _usuarioLogado;
  int _pontos = 0;

  Usuario? get usuarioLogado => _usuarioLogado;
  int get pontos => _pontos;

  void cadastrarUsuario(String nome, String senha) {
    _usuarioLogado = Usuario(nome: nome, senha: senha);
    notifyListeners();
  }

  void adicionarPontos(int valor) {
    _pontos += valor;
    notifyListeners();
  }
}