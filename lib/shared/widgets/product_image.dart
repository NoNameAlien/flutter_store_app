import 'dart:io';

import 'package:flutter/material.dart';

class ProductImage extends StatelessWidget {
  const ProductImage({
    super.key,
    required this.path,
    this.size = 72,
    this.expand = false,
  });

  final String? path;
  final double size;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final image = path == null
        ? ColoredBox(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Icon(
              Icons.image_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
          )
        : Image.file(
            File(path!),
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => ColoredBox(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(
                Icons.image_not_supported_outlined,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          );
    final thumbnail = ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: expand
          ? SizedBox.expand(child: image)
          : SizedBox(width: size, height: size, child: image),
    );
    if (path == null) return thumbnail;
    return GestureDetector(
      onTap: () => _showPreview(context),
      child: thumbnail,
    );
  }

  Future<void> _showPreview(BuildContext context) => showDialog<void>(
    context: context,
    barrierColor: Colors.black,
    builder: (dialogContext) => Dialog.fullscreen(
      backgroundColor: Colors.black,
      child: Stack(
        children: [
          Center(
            child: InteractiveViewer(
              minScale: 0.8,
              maxScale: 4,
              child: Image.file(
                File(path!),
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.image_not_supported_outlined,
                  color: Colors.white,
                  size: 56,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: IconButton.filledTonal(
                tooltip: 'Закрыть',
                onPressed: () => Navigator.of(dialogContext).pop(),
                icon: const Icon(Icons.close),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
