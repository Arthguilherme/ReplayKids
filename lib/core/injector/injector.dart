import 'package:auto_injector/auto_injector.dart';
import '../../features/auth/data/datasources/auth_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/fazer_login_usecase.dart';
import '../../features/auth/presentation/controllers/login_controller.dart';

final injector = AutoInjector();

void setupInjector() {
  // Datasource
  injector.addSingleton<AuthDatasource>(AuthDatasourceMock.new);

  // Repository
  injector.addSingleton<AuthRepository>(AuthRepositoryImpl.new);

  // UseCase
  injector.addSingleton(FazerLoginUsecase.new);

  // Controller
  injector.add(LoginController.new);

  injector.commit();
}