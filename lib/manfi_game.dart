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
  static const _ranks = ['2','3','4','5','6','7','8','9','10','J','Q','K','A'];
  static const _suits = ['♠','♥','♦','♣'];
  static const _players = ['ساحل','محمود خان','محبت الله','ذبیح الله'];
  static const _teams = ['ساحل + محبت الله','محمود خان + ذبیح الله'];
  List<List<String>> _hands = [];
  bool _dealt = false;
  int? _openingLeader;

  void _dealCards() {
    final deck = <String>[
      for (final suit in _suits)
        for (final rank in _ranks) '\$rank\$suit',
    ]..shuffle(Random());
    final hands = List.generate(4, (_) => <String>[]);
    for (int i = 0; i < deck.length; i++) {
      hands[i % 4].add(deck[i]);
    }
    int suitOrder(String card) => _suits.indexOf(card.substring(card.length - 1));
    int rankOrder(String card) => _ranks.indexOf(card.substring(0, card.length - 1));
    for (final hand in hands) {
      hand.sort((a, b) {
        final suitCompare = suitOrder(a).compareTo(suitOrder(b));
        return suitCompare != 0 ? suitCompare : rankOrder(a).compareTo(rankOrder(b));
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
    return Container(
      width: 43, height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF3),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: widget.accent.withOpacity(.8)),
        boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 3, offset: Offset(1, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(card.substring(0, card.length - 1),
          style: TextStyle(color: _cardInk(card), fontSize: 12, fontWeight: FontWeight.w900, height: 1)),
        Expanded(child: Center(child: Text(suit,
          style: TextStyle(color: _cardInk(card), fontSize: 22, fontWeight: FontWeight.w900)))),
      ]),
    );
  }

  Widget _playerPanel(int index) {
    final leader = _dealt && _openingLeader == index;
    final team = index == 0 || index == 2 ? _teams[0] : _teams[1];
    return Container(
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: widget.panel.withOpacity(.92),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: leader ? widget.accent : widget.accent.withOpacity(.35), width: leader ? 2 : 1),
      ),
      child: Row(children: [
        Icon(index == 0 ? Icons.person_rounded : Icons.person_outline_rounded, color: widget.accent, size: 21),
        const SizedBox(width: 7),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_players[index], style: TextStyle(color: widget.accent, fontSize: 12, fontWeight: FontWeight.w900)),
          Text(team, maxLines: 1, overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white54, fontSize: 9)),
        ])),
        if (_dealt) Text('\${_hands[index].length}/13',
          style: const TextStyle(color: Colors.white70, fontSize: 10)),
        if (leader) Icon(Icons.stars_rounded, color: widget.accent, size: 18),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final myHand = _dealt ? _hands[0] : <String>[];
    return Scaffold(
      backgroundColor: widget.background,
      appBar: AppBar(
        backgroundColor: widget.background, foregroundColor: widget.accent,
        title: const Text('MANFI GAME', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5)),
      ),
      body: SafeArea(child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
          child: Row(children: [
            Expanded(child: Text('MANFI • FIRST DEAL', style: TextStyle(color: widget.accent, fontWeight: FontWeight.w900, letterSpacing: 1))),
            Text(widget.styleName, style: const TextStyle(color: Colors.white54, fontSize: 10)),
          ]),
        ),
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
          child: Column(children: [
            _playerPanel(1),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: _playerPanel(2)),
              const SizedBox(width: 8),
              Expanded(child: _playerPanel(3)),
            ]),
            const SizedBox(height: 12),
            Container(
              width: double.infinity, padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: widget.felt, borderRadius: BorderRadius.circular(18),
                border: Border.all(color: widget.accent, width: 1.5),
                boxShadow: [BoxShadow(color: widget.accent.withOpacity(.10), blurRadius: 12)],
              ),
              child: Column(children: [
                Icon(Icons.style_rounded, color: widget.accent, size: 28),
                const SizedBox(height: 5),
                Text(_dealt ? 'CARDS DEALT' : 'READY TO DEAL',
                  style: TextStyle(color: widget.accent, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                const SizedBox(height: 5),
                Text(_dealt ? 'هر لوبغاړي ته ۱۳ کارتونه ورکړل شول.' : 'د MANFI د لومړي پړاو لپاره ۵۲ کارتونه وېشل کېږي.',
                  textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontSize: 11)),
                if (_dealt && _openingLeader != null) ...[
                  const SizedBox(height: 10),
                  Text('لومړی وار: \${_players[_openingLeader!]}',
                    style: TextStyle(color: widget.accent, fontSize: 15, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 3),
                  const Text('د چمچي ۲ (2♣) خاوند لومړی کارت پیلوي.',
                    textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 10)),
                ],
              ]),
            ),
            const SizedBox(height: 10),
            _playerPanel(0),
            const SizedBox(height: 10),
            if (_dealt) ...[
              Align(alignment: Alignment.centerLeft, child: Text('ستاسو ۱۳ کارتونه',
                style: TextStyle(color: widget.accent, fontWeight: FontWeight.w900, fontSize: 12))),
              const SizedBox(height: 7),
              Wrap(alignment: WrapAlignment.center, spacing: 5, runSpacing: 6,
                children: [for (final card in myHand) _playingCard(card)]),
              const SizedBox(height: 12),
              const Text('د نورو لوبغاړو کارتونه پټ ساتل کېږي.',
                style: TextStyle(color: Colors.white54, fontSize: 10)),
            ] else
              const Text('لومړی کارتونه ووېشه؛ د نورو درې لوبغاړو کارتونه به پټ وي.',
                textAlign: TextAlign.center, style: TextStyle(color: Colors.white60, fontSize: 11)),
          ]),
        )),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
          child: SizedBox(width: double.infinity, height: 48,
            child: FilledButton.icon(
              onPressed: _dealCards,
              style: FilledButton.styleFrom(
                backgroundColor: widget.accent, foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13))),
              icon: const Icon(Icons.shuffle_rounded),
              label: Text(_dealt ? 'REDEAL 13 CARDS' : 'DEAL 13 CARDS',
                style: const TextStyle(fontWeight: FontWeight.w900)),
            ),
          ),
        ),
      ])),
    );
  }
}
