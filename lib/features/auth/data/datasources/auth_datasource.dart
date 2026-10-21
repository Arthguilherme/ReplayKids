import 'package:flutter/foundation.dart';
import 'package:replaykids/core/database/database_helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/usuario_model.dart';

abstract class AuthDatasource {
  Future<UsuarioModel> login(String email, String senha);
  Future<UsuarioModel> cadastrar(UsuarioModel usuario);
}

class AuthDatasourceMock implements AuthDatasource {
  final List<UsuarioModel> _usuarios = [
    UsuarioModel(
      id: 1,
      nome: 'Ana Oliveira',
      email: 'ana@email.com',
      senha: '12345678',
      telefone: '(41) 99999-0000',
      cidade: 'Matinhos, PR',
    ),
  ];

  @override
  Future<UsuarioModel> login(String email, String senha) async {
    await Future.delayed(const Duration(seconds: 1));
    final usuario = _usuarios.firstWhere(
      (u) => u.email == email && u.senha == senha,
      orElse: () => throw Exception('Email ou senha incorretos'),
    );
    return usuario;
  }

  @override
  Future<UsuarioModel> cadastrar(UsuarioModel usuario) async {
    await Future.delayed(const Duration(seconds: 1));
    final jaExiste = _usuarios.any((u) => u.email == usuario.email);
    if (jaExiste) throw Exception('Email já cadastrado');
    final novoUsuario = UsuarioModel(
      id: _usuarios.length + 1,
      nome: usuario.nome,
      email: usuario.email,
      senha: usuario.senha,
      telefone: usuario.telefone,
      cidade: usuario.cidade,
    );
    _usuarios.add(novoUsuario);
    return novoUsuario;
  }
}

class AuthDatasourceSqlite implements AuthDatasource {
  @override
  Future<UsuarioModel> login(String email, String senha) async {
    final db = await DatabaseHelper.database;
    final resultado = await db.query(
      'usuarios',
      where: 'email = ? AND senha = ?',
      whereArgs: [email, senha],
    );
    if (resultado.isEmpty) throw Exception('Email ou senha incorretos');
    return UsuarioModel.fromMap(resultado.first);
  }

  @override
  Future<UsuarioModel> cadastrar(UsuarioModel usuario) async {
    final db = await DatabaseHelper.database;
    final existente = await db.query(
      'usuarios',
      where: 'email = ?',
      whereArgs: [usuario.email],
    );
    if (existente.isNotEmpty) throw Exception('Email já cadastrado');
    final id = await db.insert('usuarios', usuario.toMap());
    return UsuarioModel(
      id: id,
      nome: usuario.nome,
      email: usuario.email,
      senha: usuario.senha,
      telefone: usuario.telefone,
      cidade: usuario.cidade,
    );
  }
}

class AuthDatasourceSupabase implements AuthDatasource {
  final _supabase = Supabase.instance.client;

  @override
  Future<UsuarioModel> login(String email, String senha) async {
    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: senha,
    );

    if (response.user == null) {
      throw Exception('Email ou senha incorretos');
    }

    final perfil = await _supabase
        .from('perfis')
        .select()
        .eq('id', response.user!.id)
        .single();

    return UsuarioModel(
      id: null,
      nome: perfil['nome'] as String,
      email: response.user!.email!,
      senha: '',
      telefone: perfil['telefone'] as String?,
      cidade: perfil['cidade'] as String?,
    );
  }

  @override
  Future<UsuarioModel> cadastrar(UsuarioModel usuario) async {
    try {
      final response = await _supabase.auth.signUp(
        email: usuario.email,
        password: usuario.senha,
        data: {
          'nome': usuario.nome,
          'telefone': usuario.telefone,
          'cidade': usuario.cidade,
          'tipo': usuario.tipo,
          'nome_estabelecimento': usuario.nomeEstabelecimento,
        },
      );

      debugPrint('SignUp response: ${response.user}');

      if (response.user == null) {
        throw Exception('Erro ao criar conta');
      }

      return UsuarioModel(
        id: null,
        nome: usuario.nome,
        email: usuario.email,
        senha: '',
        telefone: usuario.telefone,
        cidade: usuario.cidade,
      );
    } catch (e) {
      debugPrint('Erro no cadastro: $e');
      rethrow;
    }
  }
}