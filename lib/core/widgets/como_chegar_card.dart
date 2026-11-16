import 'package:flutter/material.dart';
import 'package:replaykids/core/theme/app_colors.dart';
import 'package:replaykids/core/utils/mapas.dart';

class ComoChegarCard extends StatelessWidget {
  final double? lat;
  final double? lng;
  final String? endereco;
  final String? cidade;

  const ComoChegarCard({
    super.key,
    this.lat,
    this.lng,
    this.endereco,
    this.cidade,
  });

  bool get _temEndereco => (endereco ?? '').trim().isNotEmpty;
  bool get _temLocal => (lat != null && lng != null) || _temEndereco;

  Future<void> _abrir(BuildContext context) async {
    final ok = await Mapas.abrir(
      lat: lat,
      lng: lng,
      endereco: endereco,
      cidade: cidade,
    );
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir o mapa')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_temLocal) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        children: [
          if (_temEndereco)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.place_outlined,
                    size: 14, color: AppColors.neutral600),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    endereco!.trim(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.neutral600),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => _abrir(context),
            icon: const Icon(Icons.directions_outlined, size: 18),
            label: const Text('Como chegar'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.c700,
              backgroundColor: Colors.white,
              side: const BorderSide(color: AppColors.c300),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}