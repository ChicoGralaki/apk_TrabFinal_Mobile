import 'package:flutter/material.dart';

import '../services/giphy_service.dart';
import '../theme/app_theme.dart';

class GifView extends StatefulWidget {
  const GifView({
    super.key,
    this.url,
    this.query,
    this.height = 180,
    this.label = 'Hogwarts Explorer',
    this.fit = BoxFit.cover,
  });

  final String? url;
  final String? query;
  final double height;
  final String label;
  final BoxFit fit;

  @override
  State<GifView> createState() => _GifViewState();
}

class _GifViewState extends State<GifView> {
  Future<String?>? _future;

  @override
  void initState() {
    super.initState();
    _setFuture();
  }

  @override
  void didUpdateWidget(covariant GifView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url || oldWidget.query != widget.query) {
      _setFuture();
    }
  }

  void _setFuture() {
    _future = widget.url != null
        ? Future.value(widget.url)
        : giphyService.searchGif(widget.query ?? '');
  }

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(15),
    child: SizedBox(
      height: widget.height,
      width: double.infinity,
      child: FutureBuilder<String?>(
        future: _future,
        builder: (context, snapshot) {
          final url = snapshot.data;
          if (url != null && url.isNotEmpty) {
            return Image.network(
              url,
              fit: widget.fit,
              width: double.infinity,
              height: widget.height,
              frameBuilder: (context, child, frame, syncLoaded) =>
                  frame != null || syncLoaded
                  ? child
                  : Stack(
                      alignment: Alignment.center,
                      children: [
                        _fallback(),
                        const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.gold,
                          ),
                        ),
                      ],
                    ),
              errorBuilder: (context, error, stack) => _fallback(),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            final indicatorSize = widget.height < 60 ? 14.0 : 23.0;
            return Stack(
              alignment: Alignment.center,
              children: [
                _fallback(),
                SizedBox(
                  width: indicatorSize,
                  height: indicatorSize,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.gold,
                  ),
                ),
              ],
            );
          }
          return _fallback();
        },
      ),
    ),
  );

  Widget _fallback() => CustomPaint(
    foregroundPainter: _CastlePainter(),
    child: Container(
      width: double.infinity,
      height: widget.height,
      color: AppColors.primary,
      alignment: Alignment.bottomLeft,
      padding: const EdgeInsets.all(13),
      child: Text(
        widget.label.toUpperCase(),
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 9,
          letterSpacing: 1.3,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
  );
}

class _CastlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.gold.withValues(alpha: .82)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final center = size.width / 2;
    final base = size.height * .73;
    final path = Path()
      ..moveTo(center - size.width * .31, base)
      ..lineTo(center - size.width * .31, size.height * .39)
      ..lineTo(center - size.width * .25, size.height * .39)
      ..lineTo(center - size.width * .25, size.height * .25)
      ..lineTo(center - size.width * .19, size.height * .38)
      ..lineTo(center - size.width * .19, base)
      ..lineTo(center - size.width * .08, base)
      ..lineTo(center - size.width * .08, size.height * .48)
      ..lineTo(center, size.height * .28)
      ..lineTo(center + size.width * .08, size.height * .48)
      ..lineTo(center + size.width * .08, base)
      ..lineTo(center + size.width * .19, base)
      ..lineTo(center + size.width * .19, size.height * .38)
      ..lineTo(center + size.width * .25, size.height * .25)
      ..lineTo(center + size.width * .25, size.height * .39)
      ..lineTo(center + size.width * .31, size.height * .39)
      ..lineTo(center + size.width * .31, base)
      ..close();
    canvas.drawPath(path, paint);
    canvas.drawLine(
      Offset(center - size.width * .35, base),
      Offset(center + size.width * .35, base),
      paint,
    );
    final door = Rect.fromCenter(
      center: Offset(center, base - size.height * .06),
      width: size.width * .07,
      height: size.height * .13,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(door, const Radius.circular(12)),
      paint,
    );
    for (final dx in [-.27, -.21, .21, .27]) {
      canvas.drawLine(
        Offset(center + size.width * dx, size.height * .49),
        Offset(center + size.width * dx, size.height * .58),
        paint,
      );
    }
    canvas.drawCircle(
      Offset(center, size.height * .14),
      size.height * .025,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
