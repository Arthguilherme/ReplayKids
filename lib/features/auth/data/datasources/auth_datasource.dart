import '../models/usuario_model.dart';

abstract class AuthDatasource {
  Future<UsuarioModel> login(String email, String senha);
  Future<UsuarioModel> cadastrar(UsuarioModel usuario);
}

class AuthDatasourceMock implements AuthDatasource {
  // "Banco de dados" fake em memória
  final List<UsuarioModel> _usuarios = [
    const UsuarioModel(
      id: 1,
      nome: 'Guilherme Arthur',
      email: 'Arth@email.com',
      senha: 'senha1234',
      telefone: '(41) 99999-0000',
      cidade: 'Paranaguá, PR',
    ),
  ];

  @override
  Future<UsuarioModel> login(String email, String senha) async {
    // Simula delay de rede
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
    if (jaExiste) {
      throw Exception('Email já cadastrado');
    }

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