import '../entities/usuario_entity.dart';
import '../repositories/auth_repository.dart';

class FazerLoginUsecase {
  final AuthRepository repository;

  FazerLoginUsecase({required this.repository});

  Future<UsuarioEntity> call(String email, String senha) async {
    if (email.isEmpty || senha.isEmpty) {
      throw Exception('Email e senha são obrigatórios');
    }

    if (!email.contains('@')) {
      throw Exception('Email inválido');
    }

    return await repository.login(email, senha);
  }
}