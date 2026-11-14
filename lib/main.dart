import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(const [
    DeviceOrientation.portraitUp,
  ]);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyAn0lTS0y_seDTOQv89Ni5AE2VKFVqmFdI',
      appId: '1:861957149630:android:83cd8aa742e117c9971fef',
      messagingSenderId: '861957149630',
      projectId: 'tora-card-game',
      storageBucket: 'tora-card-game.firebasestorage.app',
    ),
  );
  runApp(const ToraApp());
}

const Color _gold = Color(0xFFD6B15C);
const Color _black = Color(0xFF090B10);
const Color _panel = Color(0xFF171A22);
const List<String> _ranks = ['2','3','4','5','6','7','8','9','10','J','Q','K','A'];
const List<String> _suits = ['♠','♥','♦','♣'];

class ToraTheme {
  final String name;
  final Color background, panel, accent, table, cardTop, cardBottom, silver;
  final int pattern;
  const ToraTheme(this.name, this.background, this.panel, this.accent, this.table, this.cardTop, this.cardBottom, this.silver, this.pattern);
}
const List<ToraTheme> _themes = [
  ToraTheme('Royal Black Gold', Color(0xFF08090D), Color(0xFF17130B), Color(0xFFE0BC68), Color(0xFF111216), Color(0xFF302719), Color(0xFF08090D), Color(0xFFFFE6A6), 0),
  ToraTheme('Royal Green Gold', Color(0xFF061710), Color(0xFF10271D), Color(0xFFE0BC68), Color(0xFF0D4932), Color(0xFF1C5139), Color(0xFF062318), Color(0xFFFFE6A6), 1),
  ToraTheme('Royal Red Gold', Color(0xFF1A080D), Color(0xFF32121A), Color(0xFFE0BC68), Color(0xFF641827), Color(0xFF762638), Color(0xFF260A12), Color(0xFFFFE6A6), 2),
  ToraTheme('Royal Blue Gold', Color(0xFF071326), Color(0xFF12233D), Color(0xFFE0BC68), Color(0xFF123D70), Color(0xFF244D79), Color(0xFF091A31), Color(0xFFFFE6A6), 3),
  ToraTheme('Royal White Gold', Color(0xFF17212B), Color(0xFF263746), Color(0xFFD2A84F), Color(0xFFE8DFC9), Color(0xFFF8F0DD), Color(0xFFBDB092), Color(0xFF80612B), 4),
];

class _CardFacePatternPainter extends CustomPainter {
  final Color color;
  final int style;
  const _CardFacePatternPainter(this.color, this.style);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final gold = Paint()..color = color.withOpacity(.48)..style = PaintingStyle.stroke..strokeWidth = 1.05;
    final glow = Paint()..color = const Color(0xFFFFE3A0).withOpacity(.22)..style = PaintingStyle.stroke..strokeWidth = .65;
    final center = Offset(size.width / 2, size.height / 2);
    final frame = rect.deflate(4);
    canvas.drawRRect(RRect.fromRectAndRadius(frame, const Radius.circular(5)), gold);
    canvas.drawRRect(RRect.fromRectAndRadius(frame.deflate(3), const Radius.circular(4)), glow);

    if (style == 0) {
      for (int i = 0; i < 4; i++) {
        final x = i.isEven ? 8.0 : size.width - 8;
        final y = i < 2 ? 9.0 : size.height - 9;
        final path = Path()..moveTo(x, y + 7)..lineTo(x, y)..lineTo(x + (i.isEven ? 7 : -7), y);
        canvas.drawPath(path, gold);
      }
      canvas.drawCircle(center, size.width * .20, gold);
      canvas.drawCircle(center, size.width * .15, glow);
      canvas.drawPath(Path()..moveTo(center.dx, center.dy-size.width*.12)..lineTo(center.dx+size.width*.12,center.dy)..lineTo(center.dx,center.dy+size.width*.12)..lineTo(center.dx-size.width*.12,center.dy)..close(), gold);
    } else if (style == 1) {
      for (double y = 8; y < size.height - 5; y += 9) {
        canvas.drawLine(Offset(7, y), Offset(size.width - 7, y), glow);
      }
      for (double x = 8; x < size.width - 5; x += 9) {
        canvas.drawLine(Offset(x, 7), Offset(size.width - x, size.height - 7), gold);
      }
      canvas.drawCircle(center, size.width * .18, gold);
    } else if (style == 2) {
      for (int i = 0; i < 8; i++) {
        final a = i * pi / 4;
        final p = Path()
          ..moveTo(center.dx + cos(a) * size.width * .10, center.dy + sin(a) * size.width * .10)
          ..lineTo(center.dx + cos(a + .22) * size.width * .31, center.dy + sin(a + .22) * size.width * .31)
          ..lineTo(center.dx + cos(a - .22) * size.width * .31, center.dy + sin(a - .22) * size.width * .31)
          ..close();
        canvas.drawPath(p, gold);
      }
      canvas.drawCircle(center, size.width * .12, glow);
    } else if (style == 3) {
      for (int i = 0; i < 5; i++) {
        final rr = frame.deflate(i * 4.0);
        canvas.drawRRect(RRect.fromRectAndRadius(rr, Radius.circular(3.0 + i)), i.isEven ? gold : glow);
      }
      canvas.drawLine(Offset(8, center.dy), Offset(size.width - 8, center.dy), glow);
    } else {
      final path = Path();
      for (int i = 0; i < 12; i++) {
        final a = i * pi / 6;
        final radius = i.isEven ? size.width * .27 : size.width * .13;
        final point = Offset(center.dx + cos(a) * radius, center.dy + sin(a) * radius);
        if (i == 0) { path.moveTo(point.dx, point.dy); } else { path.lineTo(point.dx, point.dy); }
      }
      path.close();
      canvas.drawPath(path, gold);
      canvas.drawCircle(center, size.width * .08, glow);
    }
  }

  @override
  bool shouldRepaint(covariant _CardFacePatternPainter old) => old.color != color || old.style != style;
}

class _CardPipsPainter extends CustomPainter {
  final String rank;
  final String suit;
  final Color ink;
  final Color gold;
  const _CardPipsPainter(this.rank, this.suit, this.ink, this.gold);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final count = int.tryParse(rank) ?? 0;
    final symbol = suit;
    final isAce = rank == 'A';
    final positions = <Offset>[];
    if (isAce) {
      positions.add(const Offset(.5, .5));
    } else {
      final rows = switch (count) {
        2 => [.30, .70],
        3 => [.22, .50, .78],
        4 => [.30, .70],
        5 => [.22, .50, .78],
        6 => [.22, .50, .78],
        7 => [.22, .50, .78],
        8 => [.16, .39, .61, .84],
        9 => [.16, .39, .61, .84],
        10 => [.13, .31, .50, .69, .87],
        _ => [.50],
      };
      for (final y in rows) {
        if (count == 2 || count == 3) {
          positions.add(Offset(.5, y));
        } else {
          positions.add(Offset(.32, y));
          positions.add(Offset(.68, y));
        }
      }
      if (count == 5 || count == 7 || count == 9) {
        positions.add(const Offset(.5, .5));
      }
    }
    final pipSize = isAce ? w * .48 : (count >= 9 ? w * .18 : w * .22);
    for (int i = 0; i < positions.length; i++) {
      final p = positions[i];
      final y = p.dy * h;
      final x = p.dx * w;
      final flip = i.isOdd && !isAce;
      canvas.save();
      if (flip) {
        canvas.translate(x, y);
        canvas.rotate(pi);
        canvas.translate(-x, -y);
      }
      final tp = TextPainter(
        text: TextSpan(text: symbol, style: TextStyle(
          color: ink, fontSize: pipSize, fontWeight: FontWeight.w900,
          height: 1, shadows: [Shadow(color: gold.withOpacity(.32), blurRadius: 2)],
        )),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x - tp.width / 2, y - tp.height / 2));
      canvas.restore();
    }
    if (isAce) {
      final center = Offset(w / 2, h / 2);
      final ring = Paint()..color = gold.withOpacity(.8)..style = PaintingStyle.stroke..strokeWidth = 1.2;
      canvas.drawCircle(center, w * .31, ring);
      canvas.drawCircle(center, w * .36, ring..color = gold.withOpacity(.35)..strokeWidth = .7);
    }
  }

  @override
  bool shouldRepaint(covariant _CardPipsPainter old) =>
      old.rank != rank || old.suit != suit || old.ink != ink || old.gold != gold;
}

class _BackPatternPainter extends CustomPainter {
  final Color color;
  final int style;
  const _BackPatternPainter(this.color, this.style);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = Offset(size.width / 2, size.height / 2);
    final line = Paint()..color = color.withOpacity(.92)..style = PaintingStyle.stroke..strokeWidth = 1.15;
    final highlight = Paint()..color = const Color(0xFFFFE7AC).withOpacity(.55)..style = PaintingStyle.stroke..strokeWidth = .7;
    canvas.drawRRect(RRect.fromRectAndRadius(rect.deflate(2), const Radius.circular(5)), line);
    canvas.drawRRect(RRect.fromRectAndRadius(rect.deflate(6), const Radius.circular(4)), highlight);

    if (style == 0) {
      for (int i = 0; i < 5; i++) {
        canvas.drawRRect(RRect.fromRectAndRadius(rect.deflate(5 + i * 4), Radius.circular(4.0 + i)), i.isEven ? line : highlight);
      }
      canvas.drawCircle(center, size.width * .23, line);
      canvas.drawCircle(center, size.width * .17, highlight);
    } else if (style == 1) {
      for (int i = -4; i <= 4; i++) {
        final dx = i * size.width * .13;
        canvas.drawLine(Offset(center.dx + dx, 4), Offset(center.dx - dx, size.height - 4), line);
        canvas.drawLine(Offset(4, center.dy + dx), Offset(size.width - 4, center.dy - dx), highlight);
      }
    } else if (style == 2) {
      for (int i = 0; i < 12; i++) {
        final a = i * pi / 6;
        final path = Path()
          ..moveTo(center.dx, center.dy)
          ..lineTo(center.dx + cos(a) * size.width * .46, center.dy + sin(a) * size.width * .46);
        canvas.drawPath(path, line);
      }
      canvas.drawCircle(center, size.width * .29, highlight);
      canvas.drawCircle(center, size.width * .20, line);
    } else if (style == 3) {
      for (int i = 0; i < 4; i++) {
        final inset = 8.0 + i * 7;
        final p = Path()
          ..moveTo(center.dx, inset)
          ..lineTo(size.width - inset, center.dy)
          ..lineTo(center.dx, size.height - inset)
          ..lineTo(inset, center.dy)
          ..close();
        canvas.drawPath(p, i.isEven ? line : highlight);
      }
    } else {
      for (int i = 0; i < 8; i++) {
        final a = i * pi / 4;
        final path = Path()
          ..moveTo(center.dx + cos(a) * size.width * .08, center.dy + sin(a) * size.width * .08)
          ..quadraticBezierTo(center.dx + cos(a + .35) * size.width * .48, center.dy + sin(a + .35) * size.width * .48, center.dx + cos(a) * size.width * .36, center.dy + sin(a) * size.width * .36);
        canvas.drawPath(path, line);
      }
      canvas.drawCircle(center, size.width * .14, highlight);
    }
  }

  @override
  bool shouldRepaint(covariant _BackPatternPainter old) => old.style != style || old.color != color;
}

class _RoyalTablePainter extends CustomPainter {
  final Color accent;
  final int pattern;
  const _RoyalTablePainter(this.accent, this.pattern);

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    final rect = Offset.zero & size;
    final center = Offset(size.width / 2, size.height / 2);
    final shortSide = min(size.width, size.height);
    final gold = Paint()
      ..color = accent.withOpacity(.88)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.35;
    final bright = Paint()
      ..color = const Color(0xFFFFE9B5).withOpacity(.58)
      ..style = PaintingStyle.stroke
      ..strokeWidth = .75;
    final muted = Paint()
      ..color = accent.withOpacity(.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final glow = Paint()
      ..color = accent.withOpacity(.10)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);

