import 'dart:async';

import 'package:flutter/material.dart';

class ArrayMaxAnimation extends StatefulWidget {
  const ArrayMaxAnimation({super.key});

  @override
  State<ArrayMaxAnimation> createState() => _ArrayMaxAnimationState();
}

class _ArrayMaxAnimationState extends State<ArrayMaxAnimation> {
  final List<int> numbers = [3, 7, 2, 9, 4];

  int currentIndex = 0;
  int maxIndex = 0;
  bool isPlaying = false;
  Timer? _timer;

  final List<String> explanations = [
    'Start with the first element as the maximum.',
    '7 is greater than 3, so update the maximum.',
    '2 is smaller than 7, so keep the maximum unchanged.',
    '9 is greater than 7, so update the maximum.',
    '4 is smaller than 9, so keep the maximum unchanged.',
    'The maximum element is 9!',
  ];

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void play() {
    if (isPlaying) return;

    setState(() {
      isPlaying = true;
    });

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        if (currentIndex >= numbers.length) {
          _timer?.cancel();

          setState(() {
            isPlaying = false;
          });

          return;
        }

        nextStep();
      },
    );
  }

  void pause() {
    _timer?.cancel();

    setState(() {
      isPlaying = false;
    });
  }

  void replay() {
    _timer?.cancel();

    setState(() {
      currentIndex = 0;
      maxIndex = 0;
      isPlaying = false;
    });
  }

  void nextStep() {
    if (currentIndex >= numbers.length) {
      return;
    }

    setState(() {
      if (numbers[currentIndex] > numbers[maxIndex]) {
        maxIndex = currentIndex;
      }

      currentIndex++;
    });
  }

  void previousStep() {
    if (currentIndex <= 0) {
      return;
    }

    _timer?.cancel();

    setState(() {
      isPlaying = false;

      currentIndex--;

      maxIndex = 0;

      for (int i = 1; i <= currentIndex; i++) {
        if (numbers[i] > numbers[maxIndex]) {
          maxIndex = i;
        }
      }
    });
  }

  String get currentExplanation {
    if (currentIndex >= numbers.length) {
      return explanations.last;
    }

    return explanations[currentIndex];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF101827),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF22D3EE).withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.play_circle_fill_rounded,
                color: Color(0xFF22D3EE),
              ),
              SizedBox(width: 8),
              Text(
                'HOW IT WORKS',
                style: TextStyle(
                  color: Color(0xFF22D3EE),
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          const Text(
            'Find the Maximum Element',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'Watch the algorithm compare each element.',
            style: TextStyle(
              color: Colors.white60,
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 22),

          _buildArray(),

          const SizedBox(height: 22),

          _buildStatus(),

          const SizedBox(height: 18),

          _buildExplanation(),

          const SizedBox(height: 20),

          _buildProgress(),

          const SizedBox(height: 18),

          _buildControls(),
        ],
      ),
    );
  }

  Widget _buildArray() {
    return SizedBox(
      height: 75,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          numbers.length,
          (index) {
            final bool isCurrent =
                index == currentIndex && currentIndex < numbers.length;

            final bool isMaximum = index == maxIndex;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutBack,
              margin: const EdgeInsets.symmetric(horizontal: 5),
              width: 48,
              height: isCurrent ? 62 : 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isMaximum
                    ? const Color(0xFF22C55E).withValues(alpha: 0.20)
                    : isCurrent
                        ? const Color(0xFF22D3EE).withValues(alpha: 0.20)
                        : Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isMaximum
                      ? const Color(0xFF22C55E)
                      : isCurrent
                          ? const Color(0xFF22D3EE)
                          : Colors.white.withValues(alpha: 0.12),
                  width: isMaximum || isCurrent ? 2 : 1,
                ),
              ),
              child: Text(
                '${numbers[index]}',
                style: TextStyle(
                  color: isMaximum
                      ? const Color(0xFF22C55E)
                      : Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatus() {
    return Center(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: Text(
          currentIndex == 0
              ? 'MAX = ${numbers[maxIndex]}'
              : currentIndex >= numbers.length
                  ? '🎯 MAX = ${numbers[maxIndex]}'
                  : 'MAX = ${numbers[maxIndex]}   •   Checking ${numbers[currentIndex]}',
          key: ValueKey(
            '$currentIndex-$maxIndex',
          ),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: currentIndex >= numbers.length
                ? const Color(0xFF22C55E)
                : const Color(0xFF22D3EE),
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  Widget _buildExplanation() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.08, 0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: Container(
        key: ValueKey(currentExplanation),
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          currentExplanation,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 13,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildProgress() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        numbers.length + 1,
        (index) {
          final bool active = index == currentIndex;

          final bool completed = index < currentIndex;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: active ? 22 : 7,
            height: 7,
            decoration: BoxDecoration(
              color: active || completed
                  ? const Color(0xFF22D3EE)
                  : Colors.white24,
              borderRadius: BorderRadius.circular(10),
            ),
          );
        },
      ),
    );
  }

  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _controlButton(
          icon: Icons.skip_previous_rounded,
          onPressed: previousStep,
        ),
        const SizedBox(width: 8),
        _controlButton(
          icon: isPlaying
              ? Icons.pause_rounded
              : Icons.play_arrow_rounded,
          onPressed: isPlaying ? pause : play,
          large: true,
        ),
        const SizedBox(width: 8),
        _controlButton(
          icon: Icons.skip_next_rounded,
          onPressed: nextStep,
        ),
        const SizedBox(width: 8),
        _controlButton(
          icon: Icons.replay_rounded,
          onPressed: replay,
        ),
      ],
    );
  }

  Widget _controlButton({
    required IconData icon,
    required VoidCallback onPressed,
    bool large = false,
  }) {
    return Material(
      color: const Color(0xFF22D3EE).withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: large ? 52 : 44,
          height: large ? 52 : 44,
          child: Icon(
            icon,
            color: const Color(0xFF22D3EE),
            size: large ? 27 : 21,
          ),
        ),
      ),
    );
  }
}