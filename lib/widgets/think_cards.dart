import 'package:flutter/material.dart';
import '../theme_selection_screen.dart';

class ThinkCard {
  final String type;
  final String title;
  final String content;

  const ThinkCard({
    required this.type,
    required this.title,
    required this.content,
  });
}

class ThinkCards extends StatefulWidget {
  final List<ThinkCard> cards;
  final AppTheme theme;

  const ThinkCards({
    super.key,
    required this.cards,
    required this.theme,
  });

  @override
  State<ThinkCards> createState() => _ThinkCardsState();
}

class _ThinkCardsState extends State<ThinkCards> {
  int currentIndex = 0;
  bool isFlipped = false;

  List<Color> get themeColors {
    switch (widget.theme) {
      case AppTheme.forest:
        return const [
          Color(0xFF0D5148),
          Color(0xFF06251F),
        ];

      case AppTheme.cyberpunk:
        return const [
          Color(0xFF4B176E),
          Color(0xFF101A51),
        ];

      case AppTheme.kingdom:
        return const [
          Color(0xFF71451C),
          Color(0xFF321B15),
        ];
    }
  }

  Color get primaryThemeColor => themeColors.first;
  Color get secondaryThemeColor => themeColors.last;

  void nextCard() {
    if (currentIndex < widget.cards.length - 1) {
      setState(() {
        currentIndex++;
        isFlipped = false;
      });
    }
  }

  void previousCard() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
        isFlipped = false;
      });
    }
  }

  void flipCard() {
    setState(() {
      isFlipped = !isFlipped;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.cards.isEmpty) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(28),
          ),
          child: const Text(
            'No Think Cards available for this level.',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    final card = widget.cards[currentIndex];

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: primaryThemeColor.withValues(alpha: 0.25),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: primaryThemeColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.lightbulb_outline,
                    color: primaryThemeColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Think Cards',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Build your solution step by step',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Progress
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Card ${currentIndex + 1} of ${widget.cards.length}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: primaryThemeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: primaryThemeColor.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Text(
                    card.type,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: primaryThemeColor,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // Flash Card
            GestureDetector(
              onTap: flipCard,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(
                    scale: animation,
                    child: child,
                  );
                },
                child: Container(
                  key: ValueKey('${currentIndex}_$isFlipped'),
                  width: double.infinity,
                  height: 260,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isFlipped
                          ? [
                              secondaryThemeColor,
                              primaryThemeColor,
                            ]
                          : themeColors,
                    ),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: primaryThemeColor.withValues(alpha: 0.20),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Center(
                    child: isFlipped
                        // BACK
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.auto_awesome,
                                color: Colors.white70,
                                size: 30,
                              ),
                              const SizedBox(height: 18),
                              Text(
                                card.content,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  height: 1.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          )
                        // FRONT
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'THINK',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                ),
                              ),
                              const SizedBox(height: 15),
                              Text(
                                card.title,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'Tap to reveal',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Navigation
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: currentIndex == 0 ? null : previousCard,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Previous'),
                ),
                TextButton.icon(
                  onPressed: currentIndex == widget.cards.length - 1
                      ? null
                      : nextCard,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Next'),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Text(
              '💡 Try solving the problem before taking another hint.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
