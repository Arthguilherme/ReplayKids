import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

class Mapas {
  static Future<bool> abrir({
    double? lat,
    double? lng,
    String? endereco,
    String? cidade,
  }) async {
    final String consulta;
    if (lat != null && lng != null) {
      consulta = '$lat,$lng';
    } else if ((endereco ?? '').trim().isNotEmpty) {
      consulta = [endereco, cidade]
          .where((e) => (e ?? '').trim().isNotEmpty)
          .join(', ');
    } else {
      return false;
    }

    final uri = Uri.https('www.google.com', '/maps/search/', {
      'api': '1',
      'query': consulta,
    });

    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Erro ao abrir mapa: $e');
      return false;
    }
  }
}