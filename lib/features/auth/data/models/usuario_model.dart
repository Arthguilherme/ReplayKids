import '../../domain/entities/usuario_entity.dart';

class UsuarioModel extends UsuarioEntity {
  UsuarioModel({
    super.id,
    required super.nome,
    required super.email,
    required super.senha,
    super.telefone,
    super.cidade,
  });

  factory UsuarioModel.fromMap(Map<String, dynamic> map) {
    return UsuarioModel(
      id: map['id'] as int?,
      nome: map['nome'] as String,
      email: map['email'] as String,
      senha: map['senha'] as String,
      telefone: map['telefone'] as String?,
      cidade: map['cidade'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'email': email,
      'senha': senha,
      'telefone': telefone,
      'cidade': cidade,
    };
  }

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