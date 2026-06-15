import '../../domain/entities/usuario_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_datasource.dart';
import '../models/usuario_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDatasource datasource;

  AuthRepositoryImpl({required this.datasource});

  @override
  Future<UsuarioEntity> login(String email, String senha) async {
    return await datasource.login(email, senha);
  }

  @override
  Future<UsuarioEntity> cadastrar(UsuarioEntity usuario) async {
    final model = UsuarioModel(
      id: usuario.id,
      nome: usuario.nome,
      email: usuario.email,
      senha: usuario.senha,
      telefone: usuario.telefone,
      cidade: usuario.cidade,
    );

    return await datasource.cadastrar(model);
  }
}