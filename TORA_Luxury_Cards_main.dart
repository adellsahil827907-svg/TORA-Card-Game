
import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(const ToraApp());

const gold = Color(0xFFD6A638);
const dark = Color(0xFF090909);
const panel = Color(0xFF17130B);

class ToraApp extends StatelessWidget {
  const ToraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TORA',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: dark,
        colorScheme: const ColorScheme.dark(
          primary: gold,
          secondary: gold,
          surface: panel,
        ),
        useMaterial3: true,
      ),
      home: const ToraTablePage(),
    );
  }
}

class ToraTablePage extends StatefulWidget {
  const ToraTablePage({super.key});

  @override
  State<ToraTablePage> createState() => _ToraTablePageState();
}

class _ToraTablePageState extends State<ToraTablePage> {
  final Map<String, List<String>> hands = {};
  List<String> get hand => hands['Sahil'] ?? <String>[];

  final List<String> tableCards = [];
  int roundNumber = 0;

  static const List<String> ranks = [
    '2', '3', '4', '5', '6', '7',
    '8', '9', '10', 'J', 'Q', 'K', 'A'
  ];

  static const List<String> suits = ['♠', '♥', '♦', '♣'];

  String? selectedCard;
  int turn = 0;

  final List<String> players = [
    'Sahil',
    'Player 2',
    'Player 3',
    'Player 4',
  ];

  final Map<String, int> teamPenalties = {
    'Team 1': 0,
    'Team 2': 0,
  };

  @override
  void initState() {
    super.initState();
    dealNewRound();
  }

  void dealNewRound() {
    final deck = [
      for (final suit in suits)
        for (final rank in ranks)
          '$rank$suit'
    ];

    deck.shuffle(Random());

    setState(() {
      hands.clear();

      for (var i = 0; i < players.length; i++) {
        hands[players[i]] =
            deck.sublist(i * 13, (i + 1) * 13);
      }

      for (final cards in hands.values) {
        cards.sort((a, b) {
          final suitCompare = suits
              .indexOf(a.substring(a.length - 1))
              .compareTo(
                suits.indexOf(b.substring(b.length - 1)),
              );

          if (suitCompare != 0) return suitCompare;

          return ranks
              .indexOf(a.substring(0, a.length - 1))
              .compareTo(
                ranks.indexOf(b.substring(0, b.length - 1)),
              );
        });
      }

      selectedCard = null;
      tableCards.clear();
      turn = 0;
      roundNumber++;
    });
  }

  void playSelectedCard() {
    if (selectedCard == null) return;

    setState(() {
      hand.remove(selectedCard);
      tableCards.add(selectedCard!);
      selectedCard = null;
      turn = 0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Card played on the test table.'),
      ),
    );
  }

  Widget _fieldCards(int side, {bool vertical = false}) {
    final cards = tableCards
        .asMap()
        .entries
        .where((entry) => entry.key % 4 == side)
        .map((entry) => entry.value)
        .toList();

    return Wrap(
      direction: vertical ? Axis.vertical : Axis.horizontal,
      spacing: 3,
      runSpacing: 3,
      children: cards.map((card) {
        final isRed =
            card.contains('♥') || card.contains('♦');

        return SizedBox(
          width: 35,
          height: 49,
          child: _playingCardFace(card, isRed, false),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: dark,
        foregroundColor: gold,
        title: const Text(
          '👑 TORA',
          style: TextStyle(
            color: gold,
            fontWeight: FontWeight.w900,
            letterSpacing: 3,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'New round',
            onPressed: dealNewRound,
            icon: const Icon(Icons.shuffle, color: gold),
          ),
          IconButton(
            tooltip: 'Settings',
            onPressed: () => _showInfo(context),
            icon: const Icon(Icons.settings, color: gold),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 4),

            Text(
              'PLAY • ENJOY • WIN  |  ROUND: $roundNumber',
              style: TextStyle(
                color: gold,
                letterSpacing: 2,
                fontSize: 11,
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 8,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _teamScore(
                      'Team 1',
                      teamPenalties['Team 1']!,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _teamScore(
                      'Team 2',
                      teamPenalties['Team 2']!,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF10100D),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: gold, width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x553D2B08),
                      blurRadius: 18,
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.spa,
                            color: gold,
                            size: 48,
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'TORA TABLE',
                            style: TextStyle(
                              color: gold,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                          const Text(
                            'CARD TABLE',
                            style: TextStyle(
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'ON TABLE: ${tableCards.length}',
                            style: const TextStyle(
                              color: gold,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // TOP CARDS
                    Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 58),
                        child: _fieldCards(1),
                      ),
                    ),

                    // BOTTOM CARDS
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 58),
                        child: _fieldCards(0),
                      ),
                    ),

                    // LEFT CARDS
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 2),
                        child: _fieldCards(
                          2,
                          vertical: true,
                        ),
                      ),
                    ),

                    // RIGHT CARDS
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 2),
                        child: _fieldCards(
                          3,
                          vertical: true,
                        ),
                      ),
                    ),

                    // TOP PLAYER
                    Align(
                      alignment: Alignment.topCenter,
                      child: _playerChip(
                        players[1],
                        'Opponent',
                        hands[players[1]]?.length ?? 0,
                      ),
                    ),

