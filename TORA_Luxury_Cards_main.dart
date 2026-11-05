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
  // Sahil's hand is always the only visible hand on this device.
  List<String> get hand => hands['Sahil'] ?? <String>[];
  final List<String> tableCards = [];
  int roundNumber = 0;

  static const List<String> ranks = ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A'];
  static const List<String> suits = ['♠', '♥', '♦', '♣'];
  String? selectedCard;
  int turn = 0;

  @override
  void initState() {
    super.initState();
    dealNewRound();
  }

  void dealNewRound() {
    final deck = [for (final suit in suits) for (final rank in ranks) '$rank$suit'];
    deck.shuffle(Random());
    setState(() {
      hands.clear();
      for (var i = 0; i < players.length; i++) {
        hands[players[i]] = deck.sublist(i * 13, (i + 1) * 13);
      }
      for (final cards in hands.values) {
        cards.sort((a, b) {
          final suitCompare = suits.indexOf(a.substring(a.length - 1)).compareTo(suits.indexOf(b.substring(b.length - 1)));
          if (suitCompare != 0) return suitCompare;
          return ranks.indexOf(a.substring(0, a.length - 1)).compareTo(ranks.indexOf(b.substring(0, b.length - 1)));
        });
      }
      selectedCard = null;
      tableCards.clear();
      turn = 0;
      roundNumber++;
    });
  }

  final List<String> players = [
    'Sahil',
    'لوبغاړی ۲',
    'لوبغاړی ۳',
    'لوبغاړی ۴',
  ];

  final Map<String, int> teamPenalties = {
    'ټیم ۱': 0,
    'ټیم ۲': 0,
  };

  void playSelectedCard() {
    if (selectedCard == null) return;
    setState(() {
      hand.remove(selectedCard);
      tableCards.add(selectedCard!);
      selectedCard = null;
      // Until the complete four-player turn engine is implemented, keep Sahil's
      // hand selected; never reveal another player's cards on this screen.
      turn = 0;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('ورقه د ازمایښتي میدان لپاره کېښودل شوه')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: dark,
        foregroundColor: gold,
        title: const Text('👑 TORA', style: TextStyle(
          color: gold, fontWeight: FontWeight.w900, letterSpacing: 3,
        )),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'نوی لاس / نوې ورقې',
            onPressed: dealNewRound,
            icon: const Icon(Icons.shuffle, color: gold),
          ),
          IconButton(
            tooltip: 'تنظیمات',
            onPressed: () => _showInfo(context),
            icon: const Icon(Icons.settings, color: gold),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 4),
            Text('PLAY • ENJOY • WIN  |  لاس: $roundNumber',
              style: TextStyle(color: gold, letterSpacing: 2, fontSize: 11)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                children: [
                  Expanded(child: _teamScore(
                    'ټیم ۱',
                    teamPenalties['ټیم ۱']!,
                  )),
                  const SizedBox(width: 8),
                  Expanded(child: _teamScore(
                    'ټیم ۲',
                    teamPenalties['ټیم ۲']!,
                  )),
                ],
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF10100D),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: gold, width: 2),
                  boxShadow: const [
                    BoxShadow(color: Color(0x553D2B08), blurRadius: 18),
                  ],
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.spa, color: gold, size: 48),
                          SizedBox(height: 6),
                          Text('TORA TABLE', style: TextStyle(
                            color: gold, fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          )),
                          Text('د ورقو میدان', style: TextStyle(color: Colors.white70)),
                          SizedBox(height: 8),
                          Text('پر میدان: ${tableCards.length} ورقې', style: TextStyle(color: gold, fontSize: 11)),
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.topCenter,
                      child: _playerChip(players[1], 'مخ په مخ', hands[players[1]]?.length ?? 0),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: _playerChip(players[0], 'Sahil', hands[players[0]]?.length ?? 0),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: RotatedBox(
                        quarterTurns: 1,
                        child: _playerChip(players[2], 'ملګری', hands[players[2]]?.length ?? 0),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: RotatedBox(
                        quarterTurns: 3,
                        child: _playerChip(players[3], 'ملګری', hands[players[3]]?.length ?? 0),
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(.82),
                          border: Border.all(color: gold),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text('د وار لوبغاړی: ${players[turn]}',
                          style: const TextStyle(color: gold, fontWeight: FontWeight.bold)),
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
                  Text('د Sahil ورقې', style: const TextStyle(color: gold, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  Text('${hand.length} ورقې پاتې', style: const TextStyle(color: Colors.white70)),
                ],
              ),
            ),
            SizedBox(
              height: 92,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                scrollDirection: Axis.horizontal,
                itemCount: hand.length,
                separatorBuilder: (_, __) => const SizedBox(width: 5),
                itemBuilder: (context, index) {
                  final card = hand[index];
                  final isRed = card.contains('♥') || card.contains('♦');
                  final chosen = selectedCard == card;
                  return GestureDetector(
                    onTap: () => setState(() => selectedCard = chosen ? null : card),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 140),
                      width: 62,
                      transform: Matrix4.translationValues(0, chosen ? -8 : 0, 0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: chosen ? gold.withOpacity(.42) : Colors.black54,
                            blurRadius: chosen ? 10 : 4,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: _playingCardFace(card, isRed, chosen),
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
                      style: OutlinedButton.styleFrom(foregroundColor: gold, side: const BorderSide(color: gold)),
                      onPressed: () => _showTakalDialog(context),
                      child: const Text('نورې ورقې نشته'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(backgroundColor: gold, foregroundColor: Colors.black),
                      onPressed: selectedCard == null ? null : playSelectedCard,
                      child: const Text('ورقه واچوه', style: TextStyle(fontWeight: FontWeight.bold)),
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


  Widget _playingCardFace(String card, bool isRed, bool chosen) {
    final rank = card.substring(0, card.length - 1);
    final suit = card.substring(card.length - 1);
    final suitColor = isRed ? const Color(0xFFC62838) : const Color(0xFF171717);
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFFDF5), Color(0xFFE9DFC7)],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: chosen ? const Color(0xFFFFD45A) : const Color(0xFF9B7A32),
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
                  border: Border.all(color: const Color(0x339B7A32), width: .8),
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
                Text(rank, style: TextStyle(color: suitColor, fontSize: 15, height: 1, fontWeight: FontWeight.w900)),
                Text(suit, style: TextStyle(color: suitColor, fontSize: 13, height: 1.05)),
              ],
            ),
          ),
          Center(
            child: Text(suit, style: TextStyle(
              color: suitColor.withOpacity(.94),
              fontSize: 31,
              fontWeight: FontWeight.w900,
              shadows: const [Shadow(color: Color(0x559B7A32), blurRadius: 3, offset: Offset(1, 1))],
            )),
          ),
          Positioned(
            right: 6,
            bottom: 5,
            child: RotatedBox(
              quarterTurns: 2,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(rank, style: TextStyle(color: suitColor, fontSize: 15, height: 1, fontWeight: FontWeight.w900)),
                  Text(suit, style: TextStyle(color: suitColor, fontSize: 13, height: 1.05)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _teamScore(String name, int score) => Container(
    padding: const EdgeInsets.all(9),
    decoration: BoxDecoration(
      color: panel,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: gold.withOpacity(.75)),
    ),
    child: Column(
      children: [
        Text(name, textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 11)),
        const SizedBox(height: 3),
        Text('$score', style: const TextStyle(color: gold, fontSize: 22, fontWeight: FontWeight.w900)),
      ],
    ),
  );

  Widget _playerChip(String name, String subtitle, int cardCount) => Container(
    constraints: const BoxConstraints(maxWidth: 120),
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: const Color(0xEE090909),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: gold),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
        Text(subtitle, style: const TextStyle(color: gold, fontSize: 9)),
        Text('$cardCount ورقې', style: const TextStyle(color: Colors.white70, fontSize: 9)),
      ],
    ),
  );

  void _showTakalDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: panel,
        title: const Text('نورې ورقې نشته', style: TextStyle(color: gold)),
        content: const Text('دا تڼۍ د تکول د قانون لپاره ده؛ د پاتې ورقو شمېر او د ۳۰ نمرو انتقال به په راتلونکې مرحله کې بشپړ شي.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context),
            child: const Text('سمه ده', style: TextStyle(color: gold))),
        ],
      ),
    );
  }

  void _showInfo(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: panel,
        title: const Text('د TORA لومړنۍ نسخه', style: TextStyle(color: gold)),
        content: const Text('د ۵۲ ورقو ډیک په څلورو لوبغاړو وېشل کېږي. د Sahil ورقې تل ښکاره وي او د نورو درېیو لوبغاړو ورقې پټې وي. د لوبې بشپړ وارونه، نمرې، تکول او آنلاین برخه لا د جوړولو په حال کې دي.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context),
            child: const Text('بند', style: TextStyle(color: gold))),
        ],
      ),
    );
  }
}
