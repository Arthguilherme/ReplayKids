class ProfanityFilter {
  static const _palavroes = [
    'merda', 'porra', 'caralho', 'fodase', 'foda-se', 'foda',
    'viado', 'viadinho', 'buceta', 'cu', 'cuzao', 'cuzão',
    'putaria', 'puta', 'putas', 'putinha', 'vagabunda', 'vagabundo',
    'idiota', 'imbecil', 'retardado', 'retardada', 'corno', 'corna',
    'arrombado', 'arrombada', 'desgraça', 'desgraçado', 'desgraçada',
    'filho da puta', 'filha da puta', 'vai se fuder', 'vai tomar no',
    'sua mae', 'sua mãe', 'babaca', 'otario', 'otário', 'otaria',
    'piranha', 'cachorra', 'safado', 'safada', 'lixo', 'inutil',
    'inútil', 'burro', 'burra', 'fdp', 'vsf', 'pqp', 'krl',
  ];

  static bool contemPalavrао(String texto) {
    final textoNormalizado = _normalizar(texto);
    return _palavroes.any((p) => textoNormalizado.contains(_normalizar(p)));
  }

  static String filtrar(String texto) {
    String resultado = texto;
    for (final palavrao in _palavroes) {
      final regex = RegExp(
        _normalizar(palavrao),
        caseSensitive: false,
        unicode: true,
      );
      resultado = resultado.replaceAllMapped(regex, (match) {
        return '*' * match.group(0)!.length;
      });
    }
    return resultado;
  }

  static String _normalizar(String texto) {
    return texto
        .toLowerCase()
        .replaceAll('á', 'a').replaceAll('à', 'a').replaceAll('ã', 'a')
        .replaceAll('â', 'a').replaceAll('ä', 'a')
        .replaceAll('é', 'e').replaceAll('ê', 'e').replaceAll('ë', 'e')
        .replaceAll('í', 'i').replaceAll('î', 'i').replaceAll('ï', 'i')
        .replaceAll('ó', 'o').replaceAll('ô', 'o').replaceAll('õ', 'o')
        .replaceAll('ö', 'o').replaceAll('ú', 'u').replaceAll('û', 'u')
        .replaceAll('ü', 'u').replaceAll('ç', 'c').replaceAll('ñ', 'n');
  }
}