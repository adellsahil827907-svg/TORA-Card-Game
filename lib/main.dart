```dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(const [
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
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
  const ToraTheme(this.name, this.background, this.panel, this.accent, this.table, this.cardTop, this.cardBottom, this.silver);
}

const List<ToraTheme> _themes = [
  ToraTheme('Black & Gold', Color(0xFF090B10), Color(0xFF17130B), Color(0xFFD6B15C), Color(0xFF123B2B), Color(0xFF27231B), Color(0xFF090909), Color(0xFFE7D4A2)),
  ToraTheme('Midnight Blue', Color(0xFF071326), Color(0xFF12233D), Color(0xFFC6D2E3), Color(0xFF102B46), Color(0xFF273A55), Color(0xFF101D31), Color(0xFFE6EDF7)),
  ToraTheme('Emerald Gold', Color(0xFF061D18), Color(0xFF10352B), Color(0xFFE0C16B), Color(0xFF0C4938), Color(0xFF234B3B), Color(0xFF10271F), Color(0xFFF0D98C)),
  ToraTheme('Royal Purple', Color(0xFF170D25), Color(0xFF28183A), Color(0xFFE4C3FF), Color(0xFF39204F), Color(0xFF4A315F), Color(0xFF1C1028), Color(0xFFEADCF5)),
  ToraTheme('Ruby Velvet', Color(0xFF210B12), Color(0xFF35121D), Color(0xFFFFC1C9), Color(0xFF521A2A), Color(0xFF612638), Color(0xFF260D16), Color(0xFFFFDCE0)),
  ToraTheme('Ocean Blue', Color(0xFF061B2A), Color(0xFF0C2B40), Color(0xFF8DE1F5), Color(0xFF07506A), Color(0xFF17617A), Color(0xFF082638), Color(0xFFD1F5FF)),
  ToraTheme('Silver Chrome', Color(0xFF171B20), Color(0xFF292F36), Color(0xFFE1E7ED), Color(0xFF35434A), Color(0xFF4B555D), Color(0xFF171D22), Color(0xFFF4F6F8)),
  ToraTheme('Copper Luxe', Color(0xFF1D120C), Color(0xFF332016), Color(0xFFE6A66F), Color(0xFF563522), Color(0xFF70472D), Color(0xFF28180F), Color(0xFFFFD5B0)),
  ToraTheme('Jade Table', Color(0xFF071A17), Color(0xFF102B25), Color(0xFF9DE0B9), Color(0xFF17634A), Color(0xFF28765B), Color(0xFF0B2B20), Color(0xFFD6F5E2)),
  ToraTheme('Arctic White', Color(0xFF17212B), Color(0xFF263746), Color(0xFFFFD77A), Color(0xFF47717B), Color(0xFF607D86), Color(0xFF243E49), Color(0xFFEAF7FA)),
];

class ToraApp extends StatefulWidget {
  const ToraApp({super.key});
  @override
  State<ToraApp> createState() => _ToraAppState();
}

class _ToraAppState extends State<ToraApp> {
  int themeIndex = 0;
  void setTheme(int value) => setState(() => themeIndex = value);

  @override
  Widget build(BuildContext context) {
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
        ),
        useMaterial3: true,
      ),
      home: ToraSplashPage(
        theme: t,
        onStart: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ToraGamePage(theme: t, onThemeChanged: setTheme),
          ),
        ),
      ),
    );
  }
}

class ToraSplashPage extends StatelessWidget {
  final ToraTheme theme;
  final VoidCallback onStart;

  const ToraSplashPage({
    super.key,
    required this.theme,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: theme.background,
    body: SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 116,
                height: 116,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [theme.cardTop, theme.cardBottom],
                  ),
                  border: Border.all(color: theme.accent, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: theme.accent.withOpacity(.2),
                      blurRadius: 24,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'T',
                    style: TextStyle(
                      color: theme.accent,
                      fontSize: 72,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'TORA',
                style: TextStyle(
                  color: theme.accent,
                  fontSize: 38,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 8,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'THINK SMART • PLAY TORA',
                style: TextStyle(
                  color: Colors.white70,
                  letterSpacing: 2,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 38),
              CircleAvatar(
                radius: 35,
                backgroundColor: theme.panel,
                child: Text(
                  'AS',
                  style: TextStyle(
                    color: theme.accent,
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Created by Adell Sahil',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 42),
              SizedBox(
                width: 220,
                child: FilledButton(
                  onPressed: onStart,
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.accent,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: const Text(
                    'START GAME',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
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

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * .19,
          size.height * .64,
          size.width * .62,
          size.height * .29,
        ),
        const Radius.circular(8),
      ),
      cloth,
    );

    canvas.drawRect(
      Rect.fromLTWH(
        cx - size.width * .09,
        size.height * .53,
        size.width * .18,
        size.height * .19,
      ),
      skin,
    );

    canvas.drawOval(
      Rect.fromLTWH(
        size.width * .28,
        size.height * .19,
        size.width * .44,
        size.height * .48,
      ),
      dark,
    );

    canvas.drawOval(
      Rect.fromLTWH(
        size.width * .32,
        size.height * .25,
        size.width * .36,
        size.height * .39,
      ),
      skin,
    );

    final hair = Paint()..color = dark.color;
    final features = Paint()
      ..color = const Color(0xFF563A2B)
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

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
      canvas.drawCircle(
        Offset(cx, size.height * .18),
        size.width * .035,
        Paint()..color = const Color(0xFF9B3155),
      );
    } else {
      final plume = Path()
        ..moveTo(size.width * .36, size.height * .27)
        ..quadraticBezierTo(size.width * .13, size.height * .02, size.width * .58, size.height * .10)
        ..quadraticBezierTo(size.width * .48, size.height * .20, size.width * .64, size.height * .28)
        ..close();
      canvas.drawPath(plume, Paint()..color = const Color(0xFF3E7058));
      canvas.drawLine(
        Offset(size.width * .39, size.height * .25),
        Offset(size.width * .58, size.height * .12),
        gold..style = PaintingStyle.stroke..strokeWidth = 1.3,
      );
    }

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * .12,
          size.height * .08,
          size.width * .76,
          size.height * .84,
        ),
        const Radius.circular(4),
      ),
      Paint()
        ..color = const Color(0xFF9A7131)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(covariant _FacePortraitPainter oldDelegate) =>
      oldDelegate.rank != rank || oldDelegate.robe != robe;
}
