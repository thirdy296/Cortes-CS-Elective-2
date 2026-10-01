import 'package:flutter/material.dart';

class AppImage extends StatelessWidget {
  final String urlOrAsset;
  final double? width;
  final double? height;
  final BoxFit fit;

  const AppImage({
    super.key,
    required this.urlOrAsset,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (urlOrAsset.startsWith('assets/')) {
      return Image.asset(
        urlOrAsset,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, _, _) => _placeholder(colorScheme),
      );
    }

    return Image.network(
      urlOrAsset,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          width: width,
          height: height,
          color: colorScheme.surfaceContainerHighest,
          child: const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
      errorBuilder: (_, _, _) => _placeholder(colorScheme),
    );
  }

  Widget _placeholder(ColorScheme colorScheme) {
    return Container(
      width: width,
      height: height,
      color: colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.sports_tennis,
        size: (width != null && width! < 60) ? 24 : 48,
        color: colorScheme.primary.withValues(alpha: 0.5),
      ),
    );
  }
}
