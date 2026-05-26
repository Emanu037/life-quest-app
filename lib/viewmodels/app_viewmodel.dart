import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/usuario_model.dart';
import '../database/database_helper.dart';

class AppViewModel extends ChangeNotifier {
  Usuario? _usuarioLogado;
  int _pontos = 0;
  bool _isFirstTime = true;

  // --- LISTAS DE DADOS ---
  List<Map<String, dynamic>> _historicoDiario = []; 
  final List<Map<String, dynamic>> _listaTarefas = []; // Lista ativa fica em memória até salvar o dia
  List<Map<String, dynamic>> _historicoTarefas = []; // Carregada do SQLite
  
  // --- SISTEMA DE CUSTOMIZAÇÃO ---
  List<String> guardaRoupa = []; 
  String? roupaAtual; 

  // --- GETTERS ---
  Usuario? get usuarioLogado => _usuarioLogado;
  int get pontos => _pontos;
  bool get isFirstTime => _isFirstTime;
  String get nomePet => _usuarioLogado?.nome ?? "Floquinho";
  
  List<Map<String, dynamic>> get historicoDiario => List.unmodifiable(_historicoDiario);
  List<Map<String, dynamic>> get listaTarefas => _listaTarefas;
  List<Map<String, dynamic>> get historicoTarefas => _historicoTarefas;

  // --- CONSTRUTOR ---
  // CORRIGIDO: Não carregamos dados globais aqui se eles dependem de um usuário estar logado.
  AppViewModel() {
    // Se o seu app tiver um sistema de "lembrar login", a busca começaria aqui.
  }

  // --- CARREGAR DADOS DO SQLITE ---
  Future<void> carregarConfiguracoesIniciais() async {
    // 1. Carrega os pontos do banco
    final pontosSalvos = await DatabaseHelper.instance.buscarConfiguracao('pontos');
    if (pontosSalvos != null) {
      _pontos = int.parse(pontosSalvos);
    } else {
      _pontos = 0; // Padrão caso não exista
    }

    // 2. Carrega a roupa que o pet está vestindo
    final roupaSalva = await DatabaseHelper.instance.buscarConfiguracao('roupa_atual');
    if (roupaSalva != null) {
      roupaAtual = roupaSalva == 'null' ? null : roupaSalva;
    }

    // 3. Carrega o guarda-roupa decodificando o texto JSON do banco
    final guardaRoupaSalvo = await DatabaseHelper.instance.buscarConfiguracao('guarda_roupa');
    if (guardaRoupaSalvo != null) {
      List<dynamic> listaJson = jsonDecode(guardaRoupaSalvo);
      guardaRoupa = listaJson.map((item) => item.toString()).toList();
    }

    notifyListeners();
  }

  // --- GESTÃO DE USUÁRIO E PONTOS COM PERSISTÊNCIA ---
  Future<bool> autenticarUsuario(String nome, String senha) async {
    final db = await DatabaseHelper.instance.database;
    final resultado = await db.query(
      'usuarios',
      where: 'nome = ? AND senha = ?',
      whereArgs: [nome, senha],
    );

    if (resultado.isNotEmpty) {
      // Agora o modelo mapeia o ID corretamente
      _usuarioLogado = Usuario.fromMap(resultado.first); 
      
      // SÓ CARREGA AS COISAS SE O LOGIN FOR SUCESSO
      await carregarConfiguracoesIniciais();
      await carregarMissoes();
      return true;
    }
    return false; // Retorna false se errar a senha ou usuário não existir!
  }

  Future<void> cadastrarUsuario(String nome, String senha) async {
    final db = await DatabaseHelper.instance.database;
    
    // CORRIGIDO: Pegamos o ID numérico gerado pelo SQLite
    int novoId = await db.insert('usuarios', {'nome': nome, 'senha': senha});
    
    // Criamos o usuário com o ID correto na memória do app
    _usuarioLogado = Usuario(id: novoId, nome: nome, senha: senha);
    
    // Zera os dados locais para o novo usuário criado
    _pontos = 0;
    guardaRoupa = [];
    roupaAtual = null;
    _listaTarefas.clear();
    _historicoTarefas = [];
    
    notifyListeners();
  }

