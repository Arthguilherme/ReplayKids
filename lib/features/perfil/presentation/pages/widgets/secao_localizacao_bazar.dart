import 'package:flutter/material.dart';
import 'package:replaykids/core/injector/injector.dart';
import 'package:replaykids/core/location/localizacao_service.dart';
import 'package:replaykids/core/theme/app_colors.dart';
import 'package:replaykids/core/widgets/labeled_field.dart';

class SecaoLocalizacaoBazar extends StatefulWidget {
  final TextEditingController enderecoController;
  final bool temLocalizacao;
  final void Function(double lat, double lng) onCapturada;

  const SecaoLocalizacaoBazar({
    super.key,
    required this.enderecoController,
    required this.temLocalizacao,
    required this.onCapturada,
  });

  @override
  State<SecaoLocalizacaoBazar> createState() => _SecaoLocalizacaoBazarState();
}

class _SecaoLocalizacaoBazarState extends State<SecaoLocalizacaoBazar> {
  bool _buscando = false;
  late bool _definida = widget.temLocalizacao;

  Future<void> _usarLocalAtual() async {
    setState(() => _buscando = true);
    final pos = await injector.get<LocalizacaoService>().posicaoPrecisa();
    if (!mounted) return;
    setState(() => _buscando = false);

    if (pos == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Não foi possível obter a localização. Verifique o GPS e a permissão.'),
        ),
      );
      return;
    }

    widget.onCapturada(pos.latitude, pos.longitude);
    setState(() => _definida = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Localização capturada. Toque em Salvar.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Localização do bazar',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.neutral800,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Fica visível para todos os usuários. Use só se o bazar funciona neste endereço.',
          style: TextStyle(fontSize: 11, color: AppColors.neutral500),
        ),
        const SizedBox(height: 12),
        LabeledField(
          label: 'Endereço',
          hint: 'Rua, número, bairro',
          icon: Icons.storefront_outlined,
          controller: widget.enderecoController,
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _buscando ? null : _usarLocalAtual,
            icon: _buscando
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.my_location_outlined, size: 18),
            label: const Text('Usar minha localização atual'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.c700,
              side: const BorderSide(color: AppColors.c300),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _definida
              ? 'Ponto no mapa definido ✓'
              : 'Toque quando estiver no bazar para marcar o ponto no mapa.',
          style: TextStyle(
            fontSize: 11,
            color: _definida ? AppColors.c600 : AppColors.neutral500,
          ),
        ),
      ],
    );
  }
}