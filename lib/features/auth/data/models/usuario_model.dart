import '../../domain/entities/usuario_entity.dart';

class UsuarioModel extends UsuarioEntity {
  const UsuarioModel({
    super.id,
    required super.nome,
    required super.email,
    required super.senha,
    super.telefone,
    super.cidade,
  });

  // JSON → UsuarioModel
  factory UsuarioModel.fromJson(Map<String, dynamic> json) {
    return UsuarioModel(
      id: json['id'],
      nome: json['nome'],
      email: json['email'],
      senha: json['senha'] ?? '',
      telefone: json['telefone'],
      cidade: json['cidade'],
    );
  }

  // UsuarioModel → JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'senha': senha,
      'telefone': telefone,
      'cidade': cidade,
    };
  }
}