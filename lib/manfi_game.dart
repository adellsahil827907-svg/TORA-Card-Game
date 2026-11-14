import 'dart:math';
import 'package:flutter/material.dart';

class ManfiGamePage extends StatefulWidget {
  final String styleName;
  final Color background, panel, felt, accent;
  const ManfiGamePage({super.key, required this.styleName, required this.background, required this.panel, required this.felt, required this.accent});
  @override
  State<ManfiGamePage> createState() => _ManfiGamePageState();
}

class _ManfiGamePageState extends State<ManfiGamePage> {
  static const List<String> _suits = ['♠', '♥', '♦', '♣'];
  static const List<String> _ranks = ['A', 'K', 'Q', 'J', '10', '9', '8', '7', '6', '5', '4', '3', '2'];
  static const List<String> _players = ['ساحل', 'محمود خان', 'محبت الله', 'ذبیح الله'];
  List<List<String>> _hands = [];
  bool _dealt = false;
  int? _openingLeader;

  void _dealCards() {
    final deck = <String>[
      for (final suit in _suits)
        for (final rank in _ranks) '$rank$suit',
    ]..shuffle(Random());
    final hands = List.generate(4, (_) => <String>[]);
    for (int i = 0; i < deck.length; i++) {
      hands[i % 4].add(deck[i]);
    }
    int suitOrder(String card) => _suits.indexOf(card.substring(card.length - 1));
    int rankOrder(String card) => _ranks.indexOf(card.substring(0, card.length - 1));
    for (final hand in hands) {
      hand.sort((a, b) {
        final s = suitOrder(a).compareTo(suitOrder(b));
        return s != 0 ? s : rankOrder(a).compareTo(rankOrder(b));
      });
    }
    final leader = hands.indexWhere((hand) => hand.contains('2♣'));
    setState(() {
      _hands = hands;
      _openingLeader = leader;
      _dealt = true;
    });
  }

  Color _cardInk(String card) => card.endsWith('♥') || card.endsWith('♦')
      ? const Color(0xFFCB3448) : const Color(0xFF17202A);

