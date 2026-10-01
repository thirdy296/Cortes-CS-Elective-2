import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TransparentImage extends StatefulWidget {
  final String assetPath;
  final double? width;
  final double? height;
  final BoxFit fit;

  const TransparentImage({
    super.key,
    required this.assetPath,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
  });

  @override
  State<TransparentImage> createState() => _TransparentImageState();
}

class _TransparentImageState extends State<TransparentImage> {
  ui.Image? _processedImage;
  bool _loading = true;
  bool _failed = false;

  // Cache shared across all instances
  static final Map<String, ui.Image?> _cache = {};

  @override
  void initState() {
    super.initState();
    _process();
  }

  @override
  void didUpdateWidget(TransparentImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.assetPath != widget.assetPath) {
      setState(() {
        _loading = true;
        _failed = false;
        _processedImage = null;
      });
      _process();
    }
  }

  Future<void> _process() async {
    final key = widget.assetPath;

    // Already cached
    if (_cache.containsKey(key)) {
      if (mounted) {
        setState(() {
          _processedImage = _cache[key];
          _loading = false;
          _failed = _cache[key] == null;
        });
      }
      return;
    }

    try {
      // Load raw bytes
      final ByteData data = await rootBundle.load(key);
      final Uint8List bytes = data.buffer.asUint8List();

      // Decode image
      final ui.Codec codec = await ui.instantiateImageCodec(bytes);
      final ui.FrameInfo frame = await codec.getNextFrame();
      final ui.Image srcImage = frame.image;

      // Extract RGBA pixels
      final ByteData? byteData =
          await srcImage.toByteData(format: ui.ImageByteFormat.rawRgba);

      if (byteData == null) {
        // toByteData not supported (some Flutter Web configs) — use original
        _cache[key] = null;
        if (mounted) setState(() { _loading = false; _failed = true; });
        return;
      }

      final Uint8List pixels = byteData.buffer.asUint8List();
      final int w = srcImage.width;
      final int h = srcImage.height;

      // --- Flood-fill from all 4 edges to detect background pixels ---
      // We mark pixels that are "background-like" (near-white or near-light)
      // starting from the image border and flood inward.
      final List<bool> visited = List<bool>.filled(w * h, false);
      final List<bool> isBackground = List<bool>.filled(w * h, false);

      bool isLightPixel(int idx) {
        final int r = pixels[idx];
        final int g = pixels[idx + 1];
        final int b = pixels[idx + 2];
        // Count as light/background if it's near-white or near-light-gray
        return r > 200 && g > 200 && b > 200;
      }

      // BFS from border
      final List<int> queue = [];

      void enqueue(int x, int y) {
        if (x < 0 || y < 0 || x >= w || y >= h) return;
        final int idx = y * w + x;
        if (visited[idx]) return;
        final int pxIdx = idx * 4;
        if (!isLightPixel(pxIdx)) return;
        visited[idx] = true;
        isBackground[idx] = true;
        queue.add(idx);
      }

      // Seed the border
      for (int x = 0; x < w; x++) {
        enqueue(x, 0);
        enqueue(x, h - 1);
      }
      for (int y = 0; y < h; y++) {
        enqueue(0, y);
        enqueue(w - 1, y);
      }

      // Flood
      int qi = 0;
      while (qi < queue.length) {
        final int idx = queue[qi++];
        final int x = idx % w;
        final int y = idx ~/ w;
        enqueue(x + 1, y);
        enqueue(x - 1, y);
        enqueue(x, y + 1);
        enqueue(x, y - 1);
      }

      // Apply transparency: background → transparent, near-edge → feathered
      for (int i = 0; i < w * h; i++) {
        if (!isBackground[i]) continue;
        final int pxIdx = i * 4;
        final int r = pixels[pxIdx];
        final int g = pixels[pxIdx + 1];
        final int b = pixels[pxIdx + 2];
        final double brightness = (r + g + b) / 3.0;
        // Fully transparent if very bright, feather near edges
        if (brightness > 230) {
          pixels[pxIdx + 3] = 0;
        } else {
          final double t = (brightness - 200) / 30.0;
          pixels[pxIdx + 3] = ((1.0 - t.clamp(0.0, 1.0)) * 255).toInt();
        }
      }

      // Re-encode
      final Completer<ui.Image> completer = Completer();
      ui.decodeImageFromPixels(
        pixels,
        w,
        h,
        ui.PixelFormat.rgba8888,
        (ui.Image result) => completer.complete(result),
      );
      final ui.Image result = await completer.future;

      _cache[key] = result;
      if (mounted) {
        setState(() {
          _processedImage = result;
          _loading = false;
        });
      }
    } catch (_) {
      _cache[key] = null;
      if (mounted) setState(() { _loading = false; _failed = true; });
    }
  }

  @override
  Widget build(BuildContext context) {
    // While processing, show original (will swap when done)
    if (_loading) {
      return Image.asset(
        widget.assetPath,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
      );
    }

    // If processing failed, fall back to original image
    if (_failed || _processedImage == null) {
      return Image.asset(
        widget.assetPath,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
      );
    }

    return RawImage(
      image: _processedImage,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
    );
  }
}
