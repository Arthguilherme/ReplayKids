import '../entities/usuario_entity.dart';
import '../repositories/auth_repository.dart';

class FazerCadastroUsecase {
  final AuthRepository repository;

  FazerCadastroUsecase({required this.repository});

  Future<UsuarioEntity> call(UsuarioEntity usuario) async {
    if (usuario.nome.trim().isEmpty) {
      throw Exception('Nome é obrigatório');
    }

    if (usuario.email.trim().isEmpty) {
      throw Exception('E-mail é obrigatório');
    }

    if (usuario.senha.trim().length < 6) {
      throw Exception('Senha deve ter pelo menos 6 caracteres');
    }

    if (usuario.tipo == 'bazar' &&
         (usuario.nomeEstabelecimento ?? '').trim().isEmpty) {
      throw Exception('Informe o nome do estabelecimento');
    }
    
    return await repository.cadastrar(usuario);
  }
}