    // Soft velvet-like sheen under the cards; the board remains uncluttered.
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.deflate(3), const Radius.circular(18)),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent.withOpacity(.075),
            Colors.black.withOpacity(.025),
            accent.withOpacity(.045),
          ],
        ).createShader(rect),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.deflate(13), Radius.circular(shortSide * .055)),
      glow,
    );

    // Triple beveled frame with a fine inner highlight.
    final outer = rect.deflate(6);
    canvas.drawRRect(
      RRect.fromRectAndRadius(outer, const Radius.circular(19)),
      Paint()..color = Colors.black.withOpacity(.42)..style = PaintingStyle.stroke..strokeWidth = 7,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(outer, const Radius.circular(19)),
      Paint()..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [const Color(0xFFFFE9B5), accent, const Color(0xFF76501C), accent],
      ).createShader(outer)..style = PaintingStyle.stroke..strokeWidth = 2.2,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.deflate(12), const Radius.circular(15)),
      bright,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.deflate(19), const Radius.circular(12)),
      muted,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.deflate(25), const Radius.circular(10)),
      Paint()..color = accent.withOpacity(.10)..style = PaintingStyle.stroke..strokeWidth = .7,
    );

    // Fine stitched inner rail.
    final stitch = Paint()
      ..color = accent.withOpacity(.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = .65;
    final stitchRect = rect.deflate(31);
    for (double x = stitchRect.left + 5; x < stitchRect.right - 4; x += 12) {
      canvas.drawLine(Offset(x, stitchRect.top), Offset(x + 4, stitchRect.top), stitch);
      canvas.drawLine(Offset(x, stitchRect.bottom), Offset(x + 4, stitchRect.bottom), stitch);
    }
    for (double y = stitchRect.top + 5; y < stitchRect.bottom - 4; y += 12) {
      canvas.drawLine(Offset(stitchRect.left, y), Offset(stitchRect.left, y + 4), stitch);
      canvas.drawLine(Offset(stitchRect.right, y), Offset(stitchRect.right, y + 4), stitch);
    }

    // Four ornate corner flourishes and small gold rivets.
    for (int i = 0; i < 4; i++) {
      final left = i.isEven;
      final top = i < 2;
      final x = left ? 24.0 : size.width - 24.0;
      final y = top ? 24.0 : size.height - 24.0;
      final sx = left ? 1.0 : -1.0;
      final sy = top ? 1.0 : -1.0;
      final flourish = Path()
        ..moveTo(x, y + sy * 25)
        ..cubicTo(x + sx * 1, y + sy * 7, x + sx * 7, y + sy * 1, x + sx * 25, y)
        ..moveTo(x + sx * 5, y + sy * 20)
        ..quadraticBezierTo(x + sx * 7, y + sy * 8, x + sx * 20, y + sy * 5)
        ..moveTo(x + sx * 8, y + sy * 15)
        ..quadraticBezierTo(x + sx * 11, y + sy * 11, x + sx * 15, y + sy * 8);
      canvas.drawPath(flourish, gold);
      canvas.drawCircle(Offset(x, y), 3.1, Paint()..color = const Color(0xFFFFE8B0).withOpacity(.82));
      canvas.drawCircle(Offset(x, y), 5.4, Paint()..color = accent.withOpacity(.45)..style = PaintingStyle.stroke..strokeWidth = .7);
    }

    // Theme-specific engraved geometry, kept subtle beneath active cards.
    if (pattern == 0) {
      for (int i = 0; i < 4; i++) {
        final inset = 39.0 + i * 10;
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect.deflate(inset), Radius.circular(10 + i * 2)),
          muted,
        );
      }
      canvas.drawCircle(center, shortSide * .105, gold);
      canvas.drawCircle(center, shortSide * .083, bright);
      canvas.drawCircle(center, shortSide * .061, muted);
    } else if (pattern == 1) {
      final step = max(22.0, shortSide * .085);
      for (double x = 35; x < size.width - 25; x += step) {
        canvas.drawLine(Offset(x, 34), Offset(x, size.height - 34), muted);
      }
      for (double y = 35; y < size.height - 25; y += step) {
        canvas.drawLine(Offset(34, y), Offset(size.width - 34, y), muted);
      }
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect.deflate(43), const Radius.circular(17)),
        gold,
      );
      canvas.drawCircle(center, shortSide * .095, bright);
    } else if (pattern == 2) {
      for (int i = 0; i < 12; i++) {
        final a = i * pi / 6;
        final path = Path()
          ..moveTo(center.dx + cos(a) * shortSide * .035, center.dy + sin(a) * shortSide * .035)
          ..quadraticBezierTo(
            center.dx + cos(a + .18) * shortSide * .16,
            center.dy + sin(a + .18) * shortSide * .16,
            center.dx + cos(a) * shortSide * .24,
            center.dy + sin(a) * shortSide * .24,
          );
        canvas.drawPath(path, gold);
      }
      canvas.drawCircle(center, shortSide * .13, bright);
      canvas.drawCircle(center, shortSide * .105, muted);
    } else if (pattern == 3) {
      for (int i = 0; i < 5; i++) {
        final inset = 37.0 + i * 13;
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect.deflate(inset), Radius.circular(9 + i * 2)),
          i.isEven ? gold : muted,
        );
      }
      canvas.drawLine(Offset(center.dx, 35), Offset(center.dx, size.height - 35), bright);
      canvas.drawLine(Offset(35, center.dy), Offset(size.width - 35, center.dy), muted);
    } else {
      final path = Path();
      for (int i = 0; i < 16; i++) {
        final a = i * pi / 8;
        final radius = i.isEven ? shortSide * .13 : shortSide * .065;
        final p = Offset(center.dx + cos(a) * radius, center.dy + sin(a) * radius);
        if (i == 0) { path.moveTo(p.dx, p.dy); } else { path.lineTo(p.dx, p.dy); }
      }
      path.close();
      canvas.drawPath(path, gold);
      canvas.drawCircle(center, shortSide * .045, bright);
    }

    // Small engraved emblems at the midpoint of each side.
    final emblemPaint = Paint()..color = accent.withOpacity(.48)..style = PaintingStyle.stroke..strokeWidth = 1;
    final sidePoints = [
      Offset(center.dx, 18),
      Offset(center.dx, size.height - 18),
      Offset(18, center.dy),
      Offset(size.width - 18, center.dy),
    ];
    for (final p in sidePoints) {
      final diamond = Path()
        ..moveTo(p.dx, p.dy - 5)
        ..lineTo(p.dx + 4, p.dy)
        ..lineTo(p.dx, p.dy + 5)
        ..lineTo(p.dx - 4, p.dy)
        ..close();
      canvas.drawPath(diamond, emblemPaint);
      canvas.drawCircle(p, 1.3, Paint()..color = const Color(0xFFFFE8B0).withOpacity(.75));
    }

    final symbols = ['♛', '✦', '❖', '♜', '♕'];
    final tp = TextPainter(
      text: TextSpan(
        text: symbols[pattern.clamp(0, 4)],
        style: TextStyle(
          color: accent.withOpacity(.13),
          fontSize: min(shortSide * .16, 62),
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(center.dx - tp.width / 2, center.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _RoyalTablePainter old) =>
      old.pattern != pattern || old.accent != accent;
}

class ToraApp extends StatefulWidget {
  const ToraApp({super.key});
  @override State<ToraApp> createState() => _ToraAppState();
}
class _ToraAppState extends State<ToraApp> {
  int themeIndex = 0;
  void setTheme(int value) => setState(() => themeIndex = value);
  @override Widget build(BuildContext context) {
    final t = _themes[themeIndex];
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TORA',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: t.background,
        colorScheme: ColorScheme.dark(
          primary: t.accent,
          secondary: t.accent,
          surface: t.panel,
          onPrimary: Colors.black,
          onSecondary: Colors.black,
          onSurface: Colors.white,
        ),
        // Shared Royal styling for account dialogs, settings and game controls.
        // This changes presentation only; authentication and game logic are untouched.
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: t.background.withOpacity(.78),
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
          labelStyle: const TextStyle(color: Colors.white70),
          hintStyle: const TextStyle(color: Colors.white38),
          prefixIconColor: t.accent,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: t.accent.withOpacity(.38)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: t.accent, width: 1.8),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.redAccent),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.redAccent, width: 1.8),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: t.accent,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            textStyle: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: .5),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: t.accent,
            side: BorderSide(color: t.accent.withOpacity(.72)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            textStyle: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: .25),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: t.accent,
            textStyle: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        progressIndicatorTheme: ProgressIndicatorThemeData(color: t.accent),
        dividerTheme: DividerThemeData(color: t.accent.withOpacity(.24), thickness: 1),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: t.panel,
          contentTextStyle: const TextStyle(color: Colors.white),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: t.accent.withOpacity(.55)),
          ),
        ),
        useMaterial3: true,
      ),
      home: ToraSplashPage(
        theme: t,
        onStart: (splashContext) {
          Navigator.of(splashContext).push(
            MaterialPageRoute(
              builder: (_) => GameSelectionPage(
                theme: t,
                onThemeChanged: setTheme,
              ),
            ),
          );
        },
      ),
    );
  }
}

class RoyalToraLogo extends StatelessWidget {
  final double size;
  const RoyalToraLogo({super.key, required this.size});

  @override
  Widget build(BuildContext context) => SizedBox(
    width: size,
    height: size,
    child: CustomPaint(painter: _RoyalToraLogoPainter()),
  );
}

class _RoyalToraLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const gold = Color(0xFFFFD36A);
    const paleGold = Color(0xFFFFE7A0);
    final w = size.width;
    final h = size.height;

    // Minimal royal crown.
    final crown = Path()
      ..moveTo(w * .25, h * .38)
      ..lineTo(w * .20, h * .17)
      ..lineTo(w * .38, h * .29)
      ..lineTo(w * .50, h * .10)
      ..lineTo(w * .62, h * .29)
      ..lineTo(w * .80, h * .17)
      ..lineTo(w * .75, h * .38)
      ..close();
    canvas.drawPath(crown, Paint()..shader = const LinearGradient(
      begin: Alignment.topCenter, end: Alignment.bottomCenter,
      colors: [Color(0xFFFFF0B0), Color(0xFFD6A642), Color(0xFF9B681B)],
    ).createShader(Rect.fromLTWH(w*.2,h*.1,w*.6,h*.3)));
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w*.25,h*.36,w*.5,h*.075),
        Radius.circular(w*.025)),
      Paint()..color = gold,
    );
    for (final x in [.20, .50, .80]) {
      canvas.drawCircle(Offset(w*x,h * (x == .50 ? .10 : .17)),w*.025,
        Paint()..color=paleGold);
    }

    // Bold Queen of Spades mark: Q with a clear spade glyph.
    final painter = TextPainter(
      text: const TextSpan(
        text: 'Q♠',
        style: TextStyle(
          color: Color(0xFFFFD36A),
          fontSize: 1,
          fontWeight: FontWeight.w900,
          letterSpacing: -1,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    painter.layout();
    final targetWidth = w * .66;
    final scale = targetWidth / painter.width;
    canvas.save();
    canvas.translate((w-targetWidth)/2, h*.49);
    canvas.scale(scale, scale);
    painter.paint(canvas, Offset.zero);
    canvas.restore();

    // Fine underline, no portrait or extra card decorations.
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w*.32,h*.83,w*.36,h*.012),
        Radius.circular(w*.01)),
      Paint()..color=const Color(0xFF9B681B),
    );
  }

  @override
  bool shouldRepaint(covariant _RoyalToraLogoPainter oldDelegate) => false;
}

class ToraSplashPage extends StatelessWidget {
  final ToraTheme theme;
  final ValueChanged<BuildContext> onStart;
  const ToraSplashPage({super.key, required this.theme, required this.onStart});

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFFFD36A);
    const deepGold = Color(0xFF9B681B);
    return Scaffold(
      backgroundColor: const Color(0xFF030303),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final scale = (constraints.maxHeight / 620).clamp(.72, 1.0);
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 250 * scale,
                      padding: EdgeInsets.all(7 * scale),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(26),
                        gradient: const LinearGradient(
                          colors: [gold, deepGold, Color(0xFFFFF0B0), deepGold, gold],
                          begin: Alignment.topLeft, end: Alignment.bottomRight,
                        ),
                        boxShadow: [BoxShadow(color: gold.withOpacity(.28), blurRadius: 28, spreadRadius: 2)],
                      ),
                      child: Container(
                        height: 440 * scale,
                        decoration: BoxDecoration(
                          color: const Color(0xFF080705),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: gold.withOpacity(.85), width: 1.4),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Positioned.fill(child: CustomPaint(painter: _SplashOrnamentPainter())),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 142 * scale,
                                  height: 164 * scale,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15 * scale),
                                    border: Border.all(color: gold, width: 3 * scale),
                                    boxShadow: [BoxShadow(color: gold.withOpacity(.25), blurRadius: 16)],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12 * scale),
                                    child: Image.asset(
                                      'assets/adell_sahil.png',
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => Container(
                                        color: const Color(0xFF17110A),
                                        alignment: Alignment.center,
                                        child: Icon(Icons.person, color: gold, size: 58 * scale),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 12 * scale),
                                RoyalToraLogo(size: 172 * scale),
                                SizedBox(height: 15 * scale),
                                Text('Adell Sahil', textAlign: TextAlign.center,
                                  style: TextStyle(color: gold, fontSize: 25 * scale,
                                    fontWeight: FontWeight.w900, letterSpacing: 1.8,
                                    shadows: const [Shadow(color: deepGold, blurRadius: 12)])),
                                SizedBox(height: 5 * scale),
                                Text('FOUNDER • TORA', style: TextStyle(
                                  color: const Color(0xFFE8D5A5), fontSize: 9 * scale,
                                  letterSpacing: 2.2, fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20 * scale),
                    Text('TORA', style: TextStyle(
                      color: gold, fontSize: 43 * scale, fontWeight: FontWeight.w900,
                      letterSpacing: 8, shadows: const [Shadow(color: deepGold, blurRadius: 16)])),
                    SizedBox(height: 5 * scale),
                    Text('ROYAL CARD GAME', style: TextStyle(
                      color: const Color(0xFFE8D5A5), fontSize: 10 * scale,
                      letterSpacing: 3, fontWeight: FontWeight.w700)),
                    SizedBox(height: 24 * scale),
                    SizedBox(
                      width: 238, height: 50 * scale,
                      child: FilledButton(
                        onPressed: () => onStart(context),
                        style: FilledButton.styleFrom(
                          backgroundColor: gold, foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14),
                            side: const BorderSide(color: deepGold, width: 2)),
                          elevation: 10, shadowColor: gold.withOpacity(.35),
                        ),
                        child: Text('START GAME', style: TextStyle(
                          fontWeight: FontWeight.w900, letterSpacing: 2.5, fontSize: 14 * scale)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}


class GameSelectionPage extends StatelessWidget {
  final ToraTheme theme;
  final ValueChanged<int> onThemeChanged;
  const GameSelectionPage({
    super.key,
    required this.theme,
    required this.onThemeChanged,
  });

  void _openTora(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ToraGamePage(
          theme: theme,
          onThemeChanged: onThemeChanged,
        ),
      ),
    );
  }

  void _openManfi(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ManfiHomePage()),
    );
  }

  Widget _gameTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String symbol,
    required bool available,
    String? statusText,
    required VoidCallback onTap,
  }) {
    const gold = Color(0xFFFFD36A);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF242019), Color(0xFF09090B), Color(0xFF17130B)],
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: gold.withOpacity(available ? .95 : .48), width: available ? 2 : 1.2),
            boxShadow: [
              BoxShadow(color: gold.withOpacity(available ? .16 : .07), blurRadius: 18, spreadRadius: 1),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 66,
                height: 82,
                decoration: BoxDecoration(
                  color: const Color(0xFF080808),
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(color: gold.withOpacity(.8), width: 1.2),
                ),
                child: Center(
                  child: Text(
                    symbol,
                    style: const TextStyle(color: gold, fontSize: 35, fontWeight: FontWeight.w900),
                  ),
                ),
              ),
              const SizedBox(width: 17),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(color: gold, fontSize: 23, fontWeight: FontWeight.w900, letterSpacing: 2)),
                    const SizedBox(height: 5),
                    Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 11, height: 1.4)),
                    const SizedBox(height: 9),
                    Text(
                      statusText ?? (available ? 'PLAY NOW' : 'COMING SOON'),
                      style: TextStyle(color: gold.withOpacity(available ? 1 : .75), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.6),
                    ),
                  ],
                ),
              ),
              Icon(
                available ? Icons.arrow_forward_ios_rounded : Icons.lock_clock_outlined,
                color: gold.withOpacity(.9),
                size: 19,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFFFD36A);
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 26),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.workspace_premium_rounded, color: gold, size: 54),
                  const SizedBox(height: 12),
                  const Text('CHOOSE YOUR GAME', textAlign: TextAlign.center,
                    style: TextStyle(color: gold, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 2)),
                  const SizedBox(height: 7),
                  const Text('THE ROYAL WORLD OF CARD GAMES', textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFFE8D5A5), fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 30),
                  _gameTile(
                    context: context,
                    title: 'TORA',
                    subtitle: 'Royal Card Game • Existing game',
                    symbol: '♛',
                    available: true,
                    onTap: () => _openTora(context),
                  ),
                  const SizedBox(height: 16),
                  _gameTile(
                    context: context,
                    title: 'MANFI',
                    subtitle: 'Separate game • Five modern table designs',
                    symbol: '♠',
                    available: true,
                    statusText: 'OPEN MANFI',
                    onTap: () => _openManfi(context),
                  ),
                  const SizedBox(height: 28),
                  TextButton.icon(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back_rounded, color: gold, size: 17),
                    label: const Text('BACK', style: TextStyle(color: gold, fontWeight: FontWeight.w800, letterSpacing: 1.4)),
                  ),
                  const SizedBox(height: 8),
                  const Text('CREATED BY ADELL SAHIL',
                    style: TextStyle(color: Colors.white38, fontSize: 9, letterSpacing: 1.8, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SplashOrnamentPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = const Color(0xFFFFD36A).withOpacity(.34)
      ..style = PaintingStyle.stroke..strokeWidth = 1;
    final r = Rect.fromLTWH(12, 12, size.width - 24, size.height - 24);
    canvas.drawRRect(RRect.fromRectAndRadius(r, const Radius.circular(14)), p);
    for (final x in [18.0, size.width - 18]) {
      for (final y in [18.0, size.height - 18]) {
        canvas.drawCircle(Offset(x, y), 5, p);
        canvas.drawCircle(Offset(x, y), 9, p..strokeWidth = .6);
        final path = Path()..moveTo(x - 11, y)..quadraticBezierTo(x, y - 13, x + 11, y)
          ..quadraticBezierTo(x, y + 13, x - 11, y);
        canvas.drawPath(path, p);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SplashOrnamentPainter oldDelegate) => false;
}

class _FacePortraitPainter extends CustomPainter {
  final String rank;
  final Color robe;
  const _FacePortraitPainter(this.rank, this.robe);

  @override
  void paint(Canvas canvas, Size size) {
    final gold = Paint()..color = const Color(0xFF9A7131);
    final dark = Paint()..color = const Color(0xFF49301F);
    final skin = Paint()..color = const Color(0xFFF1C99D);
    final cloth = Paint()..color = robe;
    final cx = size.width / 2;

    // shoulders and neck
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * .19, size.height * .64, size.width * .62, size.height * .29),
      const Radius.circular(8),
    ), cloth);
    canvas.drawRect(Rect.fromLTWH(cx - size.width * .09, size.height * .53,
      size.width * .18, size.height * .19), skin);

    // hair behind the face and the face itself
    canvas.drawOval(Rect.fromLTWH(size.width * .28, size.height * .19,
      size.width * .44, size.height * .48), dark);
    canvas.drawOval(Rect.fromLTWH(size.width * .32, size.height * .25,
      size.width * .36, size.height * .39), skin);

    // hairline, eyes, nose and mouth
    final hair = Paint()..color = dark.color;
    final features = Paint()..color = const Color(0xFF563A2B)..strokeWidth = 1.2..strokeCap = StrokeCap.round;
    final hairPath = Path()
      ..moveTo(size.width * .30, size.height * .36)
      ..quadraticBezierTo(cx, size.height * .08, size.width * .70, size.height * .36)
      ..lineTo(size.width * .64, size.height * .29)
      ..quadraticBezierTo(cx, size.height * .20, size.width * .36, size.height * .31)
      ..close();
    canvas.drawPath(hairPath, hair);
    canvas.drawLine(Offset(size.width * .40, size.height * .43), Offset(size.width * .46, size.height * .43), features);
    canvas.drawLine(Offset(size.width * .54, size.height * .43), Offset(size.width * .60, size.height * .43), features);
    canvas.drawLine(Offset(cx, size.height * .44), Offset(cx - 1, size.height * .52), features);
    canvas.drawLine(Offset(size.width * .45, size.height * .57), Offset(size.width * .55, size.height * .57), features);

    // Three different royal headpieces distinguish Jack, Queen and King.
    if (rank == 'K') {
      final crown = Path()
        ..moveTo(size.width * .29, size.height * .27)
        ..lineTo(size.width * .33, size.height * .12)
        ..lineTo(size.width * .45, size.height * .22)
        ..lineTo(cx, size.height * .08)
        ..lineTo(size.width * .55, size.height * .22)
        ..lineTo(size.width * .67, size.height * .12)
        ..lineTo(size.width * .71, size.height * .27)
        ..close();
      canvas.drawPath(crown, gold);
    } else if (rank == 'Q') {
      final tiara = Path()
        ..moveTo(size.width * .32, size.height * .28)
        ..lineTo(size.width * .39, size.height * .13)
        ..lineTo(cx, size.height * .23)
        ..lineTo(size.width * .61, size.height * .13)
        ..lineTo(size.width * .68, size.height * .28)
        ..close();
      canvas.drawPath(tiara, gold);
      canvas.drawCircle(Offset(cx, size.height * .18), size.width * .035, Paint()..color = const Color(0xFF9B3155));
    } else {
      final plume = Path()
        ..moveTo(size.width * .36, size.height * .27)
        ..quadraticBezierTo(size.width * .13, size.height * .02, size.width * .58, size.height * .10)
        ..quadraticBezierTo(size.width * .48, size.height * .20, size.width * .64, size.height * .28)
        ..close();
      canvas.drawPath(plume, Paint()..color = const Color(0xFF3E7058));
      canvas.drawLine(Offset(size.width * .39, size.height * .25), Offset(size.width * .58, size.height * .12), gold..style = PaintingStyle.stroke..strokeWidth = 1.3);
    }
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * .12, size.height * .08, size.width * .76, size.height * .84),
      const Radius.circular(4),
    ), Paint()..color = const Color(0xFF9A7131)..style = PaintingStyle.stroke..strokeWidth = 1);
  }

  @override
  bool shouldRepaint(covariant _FacePortraitPainter oldDelegate) =>
      oldDelegate.rank != rank || oldDelegate.robe != robe;
}

