import 'package:flutter/material.dart';

class ProcessLifecycleAnimation extends StatefulWidget {
  final Color accentColor;
  final Color textColor;
  final Color mutedColor;

  const ProcessLifecycleAnimation({
    super.key,
    required this.accentColor,
    required this.textColor,
    required this.mutedColor,
  });

  @override
  State<ProcessLifecycleAnimation> createState() =>
      _ProcessLifecycleAnimationState();
}

class _ProcessLifecycleAnimationState
    extends State<ProcessLifecycleAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  int currentStep = 0;
  bool isPlaying = false;

  // Lifecycle:
  // 0 = READY
  // 1 = RUNNING
  // 2 = WAITING
  // 3 = READY again
  final List<String> states = const [
    'READY',
    'RUNNING',
    'WAITING',
    'READY',
  ];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _controller.addStatusListener(_handleAnimationStatus);
  }

  void _handleAnimationStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed || !isPlaying) {
      return;
    }

    if (!mounted) return;

    setState(() {
      currentStep = (currentStep + 1) % states.length;
    });

    _controller.forward(from: 0);
  }

  // ------------------------------------------------------------
  // PLAY
  // ------------------------------------------------------------

  void _play() {
    if (isPlaying) return;

    setState(() {
      isPlaying = true;
    });

    _controller.forward(from: 0);
  }

  // ------------------------------------------------------------
  // PAUSE
  // ------------------------------------------------------------

  void _pause() {
    if (!isPlaying) return;

    setState(() {
      isPlaying = false;
    });

    _controller.stop();
  }

  // ------------------------------------------------------------
  // NEXT STEP
  // ------------------------------------------------------------

  void _nextStep() {
    setState(() {
      isPlaying = false;
      currentStep = (currentStep + 1) % states.length;
    });

    _controller.forward(from: 0);
  }

  // ------------------------------------------------------------
  // REPLAY
  // ------------------------------------------------------------

  void _replay() {
    setState(() {
      isPlaying = false;
      currentStep = 0;
    });

    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.removeStatusListener(_handleAnimationStatus);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.accentColor.withValues(alpha: 0.35),
        ),
        color: widget.accentColor.withValues(alpha: 0.025),
      ),
      child: Column(
        children: [
          // ------------------------------------------------------
          // TITLE ICON
          // ------------------------------------------------------

          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final pulse =
                  1.0 + (_controller.value * 0.08);

              return Transform.scale(
                scale: pulse,
                child: child,
              );
            },
            child: Icon(
              Icons.account_tree_rounded,
              size: 42,
              color: widget.accentColor,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            'PROCESS LIFECYCLE',
            style: TextStyle(
              color: widget.accentColor,
              fontSize: 16,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),

          const SizedBox(height: 20),

          // ------------------------------------------------------
          // PROCESS VISUALIZER
          // ------------------------------------------------------

          LayoutBuilder(
            builder: (context, constraints) {
              final isSmall = constraints.maxWidth < 500;

              if (isSmall) {
                return _buildMobileVisualizer();
              }

              return _buildDesktopVisualizer();
            },
          ),

          const SizedBox(height: 20),

          // ------------------------------------------------------
          // CURRENT STEP
          // ------------------------------------------------------

          _buildCurrentStep(),

          const SizedBox(height: 18),

          // ------------------------------------------------------
          // PLAYBACK CONTROLS
          // ------------------------------------------------------

          _buildControls(),
        ],
      ),
    );
  }

  // ============================================================
  // DESKTOP VISUALIZER
  // ============================================================

  Widget _buildDesktopVisualizer() {
    return SizedBox(
      height: 150,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Connecting line
          Positioned(
            left: 50,
            right: 50,
            top: 70,
            child: Container(
              height: 2,
              color: widget.mutedColor.withValues(alpha: 0.25),
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStateWithArrow(
                'READY',
                0,
                showArrow: true,
              ),
              _buildStateWithArrow(
                'RUNNING',
                1,
                showArrow: true,
              ),
              _buildStateWithArrow(
                'WAITING',
                2,
                showArrow: false,
              ),
            ],
          ),

          // Animated process indicator
          AnimatedAlign(
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeInOutCubic,
            alignment: _desktopIndicatorAlignment(),
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final glow =
                      10 + (_controller.value * 12);

                  return Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.accentColor,
                      boxShadow: [
                        BoxShadow(
                          color: widget.accentColor.withValues(
                            alpha: 0.75,
                          ),
                          blurRadius: glow,
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Alignment _desktopIndicatorAlignment() {
    switch (currentStep) {
      case 0:
      case 3:
        return const Alignment(-0.88, 0);

      case 1:
        return const Alignment(0, 0);

      case 2:
        return const Alignment(0.88, 0);

      default:
        return const Alignment(0, 0);
    }
  }

  // ============================================================
  // MOBILE VISUALIZER
  // ============================================================

  Widget _buildMobileVisualizer() {
    return Column(
      children: [
        _buildMobileState('READY', 0),

        _buildVerticalArrow(
          'Scheduler Selects',
        ),

        _buildMobileState('RUNNING', 1),

        _buildVerticalArrow(
          'I/O Request',
        ),

        _buildMobileState('WAITING', 2),
      ],
    );
  }

  Widget _buildVerticalArrow(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Column(
        children: [
          Icon(
            Icons.arrow_downward_rounded,
            color: widget.mutedColor,
            size: 20,
          ),
          Text(
            label,
            style: TextStyle(
              color: widget.mutedColor,
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STATE + ARROW
  // ============================================================

  Widget _buildStateWithArrow(
    String text,
    int index, {
    required bool showArrow,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildStateBox(text, index),

        if (showArrow)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final opacity =
                    0.35 + (_controller.value * 0.65);

                return Opacity(
                  opacity: opacity,
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    color: widget.accentColor,
                    size: 24,
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildMobileState(
    String text,
    int index,
  ) {
    return _buildStateBox(
      text,
      index,
      width: 150,
    );
  }

  // ============================================================
  // STATE BOX
  // ============================================================

  Widget _buildStateBox(
    String text,
    int index, {
    double? width,
  }) {
    final isActive = currentStep == index;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOut,
      width: width,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: isActive
            ? widget.accentColor.withValues(alpha: 0.18)
            : widget.accentColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive
              ? widget.accentColor
              : widget.accentColor.withValues(alpha: 0.35),
          width: isActive ? 2 : 1,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: widget.accentColor.withValues(
                    alpha: 0.28,
                  ),
                  blurRadius: 18,
                  spreadRadius: 1,
                ),
              ]
            : [],
      ),
      child: Column(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: isActive
                ? Icon(
                    Icons.circle,
                    key: ValueKey('$text-active'),
                    size: 8,
                    color: widget.accentColor,
                  )
                : const SizedBox(
                    key: ValueKey('inactive'),
                    height: 8,
                  ),
          ),

          const SizedBox(height: 5),

          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isActive
                  ? widget.accentColor
                  : widget.textColor,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CURRENT STEP
  // ============================================================

  Widget _buildCurrentStep() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: widget.accentColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: widget.accentColor.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: widget.accentColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Text(
              '${currentStep + 1}',
              style: TextStyle(
                color: widget.accentColor,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CURRENT STEP',
                  style: TextStyle(
                    color: widget.accentColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),

                const SizedBox(height: 5),

                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (
                    child,
                    animation,
                  ) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                  child: Text(
                    _stepDescription(),
                    key: ValueKey(currentStep),
                    style: TextStyle(
                      color: widget.textColor,
                      fontSize: 13,
                      height: 1.4,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _stepDescription() {
    switch (currentStep) {
      case 0:
        return 'The process is in the Ready state and is waiting for the CPU scheduler.';

      case 1:
        return 'The process is currently Running and is using the CPU.';

      case 2:
        return 'The process is Waiting because it requested I/O or another resource.';

      case 3:
        return 'The process returns to Ready and can be selected by the scheduler again.';

      default:
        return '';
    }
  }

  // ============================================================
  // CONTROLS
  // ============================================================

  Widget _buildControls() {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        _controlButton(
          icon: Icons.play_arrow_rounded,
          label: 'Play',
          onPressed: _play,
          active: isPlaying,
        ),

        _controlButton(
          icon: Icons.pause_rounded,
          label: 'Pause',
          onPressed: _pause,
          active: !isPlaying,
        ),

        _controlButton(
          icon: Icons.skip_next_rounded,
          label: 'Next Step',
          onPressed: _nextStep,
        ),

        _controlButton(
          icon: Icons.replay_rounded,
          label: 'Replay',
          onPressed: _replay,
        ),
      ],
    );
  }

  Widget _controlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool active = false,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(
          icon,
          size: 17,
        ),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: active
              ? widget.accentColor
              : widget.textColor,
          side: BorderSide(
            color: active
                ? widget.accentColor
                : widget.mutedColor.withValues(alpha: 0.45),
          ),
          backgroundColor: active
              ? widget.accentColor.withValues(alpha: 0.10)
              : Colors.transparent,
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}