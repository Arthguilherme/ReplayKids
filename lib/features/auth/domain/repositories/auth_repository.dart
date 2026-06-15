import '../entities/usuario_entity.dart';

abstract class AuthRepository {
  Future<UsuarioEntity> login(String email, String senha);
  Future<UsuarioEntity> cadastrar(UsuarioEntity usuario);
}