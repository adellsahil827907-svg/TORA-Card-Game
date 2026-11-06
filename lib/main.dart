import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(const ToraApp());

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
  ToraTheme('Midnight Blue & Silver', Color(0xFF071326), Color(0xFF12233D), Color(0xFFC6D2E3), Color(0xFF102B46), Color(0xFF273A55), Color(0xFF101D31), Color(0xFFE6EDF7)),
  ToraTheme('Emerald & Gold', Color(0xFF061D18), Color(0xFF10352B), Color(0xFFE0C16B), Color(0xFF0C4938), Color(0xFF234B3B), Color(0xFF10271F), Color(0xFFF0D98C)),
];

class ToraApp extends StatefulWidget {
  const ToraApp({super.key});
  @override State<ToraApp> createState() => _ToraAppState();
}
class _ToraAppState extends State<ToraApp> {
  int themeIndex = 0;
  void setTheme(int value) => setState(() => themeIndex = value);
  @override Widget build(BuildContext context) {
    final t = _themes[themeIndex];
    return MaterialApp(debugShowCheckedModeBanner: false, title: 'TORA', theme: ThemeData(brightness: Brightness.dark, scaffoldBackgroundColor: t.background, colorScheme: ColorScheme.dark(primary: t.accent, secondary: t.accent, surface: t.panel), useMaterial3: true), home: ToraSplashPage(theme: t, onStart: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ToraGamePage(theme: t, onThemeChanged: setTheme)))));
  }
}

class ToraSplashPage extends StatelessWidget {
  final ToraTheme theme;
  final VoidCallback onStart;
  const ToraSplashPage({super.key, required this.theme, required this.onStart});
  @override Widget build(BuildContext context) => Scaffold(backgroundColor: theme.background, body: SafeArea(child: Center(child: Padding(padding: const EdgeInsets.all(28), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    Container(width: 116, height: 116, decoration: BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [theme.cardTop, theme.cardBottom]), border: Border.all(color: theme.accent, width: 2), boxShadow: [BoxShadow(color: theme.accent.withOpacity(.2), blurRadius: 24)]), child: Center(child: Text('T', style: TextStyle(color: theme.accent, fontSize: 72, fontWeight: FontWeight.w900))),
    const SizedBox(height: 20), Text('TORA', style: TextStyle(color: theme.accent, fontSize: 38, fontWeight: FontWeight.w900, letterSpacing: 8)), const SizedBox(height: 8), const Text('THINK SMART • PLAY TORA', style: TextStyle(color: Colors.white70, letterSpacing: 2, fontSize: 11)), const SizedBox(height: 38), CircleAvatar(radius: 35, backgroundColor: theme.panel, child: Text('AS', style: TextStyle(color: theme.accent, fontSize: 25, fontWeight: FontWeight.w900))), const SizedBox(height: 10), const Text('Created by Adell Sahil', style: TextStyle(color: Colors.white70, fontSize: 13)), const SizedBox(height: 42), SizedBox(width: 220, child: FilledButton(onPressed: onStart, style: FilledButton.styleFrom(backgroundColor: theme.accent, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 15)), child: const Text('START GAME', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2)))),
  ])))));
}

class ToraGamePage extends StatefulWidget {
  final ToraTheme theme;
  final ValueChanged<int> onThemeChanged;
  const ToraGamePage({super.key, required this.theme, required this.onThemeChanged});
  @override State<ToraGamePage> createState() => _ToraGamePageState();
}

class _ToraGamePageState extends State<ToraGamePage> {
  final Random _random = Random();
  final List<String> _names = ['Sahil', 'Player 2', 'Player 3', 'Player 4'];
  final List<List<String>> _hands = List.generate(4, (_) => <String>[]);
  final List<List<String>> _won = List.generate(4, (_) => <String>[]);
  final List<String?> _trick = List.filled(4, null);
  final List<int> _trickOrder = [];
  final List<int> _trickSeats = [];
  final List<String> _history = [];
  int _turn = 0, _leader = 0, _round = 0, _teamOne = 0, _teamTwo = 0;
  bool _aiBusy = false, _gameOver = false, _checkingClaim = false;
  late ToraTheme _activeTheme;
  String? _ledSuit;
  String _status = 'Your turn: drag a card to the centre.';
  int _lastWinner = -1;