class _FaceOrnamentPainter extends CustomPainter {
  final Color color;
  const _FaceOrnamentPainter(this.color);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color.withOpacity(.75)..style = PaintingStyle.stroke..strokeWidth = 1;
    final rect = Rect.fromLTWH(size.width * .12, size.height * .12, size.width * .76, size.height * .76);
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(4)), paint);
    final path = Path()
      ..moveTo(size.width * .18, size.height * .25)
      ..lineTo(size.width * .5, size.height * .13)
      ..lineTo(size.width * .82, size.height * .25)
      ..moveTo(size.width * .18, size.height * .75)
      ..lineTo(size.width * .5, size.height * .87)
      ..lineTo(size.width * .82, size.height * .75);
    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(covariant _FaceOrnamentPainter oldDelegate) => oldDelegate.color != color;
}




class ManfiTableStyle {
  final String name;
  final String description;
  final Color background;
  final Color panel;
  final Color felt;
  final Color accent;
  final int shape;
  const ManfiTableStyle(
    this.name, this.description, this.background, this.panel,
    this.felt, this.accent, this.shape,
  );
}

const List<ManfiTableStyle> _manfiTableStyles = [
  ManfiTableStyle('Obsidian Crown', 'Oval velvet table • Gold inlay',
    Color(0xFF080A0F), Color(0xFF171923), Color(0xFF10151D), Color(0xFFE4BD68), 0),
  ManfiTableStyle('Emerald Arena', 'Octagonal table • Emerald felt',
    Color(0xFF061A16), Color(0xFF102B24), Color(0xFF0D4938), Color(0xFFD8C078), 1),
  ManfiTableStyle('Crimson Royale', 'Modern rectangle • Layered rails',
    Color(0xFF1B090F), Color(0xFF35121D), Color(0xFF641D32), Color(0xFFFFC477), 2),
  ManfiTableStyle('Azure Orbit', 'Circular arena • Orbit details',
    Color(0xFF071426), Color(0xFF122B49), Color(0xFF123E68), Color(0xFF9FD9FF), 3),
  ManfiTableStyle('Ivory Diamond', 'Diamond table • Ivory and champagne',
    Color(0xFF242019), Color(0xFF3B3328), Color(0xFFE9DFC9), Color(0xFFB88A43), 4),
];

class ManfiHomePage extends StatefulWidget {
  const ManfiHomePage({super.key});

  @override
  State<ManfiHomePage> createState() => _ManfiHomePageState();
}

class _ManfiHomePageState extends State<ManfiHomePage> {
  int _selectedStyle = 0;
  bool _authBusy = false;
  String? _authMessage;

  ManfiTableStyle get _style => _manfiTableStyles[_selectedStyle];

  @override
  void initState() {
    super.initState();
    _loadSelectedStyle();
  }

  Future<void> _loadSelectedStyle() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getInt('manfi_table_style') ?? 0;
    if (!mounted) return;
    setState(() => _selectedStyle = saved.clamp(0, _manfiTableStyles.length - 1).toInt());
  }

  Future<void> _selectStyle(int index) async {
    setState(() => _selectedStyle = index);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('manfi_table_style', index);
  }

  Future<void> _emailLogin() async {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    bool createAccount = false;
    bool busy = false;
    String? errorText;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, updateDialog) => AlertDialog(
          backgroundColor: const Color(0xFF11151D),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: BorderSide(color: _style.accent, width: 1.3),
          ),
          title: Text(
            'MANFI ACCOUNT',
            textAlign: TextAlign.center,
            style: TextStyle(color: _style.accent, fontWeight: FontWeight.w900, letterSpacing: 1.5),
          ),
          content: SizedBox(
            width: 340,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email address',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
              ),
              if (errorText != null) ...[
                const SizedBox(height: 10),
                Text(errorText!, textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 11)),
              ],
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: busy ? null : () async {
                    final email = emailController.text.trim();
                    final password = passwordController.text;
                    if (email.isEmpty || password.length < 6) {
                      updateDialog(() => errorText = 'Enter an email and a password with at least 6 characters.');
                      return;
                    }
                    updateDialog(() { busy = true; errorText = null; });
                    try {
                      final auth = FirebaseAuth.instance;
                      if (createAccount) {
                        await auth.createUserWithEmailAndPassword(email: email, password: password)
                            .timeout(const Duration(seconds: 25));
                      } else {
                        await auth.signInWithEmailAndPassword(email: email, password: password)
                            .timeout(const Duration(seconds: 25));
                      }
                      if (dialogContext.mounted) Navigator.pop(dialogContext);
                      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('MANFI account connected.')),
                      );
                    } on FirebaseAuthException catch (e) {
                      if (dialogContext.mounted) updateDialog(() => errorText = e.message ?? e.code);
                    } on TimeoutException {
                      if (dialogContext.mounted) updateDialog(() => errorText = 'Connection timed out. Check internet and try again.');
                    } catch (e) {
                      if (dialogContext.mounted) updateDialog(() => errorText = 'Login failed: $e');
                    } finally {
                      if (dialogContext.mounted) updateDialog(() => busy = false);
                    }
                  },
                  child: Text(createAccount ? 'CREATE EMAIL ACCOUNT' : 'SIGN IN WITH EMAIL'),
                ),
              ),
              TextButton(
                onPressed: busy ? null : () => updateDialog(() {
                  createAccount = !createAccount;
                  errorText = null;
                }),
                child: Text(createAccount ? 'Already registered? Sign in' : 'New player? Create account'),
              ),
              if (busy) const Padding(
                padding: EdgeInsets.only(top: 8),
                child: CircularProgressIndicator(),
              ),
            ]),
          ),
          actions: [
            TextButton(
              onPressed: busy ? null : () => Navigator.pop(dialogContext),
              child: const Text('CLOSE'),
            ),
          ],
        ),
      ),
    );
    emailController.dispose();
    passwordController.dispose();
  }

  Future<void> _facebookLogin() async {
    if (_authBusy) return;
    setState(() { _authBusy = true; _authMessage = null; });
    try {
      final result = await FacebookAuth.instance.login(
        permissions: const ['email', 'public_profile'],
      );
      if (result.status == LoginStatus.success && result.accessToken != null) {
        final credential = FacebookAuthProvider.credential(result.accessToken!.tokenString);
        await FirebaseAuth.instance.signInWithCredential(credential)
            .timeout(const Duration(seconds: 30));
        if (mounted) setState(() => _authMessage = 'Facebook account connected.');
      } else if (result.status == LoginStatus.cancelled) {
        if (mounted) setState(() => _authMessage = 'Facebook login was cancelled.');
      } else {
        if (mounted) setState(() => _authMessage = 'Facebook login failed: ' + (result.message ?? result.status.name));
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) setState(() => _authMessage = e.message ?? e.code);
    } catch (e) {
      if (mounted) setState(() => _authMessage = 'Facebook login failed: $e');
    } finally {
      if (mounted) setState(() => _authBusy = false);
    }
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) setState(() => _authMessage = 'Signed out.');
  }

  Widget _accountPanel(ManfiTableStyle style) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final user = snapshot.data;
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: style.panel.withOpacity(.88),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: style.accent.withOpacity(.55)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Row(children: [
              Icon(Icons.verified_user_rounded, color: style.accent, size: 22),
              const SizedBox(width: 9),
              Expanded(child: Text(
                user == null ? 'MANFI PLAYER ACCOUNT' : (user.displayName ?? 'MANFI PLAYER'),
                style: TextStyle(color: style.accent, fontWeight: FontWeight.w900, letterSpacing: .8),
              )),
              if (user != null) Icon(Icons.check_circle, color: style.accent, size: 19),
            ]),
            const SizedBox(height: 7),
            if (user == null) ...[
              const Text('Use the same secure Firebase account system as TORA.',
                style: TextStyle(color: Colors.white60, fontSize: 11)),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: OutlinedButton.icon(
                  onPressed: _authBusy ? null : _emailLogin,
                  icon: const Icon(Icons.email_outlined),
                  label: const Text('EMAIL LOGIN'),
                )),
                const SizedBox(width: 8),
                Expanded(child: OutlinedButton.icon(
                  onPressed: _authBusy ? null : _facebookLogin,
                  icon: const Icon(Icons.facebook, color: Color(0xFF1877F2)),
                  label: const Text('FACEBOOK'),
                )),
              ]),
            ] else ...[
              Text(user.email ?? user.phoneNumber ?? 'Signed in with Facebook',
                style: const TextStyle(color: Colors.white70, fontSize: 11)),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: _signOut,
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('SIGN OUT'),
                ),
              ),
            ],
            if (_authMessage != null) ...[
              const SizedBox(height: 6),
              Text(_authMessage!, style: TextStyle(color: style.accent, fontSize: 11)),
            ],
            if (_authBusy) const Padding(
              padding: EdgeInsets.only(top: 8),
              child: LinearProgressIndicator(),
            ),
          ]),
        );
      },
    );
  }

  Widget _themeCard(int index, double width) {
    final style = _manfiTableStyles[index];
    final selected = _selectedStyle == index;
    return SizedBox(
      width: width,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(17),
          onTap: () => _selectStyle(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: style.panel,
              borderRadius: BorderRadius.circular(17),
              border: Border.all(color: selected ? style.accent : style.accent.withOpacity(.32),
                width: selected ? 2 : 1),
              boxShadow: selected ? [BoxShadow(color: style.accent.withOpacity(.16), blurRadius: 12)] : [],
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(
                height: 104,
                width: double.infinity,
                child: CustomPaint(
                  painter: _ManfiTablePainter(style),
                  child: Center(child: Text('MANFI',
                    style: TextStyle(color: style.accent, fontSize: 12,
                      fontWeight: FontWeight.w900, letterSpacing: 2))),
                ),
              ),
              const SizedBox(height: 8),
              Text(style.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: TextStyle(color: style.accent, fontWeight: FontWeight.w900, fontSize: 11)),
              const SizedBox(height: 3),
              Text(style.description, maxLines: 2, overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white60, fontSize: 9, height: 1.25)),
              const SizedBox(height: 6),
              Row(children: [
                Icon(selected ? Icons.check_circle : Icons.circle_outlined,
                  color: style.accent, size: 15),
                const SizedBox(width: 5),
                Text(selected ? 'SELECTED' : 'SELECT TABLE',
                  style: TextStyle(color: style.accent, fontSize: 8, fontWeight: FontWeight.w900)),
              ]),
            ]),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final style = _style;
    return Scaffold(
      backgroundColor: style.background,
      appBar: AppBar(
        backgroundColor: style.background,
        foregroundColor: style.accent,
        elevation: 0,
        title: Text('MANFI', style: TextStyle(color: style.accent,
          fontWeight: FontWeight.w900, letterSpacing: 3)),
        actions: [
          IconButton(
            tooltip: 'Back to game selection',
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.grid_view_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = (constraints.maxWidth - 30) / 2;
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(14, 4, 14, 24),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [style.panel, style.background],
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: style.accent.withOpacity(.55)),
                  ),
                  child: Column(children: [
                    Text('THE MANFI TABLE COLLECTION',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: style.accent, fontSize: 15,
                        fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                    const SizedBox(height: 5),
                    const Text('Five independent modern table designs',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white60, fontSize: 10)),
                    const SizedBox(height: 13),
                    SizedBox(
                      height: 174,
                      child: CustomPaint(
                        painter: _ManfiTablePainter(style),
                        child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                          Text('♠', style: TextStyle(color: style.accent, fontSize: 34,
                            fontWeight: FontWeight.w900)),
                          Text('MANFI', style: TextStyle(color: style.accent, fontSize: 18,
                            fontWeight: FontWeight.w900, letterSpacing: 3)),
                          const Text('FOUR PLAYER TABLE',
                            style: TextStyle(color: Colors.white70, fontSize: 8, letterSpacing: 1.4)),
                        ])),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(style.name, style: TextStyle(color: style.accent,
                      fontWeight: FontWeight.w900, fontSize: 13)),
                  ]),
                ),
                const SizedBox(height: 16),
                _accountPanel(style),
                const SizedBox(height: 20),
                Text('CHOOSE YOUR TABLE DESIGN',
                  style: TextStyle(color: style.accent, fontSize: 12,
                    fontWeight: FontWeight.w900, letterSpacing: 1.1)),
                const SizedBox(height: 9),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (int i = 0; i < _manfiTableStyles.length; i++)
                      _themeCard(i, width),
                  ],
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: style.panel.withOpacity(.75),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: style.accent.withOpacity(.35)),
                  ),
                  child: const Text(
                    'MANFI gameplay is being built as a separate game module. TORA rules, cards and gameplay are not changed by this design page.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white60, fontSize: 10, height: 1.45),
                  ),
                ),
              ]),
            );
          },
        ),
      ),
    );
  }
}

