import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
  );
  runApp(const ToraApp());
}

const gold = Color(0xFFD6B15C);
const black = Color(0xFF090B10);
const green = Color(0xFF123B2B);

class ToraTheme {
  final String name;
  final Color background;
  final Color table;
  final Color accent;
  final Color felt;

  const ToraTheme(
    this.name,
    this.background,
    this.table,
    this.accent,
    this.felt,
  );
}

const themes = [
  ToraTheme('Black & Gold', Color(0xFF090B10),
      Color(0xFF17130B), Color(0xFFD6B15C), Color(0xFF123B2B)),
  ToraTheme('Midnight Blue', Color(0xFF071326),
      Color(0xFF12233D), Color(0xFFC6D2E3), Color(0xFF102B46)),
  ToraTheme('Emerald Gold', Color(0xFF061D18),
      Color(0xFF10352B), Color(0xFFE0C16B), Color(0xFF0C4938)),
  ToraTheme('Royal Purple', Color(0xFF170D25),
      Color(0xFF28183A), Color(0xFFE4C3FF), Color(0xFF39204F)),
  ToraTheme('Ruby Velvet', Color(0xFF210B12),
      Color(0xFF35121D), Color(0xFFFFC1C9), Color(0xFF521A2A)),
  ToraTheme('Ocean Blue', Color(0xFF061B2A),
      Color(0xFF0C2B40), Color(0xFF8DE1F5), Color(0xFF07506A)),
  ToraTheme('Silver Chrome', Color(0xFF171B20),
      Color(0xFF292F36), Color(0xFFE1E7ED), Color(0xFF35434A)),
  ToraTheme('Copper Luxe', Color(0xFF1D120C),
      Color(0xFF332016), Color(0xFFE6A66F), Color(0xFF563522)),
  ToraTheme('Jade Table', Color(0xFF071A17),
      Color(0xFF102B25), Color(0xFF9DE0B9), Color(0xFF17634A)),
  ToraTheme('Arctic White', Color(0xFF17212B),
      Color(0xFF263746), Color(0xFFFFD77A), Color(0xFF47717B)),
];

class ToraApp extends StatefulWidget {
  const ToraApp({super.key});

  @override
  State<ToraApp> createState() => _ToraAppState();
}

class _ToraAppState extends State<ToraApp> {
  ToraTheme theme = themes.first;
  bool started = false;

