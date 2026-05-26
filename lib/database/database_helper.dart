
import 'dart:io'; // Importante para detectar se está rodando no Windows
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/diario_model.dart';

class DatabaseHelper {
  // Padrão Singleton: garante que haverá apenas uma instância do banco rodando
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  // Instância do banco de dados
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('soft_life_quest.db');
    return _database!;
  }

  // Inicializa o banco no dispositivo ou no computador
  Future<Database> _initDB(String filePath) async {
    String path;

    // SE ESTIVER NO WINDOWS: Salva o arquivo .db direto na pasta do seu código
    if (Platform.isWindows) {
      path = join(Directory.current.path, filePath);
      print("➔ BANCO DE DADOS CRIADO NA RAIZ DO PROJETO: $path");
    } else {
      // Caso contrário (Emulador Android/iOS), usa o caminho oculto padrão
      final dbPath = await getDatabasesPath();
      path = join(dbPath, filePath);
    }

    // Abre o banco e define a versão. Se mudar a estrutura no futuro, aumente a versão.
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onConfigure: (db) async =>
          await db.execute('PRAGMA foreign_keys = ON;'),
    );
  }

  // Criação das tabelas
  Future<void> _createDB(Database db, int version) async {
    // 1. Tabela de Usuários
    await db.execute('''
      CREATE TABLE usuarios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        senha TEXT NOT NULL
      )
    ''');

    // 2. Tabela de Configurações Gerais (Chave-Valor)
    await db.execute('''
      CREATE TABLE app_settings (
        chave TEXT PRIMARY KEY,
        valor TEXT NOT NULL
      )
    ''');

    // 3. Tabela de Cabeçalho das Missões (Histórico de Tarefas)
    await db.execute('''
      CREATE TABLE missoes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        data TEXT NOT NULL
      )
    ''');

    // 4. Tabela de Itens das Tarefas
    await db.execute('''
      CREATE TABLE tarefa_itens (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        missao_id INTEGER NOT NULL,
        titulo TEXT NOT NULL,
        concluido INTEGER NOT NULL,
        FOREIGN KEY (missao_id) REFERENCES missoes (id) ON DELETE CASCADE
      )
    ''');

    // 5. TABELA DO DIÁRIO
    await db.execute('''
      CREATE TABLE diario (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        data TEXT NOT NULL,
        humor TEXT NOT NULL,
        palavraDia TEXT NOT NULL,
        texto TEXT NOT NULL
      )
    ''');
  }

  // =========================================================
  // CONFIGURAÇÕES
  // =========================================================

  Future<void> salvarConfiguracao(String chave, String valor) async {
    final db = await instance.database;

    await db.insert(
      'app_settings',
      {'chave': chave, 'valor': valor},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> buscarConfiguracao(String chave) async {
    final db = await instance.database;

    final maps = await db.query(
      'app_settings',
      columns: ['valor'],
      where: 'chave = ?',
      whereArgs: [chave],
    );

    if (maps.isNotEmpty) {
      return maps.first['valor'] as String;
    }

    return null;
  }

  // =========================================================
  // HISTÓRICO DE TAREFAS
  // =========================================================

  Future<void> inserirHistoricoTarefa(
    String data,
    List<Map<String, dynamic>> itens,
  ) async {
    final db = await instance.database;

    int listaId = await db.insert(
      'missoes',
      {'data': data},
    );

    for (var item in itens) {
      await db.insert('tarefa_itens', {
        'missao_id': listaId,
        'titulo': item['titulo'],
        'concluido': item['concluido'] ? 1 : 0,
      });
    }
  }

  Future<void> atualizarHistoricoTarefa(
    int listaId,
    List<Map<String, dynamic>> itens,
  ) async {
    final db = await instance.database;

    await db.delete(
      'tarefa_itens',
      where: 'missao_id = ?',
      whereArgs: [listaId],
    );

    for (var item in itens) {
      await db.insert('tarefa_itens', {
        'missao_id': listaId,
        'titulo': item['titulo'],
        'concluido': item['concluido'] ? 1 : 0,
      });
    }
  }

  Future<List<Map<String, dynamic>>> buscarHistoricoCompleto() async {
    final db = await instance.database;

    final List<Map<String, dynamic>> listasGerais =
        await db.query(
      'missoes',
      orderBy: 'id DESC',
    );

    List<Map<String, dynamic>> resultadoFinal = [];

    for (var lista in listasGerais) {
      int listaId = lista['id'] as int;

      final List<Map<String, dynamic>> itensGerais =
          await db.query(
        'tarefa_itens',
        where: 'missao_id = ?',
        whereArgs: [listaId],
      );

      List<Map<String, dynamic>> itensFormatados =
          itensGerais.map((item) {
        return {
          'titulo': item['titulo'],
          'concluido': item['concluido'] == 1,
        };
      }).toList();

      resultadoFinal.add({
        'id': listaId,
        'data': lista['data'],
        'itens': itensFormatados,
      });
    }

    return resultadoFinal;
  }

  // =========================================================
  // DIÁRIO
  // =========================================================

  Future<void> inserirDiario({
    required String data,
    required String humor,
    required String palavraDia,
    required String texto,
  }) async {
    final db = await instance.database;

    await db.insert(
      'diario',
      {
        'data': data,
        'humor': humor,
        'palavraDia': palavraDia,
        'texto': texto,
      },
    );
  }

  Future<List<DiarioModel>> buscarDiario() async {
    final db = await instance.database;

    final result = await db.query(
      'diario',
      orderBy: 'id DESC',
    );

    return result.map((json) {
      return DiarioModel(
        id: json['id'] as int,
        data: json['data'] as String,
        humor: json['humor'] as String,
        palavraDia: json['palavraDia'] as String,
        texto: json['texto'] as String,
      );
    }).toList();
  }

  // =========================================================
  // FECHAR BANCO
  // =========================================================

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