  Future<void> adicionarPontos(int valor) async {
    _pontos += valor;
    if (_pontos < 0) _pontos = 0; 
    notifyListeners();
    // Salva o novo valor de pontos no banco de dados
    await DatabaseHelper.instance.salvarConfiguracao('pontos', _pontos.toString());
  }

  // --- LOJA E ROUPAS SALVANDO NO BANCO ---
  Future<void> comprarRoupa(String nome, int preco) async {
    if (_pontos >= preco && !guardaRoupa.contains(nome)) {
      await adicionarPontos(-preco); // Desconta e já salva no banco
      guardaRoupa.add(nome);
      notifyListeners();

      // Transforma a lista de roupas compradas em texto e salva no banco
      String guardaRoupaJson = jsonEncode(guardaRoupa);
      await DatabaseHelper.instance.salvarConfiguracao('guarda_roupa', guardaRoupaJson);
    }
  }

  Future<void> vestirRoupa(String nome) async {
    roupaAtual = (roupaAtual == nome) ? null : nome;
    notifyListeners();
    // Salva qual roupa está equipada (ou 'null' se tirou a roupa)
    await DatabaseHelper.instance.salvarConfiguracao('roupa_atual', roupaAtual ?? 'null');
  }

  // --- TAREFAS DIÁRIAS (EM MEMÓRIA ENQUANTO CRIA) ---
  void adicionarItemTarefa(String titulo) {
    _listaTarefas.add({'titulo': titulo, 'concluido': false});
    notifyListeners();
  }

  void removerItemTarefa(int index) {
    if (_listaTarefas[index]['concluido']) {
      adicionarPontos(-5);
    }
    _listaTarefas.removeAt(index);
    notifyListeners();
  }

  void alternarTarefa(int index) {
    _listaTarefas[index]['concluido'] = !_listaTarefas[index]['concluido'];
    adicionarPontos(_listaTarefas[index]['concluido'] ? 5 : -5);
    notifyListeners();
  }

  // --- HISTÓRICO DE TAREFAS (PERSISTIDO NO SQLITE) ---
  Future<void> carregarMissoes() async {
    _historicoTarefas = await DatabaseHelper.instance.buscarHistoricoCompleto();
    notifyListeners();
  }

  Future<void> salvarListaNoHistorico(String data) async {
    if (_listaTarefas.isNotEmpty) {
      // Grava no SQLite a lista fechada
      await DatabaseHelper.instance.inserirHistoricoTarefa(data, _listaTarefas);
      _listaTarefas.clear();
      await carregarMissoes(); // Recarrega do banco para atualizar a tela de histórico
    }
  }

  Future<void> atualizarListaNoHistorico(int indexHistorico, List<Map<String, dynamic>> novosItens) async {
    int listaId = _historicoTarefas[indexHistorico]['id'];
    await DatabaseHelper.instance.atualizarHistoricoTarefa(listaId, novosItens);
    await carregarMissoes();
  }

  Future<void> excluirHistoricoTarefa(int index) async {
    int listaId = _historicoTarefas[index]['id'];
    final db = await DatabaseHelper.instance.database;
    
    // Apaga os dados correspondentes no SQLite
    await db.delete('tarefa_itens', where: 'missao_id = ?', whereArgs: [listaId]);
    await db.delete('missoes', where: 'id = ?', whereArgs: [listaId]);
    
    await carregarMissoes();
  }

  // --- REGISTROS DO DIÁRIO (PROVISÓRIO EM MEMÓRIA) ---
  void adicionarRegistroDiario({
    required String data, 
    required String humor, 
    required String palavraDia, 
    required String texto
  }) {
    _historicoDiario.insert(0, {
      'data': data, 
      'humor': humor, 
      'palavraDia': palavraDia, 
      'texto': texto
    });
    adicionarPontos(10);
    notifyListeners();
  }

  void atualizarRegistro(int index, {required String humor, required String palavraDia, required String texto}) {
    final registroAtualizado = Map<String, dynamic>.from(_historicoDiario[index]);
    
    registroAtualizado['humor'] = humor;
    registroAtualizado['palavraDia'] = palavraDia;
    registroAtualizado['texto'] = texto;
    
    _historicoDiario[index] = registroAtualizado;
    notifyListeners();
  }

  void excluirRegistro(int index) {
    _historicoDiario.removeAt(index);
    notifyListeners();
  }
}