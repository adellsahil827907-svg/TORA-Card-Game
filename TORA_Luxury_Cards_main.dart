import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(const ToraApp());

const gold = Color(0xFFD6A638);
const dark = Color(0xFF090909);
const panel = Color(0xFF17130B);

class ToraApp extends StatelessWidget {
  const ToraApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'TORA',
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: dark,
          colorScheme: const ColorScheme.dark(primary: gold, secondary: gold, surface: panel),
          useMaterial3: true,
        ),
        home: const ToraTablePage(),
      );
}

class ToraTablePage extends StatefulWidget {
  const ToraTablePage({super.key});
  @override
  State<ToraTablePage> createState() => _ToraTablePageState();
}

class _ToraTablePageState extends State<ToraTablePage> {
  static const ranks = ['2','3','4','5','6','7','8','9','10','J','Q','K','A'];
  static const suits = ['♠','♥','♦','♣'];
  final Random random = Random();
  final List<String> players = ['Sahil', 'Player 2', 'Player 3', 'Player 4'];
  final Map<String, List<String>> hands = {};
  final Map<int, List<String>> playedByPlayer = {0: [], 1: [], 2: [], 3: []};
  final Map<String, int> teamPenalties = {'Team 1': 0, 'Team 2': 0};
  int turn = 0;
  int roundNumber = 0;
  bool aiThinking = false;
  bool roundOver = false;

  List<String> get hand => hands[players[0]] ?? <String>[];

  @override
  void initState() {
    super.initState();
    dealNewRound();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void dealNewRound() {
    final deck = [for (final suit in suits) for (final rank in ranks) '$rank$suit']..shuffle(random);
    setState(() {
      hands.clear();
      for (var i = 0; i < 4; i++) {
        final cards = deck.sublist(i * 13, (i + 1) * 13);
        cards.sort(_compareCards);
        hands[players[i]] = cards;
        playedByPlayer[i] = [];
      }
      turn = 0;
      aiThinking = false;
      roundOver = false;
      roundNumber++;
    });
  }

  int _compareCards(String a, String b) {
    final sa = suits.indexOf(a.substring(a.length - 1));
    final sb = suits.indexOf(b.substring(b.length - 1));
    if (sa != sb) return sa.compareTo(sb);
    return ranks.indexOf(a.substring(0, a.length - 1)).compareTo(ranks.indexOf(b.substring(0, b.length - 1)));
  }

  void _playSahilCard(String card) {
    if (turn != 0 || aiThinking || roundOver || !hand.contains(card)) return;
    setState(() {
      hand.remove(card);
      playedByPlayer[0]!.add(card);
      _advanceTurn();
    });
    _runComputerTurns();
  }

  void _advanceTurn() {
    if (hands.values.every((cards) => cards.isEmpty)) {
      roundOver = true;
      return;
    }
    for (var step = 1; step <= 4; step++) {
      final next = (turn + step) % 4;
      if (hands[players[next]]!.isNotEmpty) {
        turn = next;
        return;
      }
    }
    roundOver = true;
  }

  Future<void> _runComputerTurns() async {
    while (mounted && turn != 0 && !roundOver) {
      setState(() => aiThinking = true);
      await Future.delayed(const Duration(milliseconds: 850));
      if (!mounted || roundOver) return;
      final playerIndex = turn;
      final computerHand = hands[players[playerIndex]]!;
      if (computerHand.isNotEmpty) {
        final card = computerHand.removeAt(random.nextInt(computerHand.length));
        playedByPlayer[playerIndex]!.add(card);
      }
      setState(() {
        aiThinking = false;
        _advanceTurn();
      });
    }
    if (mounted && roundOver) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Round finished. Start a new round.')));
    }
  }

