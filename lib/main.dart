
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
class ToraCard {
  final String rank;
  final String suit;
  const ToraCard(this.rank, this.suit);

  int get power => _ranks.indexOf(rank);

  int get points {
    if (suit == '♥') return 1;
    if (rank == 'Q' && suit == '♠') return 9;
    if (rank == 'J' && suit == '♣') return 5;
    if (rank == '10' && suit == '♦') return 3;
    return 0;
  }
}

class PlayedCard {
  final int player;
  final ToraCard card;
  const PlayedCard(this.player, this.card);
}

class ToraGamePage extends StatefulWidget {
  final ToraTheme theme;
  final ValueChanged<int> onThemeChanged;

  const ToraGamePage({
    super.key,
    required this.theme,
    required this.onThemeChanged,
  });

  @override
  State<ToraGamePage> createState() => _ToraGamePageState();
}

class _ToraGamePageState extends State<ToraGamePage> {
  final Random random = Random();
  List<List<ToraCard>> hands = [[], [], [], []];
  List<PlayedCard> tableCards = [];
  List<ToraCard> captured = [];
  int currentPlayer = 0;
  int leader = 0;
  int trickNumber = 0;
  int teamOne = 0;
  int teamTwo = 0;
  bool dealing = false;
  bool gameOver = false;
  bool busy = false;
  String message = 'Press NEW GAME to begin';

  @override
  void initState() {
    super.initState();
    startGame();
  }

  Future<void> startGame() async {
    if (!mounted) return;
    setState(() {
      dealing = true;
      gameOver = false;
      busy = true;
      tableCards.clear();
      captured.clear();
      hands = [[], [], [], []];
      teamOne = 0;
      teamTwo = 0;
      trickNumber = 0;
      leader = 0;
      currentPlayer = 0;
      message = 'DEALING CARDS...';
    });

    final deck = <ToraCard>[];
    for (final suit in _suits) {
      for (final rank in _ranks) {
        deck.add(ToraCard(rank, suit));
      }
    }
    deck.shuffle(random);

    for (int i = 0; i < 52; i++) {
      if (!mounted) return;
      setState(() {
        hands[i % 4].add(deck[i]);
        message = 'DEALING CARDS  ${i + 1}/52';
      });
      await Future.delayed(const Duration(milliseconds: 45));
    }

    if (!mounted) return;
    setState(() {
      dealing = false;
      busy = false;
      message = 'Sahil, your turn!';
    });
    runAI();
  }

  List<ToraCard> legalCards(int player) {
    final hand = hands[player];
    if (tableCards.isEmpty) return List.of(hand);

    final suit = tableCards.first.card.suit;
    final matching = hand.where((c) => c.suit == suit).toList();
    return matching.isNotEmpty ? matching : List.of(hand);
  }

  void playCard(ToraCard card) {
    if (dealing || busy || gameOver || currentPlayer != 0) return;
    if (!legalCards(0).contains(card)) return;
    makeMove(0, card);
  }

  void makeMove(int player, ToraCard card) {
    if (!mounted) return;

    setState(() {
      hands[player].remove(card);
      tableCards.add(PlayedCard(player, card));
      currentPlayer = (player + 1) % 4;
      message = tableCards.length == 4
          ? 'FOUR CARDS ON THE TABLE'
          : '${playerName(currentPlayer)} is playing...';
    });

    if (tableCards.length == 4) {
      busy = true;
      Future.delayed(const Duration(milliseconds: 1400), resolveTrick);
    } else {
      runAI();
    }
  }

  void runAI() {
    if (!mounted || dealing || gameOver || busy) return;
    if (currentPlayer == 0) return;

    Future.delayed(const Duration(milliseconds: 650), () {
      if (!mounted || gameOver || busy || currentPlayer == 0) return;
      final options = legalCards(currentPlayer);
      if (options.isEmpty) return;
      final card = options[random.nextInt(options.length)];
      makeMove(currentPlayer, card);
    });
  }

