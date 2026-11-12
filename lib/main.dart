import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(const [
    DeviceOrientation.portraitUp,
  ]);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
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
    final rect = Offset.zero & size;
    final center = Offset(size.width / 2, size.height / 2);
    final shadow = Paint()..color = Colors.black.withOpacity(.38)..style = PaintingStyle.stroke..strokeWidth = 7;
    final gold = Paint()..color = accent.withOpacity(.78)..style = PaintingStyle.stroke..strokeWidth = 1.7;
    final shine = Paint()..color = const Color(0xFFFFE8B0).withOpacity(.42)..style = PaintingStyle.stroke..strokeWidth = .8;
    final soft = Paint()..color = accent.withOpacity(.22)..style = PaintingStyle.stroke..strokeWidth = 1;
    final outer = RRect.fromRectAndRadius(rect.deflate(7), const Radius.circular(18));
    canvas.drawRRect(outer, shadow);
    canvas.drawRRect(outer, gold);
    canvas.drawRRect(RRect.fromRectAndRadius(rect.deflate(13), const Radius.circular(15)), shine);
    canvas.drawRRect(RRect.fromRectAndRadius(rect.deflate(20), const Radius.circular(12)), soft);

    // Raised corner ornaments and beveled gold rails.
    for (int i = 0; i < 4; i++) {
      final x = i.isEven ? 22.0 : size.width - 22;
      final y = i < 2 ? 22.0 : size.height - 22;
      final corner = Path()
        ..moveTo(x, y + 18)
        ..quadraticBezierTo(x, y, x + (i.isEven ? 18 : -18), y)
        ..moveTo(x, y + 13)
        ..quadraticBezierTo(x, y + 5, x + (i.isEven ? 13 : -13), y + 5);
      canvas.drawPath(corner, gold);
      canvas.drawCircle(Offset(x, y), 2.6, shine);
    }

    if (pattern == 0) {
      for (int i = 0; i < 4; i++) {
        final inset = 30.0 + i * 8;
        canvas.drawRRect(RRect.fromRectAndRadius(rect.deflate(inset), Radius.circular(10.0 + i)), soft);
      }
      canvas.drawCircle(center, 42, gold);
      canvas.drawCircle(center, 34, shine);
      canvas.drawCircle(center, 25, soft);
    } else if (pattern == 1) {
      for (double x = 28; x < size.width - 20; x += 24) {
        canvas.drawLine(Offset(x, 22), Offset(x, size.height - 22), soft);
      }
      for (double y = 28; y < size.height - 20; y += 24) {
        canvas.drawLine(Offset(22, y), Offset(size.width - 22, y), soft);
      }
      canvas.drawRRect(RRect.fromRectAndRadius(rect.deflate(34), const Radius.circular(22)), gold);
    } else if (pattern == 2) {
      for (int i = 0; i < 12; i++) {
        final a = i * pi / 6;
        final path = Path()
          ..moveTo(center.dx + cos(a) * 20, center.dy + sin(a) * 20)
          ..quadraticBezierTo(center.dx + cos(a + .18) * 62, center.dy + sin(a + .18) * 62, center.dx + cos(a) * 92, center.dy + sin(a) * 92);
        canvas.drawPath(path, gold);
      }
      canvas.drawCircle(center, 48, shine);
      canvas.drawCircle(center, 38, soft);
    } else if (pattern == 3) {
      for (int i = 0; i < 6; i++) {
        final inset = 28.0 + i * 12;
        canvas.drawRRect(RRect.fromRectAndRadius(rect.deflate(inset), Radius.circular(8 + i * 2)), i.isEven ? gold : soft);
      }
      canvas.drawLine(Offset(center.dx, 22), Offset(center.dx, size.height - 22), shine);
    } else {
      final path = Path();
      for (int i = 0; i < 16; i++) {
        final a = i * pi / 8;
        final radius = i.isEven ? 57.0 : 28.0;
        final p = Offset(center.dx + cos(a) * radius, center.dy + sin(a) * radius);
        if (i == 0) { path.moveTo(p.dx, p.dy); } else { path.lineTo(p.dx, p.dy); }
      }
      path.close();
      canvas.drawPath(path, gold);
      canvas.drawCircle(center, 19, shine);
    }
    final symbols = ['♛', '✦', '❖', '♜', '♕'];
    final tp = TextPainter(
      text: TextSpan(text: symbols[pattern.clamp(0, 4)], style: TextStyle(color: accent.withOpacity(.22), fontSize: 48, fontWeight: FontWeight.w900)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(center.dx - tp.width / 2, center.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _RoyalTablePainter old) => old.pattern != pattern || old.accent != accent;
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
        colorScheme: ColorScheme.dark(primary: t.accent, secondary: t.accent, surface: t.panel),
        useMaterial3: true,
      ),
      home: ToraSplashPage(
        theme: t,
        onStart: (splashContext) {
          Navigator.of(splashContext).push(
            MaterialPageRoute(
              builder: (_) => ToraGamePage(theme: t, onThemeChanged: setTheme),
            ),
          );
        },
      ),
    );
  }
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
                                Container(
                                  width: 172 * scale, height: 172 * scale,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: gold, width: 3),
                                    boxShadow: [BoxShadow(color: gold.withOpacity(.22), blurRadius: 18)],
                                  ),
                                  child: ClipOval(
                                    child: Container(
                                      color: const Color(0xFF17110A),
                                      child: Center(child: Text('AS', style: TextStyle(
                                        color: gold, fontSize: 62 * scale,
                                        fontWeight: FontWeight.w900, letterSpacing: 3,
                                      ))),
                                    ),
                                  ),
                                ),
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

  ToraTheme get t => _activeTheme;

  @override void initState() { super.initState(); _activeTheme = widget.theme; _deal(first: true); }
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
    // If the Q♠ winner is an AI player, let that player make the first play
    // automatically; otherwise the human player (seat 0) can play manually.
    if (startSeat != 0 && mounted && !_gameOver) {
      await Future.delayed(const Duration(milliseconds: 450));
      if (mounted && !_gameOver && !_dealing && _turn == startSeat) {
        _runAi();
      }
    }
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
        constraints: const BoxConstraints(maxWidth: 170),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xD9101118),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _turn == seat ? t.accent : t.accent.withOpacity(.55),
            width: _turn == seat ? 2 : 1,
          ),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(.25), blurRadius: 8)],
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(_names[seat], maxLines: 1, overflow: TextOverflow.ellipsis,
            style: TextStyle(color: _turn == seat ? t.accent : Colors.white,
              fontWeight: FontWeight.w900, fontSize: fontSize)),
          Text('$position  •  ${_hands[seat].length}/13',
            style: TextStyle(color: Colors.white70, fontSize: fontSize * .72)),
        ]),
      );

  Widget _centerCross() => LayoutBuilder(builder: (context, constraints) {
    final w = constraints.maxWidth;
    final h = constraints.maxHeight;
    // Keep all four played cards together in the center in a clear plus layout.
    final cardH = (h * .25).clamp(48.0, 74.0).toDouble();
    final cardW = cardH / 1.43;
    final gap = (h * .02).clamp(5.0, 8.0).toDouble();
    final sideSeatW = (w * .17).clamp(76.0, 118.0).toDouble();
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

  Widget _scoreBox(String label, int score) => Container(padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 7), decoration: BoxDecoration(color: t.panel, borderRadius: BorderRadius.circular(10), border: Border.all(color: t.accent.withOpacity(.7))), child: Column(children: [Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70, fontSize: 9)), Text('$score', style: TextStyle(color: t.accent, fontSize: 16, fontWeight: FontWeight.w900))]));

  Future<void> _settings() async {
    await showModalBottomSheet<void>(context: context, backgroundColor: t.panel, isScrollControlled: true,
      builder: (ctx) => SafeArea(child: SizedBox(height: MediaQuery.of(ctx).size.height*.88, child: ListView(padding: const EdgeInsets.all(14), children: [
        Text('ROYAL TORA DESIGNS', textAlign: TextAlign.center, style: TextStyle(color:t.accent,fontWeight:FontWeight.w900,fontSize:16)),
        const SizedBox(height:8), const Text('۵ عصري لوکس شاهي میدانونه',textAlign:TextAlign.center,style:TextStyle(color:Colors.white70)),
        for (int i=0;i<_themes.length;i++) ListTile(leading:CircleAvatar(backgroundColor:_themes[i].table,child:Text(['♛','✦','❖','♜','♕'][i],style:TextStyle(color:_themes[i].accent))),title:Text(_themes[i].name),trailing:_activeTheme.name==_themes[i].name?Icon(Icons.check_circle,color:t.accent):null,onTap:(){setState((){_activeTheme=_themes[i];});widget.onThemeChanged(i);}),
        const Divider(), Text('CARD FRONT — ۵ LUXURY DESIGNS',style:TextStyle(color:t.accent,fontWeight:FontWeight.bold)),
        Wrap(spacing:6,children:[for(int i=0;i<5;i++)ChoiceChip(label:Text('${i+1}'),selected:_cardFaceStyle==i,onSelected:(_){setState(()=>_cardFaceStyle=i);})]),
        const SizedBox(height:8), Text('CARD BACK — ۵ LUXURY DESIGNS',style:TextStyle(color:t.accent,fontWeight:FontWeight.bold)),
        Wrap(spacing:6,children:[for(int i=0;i<5;i++)ChoiceChip(label:Text('${i+1}'),selected:_cardBackStyle==i,onSelected:(_){setState(()=>_cardBackStyle=i);})]),
        const Divider(), ListTile(leading:Icon(Icons.people,color:t.accent),title:const Text('د لوبغاړو نومونه بدلول'),onTap:(){Navigator.pop(ctx);_editNames();})
      ]))));
  }

  @override Widget build(BuildContext context) {
    final legal = _legalCards(0);
    return Scaffold(
      backgroundColor: t.background,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 24,
              child: Row(children: [
                const SizedBox(width: 8),
                Text('♛ TORA', style: TextStyle(
                  color: t.accent, fontWeight: FontWeight.w900,
                  letterSpacing: 3, fontSize: 15)),
                const Spacer(),
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
              height: 70,
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
                      child: _cardFace(card, width: 54, height: 76)),
                    childWhenDragging: Opacity(opacity: .25,
                      child: _cardFace(card, width: 50, height: 72)),
                    child: Opacity(opacity: allowed ? 1 : .48,
                      child: _cardFace(card, width: 50, height: 72)),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(7, 0, 7, 5),
              child: SizedBox(
                height: 34,
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