  void changeTheme(ToraTheme value) {
    setState(() => theme = value);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TORA',
      theme: ThemeData.dark(),
      home: started
          ? ToraGamePage(
              theme: theme,
              onThemeChanged: changeTheme,
            )
          : ToraSplashPage(
              theme: theme,
              onStart: () => setState(() => started = true),
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: theme.background,
      body: SafeArea(
        child: Center(
          child: LayoutBuilder(
            builder: (context, size) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'TORA',
                    style: TextStyle(
                      fontSize: min(size.maxHeight * .23, 90),
                      fontWeight: FontWeight.w900,
                      letterSpacing: 12,
                      color: theme.accent,
                      shadows: const [
                        Shadow(color: Colors.black, blurRadius: 15),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'THINK SMART  •  PLAY TORA',
                    style: TextStyle(
                      color: theme.accent,
                      letterSpacing: 3,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: 220,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: onStart,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.accent,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'START GAME',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Created by Adell Sahil',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class PlayingCard {
  final String rank;
  final String suit;

  const PlayingCard(this.rank, this.suit);

  int get points {
    if (suit == '♥') return 1;
    if (rank == 'Q' && suit == '♠') return 9;
    if (rank == 'J' && suit == '♣') return 5;
    if (rank == '10' && suit == '♦') return 3;
    return 0;
  }

  int get power {
    const order = [
      '2', '3', '4', '5', '6', '7',
      '8', '9', '10', 'J', 'Q', 'K', 'A'
    ];
    return order.indexOf(rank);
  }

  @override
  String toString() => '$rank$suit';
}

class PlayedCard {
  final int player;
  final PlayingCard card;

  const PlayedCard(this.player, this.card);
}

class ToraGamePage extends StatefulWidget {
  final ToraTheme theme;
  final ValueChanged<ToraTheme> onThemeChanged;

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

  final List<List<PlayingCard>> hands = [
    [],
    [],
    [],
    [],
  ];

  final List<PlayedCard> tableCards = [];
  final List<PlayingCard> captured = [];

  int turn = 0;
  int leader = 0;
  int sahilScore = 0;
  int opponentScore = 0;
  int tricks = 0;
  bool dealing = false;
  bool waiting = false;
  bool gameStarted = false;
  String message = 'Press NEW GAME to begin';
  String? selectedSuit;

  ToraTheme get theme => widget.theme;

  @override
  void initState() {
    super.initState();
    startGame();
  }

  List<PlayingCard> makeDeck() {
    final deck = <PlayingCard>[];
    const ranks = [
      '2', '3', '4', '5', '6', '7', '8',
      '9', '10', 'J', 'Q', 'K', 'A'
    ];
    const suits = ['♠', '♥', '♦', '♣'];

    for (final suit in suits) {
      for (final rank in ranks) {
        deck.add(PlayingCard(rank, suit));
      }
    }
    deck.shuffle(random);
    return deck;
  }

  Future<void> startGame() async {
    if (!mounted) return;

    setState(() {
      dealing = true;
      gameStarted = false;
      waiting = false;
      tableCards.clear();
      captured.clear();
      for (final hand in hands) {
        hand.clear();
      }
      sahilScore = 0;
      opponentScore = 0;
      tricks = 0;
      leader = 0;
      turn = 0;
      message = 'Dealing cards...';
    });

    final deck = makeDeck();

    for (int i = 0; i < 52; i++) {
      if (!mounted) return;
      setState(() {
        hands[i % 4].add(deck[i]);
      });
      await Future.delayed(const Duration(milliseconds: 35));
    }

    for (final hand in hands) {
      hand.sort((a, b) {
        const suits = ['♠', '♥', '♦', '♣'];
        final suitCompare =
            suits.indexOf(a.suit).compareTo(suits.indexOf(b.suit));
        return suitCompare != 0
            ? suitCompare
            : a.power.compareTo(b.power);
      });
    }

    if (!mounted) return;
    setState(() {
      dealing = false;
      gameStarted = true;
      message = 'Your turn, Sahil';
      turn = leader;
    });

    if (turn != 0) {
      scheduleAi();
    }
  }

  List<PlayingCard> legalCards(int player) {
    final hand = hands[player];
    if (tableCards.isEmpty) return List.of(hand);

    final suit = tableCards.first.card.suit;
    final matching = hand.where((c) => c.suit == suit).toList();

    return matching.isNotEmpty ? matching : List.of(hand);
  }

  void playHuman(PlayingCard card) {
    if (!gameStarted || dealing || waiting || turn != 0) return;

    final legal = legalCards(0);
    if (!legal.contains(card)) return;

    playCard(0, card);
  }

  void playCard(int player, PlayingCard card) {
    if (!mounted || !hands[player].contains(card)) return;

    setState(() {
      hands[player].remove(card);
      tableCards.add(PlayedCard(player, card));
      turn = (player + 1) % 4;
      message = player == 0
          ? 'Sahil played $card'
          : '${playerName(player)} played a card';
    });

    if (tableCards.length == 4) {
      waiting = true;
      Future.delayed(const Duration(milliseconds: 1500), finishTrick);
    } else if (turn == 0) {
      setState(() => message = 'Your turn, Sahil');
    } else {
      scheduleAi();
    }
  }

  void scheduleAi() {
    if (!mounted || !gameStarted || waiting || turn == 0) return;

    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted || waiting || turn == 0) return;

      final legal = legalCards(turn);
      if (legal.isEmpty) return;

      final card = legal[random.nextInt(legal.length)];
      playCard(turn, card);
    });
  }

  int trickWinner() {
    if (tableCards.isEmpty) return leader;

    final leadSuit = tableCards.first.card.suit;
    final eligible = tableCards
        .where((entry) => entry.card.suit == leadSuit)
        .toList();

    eligible.sort(
      (a, b) => b.card.power.compareTo(a.card.power),
    );

    return eligible.first.player;
  }

  void finishTrick() {
    if (!mounted || tableCards.length != 4) return;

    final winner = trickWinner();
    final points = tableCards.fold<int>(
      0,
      (sum, entry) => sum + entry.card.points,
    );

    final winningTeam = winner == 0 || winner == 2;

    setState(() {
      if (winningTeam) {
        sahilScore += points;
      } else {
        opponentScore += points;
      }

      for (final entry in tableCards) {
        captured.add(entry.card);
      }

      tableCards.clear();
      tricks++;
      leader = winner;
      turn = winner;
      waiting = false;

      message = '${playerName(winner)} won the trick';
    });

    if (hands.every((hand) => hand.isEmpty)) {
      showFinalResult();
      return;
    }

    if (turn != 0) {
      scheduleAi();
    } else {
      setState(() => message = 'Your turn, Sahil');
    }
  }

  String playerName(int player) {
    switch (player) {
      case 0:
        return 'Sahil';
      case 1:
        return 'Mahmood Khan';
      case 2:
        return 'Zabihullah';
      default:
        return 'Player 4';
    }
  }

  void showFinalResult() {
    final winner = sahilScore > opponentScore
        ? 'SAHIL TEAM'
        : sahilScore < opponentScore
            ? 'OPPONENT TEAM'
            : 'DRAW';

    setState(() {
      gameStarted = false;
      message = 'Game finished';
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: theme.table,
        title: Text(
          winner,
          style: TextStyle(color: theme.accent),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Sahil + Zabihullah: $sahilScore'),
            const SizedBox(height: 8),
            Text('Mahmood + Player 4: $opponentScore'),
            const SizedBox(height: 12),
            Text('Captured cards: ${captured.length}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              startGame();
            },
            child: Text(
              'PLAY AGAIN',
              style: TextStyle(color: theme.accent),
            ),
          ),
        ],
      ),
    );
  }

  void showRules() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.table,
        title: Text('TORA RULES',
            style: TextStyle(color: theme.accent)),
        content: const SingleChildScrollView(
          child: Text(
            '• Four players, 13 cards each.\n'
            '• Sahil and Zabihullah are teammates.\n'
            '• Mahmood Khan and Player 4 are teammates.\n'
            '• Follow the suit when possible.\n'
            '• The highest card of the led suit wins.\n'
            '• There is no trump suit.\n'
            '• Hearts = 1 point.\n'
            '• Queen of Spades = 9 points.\n'
            '• Jack of Clubs = 5 points.\n'
            '• Ten of Diamonds = 3 points.\n\n'
            'This version uses basic trick-taking rules.',
            style: TextStyle(color: Colors.white, height: 1.5),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('CLOSE',
                style: TextStyle(color: theme.accent)),
          ),
        ],
      ),
    );
  }

  void showThemes() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.table,
        title: Text('TABLE THEMES',
            style: TextStyle(color: theme.accent)),
        content: SizedBox(
          width: 300,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: themes.length,
            itemBuilder: (context, index) {
              final item = themes[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: item.accent,
                ),
                title: Text(item.name),
                onTap: () {
                  widget.onThemeChanged(item);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget playerLabel(String name, int score) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(.65),
        border: Border.all(color: theme.accent.withOpacity(.7)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$name  •  $score',
        style: TextStyle(
          color: theme.accent,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget cardWidget(
    PlayingCard card, {
    double width = 48,
    double height = 68,
    bool selected = false,
    VoidCallback? onTap,
  }) {
    final red = card.suit == '♥' || card.suit == '♦';

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: width,
        height: height,
        margin: EdgeInsets.only(bottom: selected ? 10 : 0),
        decoration: BoxDecoration(
          color: const Color(0xFFF9F7F0),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: selected ? theme.accent : Colors.black54,
            width: selected ? 2 : 1,
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black54,
              blurRadius: 4,
              offset: Offset(1, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              left: 4,
              top: 3,
              child: Column(
                children: [
                  Text(
                    card.rank,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1,
                      fontWeight: FontWeight.w900,
                      color: red ? Colors.red : Colors.black,
                    ),
                  ),
                  Text(
                    card.suit,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1,
                      color: red ? Colors.red : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            Center(
              child: Text(
                card.suit,
                style: TextStyle(
                  fontSize: height * .42,
                  color: red ? Colors.red : Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget hiddenCards(int count, {bool horizontal = true}) {
    return SizedBox(
      height: horizontal ? 48 : 75,
      width: horizontal ? min(count * 13.0 + 25, 180) : 48,
      child: Stack(
        children: List.generate(
          min(count, 13),
          (index) => Positioned(
            left: horizontal ? index * 9.0 : 0,
            top: horizontal ? 0 : index * 3.0,
            child: Container(
              width: 35,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF18243B),
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: theme.accent,
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  'T',
                  style: TextStyle(
                    color: theme.accent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget tableCard(int player) {
    final entry = tableCards.where((e) => e.player == player);
    if (entry.isEmpty) {
      return const SizedBox(width: 50, height: 68);
    }

    return cardWidget(
      entry.first.card,
      width: 48,
      height: 68,
    );
  }

  Widget centerTable() {
    return Container(
      width: 205,
      height: 160,
      decoration: BoxDecoration(
        color: theme.felt,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.accent.withOpacity(.7),
          width: 2,
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black45, blurRadius: 12),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 5,
            child: tableCard(2),
          ),
          Positioned(
            bottom: 5,
            child: tableCard(0),
          ),
          Positioned(
            left: 5,
            child: tableCard(3),
          ),
          Positioned(
            right: 5,
            child: tableCard(1),
          ),
          Text(
            'TORA',
            style: TextStyle(
              color: theme.accent.withOpacity(.18),
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: 4,
            ),
          ),
        ],
      ),
    );
  }

  Widget handCards() {
    final hand = hands[0];

    return SizedBox(
      height: 88,
      child: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: hand.map((card) {
              final legal = legalCards(0).contains(card);

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Opacity(
                  opacity: turn == 0 && legal ? 1 : .8,
                  child: cardWidget(
                    card,
                    width: 43,
                    height: 65,
                    onTap: legal ? () => playHuman(card) : null,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: theme.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  child: Row(
                    children: [
                      Text(
                        'TORA',
                        style: TextStyle(
                          color: theme.accent,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 4,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          message,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: theme.accent,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: showRules,
                        icon: Icon(Icons.help_outline,
                            color: theme.accent),
                      ),
                      IconButton(
                        onPressed: showThemes,
                        icon: Icon(Icons.palette_outlined,
                            color: theme.accent),
                      ),
                      IconButton(
                        onPressed: startGame,
                        icon: Icon(Icons.refresh,
                            color: theme.accent),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      SizedBox(
                        width: 80,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            playerLabel(
                              'Player 4',
                              opponentScore,
                            ),
                            const SizedBox(height: 8),
                            RotatedBox(
                              quarterTurns: 1,
                              child: hiddenCards(
                                hands[3].length,
                                horizontal: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            const SizedBox(height: 2),
                            playerLabel(
                              'Zabihullah',
                              sahilScore,
                            ),
                            hiddenCards(hands[2].length),
                            Expanded(
                              child: Center(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: [
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        playerLabel(
                                          'Mahmood Khan',
                                          opponentScore,
                                        ),
                                        const SizedBox(height: 5),
                                        RotatedBox(
                                          quarterTurns: 1,
                                          child: hiddenCards(
                                            hands[1].length,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 10),
                                    centerTable(),
                                    const SizedBox(width: 10),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'TRICKS  $tricks / 13',
                                          style: TextStyle(
                                            color: theme.accent,
                                            fontSize: 11,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Sahil: $sahilScore',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                          ),
                                        ),
                                        Text(
                                          'Opponents: $opponentScore',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            playerLabel('Sahil', sahilScore),
                            const SizedBox(height: 3),
                            handCards(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}