  Widget _playingCard(String card) {
    final suit = card.substring(card.length - 1);
    final rank = card.substring(0, card.length - 1);
    return Container(
      width: 42, height: 62,
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF3),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: widget.accent.withOpacity(.85)),
        boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 3, offset: Offset(1, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(rank, style: TextStyle(color: _cardInk(card), fontSize: 12, fontWeight: FontWeight.w900, height: 1)),
        Expanded(child: Center(child: Text(suit, style: TextStyle(color: _cardInk(card), fontSize: 22, fontWeight: FontWeight.w900)))),
      ]),
    );
  }

  Widget _playerPanel(int index, {bool compact = false}) {
    final isLeader = _dealt && _openingLeader == index;
    final team = (index == 0 || index == 2) ? 'ساحل + محبت الله' : 'محمود خان + ذبیح الله';
    return Container(
      constraints: const BoxConstraints(minHeight: 54),
      padding: EdgeInsets.symmetric(horizontal: compact ? 7 : 10, vertical: compact ? 6 : 8),
      decoration: BoxDecoration(
        color: widget.panel.withOpacity(.96),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: isLeader ? widget.accent : widget.accent.withOpacity(.48), width: isLeader ? 2 : 1),
        boxShadow: [BoxShadow(color: widget.accent.withOpacity(.09), blurRadius: 8)],
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.person_rounded, color: widget.accent, size: compact ? 17 : 20),
        const SizedBox(width: 5),
        Expanded(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_players[index], maxLines: 1, overflow: TextOverflow.ellipsis,
            style: TextStyle(color: widget.accent, fontSize: compact ? 10 : 12, fontWeight: FontWeight.w900)),
          Text(team, maxLines: 1, overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white60, fontSize: 8)),
        ])),
        if (_dealt) Padding(padding: const EdgeInsets.only(left: 3),
          child: Text('\${_hands[index].length}', style: const TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.bold))),
        if (isLeader) Icon(Icons.stars_rounded, color: widget.accent, size: 16),
      ]),
    );
  }

  Widget _tableCenter() => Container(
    width: 132, height: 104,
    decoration: BoxDecoration(
      color: widget.felt,
      borderRadius: BorderRadius.circular(52),
      border: Border.all(color: widget.accent, width: 2),
      boxShadow: [BoxShadow(color: widget.accent.withOpacity(.18), blurRadius: 14, spreadRadius: 1)],
    ),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text('♛', style: TextStyle(color: widget.accent, fontSize: 26, height: 1)),
      const SizedBox(height: 4),
      Text(_dealt ? 'CARDS DEALT' : 'MANFI',
        style: TextStyle(color: widget.accent, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.3)),
      const SizedBox(height: 3),
      Text(_dealt ? '۱۳ کارت هر لوبغاړي ته' : 'د لوبې میدان',
        style: const TextStyle(color: Colors.white70, fontSize: 9)),
    ]),
  );

  Widget _buildTable() => LayoutBuilder(builder: (context, constraints) => Stack(
    alignment: Alignment.center,
    children: [
      Positioned.fill(child: Container(
        margin: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          gradient: RadialGradient(colors: [
            Color.lerp(widget.felt, widget.accent, .12)!, widget.felt, widget.background,
          ]),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: widget.accent, width: 2),
          boxShadow: [BoxShadow(color: widget.accent.withOpacity(.14), blurRadius: 14)],
        ),
      )),
      Positioned(top: 12, left: constraints.maxWidth * .25, right: constraints.maxWidth * .25,
        child: _playerPanel(3)),
      Positioned(left: 9, top: constraints.maxHeight * .38, width: constraints.maxWidth * .31,
        child: _playerPanel(2, compact: true)),
      Positioned(right: 9, top: constraints.maxHeight * .38, width: constraints.maxWidth * .31,
        child: _playerPanel(1, compact: true)),
      Center(child: _tableCenter()),
      Positioned(bottom: 12, left: constraints.maxWidth * .25, right: constraints.maxWidth * .25,
        child: _playerPanel(0)),
    ],
  ));

  @override
  Widget build(BuildContext context) {
    final myHand = _dealt ? _hands[0] : <String>[];
    return Scaffold(
      backgroundColor: widget.background,
      appBar: AppBar(
        backgroundColor: widget.background,
        foregroundColor: widget.accent,
        title: const Text('MANFI GAME', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5)),
      ),
      body: SafeArea(child: Column(children: [
        Padding(padding: const EdgeInsets.fromLTRB(12, 5, 12, 5), child: Row(children: [
          Expanded(child: Text('MANFI • FIRST DEAL',
            style: TextStyle(color: widget.accent, fontWeight: FontWeight.w900, letterSpacing: 1))),
          Text(widget.styleName, style: const TextStyle(color: Colors.white54, fontSize: 9)),
        ])),
        Expanded(child: Padding(padding: const EdgeInsets.fromLTRB(7, 3, 7, 5), child: _buildTable())),
        Padding(padding: const EdgeInsets.fromLTRB(10, 3, 10, 2), child: Row(children: [
          Expanded(child: Text('ستاسو کارتونه  •  A تر 2 پورې',
            style: TextStyle(color: widget.accent, fontSize: 11, fontWeight: FontWeight.w900))),
          Text(_dealt ? '\${myHand.length}/13' : '0/13',
            style: const TextStyle(color: Colors.white70, fontSize: 10)),
        ])),
        SizedBox(height: 76, child: _dealt
          ? ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              itemCount: myHand.length,
              separatorBuilder: (_, __) => const SizedBox(width: 4),
              itemBuilder: (context, index) => _playingCard(myHand[index]),
            )
          : const Center(child: Text('لومړی کارتونه ووېشه',
              style: TextStyle(color: Colors.white54, fontSize: 11)))),
        if (_dealt && _openingLeader != null)
          Padding(padding: const EdgeInsets.only(bottom: 3), child: Text(
            'لومړی وار: \${_players[_openingLeader!]}  •  د چمچي ۲ (2♣) خاوند',
            style: TextStyle(color: widget.accent, fontSize: 10, fontWeight: FontWeight.w800))),
        Padding(padding: const EdgeInsets.fromLTRB(12, 4, 12, 9), child: SizedBox(
          width: double.infinity, height: 43,
          child: FilledButton.icon(
            onPressed: _dealCards,
            style: FilledButton.styleFrom(
              backgroundColor: widget.accent, foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            icon: const Icon(Icons.shuffle_rounded),
            label: Text(_dealt ? 'REDEAL 13 CARDS' : 'DEAL 13 CARDS',
              style: const TextStyle(fontWeight: FontWeight.w900)),
          ),
        )),
      ])),
    );
  }
}
