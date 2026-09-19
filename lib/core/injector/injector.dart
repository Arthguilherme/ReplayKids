import 'package:auto_injector/auto_injector.dart';
import '../../features/auth/data/datasources/auth_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/fazer_cadastro_usecase.dart';
import '../../features/auth/domain/usecases/fazer_login_usecase.dart';
import '../../features/auth/presentation/controllers/login_controller.dart';
import '../../features/anuncio/data/repositories/anuncio_repository_impl.dart';
import '../../features/anuncio/domain/repositories/anuncio_repository.dart';
import '../../features/anuncio/presentation/controllers/publish_controller.dart';
import '../../features/anuncio/data/datasources/anuncio_datasource.dart';
import '../../features/auth/presentation/controllers/signup_controller.dart';
import '../../features/perfil/data/datasources/perfil_datasource.dart';
import '../../features/favoritos/data/datasources/favoritos_datasource.dart';

final injector = AutoInjector();
bool _initialized = false;

void setupInjector() {
  if (_initialized) return;
  _initialized = true;

  injector.addSingleton<AuthDatasource>(AuthDatasourceSupabase.new);
  injector.addSingleton<AuthRepository>(AuthRepositoryImpl.new);
  injector.addSingleton(FazerLoginUsecase.new);
  injector.addSingleton(FazerCadastroUsecase.new);
  injector.add(LoginController.new);

  injector.addSingleton<AnuncioRepository>(AnuncioRepositoryImpl.new);
  injector.addSingleton(PublishController.new);
  injector.addSingleton<AnuncioDatasource>(AnuncioDatasourceSupabase.new);

  injector.add(SignupController.new);

  injector.addSingleton(PerfilDatasource.new);
  injector.addSingleton(FavoritosDatasource.new);
  
  injector.commit();
}

