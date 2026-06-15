import 'package:signals_flutter/signals_flutter.dart';
import '../../domain/entities/usuario_entity.dart';
import '../../domain/usecases/fazer_login_usecase.dart';

enum LoginStatus { inicial, carregando, sucesso, erro }

class LoginController {
  final FazerLoginUsecase fazerLoginUsecase;

  LoginController({required this.fazerLoginUsecase});

  // Signals: estado observável pela UI
  final status = signal(LoginStatus.inicial);
  final mensagemErro = signal<String?>(null);
  final usuarioLogado = signal<UsuarioEntity?>(null);

  Future<void> login(String email, String senha) async {
    status.value = LoginStatus.carregando;
    mensagemErro.value = null;

    try {
      final usuario = await fazerLoginUsecase.call(email, senha);
      usuarioLogado.value = usuario;
      status.value = LoginStatus.sucesso;
    } catch (e) {
      mensagemErro.value = e.toString().replaceFirst('Exception: ', '');
      status.value = LoginStatus.erro;
    }
  }
}