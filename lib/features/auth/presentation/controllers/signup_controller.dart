import 'package:flutter/foundation.dart';
import 'package:replaykids/features/auth/domain/entities/usuario_entity.dart';
import 'package:replaykids/features/auth/domain/usecases/fazer_cadastro_usecase.dart';

enum SignupStatus { inicial, carregando, sucesso, erro }

class SignupController {
  final FazerCadastroUsecase fazerCadastroUsecase;

  SignupController({required this.fazerCadastroUsecase});

  SignupStatus status = SignupStatus.inicial;
  String? mensagemErro;

  Future<void> cadastrar({
    required String nome,
    required String email,
    required String senha,
    required String telefone,
    required String cidade,
    required String tipo,
    String? nomeEstabelecimento,
  }) async {
    status = SignupStatus.carregando;
    mensagemErro = null;

    try {
      await fazerCadastroUsecase(
        UsuarioEntity(
          nome: nome,
          email: email,
          senha: senha,
          telefone: telefone,
          cidade: cidade,
          tipo: tipo,
          nomeEstabelecimento: nomeEstabelecimento,
        ),
      );
      status = SignupStatus.sucesso;
    } catch (e) {
      mensagemErro = e.toString().replaceFirst('Exception: ', '');
      status = SignupStatus.erro;
    }
  }
}