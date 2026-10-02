import 'dart:io';
import 'package:flutter/material.dart';

class FotoWidget extends StatelessWidget {
  final String src;
  final BoxFit fit;

  const FotoWidget({
    super.key,
    required this.src,
    this.fit = BoxFit.cover,
  });

  bool get _isUrl => src.startsWith('http');

  @override
  Widget build(BuildContext context) {
    if (_isUrl) {
      return Image.network(
        src,
        fit: fit,
        width: double.infinity,
        errorBuilder: (_, __, ___) => const _Placeholder(),
        loadingBuilder: (_, child, progress) {
          if (progress == null) return child;
          return const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          );
        },
      );
    }

    return Image.file(
      File(src),
      fit: fit,
      width: double.infinity,
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFDDEBDF),
      alignment: Alignment.center,
      child: const Icon(Icons.image_outlined,
          color: Color(0xFF6FA17B), size: 36),
    );
  }
}