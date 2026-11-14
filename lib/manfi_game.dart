import 'dart:async';
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
  static const suits = ['♠', '♥', '♦', '♣'];
  static const ranks = ['A', 'K', 'Q', 'J', '10', '9', '8', '7', '6', '5', '4', '3', '2'];
  static const players = ['ساحل', 'محمود خان', 'محبت الله', 'ذبیح الله'];
  static const clockwise = [0, 2, 3, 1];
  List<List<String>> hands = List.generate(4, (_) => <String>[]);
  final Map<int, String> trick = {};
  int turn = 0, leadSuit = -1, tricksA = 0, tricksB = 0, completed = 0;
  bool dealt = false, busy = false, finished = false;
  String message = 'کارتونه ووېشه؛ د چمچي ۲ خاوند لومړی وار کوي.';

  int suit(String c) => suits.indexOf(c.substring(c.length - 1));
  String rank(String c) => c.substring(0, c.length - 1);
  int power(String c) => 14 - ranks.indexOf(rank(c));
  int next(int p) => clockwise[(clockwise.indexOf(p) + 1) % 4];

  void deal() {
    final deck = [for (final s in suits) for (final r in ranks) '$r$s']..shuffle(Random());
    final h = List.generate(4, (_) => <String>[]);
    for (var i = 0; i < deck.length; i++) { h[i % 4].add(deck[i]); }
    for (final hand in h) {
      hand.sort((a, b) {
        final x = suit(a).compareTo(suit(b));
        return x != 0 ? x : ranks.indexOf(rank(a)).compareTo(ranks.indexOf(rank(b)));
      });
    }
    final leader = h.indexWhere((x) => x.contains('2♣'));
    setState(() {
      hands = h; trick.clear(); turn = leader; leadSuit = -1;
      tricksA = 0; tricksB = 0; completed = 0;
      dealt = true; busy = false; finished = false;
      message = players[leader] + ' د چمچي ۲ خاوند دی؛ لومړی وار د هغه دی.';
    });
    computerTurn();
  }

  List<String> legal(int p) {
    if (trick.isEmpty) return List<String>.from(hands[p]);
    final follow = hands[p].where((c) => suit(c) == leadSuit).toList();
    return follow.isNotEmpty ? follow : List<String>.from(hands[p]);
  }

  void play(int p, String c) {
    if (!dealt || busy || finished || p != turn || !legal(p).contains(c)) return;
    setState(() {
      hands[p].remove(c);
      trick[p] = c;
      if (trick.length == 1) leadSuit = suit(c);
      turn = next(p);
      message = players[p] + ' کارت واچاوه.';
    });
    if (trick.length == 4) settle();
    else computerTurn();
  }

  int winner() {
    final entries = trick.entries.toList();
    final trump = entries.any((e) => suit(e.value) == 0);
    final winningSuit = trump ? 0 : leadSuit;
    var best = entries.firstWhere((e) => suit(e.value) == winningSuit);
    for (final e in entries) {
      if (suit(e.value) == winningSuit && power(e.value) > power(best.value)) best = e;
    }
    return best.key;
  }

  void settle() {
    final w = winner();
    final teamA = w == 0 || w == 2;
    setState(() {
      if (teamA) { tricksA++; } else { tricksB++; }
      completed++; busy = true;
      message = players[w] + ' لاس وګاټه.';
    });
    Timer(const Duration(milliseconds: 1100), () {
      if (!mounted) return;
      setState(() {
        trick.clear(); leadSuit = -1; turn = w; busy = false;
        if (completed == 13) {
          finished = true;
          message = 'لوبه بشپړه شوه؛ ساحل او محبت الله: ' + tricksA.toString() +
              '، محمود خان او ذبیح الله: ' + tricksB.toString();
        } else {
          message = players[w] + ' بل لاس پیلوي.';
        }
      });
      computerTurn();
    });
  }

  Future<void> computerTurn() async {
    if (!mounted || !dealt || finished || busy || turn == 0 || trick.length >= 4) return;
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted || busy || finished || turn == 0 || trick.length >= 4) return;
    final p = turn;
    final options = legal(p);
    if (options.isNotEmpty) play(p, options.first);
  }

  Color ink(String c) => c.endsWith('♥') || c.endsWith('♦')
      ? const Color(0xFFCB3448) : const Color(0xFF17202A);

  Widget card(String c, {bool drag = false}) {
    final s = c.substring(c.length - 1), r = rank(c);
    final face = Container(
      width: 43, height: 64, padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: const Color(0xFFFFFCF3),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: widget.accent),
        boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 3, offset: Offset(1, 2))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(r, style: TextStyle(color: ink(c), fontSize: 12, fontWeight: FontWeight.w900, height: 1)),
        Expanded(child: Center(child: Text(s, style: TextStyle(color: ink(c), fontSize: 22, fontWeight: FontWeight.w900)))),
      ]),
    );
    if (!drag) return face;
    return Draggable<String>(data: c,
      feedback: Material(color: Colors.transparent, child: Transform.scale(scale: 1.1, child: face)),
      childWhenDragging: Opacity(opacity: .2, child: face), child: face);
  }

  Widget player(int p, {bool small = false}) {
    final active = dealt && !finished && turn == p;
    final team = p == 0 || p == 2 ? 'ساحل + محبت الله' : 'محمود خان + ذبیح الله';
    return Container(
      padding: EdgeInsets.symmetric(horizontal: small ? 6 : 9, vertical: 7),
      decoration: BoxDecoration(color: widget.panel,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: active ? Colors.greenAccent : widget.accent, width: active ? 2.5 : 1)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(active ? Icons.play_circle_fill : Icons.person, color: active ? Colors.greenAccent : widget.accent, size: 17),
        const SizedBox(width: 4),
        Expanded(child: Column(crossAxisSize: CrossAxisAlignment.start, children: [
          Text(players[p], maxLines: 1, overflow: TextOverflow.ellipsis,
            style: TextStyle(color: widget.accent, fontSize: small ? 10 : 12, fontWeight: FontWeight.bold)),
          Text(team, maxLines: 1, overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white60, fontSize: 7)),
        ])),
        if (dealt) Text(hands[p].length.toString(), style: const TextStyle(color: Colors.white70, fontSize: 9)),
      ]),
    );
  }

  Widget played(int p) => Column(mainAxisSize: MainAxisSize.min, children: [
    Text(players[p], style: TextStyle(color: widget.accent, fontSize: 8)),
    const SizedBox(height: 2),
    if (trick[p] != null) card(trick[p]!) else Container(width: 38, height: 55,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(6), color: Colors.black12,
        border: Border.all(color: widget.accent.withOpacity(.3)))),
  ]);

  Widget center() => DragTarget<String>(
    onWillAcceptWithDetails: (d) => dealt && !busy && !finished && turn == 0 && legal(0).contains(d.data),
    onAcceptWithDetails: (d) => play(0, d.data),
    builder: (context, candidates, rejected) => AnimatedContainer(
      duration: const Duration(milliseconds: 160), width: 180, height: 180,
      decoration: BoxDecoration(color: widget.felt, borderRadius: BorderRadius.circular(90),
        border: Border.all(color: candidates.isNotEmpty ? Colors.greenAccent : widget.accent, width: 2.5)),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text('MANFI', style: TextStyle(color: widget.accent, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
        const SizedBox(height: 5),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [played(3), const SizedBox(width: 5), played(1)]),
        const SizedBox(height: 5),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [played(2), const SizedBox(width: 5), played(0)]),
        if (candidates.isNotEmpty) const Text('دلته کارت خوشې کړه',
          style: TextStyle(color: Colors.greenAccent, fontSize: 8)),
      ]),
    ),
  );

  Widget table() => LayoutBuilder(builder: (context, c) => Stack(alignment: Alignment.center, children: [
    Positioned.fill(child: Container(margin: const EdgeInsets.all(5),
      decoration: BoxDecoration(gradient: RadialGradient(colors: [widget.felt, widget.background]),
        borderRadius: BorderRadius.circular(24), border: Border.all(color: widget.accent, width: 2)))),
    Positioned(top: 10, left: c.maxWidth * .25, right: c.maxWidth * .25, child: player(3)),
    Positioned(left: 8, top: c.maxHeight * .38, width: c.maxWidth * .31, child: player(2, small: true)),
    Positioned(right: 8, top: c.maxHeight * .38, width: c.maxWidth * .31, child: player(1, small: true)),
    Center(child: center()),
    Positioned(bottom: 10, left: c.maxWidth * .25, right: c.maxWidth * .25, child: player(0)),
  ]));

  @override
  Widget build(BuildContext context) {
    final mine = dealt ? hands[0] : <String>[];
    final myTurn = dealt && turn == 0 && !busy && !finished;
    return Scaffold(backgroundColor: widget.background,
      appBar: AppBar(backgroundColor: widget.background, foregroundColor: widget.accent,
        title: const Text('MANFI GAME', style: TextStyle(fontWeight: FontWeight.w900))),
      body: SafeArea(child: Column(children: [
        Padding(padding: const EdgeInsets.all(8), child: Row(children: [
          Expanded(child: Text('MANFI • LIVE GAME', style: TextStyle(color: widget.accent, fontWeight: FontWeight.bold))),
          Text('ساحل ' + tricksA.toString() + ' : ' + tricksB.toString() + ' محمود خان',
            style: const TextStyle(color: Colors.white70, fontSize: 9)),
        ])),
        Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 6), child: table())),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          child: Text(myTurn ? 'خپل قانوني کارت میدان ته کش کړه' : message, maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: widget.accent, fontSize: 10, fontWeight: FontWeight.bold))),
        SizedBox(height: 76, child: dealt ? ListView.separated(
          scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          itemCount: mine.length, separatorBuilder: (_, __) => const SizedBox(width: 4),
          itemBuilder: (context, i) {
            final ok = myTurn && legal(0).contains(mine[i]);
            return Opacity(opacity: ok ? 1 : .4, child: card(mine[i], drag: ok));
          },
        ) : const Center(child: Text('لومړی کارتونه ووېشه', style: TextStyle(color: Colors.white54)))),
        Padding(padding: const EdgeInsets.fromLTRB(12, 4, 12, 9), child: SizedBox(width: double.infinity, height: 43,
          child: FilledButton.icon(
            onPressed: (!dealt || finished) ? deal : null,
            style: FilledButton.styleFrom(backgroundColor: widget.accent, foregroundColor: Colors.black),
            icon: const Icon(Icons.shuffle),
            label: Text(finished ? 'NEW ROUND' : (dealt ? 'GAME IN PROGRESS' : 'DEAL 13 CARDS')),
          ))),
      ])),
    );
  }
}
