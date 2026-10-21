class UsuarioEntity {
  final int? id;
  final String nome;
  final String email;
  final String senha;
  final String? telefone;
  final String? cidade;
  final String tipo;
  final String? nomeEstabelecimento;

  const UsuarioEntity({
    this.id,
    required this.nome,
    required this.email,
    required this.senha,
    this.telefone,
    this.cidade,
    this.tipo = 'pessoa_fisica',
    this.nomeEstabelecimento,
  });
}