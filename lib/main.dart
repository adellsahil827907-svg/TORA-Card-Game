
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final h = constraints.maxHeight;
            final compact = h < 400;
            final logoSize = compact ? 76.0 : 100.0;
            final gap = compact ? 8.0 : 15.0;

            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: h),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 8,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: logoSize,
                        height: logoSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [theme.cardTop, theme.cardBottom],
                          ),
                          border: Border.all(
                            color: theme.accent,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: theme.accent.withOpacity(.2),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'T',
                            style: TextStyle(
                              color: theme.accent,
                              fontSize: compact ? 48 : 62,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: gap),
                      Text(
                        'TORA',
                        style: TextStyle(
                          color: theme.accent,
                          fontSize: compact ? 30 : 36,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 8,
                        ),
                      ),
                      SizedBox(height: compact ? 4 : 8),
                      const Text(
                        'THINK SMART • PLAY TORA',
                        style: TextStyle(
                          color: Colors.white70,
                          letterSpacing: 2,
                          fontSize: 10,
                        ),
                      ),
                      SizedBox(height: compact ? 10 : 20),
                      CircleAvatar(
                        radius: compact ? 25 : 30,
                        backgroundColor: theme.panel,
                        child: Text(
                          'AS',
                          style: TextStyle(
                            color: theme.accent,
                            fontSize: compact ? 20 : 24,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Created by Adell Sahil',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(height: compact ? 12 : 25),
                      SizedBox(
                        width: 220,
                        height: 48,
                        child: FilledButton(
                          onPressed: onStart,
                          style: FilledButton.styleFrom(
                            backgroundColor: theme.accent,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'START GAME',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