                    // BOTTOM PLAYER
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: _playerChip(
                        players[0],
                        'Sahil',
                        hands[players[0]]?.length ?? 0,
                      ),
                    ),

                    // LEFT PLAYER
                    Align(
                      alignment: Alignment.centerLeft,
                      child: RotatedBox(
                        quarterTurns: 1,
                        child: _playerChip(
                          players[2],
                          'Partner',
                          hands[players[2]]?.length ?? 0,
                        ),
                      ),
                    ),

                    // RIGHT PLAYER
                    Align(
                      alignment: Alignment.centerRight,
                      child: RotatedBox(
                        quarterTurns: 3,
                        child: _playerChip(
                          players[3],
                          'Partner',
                          hands[players[3]]?.length ?? 0,
                        ),
                      ),
                    ),

                    // CURRENT TURN
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(.82),
                          border: Border.all(color: gold),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Current turn: ${players[turn]}',
                          style: const TextStyle(
                            color: gold,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(10, 4, 10, 2),
              child: Row(
                children: [
                  const Text(
                    'SAHIL CARDS',
                    style: TextStyle(
                      color: gold,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${hand.length} cards left',
                    style: const TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(
              height: 92,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                scrollDirection: Axis.horizontal,
                itemCount: hand.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: 5),
                itemBuilder: (context, index) {
                  final card = hand[index];

                  final isRed =
                      card.contains('♥') ||
                      card.contains('♦');

                  final chosen = selectedCard == card;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCard =
                            chosen ? null : card;
                      });
                    },
                    child: AnimatedContainer(
                      duration:
                          const Duration(milliseconds: 140),
                      width: 62,
                      transform:
                          Matrix4.translationValues(
                        0,
                        chosen ? -8 : 0,
                        0,
                      ),
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: chosen
                                ? gold.withOpacity(.42)
                                : Colors.black54,
                            blurRadius: chosen ? 10 : 4,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: _playingCardFace(
                        card,
                        isRed,
                        chosen,
                      ),
                    ),
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(10, 2, 10, 10),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: gold,
                        side: const BorderSide(color: gold),
                      ),
                      onPressed: () =>
                          _showTakalDialog(context),
                      child: const Text('NO CARDS LEFT'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: gold,
                        foregroundColor: Colors.black,
                      ),
                      onPressed: selectedCard == null
                          ? null
                          : playSelectedCard,
                      child: const Text(
                        'PLAY CARD',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _playingCardFace(
    String card,
    bool isRed,
    bool chosen,
  ) {
    final rank = card.substring(0, card.length - 1);
    final suit = card.substring(card.length - 1);

    final suitColor = isRed
        ? const Color(0xFFC62838)
        : const Color(0xFF171717);

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFFDF5),
            Color(0xFFE9DFC7),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: chosen
              ? const Color(0xFFFFD45A)
              : const Color(0xFF9B7A32),
          width: chosen ? 2.8 : 1.4,
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(3),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(
                    color: const Color(0x339B7A32),
                    width: .8,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 6,
            top: 5,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  rank,
                  style: TextStyle(
                    color: suitColor,
                    fontSize: 15,
                    height: 1,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  suit,
                  style: TextStyle(
                    color: suitColor,
                    fontSize: 13,
                    height: 1.05,
                  ),
                ),
              ],
            ),
          ),
          Center(
            child: Text(
              suit,
              style: TextStyle(
                color: suitColor.withOpacity(.94),
                fontSize: 31,
                fontWeight: FontWeight.w900,
                shadows: const [
                  Shadow(
                    color: Color(0x559B7A32),
                    blurRadius: 3,
                    offset: Offset(1, 1),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 6,
            bottom: 5,
            child: RotatedBox(
              quarterTurns: 2,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    rank,
                    style: TextStyle(
                      color: suitColor,
                      fontSize: 15,
                      height: 1,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    suit,
                    style: TextStyle(
                      color: suitColor,
                      fontSize: 13,
                      height: 1.05,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _teamScore(String name, int score) {
    return Container(
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: gold.withOpacity(.75),
        ),
      ),
      child: Column(
        children: [
          Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            '$score',
            style: const TextStyle(
              color: gold,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _playerChip(
    String name,
    String subtitle,
    int cardCount,
  ) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 120),
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: const Color(0xEE090909),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: gold),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(
              color: gold,
              fontSize: 9,
            ),
          ),
          Text(
            '$cardCount cards',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }

  void _showTakalDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: panel,
        title: const Text(
          'NO CARDS LEFT',
          style: TextStyle(color: gold),
        ),
        content: const Text(
          'This option is reserved for the Takkal rule. '
          'Remaining-card checks and the 30-point transfer '
          'will be implemented in a later stage.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK',
              style: TextStyle(color: gold),
            ),
          ),
        ],
      ),
    );
  }

  void _showInfo(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: panel,
        title: const Text(
          'TORA - Early Version',
          style: TextStyle(color: gold),
        ),
        content: const Text(
          'A 52-card deck is dealt to four players. '
          'Sahil cards are visible; the other three hands '
          'remain hidden. Full turns, scoring, Takkal rules, '
          'and online play are still under development.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'CLOSE',
              style: TextStyle(color: gold),
            ),
          ),
        ],
      ),
    );
  }
}