import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // HTTP: Importação para a API de Frases
import 'package:speech_to_text/speech_to_text.dart' as stt; // NATIVO: Microfone / Reconhecimento de Voz
import '../models/usuario_model.dart';
import '../database/database_helper.dart';

class AppViewModel extends ChangeNotifier {
  Usuario? _usuarioLogado;
  int _pontos = 0;
  bool _isFirstTime = true;

  // --- INTEGRAÇÃO COM API EXTERNA (FRASES) ---
  String _fraseMotivacional = "Carregando sua dose de motivação diária... ";
  bool _carregandoFrase = true;

  // --- LISTAS DE DADOS ---
  List<Map<String, dynamic>> _historicoDiario = []; 
  final List<Map<String, dynamic>> _listaTarefas = []; // Lista activa fica em memória até salvar o dia
  List<Map<String, dynamic>> _historicoTarefas = []; // Carregada do SQLite
  
  // --- SISTEMA DE CUSTOMIZAÇÃO ---
  List<String> guardaRoupa = []; 
  String? roupaAtual; 

  // --- GERENCIAMENTO NATIVO DO MICROFONE (SPEECH TO TEXT) ---
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _estaOuvindo = false;
  String _textoEscutado = "";

  // --- GETTERS ---
  Usuario? get usuarioLogado => _usuarioLogado;
  int get pontos => _pontos;
  bool get isFirstTime => _isFirstTime;
  String get nomePet => _usuarioLogado?.nome ?? "Floquinho";
  
  String get fraseMotivacional => _fraseMotivacional;
  bool get carregandoFrase => _carregandoFrase;
  
  List<Map<String, dynamic>> get historicoDiario => List.unmodifiable(_historicoDiario);
  List<Map<String, dynamic>> get listaTarefas => _listaTarefas;
  List<Map<String, dynamic>> get historicoTarefas => _historicoTarefas;

  // Getters do Microfone para a View atualizar o estado do botão
  bool get estaOuvindo => _estaOuvindo;
  String get textoEscutado => _textoEscutado;

  // --- CONSTRUTOR ---
  AppViewModel() {
    
  }

  // --- FUNÇÕES NATIVAS DO MICROFONE ---
  Future<void> alternarMicrofone(Function(String) onTextoMudou) async {
    if (!_estaOuvindo) {
      // Pede permissão ao sistema e inicializa o motor de voz nativo
      bool disponivel = await _speech.initialize(
        onStatus: (status) {
          if (status == 'notListening' || status == 'done') {
            _estaOuvindo = false;
            notifyListeners();
          }
        },
        onError: (error) => print('Erro no microfone: $error'),
      );

      if (disponivel) {
        _estaOuvindo = true;
        _textoEscutado = "";
        notifyListeners();

        // Começa a escutar o áudio capturado e força o padrão em português
        _speech.listen(
          localeId: 'pt_BR',
          onResult: (result) {
            _textoEscutado = result.recognizedWords;
            // Envia o texto decodificado em tempo real para preencher a caixa de texto da View
            onTextoMudou(_textoEscutado);
            notifyListeners();
          },
        );
      }
    } else {
      // Se clicou enquanto já gravava, encerra a captura manualmente
      _estaOuvindo = false;
      _speech.stop();
      notifyListeners();
    }
  }

  // --- INTEGRAÇÃO DIRETA (ZENQUOTES) + TRADUÇÃO VIA GOOGLE TRANSLATE ---
  Future<void> buscarFraseDiaria() async {
    _carregandoFrase = true;
    notifyListeners();

    try {
      // 1. Busca a frase original em inglês na ZenQuotes
      final urlZen = Uri.parse('https://zenquotes.io/api/random');
      final respostaZen = await http.get(urlZen);

      if (respostaZen.statusCode == 200) {
        final List<dynamic> dadosZen = jsonDecode(respostaZen.body);
        final String fraseIngles = dadosZen[0]['q'];
        final String autor = dadosZen[0]['a'];

        // 2. Envia o texto em inglês para a API de tradução do Google
        final urlTradutor = Uri.parse(
          'https://translate.googleapis.com/translate_a/single?client=gtx&sl=en&tl=pt&dt=t&q=${Uri.encodeComponent(fraseIngles)}'
        );
        final respostaTraducao = await http.get(urlTradutor);

        if (respostaTraducao.statusCode == 200) {
          final List<dynamic> dadosTraducao = jsonDecode(respostaTraducao.body);
          final String fraseEmPortugues = dadosTraducao[0][0][0];
          
          _fraseMotivacional = '"$fraseEmPortugues" — $autor';
        } else {
          _fraseMotivacional = '"$fraseIngles" — $autor';
        }
      } else {
        _fraseMotivacional = '"Acredite em si mesmo e todo o resto virá naturalmente." — Christian D. Larson';
      }
    } catch (e) {
      _fraseMotivacional = '"Foque no seu progresso hoje, um passo de cada vez!" — Sistema 🐾';
    } finally {
      _carregandoFrase = false;
      notifyListeners();
    }
  }

  // --- CARREGAR DADOS DO SQLITE ---
  Future<void> carregarConfiguracoesIniciais() async {
    final pontosSalvos = await DatabaseHelper.instance.buscarConfiguracao('pontos');
    if (pontosSalvos != null) {
      _pontos = int.parse(pontosSalvos);
    } else {
      _pontos = 0; 
    }

    final roupaSalva = await DatabaseHelper.instance.buscarConfiguracao('roupa_atual');
    if (roupaSalva != null) {
      roupaAtual = roupaSalva == 'null' ? null : roupaSalva;
    }

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
      _usuarioLogado = Usuario.fromMap(resultado.first); 
      
      await carregarConfiguracoesIniciais();
      await carregarMissoes();
      return true;
    }
    return false; 
  }

  Future<void> cadastrarUsuario(String nome, String senha) async {
    final db = await DatabaseHelper.instance.database;
    int novoId = await db.insert('usuarios', {'nome': nome, 'senha': senha});
    
    _usuarioLogado = Usuario(id: novoId, nome: nome, senha: senha);
    
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
    
    await DatabaseHelper.instance.salvarConfiguracao('pontos', _pontos.toString());
  }

  // --- LOJA E ROUPAS SALVANDO NO BANCO ---
  Future<void> comprarRoupa(String nome, int preco) async {
    if (_pontos >= preco && !guardaRoupa.contains(nome)) {
      await adicionarPontos(-preco); 
      guardaRoupa.add(nome);
      notifyListeners();

      String guardaRoupaJson = jsonEncode(guardaRoupa);
      await DatabaseHelper.instance.salvarConfiguracao('guarda_roupa', guardaRoupaJson);
    }
  }

  Future<void> vestirRoupa(String nome) async {
    roupaAtual = (roupaAtual == nome) ? null : nome;
    notifyListeners();
    await DatabaseHelper.instance.salvarConfiguracao('roupa_atual', roupaAtual ?? 'null');
  }

  // --- TAREFAS DIÁRIAS ---
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
      await DatabaseHelper.instance.inserirHistoricoTarefa(data, _listaTarefas);
      _listaTarefas.clear();
      await carregarMissoes(); 
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
    
    await db.delete('tarefa_itens', where: 'missao_id = ?', whereArgs: [listaId]);
    await db.delete('missoes', where: 'id = ?', whereArgs: [listaId]);
    
    await carregarMissoes();
  }

  // --- REGISTROS DO DIÁRIO ---
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