  void resolveTrick() {
    if (!mounted || tableCards.length != 4) return;

    final ledSuit = tableCards.first.card.suit;
    final eligible = tableCards
        .where((p) => p.card.suit == ledSuit)
        .toList();

    eligible.sort((a, b) => a.card.power.compareTo(b.card.power));
    final winner = eligible.last.player;
    final points = tableCards.fold<int>(
      0,
      (sum, p) => sum + p.card.points,
    );

    setState(() {
      if (winner == 0 || winner == 2) {
        teamOne += points;
      } else {
        teamTwo += points;
      }

      captured.addAll(tableCards.map((p) => p.card));
      tableCards.clear();
      leader = winner;
      currentPlayer = winner;
      trickNumber++;
      busy = false;

      if (hands.every((h) => h.isEmpty)) {
        gameOver = true;
        message = 'GAME FINISHED';
      } else {
        message = '${playerName(winner)} won the trick';
      }
    });

    if (!gameOver) runAI();
    else showResult();
  }

  String playerName(int seat) {
    switch (seat) {
      case 0: return 'Sahil';
      case 1: return 'Right';
      case 2: return 'Partner';
      default: return 'Left';
    }
  }

  void showResult() {
    final winner = teamOne < teamTwo
        ? 'SAHIL TEAM WINS'
        : teamTwo < teamOne
            ? 'OPPONENT TEAM WINS'
            : 'DRAW';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: widget.theme.panel,
        title: Text(
          winner,
          textAlign: TextAlign.center,
          style: TextStyle(color: widget.theme.accent),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Sahil + Partner: $teamOne points'),
            const SizedBox(height: 8),
            Text('Right + Left: $teamTwo points'),
            const SizedBox(height: 12),
            Text('Cards collected: ${captured.length}/52'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              startGame();
            },
            child: const Text('PLAY AGAIN'),
          ),
        ],
      ),
    );
  }

  void showRules() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: widget.theme.panel,
        title: Text('TORA RULES',
            style: TextStyle(color: widget.theme.accent)),
        content: const SingleChildScrollView(
          child: Text(
            '• 52 cards, 13 cards per player.\n'
            '• Sahil and Partner are one team.\n'
            '• Right and Left are the other team.\n'
            '• Follow the first suit if you have it.\n'
            '• Highest card of the first suit wins.\n'
            '• Hearts = 1 point.\n'
            '• Queen of Spades = 9 points.\n'
            '• Jack of Clubs = 5 points.\n'
            '• Ten of Diamonds = 3 points.\n'
            '• The team with fewer penalty points wins.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CLOSE'),
          ),
        ],
      ),
    );
  }

  Widget playerLabel(String name, int count, {bool active = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: active
            ? widget.theme.accent.withOpacity(.22)
            : widget.theme.panel,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: active ? widget.theme.accent : Colors.white24,
        ),
      ),
      child: Text(
        '$name  •  $count',
        style: TextStyle(
          color: active ? widget.theme.accent : Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget backCards(int count, {bool vertical = false}) {
    return SizedBox(
      width: vertical ? 43 : 90,
      height: vertical ? 85 : 48,
      child: Stack(
        children: List.generate(
          min(count, 5),
          (i) => Positioned(
            left: vertical ? 0 : i * 7.0,
            top: vertical ? i * 7.0 : 0,
            child: Container(
              width: vertical ? 37 : 34,
              height: vertical ? 49 : 46,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    widget.theme.cardTop,
                    widget.theme.cardBottom,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: widget.theme.accent, width: 1),
              ),
              child: Center(
                child: Text(
                  'T',
                  style: TextStyle(
                    color: widget.theme.accent,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget tableCard(ToraCard card) {
    final red = card.suit == '♥' || card.suit == '♦';
    return Container(
      width: 62,
      height: 91,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF5),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: widget.theme.accent, width: 1.5),
        boxShadow: const [
          BoxShadow(color: Colors.black45, blurRadius: 5, offset: Offset(2, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            card.rank,
            style: TextStyle(
              color: red ? Colors.red.shade800 : Colors.black,
              fontSize: 17,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                card.suit,
                style: TextStyle(
                  color: red ? Colors.red.shade800 : Colors.black,
                  fontSize: 34,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget playedSlot(int seat) {
    final played = tableCards.where((p) => p.player == seat).toList();
    if (played.isEmpty) {
      return Container(
        width: 62,
        height: 91,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white24),
          borderRadius: BorderRadius.circular(7),
        ),
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          playerName(seat),
          style: TextStyle(color: widget.theme.accent, fontSize: 10),
        ),
        tableCard(played.first.card),
      ],
    );
  }

  Widget buildCenterTable() {
    return Container(
      width: 330,
      height: 220,
      decoration: BoxDecoration(
        color: widget.theme.table.withOpacity(.88),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: widget.theme.accent.withOpacity(.65),
          width: 2,
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black38, blurRadius: 18),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(top: 8, child: playedSlot(2)),
          Positioned(left: 8, child: playedSlot(3)),
          Positioned(right: 8, child: playedSlot(1)),
          Positioned(bottom: 8, child: playedSlot(0)),
          if (tableCards.isEmpty)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'TORA',
                  style: TextStyle(
                    color: widget.theme.accent.withOpacity(.8),
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 5,
                  ),
                ),
                const Text('PLAY YOUR CARDS',
                    style: TextStyle(color: Colors.white54, fontSize: 9)),
              ],
            ),
        ],
      ),
    );
  }

  Widget handCard(ToraCard card) {
    final red = card.suit == '♥' || card.suit == '♦';
    final allowed = legalCards(0).contains(card);
    return GestureDetector(
      onTap: () => playCard(card),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 48,
        height: allowed && currentPlayer == 0 && !busy ? 91 : 85,
        margin: const EdgeInsets.symmetric(horizontal: 1),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFDF5),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: allowed && currentPlayer == 0
                ? widget.theme.accent
                : Colors.black26,
            width: 1.2,
          ),
          boxShadow: const [
            BoxShadow(color: Colors.black38, blurRadius: 3, offset: Offset(1, 2)),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              left: 4,
              top: 4,
              child: Column(
                children: [
                  Text(
                    card.rank,
                    style: TextStyle(
                      color: red ? Colors.red.shade800 : Colors.black,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      height: 1,
                    ),
                  ),
                  Text(
                    card.suit,
                    style: TextStyle(
                      color: red ? Colors.red.shade800 : Colors.black,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            if (card.rank == 'J' || card.rank == 'Q' || card.rank == 'K')
              Positioned(
                left: 8,
                right: 8,
                top: 29,
                bottom: 5,
                child: CustomPaint(
                  painter: _FacePortraitPainter(
                    card.rank,
                    card.suit == '♥' || card.suit == '♦'
                        ? const Color(0xFF8C3040)
                        : const Color(0xFF244B3A),
                  ),
                ),
              )
            else
              Center(
                child: Text(
                  card.suit,
                  style: TextStyle(
                    color: red ? Colors.red.shade800 : Colors.black,
                    fontSize: card.rank == 'A' ? 28 : 21,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.theme;
    return Scaffold(
      backgroundColor: t.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              child: Row(
                children: [
                  Text(
                    'TORA',
                    style: TextStyle(
                      color: t.accent,
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 3,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Text('SAHIL: $teamOne',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 12),
                  Text('OPPONENTS: $teamTwo',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const Spacer(),
                  TextButton(
                    onPressed: showRules,
                    child: const Text('RULES'),
                  ),
                  PopupMenuButton<int>(
                    tooltip: 'Table themes',
                    icon: Icon(Icons.palette, color: t.accent),
                    onSelected: widget.onThemeChanged,
                    itemBuilder: (context) => List.generate(
                      _themes.length,
                      (i) => PopupMenuItem(
                        value: i,
                        child: Text(_themes[i].name),
                      ),
                    ),
                  ),
                  FilledButton(
                    onPressed: dealing ? null : startGame,
                    style: FilledButton.styleFrom(
                      backgroundColor: t.accent,
                      foregroundColor: Colors.black,
                    ),
                    child: const Text('NEW GAME'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  SizedBox(
                    width: 85,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        playerLabel('LEFT', hands[3].length,
                            active: currentPlayer == 3),
                        const SizedBox(height: 8),
                        RotatedBox(
                          quarterTurns: 1,
                          child: backCards(hands[3].length, vertical: true),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            playerLabel('PARTNER', hands[2].length,
                                active: currentPlayer == 2),
                            const SizedBox(width: 12),
                            backCards(hands[2].length),
                          ],
                        ),
                        Expanded(
                          child: Center(child: buildCenterTable()),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            playerLabel('SAHIL', hands[0].length,
                                active: currentPlayer == 0),
                            const SizedBox(width: 8),
                            Text(
                              message,
                              style: TextStyle(
                                color: t.accent,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 85,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        playerLabel('RIGHT', hands[1].length,
                            active: currentPlayer == 1),
                        const SizedBox(height: 8),
                        RotatedBox(
                          quarterTurns: 1,
                          child: backCards(hands[1].length, vertical: true),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 103,
              child: hands[0].isEmpty
                  ? const Center(
                      child: Text('Your cards will appear here'),
                    )
                  : ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      children: hands[0].map(handCard).toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}