  ToraTheme get t => _activeTheme;

  @override void initState() { super.initState(); _activeTheme = widget.theme; _deal(first: true); }
  List<String> get _myHand => _hands[0];
  int _team(int seat) => (seat == 0 || seat == 2) ? 0 : 1;
  int get _playedCount => _trick.where((c) => c != null).length;

  void _deal({bool first = false}) {
    final deck = [for (final s in _suits) for (final r in _ranks) '$r$s']..shuffle(_random);
    setState(() {
      for (int i = 0; i < 4; i++) {
        _hands[i]..clear()..addAll(deck.sublist(i * 13, (i + 1) * 13))..sort(_compareCards);
        _won[i].clear();
      }
      _trick.fillRange(0, 4, null); _trickOrder.clear(); _trickSeats.clear(); _history.clear();
      _turn = 0; _leader = 0; _ledSuit = null; _aiBusy = false; _gameOver = false; _checkingClaim = false; _lastWinner = -1;
      _round++;
      _status = 'Sahil starts. Follow the suit when you have it.';
    });
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
    if (_gameOver || _aiBusy || _checkingClaim || _turn != seat || !_hands[seat].contains(card)) return;
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
        // Takkol: no other player has any spade when a spade is led.
        if (_ledSuit == '♠' && List.generate(4, (i) => i).where((i) => i != seat).every((i) => !_hands[i].any((c) => _suit(c) == '♠'))) {
          _transferThirty(_team(seat));
          _history.add('${_names[seat]} made Takkol: 30 points transferred.');
          takkolNow = true;
        }
      }
      _status = takkolNow ? 'TAKKOL! 30 points transferred.' : '${_names[seat]} played $card';
      if (_trickSeats.length == 4) {
        _resolveTrick();
      } else {
        _turn = (seat + 1) % 4;
      }
    });
    if (mounted && !_gameOver && _turn != 0) _runAi();
  }

  void _transferThirty(int winningTeam) {
    if (winningTeam == 0) { _teamOne += 30; _teamTwo -= 30; }
    else { _teamTwo += 30; _teamOne -= 30; }
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
    final suit = _suit(card), rank = _rank(card);
    if (suit == '♥') return 1;
    if (card == 'Q♠') return 9;
    if (card == 'J♣') return 5;
    if (card == '10♦') return 3;
    return 0;
  }

  int _roundPenalty(List<String> cards) {
    final hasQueen = cards.contains('Q♠');
    final otherPenaltyCards = cards.any((c) => _suit(c) == '♥' || c == 'J♣' || c == '10♦');
    if (hasQueen && !otherPenaltyCards) return 0; // Q♠ alone carries no penalty.
    return cards.fold<int>(0, (sum, card) => sum + _cardPenalty(card));
  }

  void _resolveTrick() {
    final winner = _trickWinner();
    final captured = _trick.whereType<String>().toList();
    for (final c in captured) { _won[winner].add(c); }
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
      final loser = _teamOne >= 310 ? 'Team Sahil' : (_teamTwo >= 310 ? 'Opponents' : 'No team');
      _status = loser == 'No team' ? 'Round complete. Scores: $_teamOne / $_teamTwo' : '$loser reached 310 penalty points and loses.';
    }
  }

  Future<void> _runAi() async {
    if (_aiBusy || _gameOver || _turn == 0 || _checkingClaim) return;
    _aiBusy = true;
    setState(() => _status = '${_names[_turn]} is thinking…');
    await Future.delayed(const Duration(milliseconds: 650));
    if (!mounted || _gameOver) return;
    final seat = _turn;
    // Computer players also have the NO MORE option. They check the same 52-card state.
    for (final suit in _suits) {
      final othersCount = List.generate(4, (i) => i).where((i) => i != seat).fold<int>(0, (sum, i) => sum + _hands[i].where((c) => _suit(c) == suit).length);
      if (othersCount == 0) {
        _history.add('${_names[seat]} correctly used NO MORE for $suit.');
        break;
      }
    }
    final legal = _legalCards(seat);
    if (legal.isNotEmpty) {
      // Simple legal AI for this first complete rules build. Strategy can be improved after testing.
      String chosen;
      if (_ledSuit == null) {
        chosen = legal[_random.nextInt(legal.length)];
      } else {
        final following = legal.where((c) => _suit(c) == _ledSuit).toList();
        chosen = following.isNotEmpty ? following[_random.nextInt(following.length)] : legal[_random.nextInt(legal.length)];
      }
      _aiBusy = false;
      _playCard(seat, chosen);
    } else {
      _aiBusy = false;
    }
  }

  Future<void> _claimNoMore(int seat) async {
    if (_gameOver || _aiBusy || _checkingClaim || _turn != seat) {
      _toast('Use this option when it is your turn.'); return;
    }
    final suit = await showModalBottomSheet<String>(context: context, backgroundColor: t.panel, builder: (ctx) => SafeArea(child: Padding(padding: const EdgeInsets.all(18), child: Column(mainAxisSize: MainAxisSize.min, children: [Text('${_names[seat]} — choose a suit', style: TextStyle(color: t.accent, fontWeight: FontWeight.bold, fontSize: 18)), const SizedBox(height: 14), Wrap(spacing: 10, runSpacing: 10, alignment: WrapAlignment.center, children: [for (final s in _suits) _suitButton(ctx, s)])]))));
    if (suit == null || !mounted) return;
    final remaining = <int, List<String>>{};
    for (int i = 0; i < 4; i++) { if (i != seat) remaining[i] = _hands[i].where((c) => _suit(c) == suit).toList(); }
    final count = remaining.values.fold<int>(0, (sum, list) => sum + list.length);
    setState(() => _checkingClaim = true);
    final correct = count == 0;
    if (!correct) {
      final penalty = count * 30;
      if (_team(seat) == 0) { _teamOne += penalty; } else { _teamTwo += penalty; }
      _history.add('${_names[seat]} claimed no more $suit but $count remained: +$penalty penalty.');
      if (_teamOne >= 310 || _teamTwo >= 310) _gameOver = true;
    } else {
      _history.add('${_names[seat]} correctly claimed no more $suit.');
    }
    await showDialog<void>(context: context, barrierDismissible: false, builder: (ctx) => AlertDialog(backgroundColor: t.panel, title: Text(correct ? 'CORRECT — NO TAKKOL' : 'TAKKOL! WRONG COUNT', style: TextStyle(color: correct ? t.accent : Colors.redAccent, fontWeight: FontWeight.w900)), content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Text(correct ? 'No $suit cards were in the other three hands. No penalty.' : '$count $suit card(s) were still in the other players’ hands. ${count * 30} penalty points.'), const SizedBox(height: 10), for (final e in remaining.entries) Text('${_names[e.key]}: ${e.value.isEmpty ? 'none' : e.value.join('  ')}', style: const TextStyle(fontSize: 12, color: Colors.white70))]), actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: Text('CONTINUE', style: TextStyle(color: t.accent)))]));
    if (!mounted) return;
    setState(() { _checkingClaim = false; _status = _gameOver ? '310 points reached — game lost.' : (correct ? '${_names[seat]} counted correctly: no $suit remains.' : '${_names[seat]} was wrong: ${count * 30} penalty points.'); });
    if (seat != 0 && !_gameOver) _runAi();
  }

  Widget _suitButton(BuildContext ctx, String suit) => OutlinedButton(onPressed: () => Navigator.pop(ctx, suit), style: OutlinedButton.styleFrom(foregroundColor: _isRed(suit) ? Colors.redAccent : t.accent, side: BorderSide(color: t.accent), padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12)), child: Text(suit, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)));

  Future<void> _editNames() async {
    final controllers = List.generate(4, (i) => TextEditingController(text: _names[i]));
    await showDialog<void>(context: context, builder: (ctx) => AlertDialog(backgroundColor: t.panel, title: Text('PLAYER NAMES', style: TextStyle(color: t.accent)), content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [for (int i = 0; i < 4; i++) Padding(padding: const EdgeInsets.only(bottom: 9), child: TextField(controller: controllers[i], decoration: InputDecoration(labelText: 'Player ${i + 1}', border: const OutlineInputBorder(), isDense: true)))])), actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')), FilledButton(onPressed: () { setState(() { for (int i = 0; i < 4; i++) { if (controllers[i].text.trim().isNotEmpty) _names[i] = controllers[i].text.trim(); } }); Navigator.pop(ctx); }, child: const Text('SAVE'))]));
    for (final c in controllers) { c.dispose(); }
  }

  void _showRules() {
    showDialog<void>(context: context, builder: (ctx) => AlertDialog(backgroundColor: t.panel, title: Text('TORA RULES', style: TextStyle(color: t.accent)), content: const SingleChildScrollView(child: Text('• 52 cards: 13 cards per player.\n• Two teams: seats 1+3 and seats 2+4.\n• Follow the suit led if you have that suit.\n• If you do not have it, any suit may be played; it cannot win the trick.\n• Highest card of the led suit wins. Winner collects all four cards and leads next.\n• Spade Takkol: if nobody else holds a spade when a spade is led, 30 points transfer.\n• “No more” checks a chosen suit in the other three hands; each remaining card causes 30 penalty points.\n• Card penalties: each heart 1, Q♠ 9, J♣ 5, 10♦ 3.'), actions: []));
  }

  void _toast(String text) { if (!mounted) return; ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text), duration: const Duration(seconds: 2))); }

  Color _suitColor(String suit) => _isRed(suit) ? const Color(0xFFE14B5A) : const Color(0xFFE9E2D1);

  Widget _cardFace(String card, {double width = 52, double height = 74, bool back = false}) {
    if (back) return Container(width: width, height: height, decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), gradient: LinearGradient(colors: [t.cardTop, t.cardBottom], begin: Alignment.topLeft, end: Alignment.bottomRight), border: Border.all(color: t.accent, width: 1.4), boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 5, offset: Offset(1, 2))]), child: Center(child: Container(width: width * .72, height: height * .78, decoration: BoxDecoration(border: Border.all(color: t.accent.withOpacity(.7), width: 1), borderRadius: BorderRadius.circular(5)), child: Center(child: Text('T', style: TextStyle(color: t.accent, fontSize: width * .55, fontWeight: FontWeight.w900)))));
    final suit = _suit(card), rank = _rank(card), ink = _suitColor(suit);
    final face = ['J','Q','K','A'].contains(rank);
    return Container(width: width, height: height, decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [t.cardTop, t.cardBottom]), border: Border.all(color: t.accent, width: 1.25), boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 5, offset: Offset(1, 2))]), child: Stack(children: [Positioned(left: 4, top: 3, child: Column(mainAxisSize: MainAxisSize.min, children: [Text(rank, style: TextStyle(color: ink, fontWeight: FontWeight.w900, fontSize: width * .22, height: 1)), Text(suit, style: TextStyle(color: ink, fontSize: width * .20, height: 1))])), Center(child: face ? Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.workspace_premium, color: t.accent, size: width * .38), Text(rank, style: TextStyle(color: t.accent, fontWeight: FontWeight.w900, fontSize: width * .30)), Text(suit, style: TextStyle(color: ink, fontSize: width * .30))]) : Text(suit, style: TextStyle(color: ink, fontSize: width * .53, fontWeight: FontWeight.w900))), Positioned(right: 4, bottom: 3, child: RotatedBox(quarterTurns: 2, child: Column(mainAxisSize: MainAxisSize.min, children: [Text(rank, style: TextStyle(color: ink, fontWeight: FontWeight.w900, fontSize: width * .22, height: 1)), Text(suit, style: TextStyle(color: ink, fontSize: width * .20, height: 1))])))]));
  }

  Widget _seat(int seat, String position) => Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5), decoration: BoxDecoration(color: t.background.withOpacity(.94), borderRadius: BorderRadius.circular(10), border: Border.all(color: _turn == seat ? t.accent : t.accent.withOpacity(.35), width: _turn == seat ? 2 : 1)), child: Column(mainAxisSize: MainAxisSize.min, children: [Text(_names[seat], maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: _turn == seat ? t.accent : Colors.white, fontWeight: FontWeight.bold, fontSize: 10)), Text(position, style: const TextStyle(color: Colors.white60, fontSize: 8)), Text('${_hands[seat].length} cards', style: const TextStyle(color: Colors.white70, fontSize: 8))]));

  Widget _playedCard(int seat) {
    final card = _trick[seat];
    if (card == null) return const SizedBox(width: 48, height: 68);
    return _cardFace(card, width: 48, height: 68);
  }

  Widget _centerCross() => SizedBox.expand(child: Stack(alignment: Alignment.center, children: [
    Positioned(top: 0, child: Column(mainAxisSize: MainAxisSize.min, children: [_seat(2, 'TEAMMATE'), const SizedBox(height: 5), _playedCard(2)])),
    Positioned(bottom: 0, child: Column(mainAxisSize: MainAxisSize.min, children: [_playedCard(0), const SizedBox(height: 5), _seat(0, 'YOU') ])),
    Positioned(right: 0, child: Row(mainAxisSize: MainAxisSize.min, children: [_playedCard(1), const SizedBox(width: 3), _seat(1, 'RIGHT OPPONENT')])),
    Positioned(left: 0, child: Row(mainAxisSize: MainAxisSize.min, children: [_seat(3, 'LEFT OPPONENT'), const SizedBox(width: 3), _playedCard(3)])),
    Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7), constraints: const BoxConstraints(maxWidth: 145), decoration: BoxDecoration(color: t.background.withOpacity(.94), border: Border.all(color: t.accent.withOpacity(.8)), borderRadius: BorderRadius.circular(12)), child: Column(mainAxisSize: MainAxisSize.min, children: [Text('TORA', style: TextStyle(color: t.accent, fontWeight: FontWeight.w900, letterSpacing: 3, fontSize: 17)), Text(_status, textAlign: TextAlign.center, maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70, fontSize: 9)), if (_ledSuit != null) Text('LEAD: $_ledSuit', style: TextStyle(color: t.accent, fontSize: 10, fontWeight: FontWeight.bold))])),
  ]));

  Widget _scoreBox(String label, int score) => Container(padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8), decoration: BoxDecoration(color: t.panel, borderRadius: BorderRadius.circular(10), border: Border.all(color: t.accent.withOpacity(.7))), child: Column(children: [Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70, fontSize: 9)), Text('$score', style: TextStyle(color: t.accent, fontSize: 19, fontWeight: FontWeight.w900))]));

  Future<void> _settings() async {
    await showModalBottomSheet<void>(context: context, backgroundColor: t.panel, builder: (ctx) => SafeArea(child: Padding(padding: const EdgeInsets.all(16), child: Column(mainAxisSize: MainAxisSize.min, children: [Text('TORA APPEARANCE', style: TextStyle(color: t.accent, fontWeight: FontWeight.w900)), const SizedBox(height: 12), for (int i = 0; i < _themes.length; i++) ListTile(leading: CircleAvatar(backgroundColor: _themes[i].background, child: Icon(Icons.style, color: _themes[i].accent)), title: Text(_themes[i].name), trailing: widget.theme.name == _themes[i].name ? Icon(Icons.check_circle, color: t.accent) : null, onTap: () { setState(() => _activeTheme = _themes[i]); widget.onThemeChanged(i); Navigator.pop(ctx); })]))));
  }

  @override Widget build(BuildContext context) {
    final legal = _legalCards(0);
    return Scaffold(backgroundColor: t.background, appBar: AppBar(backgroundColor: t.background, foregroundColor: t.accent, centerTitle: true, title: Text('♛ TORA', style: TextStyle(color: t.accent, fontWeight: FontWeight.w900, letterSpacing: 4)), actions: [IconButton(onPressed: _settings, tooltip: 'Themes', icon: const Icon(Icons.palette_outlined)), IconButton(onPressed: _editNames, tooltip: 'Player names', icon: const Icon(Icons.people_alt_outlined)), IconButton(onPressed: _showRules, tooltip: 'Rules', icon: const Icon(Icons.info_outline))]),
      body: SafeArea(child: Column(children: [
        Padding(padding: const EdgeInsets.fromLTRB(10, 3, 10, 5), child: Row(children: [Expanded(child: _scoreBox('${_names[0]} + ${_names[2]}', _teamOne)), const SizedBox(width: 8), Expanded(child: _scoreBox('${_names[1]} + ${_names[3]}', _teamTwo))])),
        Expanded(child: Container(margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), padding: const EdgeInsets.all(7), decoration: BoxDecoration(color: t.table, borderRadius: BorderRadius.circular(22), border: Border.all(color: t.accent, width: 2), boxShadow: [BoxShadow(color: t.accent.withOpacity(.12), blurRadius: 15)]), child: DragTarget<String>(onWillAcceptWithDetails: (d) => _turn == 0 && !_aiBusy && !_gameOver && legal.contains(d.data), onAcceptWithDetails: (d) => _playCard(0, d.data), builder: (ctx, candidates, rejected) => Stack(children: [_centerCross(), if (candidates.isNotEmpty) Positioned.fill(child: IgnorePointer(child: Container(decoration: BoxDecoration(border: Border.all(color: Colors.white, width: 3), borderRadius: BorderRadius.circular(18)))))])))),
        Padding(padding: const EdgeInsets.fromLTRB(10, 4, 10, 0), child: Row(children: [Expanded(child: Text('${_names[0].toUpperCase()} — YOUR CARDS', style: TextStyle(color: t.accent, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1))), Text('${_myHand.length}/13', style: const TextStyle(color: Colors.white70, fontSize: 10))])),
        SizedBox(height: 100, child: ListView.separated(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7), itemCount: _myHand.length, separatorBuilder: (_, __) => const SizedBox(width: 4), itemBuilder: (ctx, i) { final card = _myHand[i]; final allowed = legal.contains(card) && _turn == 0 && !_aiBusy && !_gameOver; return Draggable<String>(data: card, maxSimultaneousDrags: allowed ? 1 : 0, feedback: Material(color: Colors.transparent, child: _cardFace(card, width: 58, height: 82)), childWhenDragging: Opacity(opacity: .25, child: _cardFace(card, width: 53, height: 76)), child: Opacity(opacity: allowed ? 1 : .48, child: _cardFace(card, width: 53, height: 76))); })),
        Padding(padding: const EdgeInsets.fromLTRB(9, 0, 9, 8), child: Row(children: [Expanded(child: OutlinedButton(onPressed: _turn == 0 && !_aiBusy && !_gameOver ? () => _claimNoMore(0) : null, style: OutlinedButton.styleFrom(foregroundColor: t.accent, side: BorderSide(color: t.accent)), child: const Text('NO MORE / نورې نشته', style: TextStyle(fontSize: 10)))), const SizedBox(width: 7), Expanded(child: OutlinedButton(onPressed: _editNames, style: OutlinedButton.styleFrom(foregroundColor: t.accent, side: BorderSide(color: t.accent)), child: const Text('PLAYERS', style: TextStyle(fontSize: 10)))), const SizedBox(width: 7), Expanded(child: FilledButton(onPressed: _gameOver ? _deal : null, style: FilledButton.styleFrom(backgroundColor: t.accent, foregroundColor: Colors.black), child: Text(_gameOver ? 'NEW ROUND' : 'PLAYING', style: const TextStyle(fontSize: 10))))])),
      ])));
  }
}