class _ManfiTablePainter extends CustomPainter {
  final ManfiTableStyle style;
  const _ManfiTablePainter(this.style);

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    final rect = Offset.zero & size;
    final board = rect.deflate(10);
    final center = board.center;
    final shortSide = min(board.width, board.height);
    final fill = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [style.felt, style.background, style.panel],
      ).createShader(board);
    final rail = Paint()
      ..color = style.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = style.shape == 2 ? 4 : 2.8;
    final fine = Paint()
      ..color = style.accent.withOpacity(.58)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.15;
    final glow = Paint()..color = style.accent.withOpacity(.10);

    // Each MANFI theme has its own unmistakable table silhouette.
    Path boardPath;
    switch (style.shape) {
      case 0: // Obsidian Crown — elongated oval.
        boardPath = Path()..addOval(board);
        break;
      case 1: // Emerald Arena — clipped eight-sided arena.
        boardPath = Path();
        for (int i = 0; i < 8; i++) {
          final a = -pi / 8 + i * pi / 4;
          final p = Offset(center.dx + cos(a) * board.width * .49,
              center.dy + sin(a) * board.height * .49);
          if (i == 0) { boardPath.moveTo(p.dx, p.dy); } else { boardPath.lineTo(p.dx, p.dy); }
        }
        boardPath.close();
        break;
      case 2: // Crimson Royale — squared, layered tournament table.
        boardPath = Path()
          ..addRRect(RRect.fromRectAndRadius(board, Radius.circular(shortSide * .075)));
        break;
      case 3: // Azure Orbit — circular arena.
        final circle = Rect.fromCircle(center: center, radius: shortSide * .485);
        boardPath = Path()..addOval(circle);
        break;
      default: // Ivory Diamond — four-sided diamond.
        boardPath = Path()
          ..moveTo(center.dx, board.top)
          ..lineTo(board.right, center.dy)
          ..lineTo(center.dx, board.bottom)
          ..lineTo(board.left, center.dy)
          ..close();
    }

    canvas.drawShadow(boardPath, Colors.black.withOpacity(.62), 9, true);
    canvas.drawPath(boardPath, glow);
    canvas.drawPath(boardPath, fill);
    canvas.drawPath(boardPath, rail);

    canvas.save();
    canvas.clipPath(boardPath);

    // Different internal architecture for each table, not just a recolor.
    switch (style.shape) {
      case 0:
        canvas.drawOval(board.deflate(shortSide * .105), fine);
        canvas.drawOval(board.deflate(shortSide * .19), fine);
        canvas.drawLine(Offset(center.dx - board.width * .28, center.dy),
            Offset(center.dx + board.width * .28, center.dy), fine);
        canvas.drawCircle(center, shortSide * .075, rail);
        break;
      case 1:
        final innerOctagon = Path();
        final oct = board.deflate(shortSide * .075);
        for (int i = 0; i < 8; i++) {
          final a = -pi / 8 + i * pi / 4;
          final p = Offset(center.dx + cos(a) * oct.width * .49,
              center.dy + sin(a) * oct.height * .49);
          if (i == 0) { innerOctagon.moveTo(p.dx, p.dy); } else { innerOctagon.lineTo(p.dx, p.dy); }
        }
        innerOctagon.close();
        canvas.drawPath(innerOctagon, fine);
        for (int i = 0; i < 4; i++) {
          final a = pi / 4 + i * pi / 2;
          canvas.drawCircle(
            Offset(center.dx + cos(a) * shortSide * .19,
                center.dy + sin(a) * shortSide * .19),
            shortSide * .075, fine);
        }
        canvas.drawCircle(center, shortSide * .105, rail);
        break;
      case 2:
        for (int i = 1; i <= 4; i++) {
          final inset = shortSide * (.045 + i * .045);
          canvas.drawRRect(
            RRect.fromRectAndRadius(board.deflate(inset), Radius.circular(5 + i * 3)),
            i.isOdd ? rail : fine,
          );
        }
        // Corner inlays make this theme visibly different from the other four.
        for (int i = 0; i < 4; i++) {
          final x = i.isEven ? board.left + 18 : board.right - 18;
          final y = i < 2 ? board.top + 18 : board.bottom - 18;
          canvas.drawCircle(Offset(x, y), shortSide * .035, rail);
        }
        break;
      case 3:
        for (int i = 1; i <= 4; i++) {
          canvas.drawCircle(center, shortSide * (.105 + i * .085), fine);
        }
        canvas.drawLine(Offset(center.dx, board.top), Offset(center.dx, board.bottom), fine);
        canvas.drawLine(Offset(board.left, center.dy), Offset(board.right, center.dy), fine);
        canvas.drawCircle(center, shortSide * .07, rail);
        break;
      default:
        for (int i = 1; i <= 4; i++) {
          final inset = shortSide * i * .055;
          canvas.drawPath(Path()
            ..moveTo(center.dx, board.top + inset)
            ..lineTo(board.right - inset, center.dy)
            ..lineTo(center.dx, board.bottom - inset)
            ..lineTo(board.left + inset, center.dy)
            ..close(), fine);
        }
        canvas.drawLine(Offset(center.dx, board.top + 8),
            Offset(center.dx, board.bottom - 8), fine);
        canvas.drawLine(Offset(board.left + 8, center.dy),
            Offset(board.right - 8, center.dy), fine);
        canvas.drawCircle(center, shortSide * .055, rail);
    }
    canvas.restore();

    // Seat locations and seat frames also change with the selected table form.
    final List<Offset> seats;
    if (style.shape == 1) {
      seats = [
        Offset(center.dx, board.top + shortSide * .105),
        Offset(board.right - shortSide * .105, center.dy),
        Offset(center.dx, board.bottom - shortSide * .105),
        Offset(board.left + shortSide * .105, center.dy),
      ];
    } else if (style.shape == 4) {
      seats = [
        Offset(center.dx, board.top + shortSide * .17),
        Offset(board.right - shortSide * .17, center.dy),
        Offset(center.dx, board.bottom - shortSide * .17),
        Offset(board.left + shortSide * .17, center.dy),
      ];
    } else if (style.shape == 3) {
      seats = [
        Offset(center.dx, center.dy - shortSide * .34),
        Offset(center.dx + shortSide * .34, center.dy),
        Offset(center.dx, center.dy + shortSide * .34),
        Offset(center.dx - shortSide * .34, center.dy),
      ];
    } else {
      seats = [
        Offset(center.dx, board.top + shortSide * .105),
        Offset(board.right - shortSide * .14, center.dy),
        Offset(center.dx, board.bottom - shortSide * .105),
        Offset(board.left + shortSide * .14, center.dy),
      ];
    }

    for (int i = 0; i < seats.length; i++) {
      final seat = seats[i];
      final seatSize = shortSide * (style.shape == 2 ? .145 : .125);
      final seatRect = Rect.fromCenter(
        center: seat,
        width: seatSize * (i.isEven ? 1.25 : 1.0),
        height: seatSize,
      );
      final seatFill = Paint()..color = style.panel.withOpacity(.96);
      final seatBorder = Paint()
        ..color = style.accent
        ..style = PaintingStyle.stroke
        ..strokeWidth = style.shape == 4 ? 1.8 : 1.35;
      if (style.shape == 1 || style.shape == 4) {
        final seatPath = Path()
          ..moveTo(seatRect.center.dx, seatRect.top)
          ..lineTo(seatRect.right, seatRect.center.dy)
          ..lineTo(seatRect.center.dx, seatRect.bottom)
          ..lineTo(seatRect.left, seatRect.center.dy)
          ..close();
        canvas.drawPath(seatPath, seatFill);
        canvas.drawPath(seatPath, seatBorder);
      } else if (style.shape == 3) {
        canvas.drawOval(seatRect, seatFill);
        canvas.drawOval(seatRect, seatBorder);
      } else {
        final radius = Radius.circular(style.shape == 2 ? 3 : seatSize * .42);
        canvas.drawRRect(RRect.fromRectAndRadius(seatRect, radius), seatFill);
        canvas.drawRRect(RRect.fromRectAndRadius(seatRect, radius), seatBorder);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ManfiTablePainter oldDelegate) =>
      oldDelegate.style.name != style.name ||
      oldDelegate.style.shape != style.shape ||
      oldDelegate.style.accent != style.accent ||
      oldDelegate.style.felt != style.felt;
}

/// Google test banner. Replace the test unit ID only after the real AdMob
/// account and production ad unit have been verified.
class ToraGamePage extends StatefulWidget {
  final ToraTheme theme;
  final ValueChanged<int> onThemeChanged;
  const ToraGamePage({super.key, required this.theme, required this.onThemeChanged});
  @override State<ToraGamePage> createState() => _ToraGamePageState();
}

class _ToraGamePageState extends State<ToraGamePage> {
  final Random _random = Random();
  final List<String> _names = ['Player 1', 'Player 2', 'Player 3', 'Player 4'];
  int _cardFaceStyle = 0;
  int _cardBackStyle = 0;
  final List<List<String>> _hands = List.generate(4, (_) => <String>[]);
  final List<List<String>> _won = List.generate(4, (_) => <String>[]);
  final List<String?> _trick = List.filled(4, null);
  final List<int> _trickOrder = [];
  final List<int> _trickSeats = [];
  final List<String> _history = [];
  // These are the only two team score accounts. Ordinary card penalties and
  // every Takkol transfer both update these same shared team totals.
  int _turn = 0, _leader = 0, _round = 0, _teamOne = 0, _teamTwo = 0;
  // Successful Takkol events by team during the current 13-card hand.
  final List<int> _takkolCount = [0, 0];
  // The player who captures Q♠ deals the next 52-card round and leads its first trick.
  int _nextDealerAndLeader = 0;
  bool _aiBusy = false, _gameOver = false, _matchFinished = false, _checkingClaim = false, _resolvingTrick = false, _auditShown = false, _dealing = false;
  int _dealProgress = 0, _lastDealtSeat = -1;
  List<String> _dealDeck = [];
  late ToraTheme _activeTheme;
  String? _ledSuit;
  String _status = 'Your turn: drag a card to the centre.';
  int _lastWinner = -1;

  // Device-local player profile and VIP entitlement placeholder.
  // Real authentication, cloud sync and purchase verification remain disabled.
  String _profileName = 'TORA Player';
  String _profileEmail = '';
  bool _profileLoaded = false;
  bool _vipActive = false;
  bool get _hasVipAccess => _profileLoaded && _vipActive;

  ToraTheme get t => _activeTheme;

  @override void initState() {
    super.initState();
    _activeTheme = widget.theme;
    _deal(first: true);
    _loadRoyalProfile();
  }

