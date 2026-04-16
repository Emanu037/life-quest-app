import 'package:flutter/material.dart';
import '../models/usuario_model.dart';

class AppViewModel extends ChangeNotifier {
  Usuario? _usuarioLogado;
  int _pontos = 0;

  // --- LISTAS DE DADOS ---
  final List<Map<String, dynamic>> _historicoDiario = [];
  final List<Map<String, dynamic>> _listaTarefas = [];
  final List<Map<String, dynamic>> _historicoTarefas = [];
  
  // --- SISTEMA DE CUSTOMIZAÇÃO ---
  List<String> guardaRoupa = []; // Nomes dos arquivos das roupas compradas
  String? roupaAtual; // Roupa vestida no momento

  // --- GETTERS ---
  Usuario? get usuarioLogado => _usuarioLogado;
  int get pontos => _pontos;

  String get nomePet => _usuarioLogado?.nome ?? "Floquinho";
  
  List<Map<String, dynamic>> get historicoDiario => List.unmodifiable(_historicoDiario);
  List<Map<String, dynamic>> get listaTarefas => _listaTarefas;
  List<Map<String, dynamic>> get historicoTarefas => _historicoTarefas;

  

  // --- GESTÃO DE USUÁRIO E PONTOS ---
  void cadastrarUsuario(String nome, String senha) {
    _usuarioLogado = Usuario(nome: nome, senha: senha);
    notifyListeners();
  }

  void adicionarPontos(int valor) {
    _pontos += valor;
    notifyListeners();
  }

  // --- FUNCIONALIDADES DO PERSONAGEM  ---
  void comprarRoupa(String nome, int preco) {
    
    if (_pontos >= preco && !guardaRoupa.contains(nome)) {
      _pontos -= preco; 
      guardaRoupa.add(nome);
      notifyListeners();
    }
  }

  void vestirRoupa(String nome) {
    // Se clicar na roupa que já está usando ele tira 
    roupaAtual = (roupaAtual == nome) ? null : nome;
    notifyListeners();
  }

  // --- FUNCIONALIDADES DO DIÁRIO ---
  void adicionarRegistroDiario({
    required String data,
    required String humor,
    required String palavraDia,
    required String texto,
  }) {
    _historicoDiario.insert(0, {
      'data': data,
      'humor': humor,
      'palavraDia': palavraDia,
      'texto': texto,
    });
    adicionarPontos(10); // Recompensa por escrita
    notifyListeners();
  }

  void atualizarRegistro(int index, {required String humor, required String palavraDia, required String texto}) {
    _historicoDiario[index]['humor'] = humor;
    _historicoDiario[index]['palavraDia'] = palavraDia;
    _historicoDiario[index]['texto'] = texto;
    notifyListeners();
  }

  void excluirRegistro(int index) {
    _historicoDiario.removeAt(index);
    notifyListeners();
  }

  // --- FUNCIONALIDADES DE TAREFAS ---
  void adicionarItemTarefa(String titulo) {
    _listaTarefas.add({'titulo': titulo, 'concluido': false});
    notifyListeners();
  }

  void removerItemTarefa(int index) {
    _listaTarefas.removeAt(index);
    notifyListeners();
  }

  void alternarTarefa(int index) {
    _listaTarefas[index]['concluido'] = !_listaTarefas[index]['concluido'];
    
    if (_listaTarefas[index]['concluido']) {
      adicionarPontos(5);
    } else {
      adicionarPontos(-5);
    }
    notifyListeners();
  }

  // --- HISTÓRICO DE TAREFAS ---
  void salvarListaNoHistorico(String data) {
    if (_listaTarefas.isNotEmpty) {
      _historicoTarefas.insert(0, {
        'data': data,
        'itens': List<Map<String, dynamic>>.from(_listaTarefas),
      });
      _listaTarefas.clear();
      notifyListeners();
    }
  }

  void atualizarListaNoHistorico(int indexHistorico, List<Map<String, dynamic>> novosItens) {
    _historicoTarefas[indexHistorico]['itens'] = List<Map<String, dynamic>>.from(novosItens);
    notifyListeners();
  }

  void excluirHistoricoTarefa(int index) {
    _historicoTarefas.removeAt(index);
    notifyListeners();
  }
}