  Future<void> _editPlayerNames() async {
    final controllers = players.map((name) => TextEditingController(text: name)).toList();
    final result = await showDialog<List<String>>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: panel,
        title: const Text('PLAYER NAMES', style: TextStyle(color: gold)),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            for (var i = 0; i < 4; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: TextField(
                  controller: controllers[i],
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(labelText: 'Player ${i + 1}', labelStyle: const TextStyle(color: gold), enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: gold))),
                ),
              ),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('CANCEL', style: TextStyle(color: gold))),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, controllers.map((c) => c.text.trim()).toList()), child: const Text('SAVE')),
        ],
      ),
    );
    for (final c in controllers) { c.dispose(); }
    if (result == null) return;
    setState(() {
      final oldHands = Map<String, List<String>>.from(hands);
      for (var i = 0; i < 4; i++) {
        final name = result[i].isEmpty ? 'Player ${i + 1}' : result[i];
        players[i] = name;
      }
      hands
        ..clear()
        ..addAll({for (var i = 0; i < 4; i++) players[i]: oldHands.values.elementAt(i)});
    });
  }

  Widget _cardFace(String card, {double width = 48, double height = 66}) {
    final rank = card.substring(0, card.length - 1);
    final suit = card.substring(card.length - 1);
    final red = suit == '♥' || suit == '♦';
    final ink = red ? const Color(0xFFC62838) : const Color(0xFF171717);
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFFFFDF5), Color(0xFFE9DFC7)]),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF9B7A32), width: 1.2),
      ),
      child: Stack(children: [
        Positioned(left: 4, top: 3, child: Column(mainAxisSize: MainAxisSize.min, children: [Text(rank, style: TextStyle(color: ink, fontWeight: FontWeight.w900, fontSize: 12, height: 1)), Text(suit, style: TextStyle(color: ink, fontSize: 11, height: 1))])),
        Center(child: Text(suit, style: TextStyle(color: ink, fontSize: width * .48, fontWeight: FontWeight.bold))),
        Positioned(right: 4, bottom: 3, child: RotatedBox(quarterTurns: 2, child: Column(mainAxisSize: MainAxisSize.min, children: [Text(rank, style: TextStyle(color: ink, fontWeight: FontWeight.w900, fontSize: 12, height: 1)), Text(suit, style: TextStyle(color: ink, fontSize: 11, height: 1))]))),
      ]),
    );
  }

  Widget _pile(int playerIndex, {bool vertical = false}) {
    final cards = playedByPlayer[playerIndex]!;
    if (cards.isEmpty) return const SizedBox(width: 40, height: 54);
    final visible = cards.length > 3 ? cards.sublist(cards.length - 3) : cards;
    return Flex(
      direction: vertical ? Axis.vertical : Axis.horizontal,
      mainAxisSize: MainAxisSize.min,
      children: [for (final card in visible) Padding(padding: const EdgeInsets.all(1), child: _cardFace(card, width: 34, height: 47))],
    );
  }

  Widget _playerChip(int index, String subtitle) => Container(
        constraints: const BoxConstraints(maxWidth: 112),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(color: const Color(0xEE090909), borderRadius: BorderRadius.circular(10), border: Border.all(color: gold)),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(players[index], maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
          Text(subtitle, style: const TextStyle(color: gold, fontSize: 9)),
          Text('${hands[players[index]]?.length ?? 0} cards', style: const TextStyle(color: Colors.white70, fontSize: 9)),
        ]),
      );

  Widget _score(String name) => Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: panel, borderRadius: BorderRadius.circular(10), border: Border.all(color: gold.withOpacity(.7))),
        child: Column(children: [Text(name, style: const TextStyle(color: Colors.white, fontSize: 11)), Text('${teamPenalties[name]}', style: const TextStyle(color: gold, fontSize: 20, fontWeight: FontWeight.w900))]),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: dark,
        foregroundColor: gold,
        centerTitle: true,
        title: const Text('👑 TORA', style: TextStyle(color: gold, fontWeight: FontWeight.w900, letterSpacing: 3)),
        actions: [IconButton(tooltip: 'New round', onPressed: dealNewRound, icon: const Icon(Icons.shuffle, color: gold)), IconButton(tooltip: 'Player names', onPressed: _editPlayerNames, icon: const Icon(Icons.people_alt, color: gold))],
      ),
      body: SafeArea(child: Column(children: [
        const SizedBox(height: 4),
        Text('PLAY • ENJOY • WIN  |  ROUND: $roundNumber', style: const TextStyle(color: gold, letterSpacing: 1.5, fontSize: 10)),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7), child: Row(children: [Expanded(child: _score('Team 1')), const SizedBox(width: 8), Expanded(child: _score('Team 2'))])),
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: const Color(0xFF10100D), borderRadius: BorderRadius.circular(25), border: Border.all(color: gold, width: 2)),
            child: DragTarget<String>(
              onWillAcceptWithDetails: (details) => turn == 0 && !aiThinking && hand.contains(details.data),
              onAcceptWithDetails: (details) => _playSahilCard(details.data),
              builder: (context, candidates, rejected) => Stack(children: [
                Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.spa, color: gold.withOpacity(.8), size: 38), const Text('TORA TABLE', style: TextStyle(color: gold, fontWeight: FontWeight.bold, letterSpacing: 2)), const SizedBox(height: 3), Text('CARDS PLAYED: ${playedByPlayer.values.fold<int>(0, (sum, list) => sum + list.length)}', style: const TextStyle(color: gold, fontSize: 10)), if (candidates.isNotEmpty) const Text('RELEASE TO PLAY', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))])),
                Align(alignment: Alignment.topCenter, child: Padding(padding: const EdgeInsets.only(top: 45), child: Column(mainAxisSize: MainAxisSize.min, children: [_playerChip(1, 'Opponent'), const SizedBox(height: 3), _pile(1)]))),
                Align(alignment: Alignment.bottomCenter, child: Padding(padding: const EdgeInsets.only(bottom: 3), child: Column(mainAxisSize: MainAxisSize.min, children: [_pile(0), const SizedBox(height: 3), _playerChip(0, 'You')]))),
                Align(alignment: Alignment.centerLeft, child: Padding(padding: const EdgeInsets.only(left: 1), child: Row(mainAxisSize: MainAxisSize.min, children: [RotatedBox(quarterTurns: 1, child: _playerChip(2, 'Partner')), const SizedBox(width: 2), _pile(2, vertical: true)]))),
                Align(alignment: Alignment.centerRight, child: Padding(padding: const EdgeInsets.only(right: 1), child: Row(mainAxisSize: MainAxisSize.min, children: [_pile(3, vertical: true), const SizedBox(width: 2), RotatedBox(quarterTurns: 3, child: _playerChip(3, 'Partner'))]))),
                Align(alignment: Alignment.center, child: Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6), decoration: BoxDecoration(color: Colors.black.withOpacity(.82), border: Border.all(color: gold), borderRadius: BorderRadius.circular(10)), child: Text(aiThinking ? '${players[turn]} is playing…' : 'TURN: ${players[turn]}', style: const TextStyle(color: gold, fontWeight: FontWeight.bold, fontSize: 11)))),
              ]),
            ),
          ),
        ),
        Padding(padding: const EdgeInsets.fromLTRB(10, 4, 10, 2), child: Row(children: [const Text('SAHIL CARDS', style: TextStyle(color: gold, fontWeight: FontWeight.bold)), const Spacer(), Text('${hand.length} cards left', style: const TextStyle(color: Colors.white70))])),
        SizedBox(
          height: 100,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
            scrollDirection: Axis.horizontal,
            itemCount: hand.length,
            separatorBuilder: (_, __) => const SizedBox(width: 4),
            itemBuilder: (context, index) {
              final card = hand[index];
              return Draggable<String>(
                data: card,
                feedback: Material(color: Colors.transparent, child: _cardFace(card, width: 62, height: 86)),
                childWhenDragging: Opacity(opacity: .22, child: _cardFace(card, width: 57, height: 78)),
                child: _cardFace(card, width: 57, height: 78),
              );
            },
          ),
        ),
        Padding(padding: const EdgeInsets.fromLTRB(10, 2, 10, 9), child: Row(children: [Expanded(child: OutlinedButton(onPressed: _showTakalInfo, style: OutlinedButton.styleFrom(foregroundColor: gold, side: const BorderSide(color: gold)), child: const Text('NO CARDS LEFT'))), const SizedBox(width: 8), Expanded(child: FilledButton(onPressed: dealNewRound, style: FilledButton.styleFrom(backgroundColor: gold, foregroundColor: Colors.black), child: const Text('NEW ROUND')))])),
      ])),
    );
  }

  void _showTakalInfo() {
    showDialog<void>(context: context, builder: (context) => AlertDialog(backgroundColor: panel, title: const Text('NO CARDS LEFT', style: TextStyle(color: gold)), content: const Text('The exact Takkal rule and 30-point transfer need the official game rules before they can be implemented.'), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK', style: TextStyle(color: gold)))]));
  }
}