  Future<void> _loadRoyalProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final user = FirebaseAuth.instance.currentUser;
    if (!mounted) return;
    setState(() {
      _profileName = user?.displayName?.isNotEmpty == true
          ? user!.displayName!
          : (prefs.getString('tora_profile_name') ?? 'TORA Player');
      _profileEmail = user?.email ?? user?.phoneNumber ??
          (prefs.getString('tora_profile_email') ?? '');
      // VIP stays inactive until a verified purchase system is integrated.
      _vipActive = false;
      _profileLoaded = true;
    });
  }

  Future<void> _saveRoyalProfile(String name, String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tora_profile_name', name);
    await prefs.setString('tora_profile_email', email);
    if (!mounted) return;
    setState(() {
      _profileName = name;
      _profileEmail = email;
    });
  }

  Future<void> _editRoyalProfile() async {
    final nameController = TextEditingController(text: _profileName);
    final emailController = TextEditingController(text: _profileEmail);
    final formKey = GlobalKey<FormState>();
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: t.panel,
        title: Text('TORA PLAYER PROFILE', style: TextStyle(color: t.accent, fontWeight: FontWeight.w900)),
        content: Form(
          key: formKey,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextFormField(
              controller: nameController,
              maxLength: 24,
              decoration: const InputDecoration(labelText: 'Player name'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter a player name' : null,
            ),
            TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email (optional)'),
            ),
            const SizedBox(height: 6),
            const Text('دا پروفایل یوازې په همدې موبایل کې ساتل کېږي؛ آنلاین ننوتل لا فعال نه دي.',
              style: TextStyle(color: Colors.white60, fontSize: 11)),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('CANCEL')),
          FilledButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) Navigator.pop(ctx, true);
            },
            child: const Text('SAVE PROFILE'),
          ),
        ],
      ),
    );
    if (result == true) {
      await _saveRoyalProfile(nameController.text.trim(), emailController.text.trim());
      if (mounted) _toast('Player profile saved on this device.');
    }
    nameController.dispose();
    emailController.dispose();
  }

  Future<void> _finishRoyalSignIn(UserCredential credential) async {
    final user = credential.user;
    if (user == null) return;
    final prefs = await SharedPreferences.getInstance();
    if (user.displayName?.isNotEmpty == true) {
      await prefs.setString('tora_profile_name', user.displayName!);
    }
    await prefs.setString('tora_profile_email', user.email ?? user.phoneNumber ?? '');
    await _loadRoyalProfile();
    if (mounted) _toast('TORA account connected successfully.');
  }

  Future<void> _openRoyalLogin() async {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    bool createAccount = false;
    bool busy = false;
    String? authError;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, updateDialog) => AlertDialog(
          backgroundColor: const Color(0xFF0D0E12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: t.accent.withOpacity(.85), width: 1.4),
          ),
          titlePadding: const EdgeInsets.fromLTRB(22, 22, 22, 8),
          contentPadding: const EdgeInsets.fromLTRB(22, 8, 22, 8),
          title: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [t.accent, const Color(0xFF8B6428)],
                  ),
                  boxShadow: [
                    BoxShadow(color: t.accent.withOpacity(.22), blurRadius: 14),
                  ],
                ),
                child: const Icon(Icons.workspace_premium_rounded,
                    color: Color(0xFF090B10), size: 27),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('TORA ACCOUNT',
                      style: TextStyle(
                        color: t.accent, fontSize: 17,
                        fontWeight: FontWeight.w900, letterSpacing: 1.1,
                      )),
                    const SizedBox(height: 2),
                    const Text('WELCOME TO THE ROYAL TABLE',
                      style: TextStyle(
                        color: Colors.white54, fontSize: 9,
                        letterSpacing: 1.0, fontWeight: FontWeight.w600,
                      )),
                  ],
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 360,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 12),
                  margin: const EdgeInsets.only(bottom: 13),
                  decoration: BoxDecoration(
                    color: const Color(0xFF17130B),
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(color: t.accent.withOpacity(.38)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock_rounded, color: Color(0xFFD6B15C), size: 15),
                      SizedBox(width: 7),
                      Text('SIGN IN TO SAVE YOUR PLAYER PROFILE',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white70, fontSize: 9,
                          fontWeight: FontWeight.w700, letterSpacing: .65,
                        )),
                    ],
                  ),
                ),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email address',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(width: double.infinity, child: ElevatedButton.icon(
                  icon: const Icon(Icons.email_rounded, size: 20),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: t.accent,
                    foregroundColor: const Color(0xFF090B10),
                    elevation: 3,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w900, letterSpacing: .7, fontSize: 11,
                    ),
                  ),
                  onPressed: busy ? null : () async {
                    final email = emailController.text.trim();
                    final password = passwordController.text;
                    if (email.isEmpty || password.length < 6) {
                      updateDialog(() => authError = 'Enter a valid email and a password of at least 6 characters.');
                      return;
                    }
                    updateDialog(() {
                      busy = true;
                      authError = null;
                    });
                    try {
                      final auth = FirebaseAuth.instance;
                      final result = await (createAccount
                          ? auth.createUserWithEmailAndPassword(email: email, password: password)
                          : auth.signInWithEmailAndPassword(email: email, password: password))
                          .timeout(const Duration(seconds: 25));
                      await _finishRoyalSignIn(result);
                      if (dialogContext.mounted) Navigator.pop(dialogContext);
                    } on FirebaseAuthException catch (e) {
                      if (dialogContext.mounted) {
                        updateDialog(() => authError = e.message ?? e.code);
                      }
                    } on TimeoutException {
                      if (dialogContext.mounted) {
                        updateDialog(() => authError = 'Connection timed out. Check internet and try again.');
                      }
                    } catch (e) {
                      if (dialogContext.mounted) {
                        updateDialog(() => authError = 'Login failed: $e');
                      }
                    } finally {
                      if (dialogContext.mounted) updateDialog(() => busy = false);
                    }
                  },
                  label: Text(createAccount ? 'CREATE EMAIL ACCOUNT' : 'SIGN IN WITH EMAIL'),
                )),
                if (authError != null) Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    authError!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                  ),
                ),
                TextButton(
                  onPressed: busy ? null : () => updateDialog(() {
                    createAccount = !createAccount;
                    authError = null;
                  }),
                  child: Text(createAccount ? 'Already registered? Sign in' : 'New player? Create account'),
                ),
                const Divider(color: Colors.white24, height: 22),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: null,
                    icon: const Icon(Icons.chat_bubble_outline),
                    label: const Text('WHATSAPP LOGIN — COMING SOON'),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'WhatsApp login is not available yet. It will be added when a reliable free option is available.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white38, fontSize: 9),
                ),
                const Divider(color: Colors.white24, height: 22),
                SizedBox(width: double.infinity, child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color(0xFF1877F2).withOpacity(.10),
                    side: const BorderSide(color: Color(0xFF1877F2), width: 1.3),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w900, letterSpacing: .7, fontSize: 11,
                    ),
                  ),
                  onPressed: busy ? null : () async {
                    updateDialog(() => busy = true);
                    try {
                      final facebookResult = await FacebookAuth.instance.login(
                        permissions: const ['email', 'public_profile'],
                      );
                      if (facebookResult.status == LoginStatus.success &&
                          facebookResult.accessToken != null) {
                        final credential = FacebookAuthProvider.credential(
                          facebookResult.accessToken!.tokenString,
                        );
                        final result = await FirebaseAuth.instance
                            .signInWithCredential(credential)
                            .timeout(const Duration(seconds: 30));
                        await _finishRoyalSignIn(result);
                        if (dialogContext.mounted) Navigator.pop(dialogContext);
                      } else if (facebookResult.status == LoginStatus.cancelled) {
                        if (dialogContext.mounted) {
                          updateDialog(() => authError = 'Facebook login was cancelled.');
                        }
                      } else {
                        final message = facebookResult.message ??
                            facebookResult.status.name;
                        if (dialogContext.mounted) {
                          updateDialog(() => authError = 'Facebook login failed: $message');
                        }
                      }
                    } on FirebaseAuthException catch (e) {
                      if (dialogContext.mounted) {
                        updateDialog(() => authError = e.message ?? e.code);
                      }
                    } catch (e) {
                      if (dialogContext.mounted) {
                        updateDialog(() => authError = 'Facebook login failed: $e');
                      }
                    } finally {
                      if (dialogContext.mounted) updateDialog(() => busy = false);
                    }
                  },
                  icon: const Icon(Icons.facebook, color: Color(0xFF1877F2), size: 27),
                  label: const Text('CONTINUE WITH FACEBOOK'),
                )),
                if (busy) const Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: CircularProgressIndicator(),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Email login is available. Facebook requires Meta app credentials and Firebase provider setup.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white38, fontSize: 9),
                ),
              ]),
            ),
          ),
          actions: [
            TextButton(
              onPressed: busy ? null : () => Navigator.pop(dialogContext),
              child: const Text('CLOSE'),
            ),
          ],
        ),
      ),
    );
    emailController.dispose();
    passwordController.dispose();
  }

  Future<void> _signOutRoyal() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: t.panel,
        title: Text('SIGN OUT',
          style: TextStyle(color: t.accent, fontWeight: FontWeight.w900)),
        content: const Text(
          'Are you sure you want to sign out of your TORA account?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('CANCEL'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: t.accent,
              foregroundColor: Colors.black,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('SIGN OUT'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    // Close the account sheet before changing the signed-in state.
    Navigator.of(context).pop();
    try {
      await FirebaseAuth.instance.signOut();
      await _loadRoyalProfile();
      if (mounted) _toast('Signed out of TORA account.');
    } catch (e) {
      if (mounted) _toast('Could not sign out: $e');
    }
  }

  Future<void> _royalAccount() async {
    if (!_profileLoaded) await _loadRoyalProfile();
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [Color.lerp(t.panel, t.accent, .16)!, t.background, const Color(0xFF050506)]),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
          border: Border.all(color: t.accent.withOpacity(.8), width: 1.4),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.account_circle_rounded, color: t.accent, size: 38),
          const SizedBox(height: 6),
          Text('ROYAL PLAYER ACCOUNT', style: TextStyle(color: t.accent, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 17)),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: t.panel, borderRadius: BorderRadius.circular(15),
              border: Border.all(color: t.accent.withOpacity(.4))),
            child: Row(children: [
              CircleAvatar(backgroundColor: t.accent.withOpacity(.15),
                child: Icon(Icons.person_rounded, color: t.accent)),
              const SizedBox(width: 11),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(_profileName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                Text(_profileEmail.isEmpty ? 'No email added' : _profileEmail,
                  style: const TextStyle(color: Colors.white60, fontSize: 10)),
              ])),
              IconButton(onPressed: () { Navigator.pop(ctx); _editRoyalProfile(); },
                icon: Icon(Icons.edit_rounded, color: t.accent), tooltip: 'Edit profile'),
            ]),
          ),
          const SizedBox(height: 10),
          SizedBox(width: double.infinity, child: OutlinedButton.icon(
            onPressed: FirebaseAuth.instance.currentUser == null ? _openRoyalLogin : _signOutRoyal,
            icon: Icon(FirebaseAuth.instance.currentUser == null ? Icons.login_rounded : Icons.logout_rounded),
            label: Text(FirebaseAuth.instance.currentUser == null ? 'SIGN IN / CREATE ACCOUNT' : 'SIGN OUT'),
            style: OutlinedButton.styleFrom(
              foregroundColor: t.accent,
              side: BorderSide(color: t.accent.withOpacity(.65)),
            ),
          )),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: _hasVipAccess ? t.accent.withOpacity(.12) : t.panel,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: t.accent.withOpacity(.55)),
            ),
            child: Row(children: [
              Icon(Icons.diamond_rounded, color: t.accent, size: 28),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(_hasVipAccess ? 'ROYAL VIP • ACTIVE' : 'ROYAL VIP • NOT ACTIVE',
                  style: TextStyle(color: t.accent, fontWeight: FontWeight.w900, fontSize: 12)),
                const SizedBox(height: 3),
                const Text('Lifetime membership entitlement',
                  style: TextStyle(color: Colors.white60, fontSize: 10)),
              ])),
              Icon(_hasVipAccess ? Icons.verified_rounded : Icons.lock_outline_rounded,
                color: t.accent),
            ]),
          ),
          const SizedBox(height: 12),
          Align(alignment: Alignment.centerLeft,
            child: Text('VIP BENEFITS', style: TextStyle(color: t.accent, fontWeight: FontWeight.w900, letterSpacing: 1))),
          const SizedBox(height: 7),
          for (final benefit in [
            'All Premium card faces and backs',
            'Golden visual effects and animations',
            'Exclusive Royal profile frames',
            'Ad-Free experience when ads are enabled',
          ])
            Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(children: [
              Icon(_hasVipAccess ? Icons.check_circle_rounded : Icons.lock_rounded,
                color: t.accent, size: 16),
              const SizedBox(width: 9),
              Expanded(child: Text(benefit, style: const TextStyle(color: Colors.white70, fontSize: 11))),
            ])),
          const SizedBox(height: 12),
          Text('د TORA حساب د Firebase له لارې ننوځي. د لوبې امتیازات او تادیات جلا دي؛ VIP یوازې د راتلونکي تایید شوي پېرود له لارې فعالېږي.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white54, fontSize: 10, height: 1.4)),
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, child: OutlinedButton.icon(
            onPressed: () { Navigator.pop(ctx); _editRoyalProfile(); },
            icon: const Icon(Icons.manage_accounts_rounded),
            label: const Text('EDIT PLAYER PROFILE'),
            style: OutlinedButton.styleFrom(foregroundColor: t.accent, side: BorderSide(color: t.accent.withOpacity(.6))),
          )),
        ]),
      ),
    );
  }
  List<String> get _myHand => _hands[0];
  int _team(int seat) => (seat == 0 || seat == 2) ? 0 : 1;

  // TORA play order: BOTTOM (Player 1) -> RIGHT (Player 2) -> TOP (Player 3) -> LEFT (Player 4).
  // Fixed table positions: seat 0=bottom, seat 1=right, seat 2=top, seat 3=left.
  static const List<int> _seatCycle = [0, 1, 2, 3];
  int _seatAtOffset(int startSeat, int offset) {
    final startIndex = _seatCycle.indexOf(startSeat);
    return _seatCycle[(startIndex + offset) % 4];
  }

  int get _playedCount => _trick.where((c) => c != null).length;

  void _deal({bool first = false}) {
    final startSeat = first ? 0 : _nextDealerAndLeader;
    final deck = [for (final suit in _suits) for (final rank in _ranks) '$rank$suit']..shuffle(_random);
    setState(() {
      for (int i = 0; i < 4; i++) {
        _hands[i].clear();
        _won[i].clear();
      }
      _dealDeck = deck;
      _dealProgress = 0;
      _lastDealtSeat = -1;
      _dealing = true;
      _trick.fillRange(0, 4, null);
      _trickOrder.clear();
      _trickSeats.clear();
      _history.clear();
      _takkolCount[0] = 0;
      _takkolCount[1] = 0;
      _turn = startSeat;
      _leader = startSeat;
      _ledSuit = null;
      _aiBusy = false;
      _gameOver = false;
      _checkingClaim = false;
      _resolvingTrick = false;
      _auditShown = false;
      _lastWinner = -1;
      _round++;
      _status = 'SHUFFLING & DEALING CARDS...';
    });
    _animateDeal(deck, startSeat);
  }

  Future<void> _animateDeal(List<String> deck, int startSeat) async {
    // Deal clockwise from the first player; next rounds start with the Q♠ winner.
    for (int i = 0; i < deck.length; i++) {
      await Future.delayed(const Duration(milliseconds: 65));
      if (!mounted || !_dealing) return;
      final seat = _seatAtOffset(startSeat, i);
      setState(() {
        _hands[seat].add(deck[i]);
        _hands[seat].sort(_compareCards);
        _dealProgress = i + 1;
        _lastDealtSeat = seat;
        _status = 'DEALING: ${_names[seat]}  •  ${i + 1}/52';
      });
    }
    if (!mounted) return;
    setState(() {
      _dealing = false;
      _lastDealtSeat = -1;
      // The Q♠ trick winner must both deal and lead the new round.
      _turn = startSeat;
      _leader = startSeat;
      _status = 'CARDS DEALT — ${_names[startSeat]} DEALS AND PLAYS FIRST';
    });
    // Automatically exchange Q♠ after all 52 cards have been dealt.
    _resolveQueenOfSpadesExchange();
    // If the Q♠ winner is an AI player, let that player make the first play
    // automatically; otherwise the human player (seat 0) can play manually.
    if (startSeat != 0 && mounted && !_gameOver) {
      await Future.delayed(const Duration(milliseconds: 450));
      if (mounted && !_gameOver && !_dealing && _turn == startSeat) {
        _runAi();
      }
    }
  }

  void _resolveQueenOfSpadesExchange() {
    const queen = 'Q♠';
    final owner = _hands.indexWhere((hand) => hand.contains(queen));
    if (owner < 0) return;

    // The Queen holder must have no other Spades.
    final ownerSpades = _hands[owner].where((card) => _suit(card) == '♠').length;
    if (ownerSpades != 1) return;

    final partner = (owner + 2) % 4;
    final partnerSpades = _hands[partner]
        .where((card) => _suit(card) == '♠' && card != queen)
        .toList()
      ..sort(_compareCards);

    late int recipient;
    late String returnedSpade;
    late String message;

    if (partnerSpades.length >= 3) {
      // Partner qualifies: exchange Q♠ for their lowest Spade automatically.
      recipient = partner;
      returnedSpade = partnerSpades.first;
      message = 'Q♠ EXCHANGE: ${_names[owner]} gave Q♠ to ${_names[recipient]} and received ${returnedSpade}.';
    } else {
      // Partner has 0–2 Spades: pass Q♠ to the opposing player holding most Spades.
      final opponents = [for (int seat = 0; seat < 4; seat++) if (_team(seat) != _team(owner)) seat];
      opponents.sort((a, b) {
        final countA = _hands[a].where((card) => _suit(card) == '♠').length;
        final countB = _hands[b].where((card) => _suit(card) == '♠').length;
        if (countA != countB) return countB.compareTo(countA);
        return a.compareTo(b);
      });
      recipient = opponents.first;
      final available = _hands[recipient]
          .where((card) => _suit(card) == '♠')
          .toList()
        ..sort(_compareCards);
      if (available.isEmpty) return;
      returnedSpade = available.first;
      message = 'Q♠ TRANSFER: ${_names[owner]} gave Q♠ to opposing player ${_names[recipient]} and received ${returnedSpade}.';
    }

    setState(() {
      _hands[owner].remove(queen);
      _hands[recipient].remove(returnedSpade);
      _hands[recipient].add(queen);
      _hands[owner].add(returnedSpade);
      _hands[owner].sort(_compareCards);
      _hands[recipient].sort(_compareCards);
      _status = message;
    });

    // Keep the exchange visible so the human player can see who gave and received which card.
    _toast(message);
  }

  int _compareCards(String a, String b) {
    final sa = _suits.indexOf(a.substring(a.length - 1));
    final sb = _suits.indexOf(b.substring(b.length - 1));
    if (sa != sb) return sa.compareTo(sb);
    return _ranks.indexOf(a.substring(0, a.length - 1)).compareTo(_ranks.indexOf(b.substring(0, b.length - 1)));
  }
  String _suit(String card) => card.substring(card.length - 1);
  String _rank(String card) => card.substring(0, card.length - 1);
  int _rankValue(String card) => _ranks.indexOf(_rank(card));
  bool _isRed(String suit) => suit == '♥' || suit == '♦';

  List<String> _legalCards(int seat) {
    final h = _hands[seat];
    if (_ledSuit == null || !h.any((c) => _suit(c) == _ledSuit)) return List<String>.from(h);
    return h.where((c) => _suit(c) == _ledSuit).toList();
  }

  void _playCard(int seat, String card) {
    if (_gameOver || _dealing || _aiBusy || _checkingClaim || _resolvingTrick || _turn != seat || !_hands[seat].contains(card)) return;
    final legal = _legalCards(seat);
    if (!legal.contains(card)) {
      if (seat == 0) _toast('You must follow ${_ledSuit ?? 'the led suit'} when you have it.');
      return;
    }
    setState(() {
      bool takkolNow = false;
      _hands[seat].remove(card);
      _trick[seat] = card;
      _trickSeats.add(seat);
      if (_ledSuit == null) {
        _ledSuit = _suit(card);
        // Any suit can trigger Takkol: the other three players must have none.
        final noSuitInOtherHands = List.generate(4, (i) => i)
            .where((i) => i != seat)
            .every((i) => !_hands[i].any((c) => _suit(c) == _ledSuit));
        if (noSuitInOtherHands) {
          _recordTakkol(seat, 'played $_ledSuit');
          takkolNow = true;
        }
      }
      _status = _gameOver
          ? '${_names[seat]} team loses: fourth Takkol in this hand.'
          : (takkolNow ? 'TAKKOL! 30 points transferred.' : '${_names[seat]} played $card');
      if (_trickSeats.length == 4) {
        _resolvingTrick = true;
        _status = 'FOUR CARDS — TRICK COMPLETE';
      } else {
        _turn = _seatAtOffset(_leader, _trickSeats.length); // Continue clockwise from the trick leader: BOTTOM -> RIGHT -> TOP -> LEFT.
      }
    });
    if (_gameOver) {
      _showFinalAudit();
    } else if (_resolvingTrick) {
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (!mounted) return;
        setState(() {
          _resolveTrick();
          _resolvingTrick = false;
        });
        if (_gameOver) _showFinalAudit();
        else if (_turn != 0) _runAi();
      });
    } else if (mounted && _turn != 0) {
      _runAi();
    }
  }


  // Team-aware TORA AI:
  // seats 1+3 (indexes 0+2) are one team; seats 2+4 (indexes 1+3) are the other.
  // The AI tries to make the opposing team capture penalty cards and protects its partner.
  String _chooseStrategicAiCard(int seat, List<String> legal) {
    final myTeam = _team(seat);
    double bestScore = double.negativeInfinity;
    String best = legal.first;

    for (final candidate in legal) {
      final cards = List<String?>.from(_trick);
      cards[seat] = candidate;
      final seats = [..._trickSeats, seat];
      final led = _ledSuit ?? _suit(candidate);

      int winner = seats.first;
      String high = cards[winner]!;
      for (final s in seats.skip(1)) {
        final played = cards[s]!;
        if (_suit(played) == led &&
            (_suit(high) != led || _rankValue(played) > _rankValue(high))) {
          winner = s;
          high = played;
        }
      }

      final winningTeam = _team(winner);
      final trickCards = cards.whereType<String>().toList();
      final penalty = trickCards.fold<int>(
        0,
        (sum, card) => sum + _cardPenalty(card),
      );
      final candidatePenalty = _cardPenalty(candidate);
      final winnerIsOurTeam = winningTeam == myTeam;

      double score = 0;

      if (penalty > 0) {
        // Strongly prefer an opponent to collect the penalty cards.
        score += winnerIsOurTeam ? -penalty * 8.0 : penalty * 7.0;
      }

      // If our partner is currently winning, do not overtake them with a high card.
      final partnerSeat = (seat + 2) % 4;
      final partnerIsInTrick = _trick[partnerSeat] != null;
      if (partnerIsInTrick && winner == seat && _team(partnerSeat) == myTeam) {
        score -= penalty > 0 ? 18.0 : 2.0;
      }

      // When an opponent is already winning a penalty-heavy trick, avoid taking it away.
      final opponentAlreadyWinning = _trickSeats.any((s) =>
          _team(s) != myTeam &&
          _trick[s] != null &&
          _suit(_trick[s]!) == led &&
          (winner == seat || _team(winner) != myTeam));
      if (opponentAlreadyWinning && penalty > 0 && winnerIsOurTeam) {
        score -= 12.0 + penalty * 2.0;
      }

      // Prefer to discard penalty cards only when the opponent is likely to win them.
      if (candidatePenalty > 0) {
        score += winnerIsOurTeam
            ? -candidatePenalty * 5.0
            : candidatePenalty * 4.0;
      }

      // Opponent AI (teams 2+4) actively tries to draw Q♠ out when it is
      // known to be in the human team's hands (Player 1 or Player 3).
      final queenInHumanTeam = _hands[0].contains('Q♠') || _hands[2].contains('Q♠');
      if (myTeam == 1 && queenInHumanTeam && _suit(candidate) == '♠') {
        // Prefer leading/following with a high spade to force the queen into play.
        score += 18.0 + _rankValue(candidate) * 1.8;
      }
      // Do not deliberately lead Q♠ from our own team if we hold it.
      if (candidate == 'Q♠' && myTeam == 1) score -= 35.0;

      // When no penalty is at stake, preserve high cards and use low cards first.
      score -= _rankValue(candidate) * (_ledSuit == null ? 0.55 : 0.18);

      // If following suit, avoid taking a clean trick from the opponents unless useful.
      if (_ledSuit != null && _suit(candidate) == led &&
          winnerIsOurTeam && penalty == 0) {
        score -= 1.2;
      }

      // Small deterministic tie-break keeps the AI's play consistent.
      score += (_ranks.length - _rankValue(candidate)) * 0.001;

      if (score > bestScore) {
        bestScore = score;
        best = candidate;
      }
    }
    return best;
  }

  // Takkol transfers whole 30-point blocks only from the opposing team's
  // existing ordinary-penalty balance. No partial block and no negative score.
  // Both teams continue using these same two shared score accounts.
  int _transferToSharedTeamScore(int winningTeam, {int times = 1}) {
    if (times <= 0) return 0;
    final opposingScore = winningTeam == 0 ? _teamTwo : _teamOne;
    final availableBlocks = opposingScore ~/ 30;
    final blocksToTransfer = times < availableBlocks ? times : availableBlocks;
    if (blocksToTransfer <= 0) return 0;

    final points = 30 * blocksToTransfer;
    if (winningTeam == 0) {
      _teamOne += points;
      _teamTwo -= points;
    } else {
      _teamTwo += points;
      _teamOne -= points;
    }

    // The 200-point losing limit applies immediately to every shared-score
    // update, including Takkol transfers (not only at the end of a hand).
    if (_teamOne >= 200 || _teamTwo >= 200) {
      _gameOver = true;
      _matchFinished = true;
      final loser = _teamOne >= 200
          ? 'Team 1 (Player 1 + Player 3)'
          : 'Team 2 (Player 2 + Player 4)';
      _status = '$loser reached 200 penalty points and loses the match.';
    }
    return points;
  }

  void _recordTakkol(int seat, String reason, {int transferredCards = 1}) {
    if (transferredCards <= 0 || _gameOver) return;
    final team = _team(seat);
    final transferredPoints =
        _transferToSharedTeamScore(team, times: transferredCards);
    _takkolCount[team]++;
    final transferMessage = transferredPoints == 0
        ? 'no points transferred (opponent has less than 30 penalty points)'
        : '$transferredPoints points transferred';
    _history.add('${_names[seat]} made Takkol ($reason): $transferMessage. Team Takkol count: ${_takkolCount[team]}/4.');
    if (_takkolCount[team] >= 4) {
      _gameOver = true;
      _matchFinished = true;
      _status = 'FOURTH TAKKOL — Team ${team + 1} loses this hand.';
    }
  }

  int _trickWinner() {
    final led = _ledSuit!;
    int winner = _trickSeats.first;
    String high = _trick[winner]!;
    for (final seat in _trickSeats.skip(1)) {
      final c = _trick[seat]!;
      if (_suit(c) == led && (_suit(high) != led || _rankValue(c) > _rankValue(high))) { winner = seat; high = c; }
    }
    return winner;
  }

  int _cardPenalty(String card) {
    final suit = _suit(card);
    if (suit == '♥') return 1;
    if (card == 'Q♠') return 9;
    if (card == 'J♣') return 5;
    if (card == '10♦') return 3;
    return 0;
  }

  int _roundPenalty(List<String> cards) {
    final hasQueen = cards.contains('Q♠');
    final otherPenaltyCards = cards.any(
      (c) => _suit(c) == '♥' || c == 'J♣' || c == '10♦',
    );

    // The spade queen alone carries no penalty.
    if (hasQueen && !otherPenaltyCards) return 0;

    final raw = cards.fold<int>(
      0,
      (sum, card) => sum + _cardPenalty(card),
    );

    if (raw < 10) return 0;
    if (raw <= 15) return 10;
    if (raw <= 20) return 20;
    return 30;
  }

  void _resolveTrick() {
    final winner = _trickWinner();
    final captured = _trick.whereType<String>().toList();
    if (captured.contains('Q♠')) {
      _nextDealerAndLeader = winner;
      _history.add('${_names[winner]} captured Q♠ and will deal and lead the next round.');
    }
    for (final c in captured) {
      _won[winner].add(c);
    }
    _lastWinner = winner;
    _history.add('${_names[winner]} won a trick: ${captured.join(' ')}');
    _status = '${_names[winner]} won the trick and leads next.';
    _leader = winner;
    _turn = winner;
    _trick.fillRange(0, 4, null);
    _trickSeats.clear();
    _ledSuit = null;

    if (_hands.every((h) => h.isEmpty)) {
      final teamOneCards = [..._won[0], ..._won[2]];
      final teamTwoCards = [..._won[1], ..._won[3]];
      _teamOne += _roundPenalty(teamOneCards);
      _teamTwo += _roundPenalty(teamTwoCards);
      _gameOver = true;
      _matchFinished = _teamOne >= 200 || _teamTwo >= 200;
      final loser = _teamOne >= 200
          ? 'Team 1 (Player 1 + Player 3)'
          : (_teamTwo >= 200 ? 'Team 2 (Player 2 + Player 4)' : 'No team');
      _status = loser == 'No team'
          ? 'Round complete. Scores: $_teamOne / $_teamTwo'
          : '$loser reached 200 penalty points and loses.';
    }
  }

  Future<void> _showFinalAudit() async {
    if (!_gameOver || _auditShown || !mounted) return;
    _auditShown = true;
    final teamA = [..._won[0], ..._won[2]]..sort(_compareCards);
    final teamB = [..._won[1], ..._won[3]]..sort(_compareCards);
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: t.panel,
        insetPadding: const EdgeInsets.all(14),
        child: SizedBox(
          width: MediaQuery.of(ctx).size.width * .94,
          height: MediaQuery.of(ctx).size.height * .84,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                Row(children: [
                  Expanded(child: Text('FINAL CARD AUDIT — ALL 52 CARDS',
                    style: TextStyle(color: t.accent, fontWeight: FontWeight.w900, letterSpacing: 1))),
                  IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close)),
                ]),
                Expanded(child: Row(children: [
                  Expanded(child: _auditTeam('TEAM 1 (PLAYER 1 + 3)', teamA, _teamOne)),
                  const SizedBox(width: 12),
                  Expanded(child: _auditTeam('TEAM 2 (PLAYER 2 + 4)', teamB, _teamTwo)),
                ])),
                const SizedBox(height: 8),
                Text('Cards captured: ${teamA.length + teamB.length}/52',
                  style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _auditTeam(String title, List<String> cards, int score) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: t.background.withOpacity(.65),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: t.accent.withOpacity(.6)),
      ),
      child: Column(children: [
        Text('$title  •  $score POINTS',
          style: TextStyle(color: t.accent, fontWeight: FontWeight.w900, fontSize: 12)),
        const SizedBox(height: 8),
        Expanded(child: SingleChildScrollView(
          child: Wrap(
            spacing: 4,
            runSpacing: 5,
            children: [for (final card in cards) _cardFace(card, width: 35, height: 50)],
          ),
        )),
        Text('${cards.length} cards', style: const TextStyle(color: Colors.white60, fontSize: 10)),
      ]),
    );
  }

  Future<void> _runAi() async {
    if (_aiBusy || _gameOver || _dealing || _turn == 0 || _checkingClaim || _resolvingTrick) return;
    _aiBusy = true;
    setState(() => _status = '${_names[_turn]} is thinking…');
    await Future.delayed(const Duration(milliseconds: 650));
    if (!mounted) return;
    if (_gameOver) {
      _aiBusy = false;
      return;
    }
    final seat = _turn;
    final legal = _legalCards(seat);
    if (legal.isNotEmpty) {
      final chosen = _chooseStrategicAiCard(seat, legal);
      _aiBusy = false;
      _playCard(seat, chosen);
    } else {
      _aiBusy = false;
    }
  }

  Future<void> _claimNoMore(int seat) async {
    if (_gameOver || _dealing || _aiBusy || _checkingClaim || _turn != seat) {
      _toast('Use this option when it is your turn.'); return;
    }
    final suit = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: t.panel,
      builder: (ctx) => SafeArea(child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('${_names[seat]} — choose a suit',
            style: TextStyle(color: t.accent, fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 14),
          Wrap(spacing: 10, runSpacing: 10, alignment: WrapAlignment.center,
            children: [for (final s in _suits) _suitButton(ctx, s)]),
        ]),
      )),
    );
    if (suit == null || !mounted) return;

    // NO MORE checks only the other three players' hands. The caller's own
    // cards are irrelevant; every remaining card elsewhere costs 30 points.
    final others = <int, List<String>>{};
    for (int i = 0; i < 4; i++) {
      if (i != seat) others[i] = _hands[i].where((c) => _suit(c) == suit).toList();
    }
    final countedCards = others.values.fold<int>(0, (sum, cards) => sum + cards.length);

    setState(() => _checkingClaim = true);
    setState(() {
      if (countedCards > 0) {
        // Add 30 penalty points per card to the caller's team and subtract
        // the same amount from the opposing team's penalty account.
        _recordTakkol(seat, 'NO MORE $suit', transferredCards: countedCards);
      } else {
        _history.add('${_names[seat]} called NO MORE for $suit; no cards remained in the other three hands.');
      }
      // Four or more cards remaining in the other hands means immediate loss.
      if (countedCards >= 4) {
        _gameOver = true;
        _matchFinished = true;
        _status = 'NO MORE failed: $countedCards cards remained. Team ${_team(seat) + 1} loses this hand.';
        _history.add('NO MORE penalty reached ${countedCards * 30} points; team loses immediately.');
      }
    });
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: t.panel,
        title: Text(_gameOver ? 'NO MORE — TEAM LOST' : 'NO MORE RESULT',
          style: TextStyle(color: _gameOver ? Colors.redAccent : t.accent, fontWeight: FontWeight.w900)),
        content: Text(countedCards == 0
          ? 'No $suit cards remained in the other three players’ hands. No points transferred.'
          : '$countedCards $suit card(s) remained in the other three players’ hands. $countedCards × 30 = ${countedCards * 30} penalty points added to your team and deducted from the opposing team.${countedCards >= 4 ? ' Your team loses immediately because four or more cards remained.' : ''}'),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx),
          child: Text('CONTINUE', style: TextStyle(color: t.accent)))],
      ),
    );
    if (!mounted) return;
    setState(() {
      _checkingClaim = false;
      if (_gameOver) _status = 'NO MORE — Team ${_team(seat) + 1} loses this hand.';
      else _status = 'NO MORE for $suit: $countedCards card(s), ${countedCards * 30} penalty points.';
    });
    if (_gameOver) {
      _showFinalAudit();
    } else if (seat != 0) {
      _runAi();
    }
  }

  Widget _suitButton(BuildContext ctx, String suit) => OutlinedButton(onPressed: () => Navigator.pop(ctx, suit), style: OutlinedButton.styleFrom(foregroundColor: _isRed(suit) ? Colors.redAccent : t.accent, side: BorderSide(color: t.accent), padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12)), child: Text(suit, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)));

  Future<void> _editNames() async {
    final controllers = List.generate(4, (i) => TextEditingController(text: _names[i]));
    await showDialog<void>(context: context, builder: (ctx) => AlertDialog(backgroundColor: t.panel, title: Text('PLAYER NAMES', style: TextStyle(color: t.accent)), content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [for (int i = 0; i < 4; i++) Padding(padding: const EdgeInsets.only(bottom: 9), child: TextField(controller: controllers[i], decoration: InputDecoration(labelText: 'Player ${i + 1}', border: const OutlineInputBorder(), isDense: true)))])), actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')), FilledButton(onPressed: () { setState(() { for (int i = 0; i < 4; i++) { if (controllers[i].text.trim().isNotEmpty) _names[i] = controllers[i].text.trim(); } }); Navigator.pop(ctx); }, child: const Text('SAVE'))]));
    for (final c in controllers) { c.dispose(); }
  }

  void _showRules() {
    const rules = '''• 52 cards: 13 cards per player.
• Two teams: Player 1 + Player 3 versus Player 2 + Player 4.
• Follow the suit led if you have that suit.
• If you do not have it, any suit may be played; it cannot win the trick.
• Highest card of the led suit wins. Winner collects all four cards and leads next.
• After dealing, if a player has Q♠ and no other Spades, an automatic exchange happens before play.
• If that player's partner has 3 or more Spades, the partner receives Q♠ and gives their lowest Spade in return.
• If the partner has 0–2 Spades, Q♠ goes to the opposing player holding the most Spades; that player gives their lowest Spade in return.
• The exchange is identical for both teams and every player keeps 13 cards. A notice names both players and the exchanged card.
• Whoever captures Q♠ deals the next round and plays its first card.
• Takkol and ordinary card penalties use the SAME two team score accounts; there is no separate Takkol score.
• Ordinary Takkol: any suit can trigger it when the other three players hold none of that suit; transfer 30 points from the opposing team's account to the caller's team account.
• NO MORE: ignore the caller's own hand. Count the chosen-suit cards in the other three hands, including the caller's partner.
• For each counted card, add 30 to the caller's team's shared score and subtract 30 from the opposing team's shared score. Four or more remaining cards make the caller's team lose immediately.
• The fourth scoring Takkol by the same team in one hand makes that team lose the hand immediately.
• Card penalties: each heart 1, Q♠ 9, J♣ 5, 10♦ 3.
• Match ends when either team reaches 200 penalty points.''';
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: t.panel,
        title: Text('TORA RULES', style: TextStyle(color: t.accent)),
        content: const SingleChildScrollView(child: Text(rules)),
        actions: [],
      ),
    );
  }

  void _toast(String text) { if (!mounted) return; ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text), duration: const Duration(seconds: 2))); }

  Color _suitColor(String suit) => _isRed(suit) ? const Color(0xFFE14B5A) : const Color(0xFFE9E2D1);

  Widget _cardFace(String card, {Key? key, double width = 52, double height = 74, bool back = false}) {
    if (back) {
      const backSymbols = ['♛', '✦', '❖', '♜', '♕'];
      const backColors = [Color(0xFF17120A), Color(0xFF102B20), Color(0xFF35121D), Color(0xFF12233D), Color(0xFFEEE3CB)];
      final style = _cardBackStyle.clamp(0, 4).toInt();
      return Container(key: key, width: width, height: height,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8),
          gradient: LinearGradient(colors: [Color.lerp(backColors[style], t.accent, .25)!, backColors[style]], begin: Alignment.topLeft, end: Alignment.bottomRight),
          border: Border.all(color: t.accent, width: style.isEven ? 1.8 : 1),
          boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 5, offset: Offset(1, 2))]),
        child: Center(child: Container(width: width*.76,height:height*.82,
          decoration: BoxDecoration(border: Border.all(color:t.accent.withOpacity(.85),width:style%3==0?2:1),borderRadius:BorderRadius.circular(style%2==0?5:18)),
          child: Stack(alignment:Alignment.center,children:[CustomPaint(size:Size(width*.7,height*.76),painter:_BackPatternPainter(t.accent,style)),Text(backSymbols[style],style:TextStyle(color:t.accent,fontSize:width*.48,fontWeight:FontWeight.w900))]))));
    }

    final suit = _suit(card);
    final rank = _rank(card);
    final suitIndex = _suits.indexOf(suit);
    final isRedSuit = _isRed(suit);
    // Standard, high-contrast suit colors: hearts/diamonds red; spades/clubs black.
    final ink = isRedSuit ? const Color(0xFFB51F35) : const Color(0xFF151923);
    const gold = Color(0xFFC49A43);
    const ivory = Color(0xFFFFFDF7);
    const facePalettes = [
      Color(0xFF8D3152), Color(0xFF315A86),
      Color(0xFF28765B), Color(0xFF794A91),
    ];
    final faceColor = facePalettes[suitIndex.clamp(0, 3)];
    final isFace = ['J', 'Q', 'K'].contains(rank);
    final isAce = rank == 'A';
    final faceStyle = _cardFaceStyle.clamp(0, 4).toInt();
    final radius = [5.0, 11.0, 7.0, 14.0][suitIndex.clamp(0, 3)];

    return Container(
      key: key,
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFFFFF), ivory, Color(0xFFECE5D6)],
        ),
        border: Border.all(color: gold, width: 1.8),
        boxShadow: const [
          BoxShadow(color: Colors.black54, blurRadius: 5, offset: Offset(1, 2)),
        ],
      ),
      child: Stack(clipBehavior: Clip.hardEdge, children: [
        // Four suit-specific corner ornaments make the card identities distinct.
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _CardFacePatternPainter(gold.withOpacity(.9), (faceStyle + suitIndex) % 5),
            ),
          ),
        ),
        Positioned.fill(
          child: Padding(
            padding: EdgeInsets.all(width * .075),
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: faceColor.withOpacity(.72), width: 1.05),
                borderRadius: BorderRadius.circular(radius),
              ),
            ),
          ),
        ),
        Positioned(
          left: 4, top: 3,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(rank, style: TextStyle(
              color: ink, fontWeight: FontWeight.w900,
              fontSize: width * .25, height: .92,
            )),
            Text(suit, style: TextStyle(
              color: ink, fontSize: width * .22, height: .92,
              fontWeight: FontWeight.w900,
            )),
          ]),
        ),
        if (isFace)
          Center(
            child: Container(
              width: width * .70,
              height: height * .65,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [faceColor.withOpacity(.95), const Color(0xFF17202B), faceColor.withOpacity(.82)],
                ),
                border: Border.all(color: gold, width: 1.35),
              ),
              child: Stack(alignment: Alignment.center, children: [
                Positioned.fill(
                  child: CustomPaint(painter: _FacePortraitPainter(rank, faceColor)),
                ),
                Positioned(top: 1, child: Text(suit, style: TextStyle(
                  color: const Color(0xFFFFE7A5),
                  fontSize: width * .20, fontWeight: FontWeight.w900,
                ))),
                Positioned(bottom: 1, child: Text(
                  rank == 'J' ? 'KNIGHT' : rank == 'Q' ? 'QUEEN' : 'KING',
                  style: TextStyle(
                    color: const Color(0xFFFFE7A5),
                    fontSize: width * .075,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .3,
                  ),
                )),
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(painter: _FaceOrnamentPainter(const Color(0xFFFFD15C))),
                  ),
                ),
              ]),
            ),
          )
        else
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: width * .16, vertical: height * .12),
              child: CustomPaint(
                painter: _CardPipsPainter(rank, suit, ink, gold),
              ),
            ),
          ),
        Positioned(
          right: 4, bottom: 3,
          child: RotatedBox(
            quarterTurns: 2,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(rank, style: TextStyle(
                color: ink, fontWeight: FontWeight.w900,
                fontSize: width * .25, height: .92,
              )),
              Text(suit, style: TextStyle(
                color: ink, fontSize: width * .22, height: .92,
                fontWeight: FontWeight.w900,
              )),
            ]),
          ),
        ),
        if (isAce)
          Center(child: IgnorePointer(child: Text(suit, style: TextStyle(
            color: ink.withOpacity(.10), fontSize: width * .72,
            fontWeight: FontWeight.w900,
          )))),
      ]),
    );
  }

  Widget _seat(int seat, String position) => Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5), decoration: BoxDecoration(color: t.background.withOpacity(.94), borderRadius: BorderRadius.circular(10), border: Border.all(color: _turn == seat ? t.accent : t.accent.withOpacity(.35), width: _turn == seat ? 2 : 1)), child: Column(mainAxisSize: MainAxisSize.min, children: [Text(_names[seat], maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: _turn == seat ? t.accent : Colors.white, fontWeight: FontWeight.bold, fontSize: 10)), Text(position, style: const TextStyle(color: Colors.white60, fontSize: 8)), Text('${_hands[seat].length} cards', style: const TextStyle(color: Colors.white70, fontSize: 8))]));

  Widget _playedCard(int seat) {
    final card = _trick[seat];
    if (card == null) return const SizedBox(width: 48, height: 68);
    return _cardFace(card, width: 48, height: 68);
  }

  Widget _dealAnimationWidget() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: t.background.withOpacity(.97),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: t.accent, width: 1.4),
      boxShadow: [BoxShadow(color: t.accent.withOpacity(.18), blurRadius: 12)],
    ),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Text('DEALING CARDS', style: TextStyle(color: t.accent, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.4)),
      const SizedBox(height: 5),
      AnimatedSwitcher(
        duration: const Duration(milliseconds: 140),
        child: _cardFace('A♠', key: ValueKey<int>(_dealProgress), back: true, width: 34, height: 48),
      ),
      const SizedBox(height: 5),
      Text('$_dealProgress / 52', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12)),
      const SizedBox(height: 5),
      SizedBox(width: 125, child: LinearProgressIndicator(
        value: _dealProgress / 52,
        minHeight: 4,
        backgroundColor: Colors.white12,
        valueColor: AlwaysStoppedAnimation<Color>(t.accent),
      )),
      const SizedBox(height: 6),
      Wrap(spacing: 7, runSpacing: 3, alignment: WrapAlignment.center, children: [
        for (int seat = 0; seat < 4; seat++)
          Text('${_names[seat]}: ${_hands[seat].length}',
            style: TextStyle(color: _lastDealtSeat == seat ? t.accent : Colors.white70, fontSize: 8, fontWeight: _lastDealtSeat == seat ? FontWeight.w900 : FontWeight.normal)),
      ]),
      if (_lastDealtSeat >= 0)
        Text('Now dealing to ${_names[_lastDealtSeat]}',
          style: TextStyle(color: t.accent, fontSize: 9, fontWeight: FontWeight.bold)),
    ]),
  );

  Widget _tableSeat(int seat, String position, {double fontSize = 12}) =>
      Container(
        constraints: const BoxConstraints(maxWidth: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _turn == seat
                ? [t.panel, Color.lerp(t.panel, t.accent, .20)!]
                : [const Color(0xF51A1B20), const Color(0xE8090A0E)],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _turn == seat ? t.accent : t.accent.withOpacity(.48),
            width: _turn == seat ? 2.2 : 1.1,
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(.38), blurRadius: 10, offset: const Offset(0, 3)),
            if (_turn == seat) BoxShadow(color: t.accent.withOpacity(.22), blurRadius: 12),
          ],
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(mainAxisSize: MainAxisSize.min, children: [
            if (_turn == seat) Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Icon(Icons.circle, size: fontSize * .55, color: t.accent),
            ),
            Flexible(child: Text(_names[seat], maxLines: 1, overflow: TextOverflow.ellipsis,
              style: TextStyle(color: _turn == seat ? t.accent : Colors.white,
                fontWeight: FontWeight.w900, fontSize: fontSize))),
          ]),
          const SizedBox(height: 2),
          Text('$position  •  ${_hands[seat].length}/13',
            style: TextStyle(color: Colors.white70, fontSize: fontSize * .72, fontWeight: FontWeight.w600)),
        ]),
      );

  Widget _centerCross() => LayoutBuilder(builder: (context, constraints) {
    final w = constraints.maxWidth;
    final h = constraints.maxHeight;
    // Keep all four played cards together in the center in a clear plus layout.
    final cardH = (h * .29).clamp(56.0, 84.0).toDouble();
    final cardW = cardH / 1.43;
    final gap = (h * .02).clamp(5.0, 8.0).toDouble();
    final sideSeatW = (w * .18).clamp(86.0, 138.0).toDouble();
    final seatFont = (w * .009).clamp(9.0, 12.0).toDouble();
    final cx = w / 2;
    final cy = h / 2;

    // Seat 2 is the partner at the top; seat 0 is the human player at the bottom.
    // Each played card stays in front of the seat belonging to that player.
    final topCard = _trick[2] == null
        ? SizedBox(width: cardW, height: cardH)
        : _cardFace(_trick[2]!, width: cardW, height: cardH);
    final bottomCard = _trick[0] == null
        ? SizedBox(width: cardW, height: cardH)
        : _cardFace(_trick[0]!, width: cardW, height: cardH);
    final leftCard = _trick[3] == null
        ? SizedBox(width: cardW, height: cardH)
        : _cardFace(_trick[3]!, width: cardW, height: cardH);
    final rightCard = _trick[1] == null
        ? SizedBox(width: cardW, height: cardH)
        : _cardFace(_trick[1]!, width: cardW, height: cardH);

    return Stack(clipBehavior: Clip.hardEdge, children: [
      // Player information remains visible around the table edges.
      Positioned(top: 3, left: 4,
        child: _tableSeat(2, 'TOP', fontSize: seatFont)),
      Positioned(bottom: 3, left: 4,
        child: _tableSeat(0, 'YOU', fontSize: seatFont)),
      Positioned(left: 3, top: 0, bottom: 0, width: sideSeatW,
        child: Center(child: _tableSeat(3, 'LEFT', fontSize: seatFont))),
      Positioned(right: 3, top: 0, bottom: 0, width: sideSeatW,
        child: Center(child: _tableSeat(1, 'RIGHT', fontSize: seatFont))),

      // Four played cards: top, bottom, left and right of the center point.
      Positioned(left: cx - cardW / 2, top: cy - cardH - gap, child: topCard),
      Positioned(left: cx - cardW / 2, top: cy + gap, child: bottomCard),
      Positioned(left: cx - cardW - gap, top: cy - cardH / 2, child: leftCard),
      Positioned(left: cx + gap, top: cy - cardH / 2, child: rightCard),

      if (_dealing)
        Center(child: _dealAnimationWidget())
      else
        Positioned(top: 4, right: sideSeatW + 8,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: (w * .28).clamp(110.0, 230.0).toDouble()),
            child: Text(_ledSuit == null ? _status : 'LEAD: $_ledSuit  •  $_status',
              textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: TextStyle(color: t.accent,
                fontSize: (w * .007).clamp(8.0, 10.0).toDouble(),
                fontWeight: FontWeight.w900)),
          )),
    ]);
  });

  Widget _scoreBox(String label, int score) => Container(
    padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: [Color.lerp(t.panel, t.accent, .15)!, t.panel, t.background],
      ),
      borderRadius: BorderRadius.circular(13),
      border: Border.all(color: t.accent.withOpacity(.82), width: 1.25),
      boxShadow: [BoxShadow(color: t.accent.withOpacity(.12), blurRadius: 9, offset: const Offset(0, 2))],
    ),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Expanded(child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.w700))),
      const SizedBox(width: 8),
      Text('$score', style: TextStyle(color: t.accent, fontSize: 19, height: 1,
        fontWeight: FontWeight.w900, shadows: [Shadow(color: t.accent.withOpacity(.28), blurRadius: 8)])),
    ]),
  );

  Future<void> _royalStore() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => Container(
        height: MediaQuery.of(ctx).size.height * .92,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color.lerp(t.panel, t.accent, .16)!, t.background, const Color(0xFF050506)],
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(color: t.accent.withOpacity(.85), width: 1.5),
          boxShadow: [BoxShadow(color: t.accent.withOpacity(.18), blurRadius: 26)],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(27)),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 26),
            children: [
              Center(child: Container(
                width: 46, height: 5,
                decoration: BoxDecoration(color: t.accent, borderRadius: BorderRadius.circular(8)),
              )),
              const SizedBox(height: 16),
              Icon(Icons.workspace_premium_rounded, color: t.accent, size: 34),
              const SizedBox(height: 5),
              Text('TORA ROYAL STORE', textAlign: TextAlign.center,
                style: TextStyle(color: t.accent, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 2.2)),
              const SizedBox(height: 5),
              const Text('شاهي ډیزاینونه او ځانګړي اختیارات',
                textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 12)),
              const SizedBox(height: 18),
              _settingsHeading('PREMIUM COLLECTION  •  راتلونکې ټولګه'),
              const SizedBox(height: 9),
              _storeOffer(
                icon: Icons.style_rounded,
                title: 'Royal Card Collection',
                subtitle: 'ځانګړي د ورقو مخونه او شاګانې',
                price: r'Global $4.99',
                status: 'COMING SOON',
              ),
              const SizedBox(height: 9),
              _storeOffer(
                icon: Icons.auto_awesome_rounded,
                title: 'Golden Effects',
                subtitle: 'طلایي ځلاوې او ځانګړي بصري افکتونه',
                price: r'Global $2.99',
                status: 'COMING SOON',
              ),
              const SizedBox(height: 9),
              _storeOffer(
                icon: Icons.workspace_premium_outlined,
                title: 'Royal Profile Frames',
                subtitle: 'د لوبغاړي لپاره ځانګړي شاهي چوکاټونه',
                price: r'Global $2.99',
                status: 'COMING SOON',
              ),
              const SizedBox(height: 9),
              _storeOffer(
                icon: Icons.block_rounded,
                title: 'Ad-Free TORA • Lifetime',
                subtitle: 'د اعلانونو د تل لپاره بندول؛ یو ځل پېرود',
                price: r'Global $29.99',
                status: 'COMING SOON',
              ),
              const SizedBox(height: 9),
              _storeOffer(
                icon: Icons.diamond_rounded,
                title: 'Royal VIP • Lifetime',
                subtitle: 'ټول Premium ډیزاینونه، افېکټونه او Ad-Free',
                price: r'Global $49.99',
                status: 'COMING SOON',
              ),
              const SizedBox(height: 18),
              _settingsHeading('REGIONAL PRICE LIST  •  د هېوادونو نرخونه'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: t.panel,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: t.accent.withOpacity(.42)),
                ),
                child: Column(children: [
                  Row(children: [
                    const Expanded(flex: 5, child: Text('PRODUCT',
                      style: TextStyle(color: Colors.white54, fontSize: 8, fontWeight: FontWeight.w900))),
                    _priceHeader('GLOBAL'),
                    _priceHeader('AF'),
                    _priceHeader('PK'),
                  ]),
                  const SizedBox(height: 6),
                  _regionalPriceRow('Royal Cards', r'$4.99', r'$2.49', r'$3.49'),
                  _regionalPriceRow('Golden Effects', r'$2.99', r'$1.49', r'$2.49'),
                  _regionalPriceRow('Profile Frames', r'$2.99', r'$1.49', r'$2.49'),
                  _regionalPriceRow('Ad-Free Lifetime', r'$29.99', r'$9.99', r'$14.99'),
                  _regionalPriceRow('Royal VIP Lifetime', r'$49.99', r'$19.99', r'$34.99', highlight: true),
                ]),
              ),
              const SizedBox(height: 8),
              const Text('VIP د ټولو Premium ظاهري ځانګړنو او د اعلانونو د تل لپاره بندولو امتیاز لري.',
                style: TextStyle(color: Colors.white70, fontSize: 10, height: 1.4)),
              const SizedBox(height: 18),
              _settingsHeading('ADVERTISING  •  د اعلانونو سیستم'),
              const SizedBox(height: 9),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: t.panel,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: t.accent.withOpacity(.48)),
                ),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Icon(Icons.campaign_rounded, color: t.accent, size: 25),
                  const SizedBox(width: 11),
                  const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('اعلانونه اوس غیرفعال دي',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13)),
                    SizedBox(height: 5),
                    Text('اعلانونه به یوازې د مناسب اعلان‌ورکوونکي او د عاید د ترلاسه کولو د ملاتړ تر تایید وروسته فعال شي. د لوبې د ورقو اچولو او نمرې حسابولو پر مهال به اعلان نه ښکاري.',
                      style: TextStyle(color: Colors.white70, fontSize: 11, height: 1.45)),
                  ])),
                ]),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: t.accent.withOpacity(.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: t.accent.withOpacity(.28)),
                ),
                child: Row(children: [
                  Icon(Icons.shield_outlined, color: t.accent, size: 20),
                  const SizedBox(width: 9),
                  const Expanded(child: Text(
                    'د TORA لوبې قوانین، نمرې، تکول او ۲۰۰ نمرو حد د ټولو لپاره یو شان پاتې کېږي.',
                    style: TextStyle(color: Colors.white70, fontSize: 11, height: 1.35),
                  )),
                ]),
              ),
              const SizedBox(height: 12),
              Center(child: Text('PREPARED STORE UI • BILLING DISABLED • NO CHARGES',
                textAlign: TextAlign.center,
                style: TextStyle(color: t.accent.withOpacity(.72), fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: .7))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _storeOffer({
    required IconData icon,
    required String title,
    required String subtitle,
    required String price,
    required String status,
  }) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      gradient: LinearGradient(colors: [t.panel, t.background]),
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: t.accent.withOpacity(.42)),
    ),
    child: Row(children: [
      Container(
        width: 42, height: 42,
        decoration: BoxDecoration(
          color: t.accent.withOpacity(.11),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: t.accent.withOpacity(.48)),
        ),
        child: Icon(icon, color: t.accent, size: 22),
      ),
      const SizedBox(width: 11),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900)),
        const SizedBox(height: 3),
        Text(subtitle, style: const TextStyle(color: Colors.white60, fontSize: 10)),
      ])),
      const SizedBox(width: 6),
      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Text(price, style: TextStyle(color: t.accent, fontSize: 10, fontWeight: FontWeight.w900)),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
          decoration: BoxDecoration(
            color: t.accent.withOpacity(.10),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: t.accent.withOpacity(.38)),
          ),
          child: Text(status, style: TextStyle(color: t.accent, fontSize: 7, fontWeight: FontWeight.w900)),
        ),
        const SizedBox(height: 6),
        OutlinedButton.icon(
          onPressed: null,
          icon: const Icon(Icons.lock_outline_rounded, size: 11),
          label: const Text('BUY • COMING SOON'),
          style: OutlinedButton.styleFrom(
            disabledForegroundColor: t.accent.withOpacity(.78),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            textStyle: const TextStyle(fontSize: 7, fontWeight: FontWeight.w900),
            side: BorderSide(color: t.accent.withOpacity(.32)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          ),
        ),
      ]),
    ]),
  );

  Widget _priceHeader(String value) => SizedBox(
    width: 53,
    child: Text(value, textAlign: TextAlign.center,
      style: TextStyle(color: t.accent, fontSize: 8, fontWeight: FontWeight.w900)),
  );

  Widget _regionalPriceRow(String title, String global, String af, String pk, {bool highlight = false}) =>
    Container(
      padding: const EdgeInsets.symmetric(vertical: 7),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: t.accent.withOpacity(.16))),
        color: highlight ? t.accent.withOpacity(.07) : Colors.transparent,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(children: [
        Expanded(flex: 5, child: Text(title,
          style: TextStyle(color: highlight ? t.accent : Colors.white70,
            fontSize: 9, fontWeight: highlight ? FontWeight.w900 : FontWeight.w600))),
        for (final value in [global, af, pk])
          SizedBox(width: 53, child: Text(value, textAlign: TextAlign.center,
            style: TextStyle(color: highlight ? t.accent : Colors.white,
              fontSize: 9, fontWeight: FontWeight.w800))),
      ]),
    );

  Future<void> _settings() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) {
        final screenWidth = MediaQuery.of(ctx).size.width;
        final tileWidth = (screenWidth - 52) / 2;
        return Container(
          height: MediaQuery.of(ctx).size.height * .94,
          decoration: BoxDecoration(
            color: t.background,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color.lerp(t.panel, t.accent, .10)!, t.background, const Color(0xFF050506)],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            border: Border.all(color: t.accent.withOpacity(.82), width: 1.5),
            boxShadow: [BoxShadow(color: t.accent.withOpacity(.18), blurRadius: 28, spreadRadius: 2)],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(29)),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
              children: [
                Center(child: Container(
                  width: 48, height: 5,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [t.accent.withOpacity(.35), t.accent, t.accent.withOpacity(.35)]),
                    borderRadius: BorderRadius.circular(8),
                  ),
                )),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.fromLTRB(14, 18, 14, 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                      colors: [Color.lerp(t.table, t.accent, .20)!, t.panel, const Color(0xFF08090D)],
                    ),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: t.accent.withOpacity(.75), width: 1.3),
                    boxShadow: [BoxShadow(color: t.accent.withOpacity(.13), blurRadius: 18)],
                  ),
                  child: Column(children: [
                    Icon(Icons.workspace_premium_rounded, color: t.accent, size: 30),
                    const SizedBox(height: 5),
                    Text('ROYAL TORA', textAlign: TextAlign.center,
                      style: TextStyle(color: t.accent, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 3,
                        shadows: [Shadow(color: t.accent.withOpacity(.28), blurRadius: 12)])),
                    const SizedBox(height: 5),
                    const Text('د شاهي ډیزاینونو او لوبې تنظیمات',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: t.accent.withOpacity(.10),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: t.accent.withOpacity(.42)),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.check_circle, color: t.accent, size: 14),
                        const SizedBox(width: 6),
                        Text('ACTIVE: ${_activeTheme.name}',
                          style: TextStyle(color: t.accent, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: .7)),
                      ]),
                    ),
                  ]),
                ),
                const SizedBox(height: 22),
                _settingsHeading('01  •  ROYAL TABLE THEMES  /  د میدان رنګونه'),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10, runSpacing: 10,
                  children: [
                    for (int i = 0; i < _themes.length; i++)
                      SizedBox(
                        width: tileWidth,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(17),
                            onTap: () {
                              setState(() => _activeTheme = _themes[i]);
                              widget.onThemeChanged(i);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                                  colors: [_themes[i].table, _themes[i].background],
                                ),
                                borderRadius: BorderRadius.circular(17),
                                border: Border.all(
                                  color: _activeTheme.name == _themes[i].name
                                      ? _themes[i].accent : _themes[i].accent.withOpacity(.38),
                                  width: _activeTheme.name == _themes[i].name ? 2.2 : 1,
                                ),
                                boxShadow: _activeTheme.name == _themes[i].name
                                    ? [BoxShadow(color: _themes[i].accent.withOpacity(.20), blurRadius: 12)]
                                    : [],
                              ),
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Row(children: [
                                  Container(
                                    width: 34, height: 34,
                                    decoration: BoxDecoration(
                                      color: _themes[i].table,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: _themes[i].accent, width: 1.3),
                                    ),
                                    child: Center(child: Text(['♛','✦','❖','♜','♕'][i % 5],
                                      style: TextStyle(color: _themes[i].accent, fontSize: 19))),
                                  ),
                                  const Spacer(),
                                  if (_activeTheme.name == _themes[i].name)
                                    Icon(Icons.verified_rounded, color: _themes[i].accent, size: 20)
                                  else
                                    Icon(Icons.circle_outlined, color: _themes[i].accent.withOpacity(.55), size: 18),
                                ]),
                                const SizedBox(height: 9),
                                Text(_themes[i].name, maxLines: 1, overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11)),
                                const SizedBox(height: 7),
                                Row(children: [
                                  for (final c in [_themes[i].background, _themes[i].table, _themes[i].panel, _themes[i].accent])
                                    Expanded(child: Container(
                                      height: 5, margin: const EdgeInsets.only(right: 3),
                                      decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(5)),
                                    )),
                                ]),
                              ]),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 22),
                _settingsHeading('02  •  CARD FRONT  /  د ورقو مخ'),
                const SizedBox(height: 9),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  for (int i = 0; i < 5; i++)
                    _royalStyleOption(
                      label: 'FRONT ${i + 1}',
                      symbol: ['A♠', 'K♥', 'Q♦', 'J♣', '10♠'][i],
                      selected: _cardFaceStyle == i,
                      onTap: () => setState(() => _cardFaceStyle = i),
                    ),
                ]),
                const SizedBox(height: 18),
                _settingsHeading('03  •  CARD BACK  /  د ورقو شا'),
                const SizedBox(height: 9),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  for (int i = 0; i < 5; i++)
                    _royalStyleOption(
                      label: 'BACK ${i + 1}',
                      symbol: ['♛', '✦', '❖', '♜', '♕'][i],
                      selected: _cardBackStyle == i,
                      onTap: () => setState(() => _cardBackStyle = i),
                    ),
                ]),
                const SizedBox(height: 20),
                _settingsHeading('04  •  PLAYER SETTINGS  /  د لوبغاړو تنظیمات'),
                const SizedBox(height: 9),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(17),
                    onTap: () { Navigator.pop(ctx); _editNames(); },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [t.panel, t.background]),
                        borderRadius: BorderRadius.circular(17),
                        border: Border.all(color: t.accent.withOpacity(.48)),
                      ),
                      child: Row(children: [
                        Container(
                          width: 42, height: 42,
                          decoration: BoxDecoration(
                            color: t.accent.withOpacity(.12), borderRadius: BorderRadius.circular(13),
                            border: Border.all(color: t.accent.withOpacity(.5)),
                          ),
                          child: Icon(Icons.groups_rounded, color: t.accent, size: 23),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('د لوبغاړو نومونه بدلول',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13)),
                          SizedBox(height: 3),
                          Text('Edit player names', style: TextStyle(color: Colors.white60, fontSize: 10)),
                        ])),
                        Icon(Icons.arrow_forward_ios_rounded, color: t.accent, size: 16),
                      ]),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Center(child: Text('ADell SAHIL  •  TORA CARD GAME',
                  style: TextStyle(color: t.accent.withOpacity(.65), fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1.2))),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _royalStyleOption({
    required String label,
    required String symbol,
    required bool selected,
    required VoidCallback onTap,
  }) => Material(
    color: Colors.transparent,
    child: InkWell(
      borderRadius: BorderRadius.circular(13),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: 91,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: selected ? [Color.lerp(t.panel, t.accent, .22)!, t.panel] : [t.panel, t.background],
          ),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: selected ? t.accent : t.accent.withOpacity(.30), width: selected ? 1.8 : 1),
          boxShadow: selected ? [BoxShadow(color: t.accent.withOpacity(.14), blurRadius: 9)] : [],
        ),
        child: Column(children: [
          Text(symbol, style: TextStyle(
            color: (symbol.contains('♥') || symbol.contains('♦')) ? const Color(0xFFFF5A68) : t.accent,
            fontSize: 24, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: selected ? t.accent : Colors.white70,
            fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: .5)),
          if (selected) ...[
            const SizedBox(height: 4),
            Icon(Icons.check_circle, color: t.accent, size: 13),
          ],
        ]),
      ),
    ),
  );

  Widget _settingsHeading(String title) => Padding(
    padding: const EdgeInsets.only(left: 2, bottom: 2),
    child: Text(title, style: TextStyle(
      color: t.accent, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.1,
    )),
  );


  @override Widget build(BuildContext context) {
    final legal = _legalCards(0);
    return Scaffold(
      backgroundColor: t.background,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 34,
              margin: const EdgeInsets.fromLTRB(6, 2, 6, 2),
              padding: const EdgeInsets.symmetric(horizontal: 9),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [t.panel, t.background]),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: t.accent.withOpacity(.42)),
              ),
              child: Row(children: [
                Text('♛ TORA', style: TextStyle(
                  color: t.accent, fontWeight: FontWeight.w900,
                  letterSpacing: 3, fontSize: 16)),
                const Spacer(),
                IconButton(
                  onPressed: _royalAccount, tooltip: 'Royal Player Account',
                  icon: const Icon(Icons.account_circle_outlined, size: 18),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints.tightFor(width: 32, height: 28)),
                IconButton(
                  onPressed: _royalStore, tooltip: 'Royal Store',
                  icon: const Icon(Icons.storefront_outlined, size: 18),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints.tightFor(width: 32, height: 28)),
                IconButton(
                  onPressed: _settings, tooltip: 'Themes',
                  icon: const Icon(Icons.palette_outlined, size: 18),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints.tightFor(width: 32, height: 24)),
                IconButton(
                  onPressed: _editNames, tooltip: 'Player names',
                  icon: const Icon(Icons.people_alt_outlined, size: 18),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints.tightFor(width: 32, height: 28)),
                IconButton(
                  onPressed: _showRules, tooltip: 'Rules',
                  icon: const Icon(Icons.info_outline, size: 18),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints.tightFor(width: 32, height: 28)),
                const SizedBox(width: 5),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 1, 8, 2),
              child: Row(children: [
                Expanded(child: _scoreBox('${_names[0]} + ${_names[2]}', _teamOne)),
                const SizedBox(width: 6),
                Expanded(child: _scoreBox('${_names[1]} + ${_names[3]}', _teamTwo)),
              ]),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 1, vertical: 0),
                padding: const EdgeInsets.all(1),
                decoration: BoxDecoration(
                  gradient: RadialGradient(center: Alignment.center, radius: 1.15,
                    colors: [Color.lerp(t.table, t.accent, .12)!, t.table, t.background]),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: t.accent, width: 2),
                  boxShadow: [BoxShadow(color: t.accent.withOpacity(.18), blurRadius: 16)],
                ),
                child: DragTarget<String>(
                  onWillAcceptWithDetails: (d) =>
                    _turn == 0 && !_dealing && !_aiBusy && !_gameOver &&
                    !_resolvingTrick && legal.contains(d.data),
                  onAcceptWithDetails: (d) => _playCard(0, d.data),
                  builder: (ctx, candidates, rejected) => Stack(children: [
                    Positioned.fill(child: IgnorePointer(
                      child: CustomPaint(painter: _RoyalTablePainter(t.accent, t.pattern)))),
                    _centerCross(),
                    if (candidates.isNotEmpty)
                      Positioned.fill(
                        child: IgnorePointer(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white, width: 3),
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                  ]),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 2, 8, 0),
              child: Row(children: [
                Expanded(child: Text('${_names[0].toUpperCase()} — YOUR CARDS',
                  style: TextStyle(color: t.accent, fontWeight: FontWeight.w900,
                    fontSize: 9, letterSpacing: 1))),
                Text('${_myHand.length}/13',
                  style: const TextStyle(color: Colors.white70, fontSize: 9)),
              ]),
            ),
            SizedBox(
              height: 82,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                itemCount: _myHand.length,
                separatorBuilder: (_, __) => const SizedBox(width: 3),
                itemBuilder: (ctx, i) {
                  final card = _myHand[i];
                  final allowed = legal.contains(card) && _turn == 0 &&
                    !_dealing && !_aiBusy && !_gameOver && !_resolvingTrick;
                  return Draggable<String>(
                    data: card,
                    maxSimultaneousDrags: allowed ? 1 : 0,
                    feedback: Material(color: Colors.transparent,
                      child: _cardFace(card, width: 60, height: 84)),
                    childWhenDragging: Opacity(opacity: .25,
                      child: _cardFace(card, width: 56, height: 78)),
                    child: Opacity(opacity: allowed ? 1 : .52,
                      child: _cardFace(card, width: 56, height: 78)),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(7, 1, 7, 6),
              child: SizedBox(
                height: 40,
                child: Row(children: [
                  Expanded(child: OutlinedButton(
                    onPressed: _turn == 0 && !_dealing && !_aiBusy &&
                      !_gameOver && !_resolvingTrick ? () => _claimNoMore(0) : null,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: t.accent, side: BorderSide(color: t.accent),
                      padding: EdgeInsets.zero, minimumSize: Size.zero),
                    child: const Text('NO MORE / نورې نشته',
                      style: TextStyle(fontSize: 9)))),
                  const SizedBox(width: 6),
                  Expanded(child: OutlinedButton(
                    onPressed: _editNames,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: t.accent, side: BorderSide(color: t.accent),
                      padding: EdgeInsets.zero, minimumSize: Size.zero),
                    child: const Text('PLAYERS', style: TextStyle(fontSize: 9)))),
                  const SizedBox(width: 6),
                  Expanded(child: FilledButton(
                    onPressed: _gameOver && !_dealing && !_matchFinished ? _deal : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: t.accent, foregroundColor: Colors.black,
                      padding: EdgeInsets.zero, minimumSize: Size.zero),
                    child: Text(_matchFinished ? 'MATCH OVER' :
                      (_gameOver ? 'NEW ROUND' : (_dealing ? 'DEALING...' : 'PLAYING')),
                      style: const TextStyle(fontSize: 9)))),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
