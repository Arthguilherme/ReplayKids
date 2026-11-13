import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class Municipio {
  final String nome; 
  final double lat;
  final double lng;
  const Municipio(this.nome, this.lat, this.lng);
}

class DeteccaoMunicipio {
  final bool localizou;     
  final String? municipio;  
  const DeteccaoMunicipio({required this.localizou, this.municipio});
}

class LocalizacaoService {

  static const municipios = [
    Municipio('Paranaguá, PR', -25.5205, -48.5095),
    Municipio('Pontal do Paraná, PR', -25.6728, -48.5111),
    Municipio('Matinhos, PR', -25.8175, -48.5425),
    Municipio('Guaratuba, PR', -25.8825, -48.5750),
    Municipio('Antonina, PR', -25.4286, -48.7119),
    Municipio('Morretes, PR', -25.4772, -48.8344),
    Municipio('Guaraqueçaba, PR', -25.3069, -48.3203),
  ];

  static const double raioMaxKm = 40;
  static const _validade = Duration(minutes: 10);

  DeteccaoMunicipio? _cache;
  DateTime? _cacheEm;

  Future<DeteccaoMunicipio> detectar() async {
   
    if (_cache != null &&
        _cacheEm != null &&
        DateTime.now().difference(_cacheEm!) < _validade) {
      return _cache!;
    }

    final resultado = await _lerLocalizacao();
    if (resultado.localizou) {
      _cache = resultado;
      _cacheEm = DateTime.now();
    }
    return resultado;
  }

  Future<DeteccaoMunicipio> _lerLocalizacao() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        return const DeteccaoMunicipio(localizou: false);
      }

      var permissao = await Geolocator.checkPermission();

      if (permissao == LocationPermission.denied) {
        permissao = await Geolocator.requestPermission();
      }
      
      if (permissao == LocationPermission.denied ||
          permissao == LocationPermission.deniedForever) {
        return const DeteccaoMunicipio(localizou: false);
      }

      final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 8),
        );
      

      final municipio = _maisProximo(pos.latitude, pos.longitude);
      debugPrint('Município detectado: $municipio');
      return DeteccaoMunicipio(localizou: true, municipio: municipio);
    } catch (e) {
      debugPrint('Erro ao obter localização: $e');
      return const DeteccaoMunicipio(localizou: false);
    }
  }

  String? _maisProximo(double lat, double lng) {
    Municipio? melhor;
    var menor = double.infinity;
    for (final m in municipios) {
      final km = Geolocator.distanceBetween(lat, lng, m.lat, m.lng) / 1000;
      if (km < menor) {
        menor = km;
        melhor = m;
      }
    }
    return menor <= raioMaxKm ? melhor?.nome : null;
  }
}