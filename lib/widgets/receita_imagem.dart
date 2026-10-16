import 'package:flutter/material.dart';

class ReceitaImagem extends StatelessWidget {
  final String url;
  final double tamanho;

  const ReceitaImagem({
    super.key,
    required this.url,
    this.tamanho = 180,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: tamanho,
        height: tamanho,
        color: Theme.of(context)
            .colorScheme.surfaceContainerHighest,
        child: url.trim().isEmpty
            ? const Icon(Icons.restaurant, size: 40)
            : Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.restaurant, size: 40);
                },
              ),
      ),
    );
  }
}
