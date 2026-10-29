class Validators {
  static final _emailRegex =
      RegExp(r'^[\w.+-]+@([\w-]+\.)+[a-zA-Z]{2,}$');

  static String? email(String? valor) {
    final v = valor?.trim() ?? '';
    if (v.isEmpty) return 'Informe seu e-mail';
    if (!_emailRegex.hasMatch(v)) return 'E-mail inválido';
    return null;
  }

  static String? senha(String? valor) {
    final v = valor ?? '';
    if (v.length < 8) return 'Mínimo de 8 caracteres';
    if (!v.contains(RegExp(r'[A-Za-z]'))) return 'Inclua ao menos uma letra';
    if (!v.contains(RegExp(r'[0-9]'))) return 'Inclua ao menos um número';
    return null;
  }
}