import 'dart:math';
import 'package:flutter/material.dart';
import 'theme_selection_screen.dart';

class StreakScreen extends StatefulWidget {
  final AppTheme theme;

  const StreakScreen({super.key, required this.theme});

  @override
  State<StreakScreen> createState() => _StreakScreenState();
}

class _StreakScreenState extends State<StreakScreen>
    with TickerProviderStateMixin {
  // Demo data for now.
  // Later these will come from the backend/database.
  int currentStreak = 7;
  int bestStreak = 12;
  int xp = 2450;

  late AnimationController _mainController;
  late AnimationController _pulseController;
  late AnimationController _particleController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5000),
    )..repeat();

    _scaleAnimation = CurvedAnimation(
      parent: _mainController,
      curve: Curves.elasticOut,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _mainController,
      curve: Curves.easeOut,
    );

    _mainController.forward();
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor(),
      body: Stack(
        children: [
          Positioned.fill(
            child: ThemeStreakBackground(
              theme: widget.theme,
              particleAnimation: _particleController,
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildTopBar(),

                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(18, 8, 18, 30),
                      child: Column(
                        children: [
                          _buildHeader(),

                          const SizedBox(height: 18),

                          ScaleTransition(
                            scale: _scaleAnimation,
                            child: _buildAnimatedStreak(),
                          ),

                          const SizedBox(height: 24),

                          _buildStats(),

                          const SizedBox(height: 18),

                          _buildWeeklyActivity(),

                          const SizedBox(height: 18),

                          _buildProgress(),

                          const SizedBox(height: 18),

                          _buildRewards(),

                          const SizedBox(height: 22),

                          _buildChallengeButton(),
                        ],
                      ),
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

  // ============================================================
  // TOP BAR
  // ============================================================

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 5),
      child: Row(
        children: [
          _roundButton(Icons.arrow_back_rounded, () => Navigator.pop(context)),

          const Spacer(),

          _topStat(Icons.star_rounded, '$xp', _accentColor()),

          const SizedBox(width: 8),

          _topStat(Icons.favorite_rounded, '5', const Color(0xFFFF5D6C)),

          const SizedBox(width: 8),

          _roundButton(Icons.more_horiz_rounded, () {}),
        ],
      ),
    );
  }

  Widget _roundButton(IconData icon, VoidCallback onTap) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black.withValues(alpha: 0.35),
        border: Border.all(color: _accentColor().withValues(alpha: 0.25)),
      ),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _topStat(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 17),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          _title(),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _accentColor(),
            fontSize: 24,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.5,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          _subtitle(),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.58),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // MAIN ANIMATED STREAK
  // ============================================================

  Widget _buildAnimatedStreak() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final pulse = 1 + (sin(_pulseController.value * 2 * pi) * 0.035);

        return Transform.scale(
          scale: pulse,
          child: SizedBox(
            width: 260,
            height: 260,
            child: Stack(
              alignment: Alignment.center,
              children: [
                _buildOuterRing(240),
                _buildOuterRing(210),
                _buildOuterRing(180),

                if (widget.theme == AppTheme.forest) const MagicalFlame(),

                if (widget.theme == AppTheme.cyberpunk) const EnergyReactor(),

                if (widget.theme == AppTheme.kingdom) const RoyalShield(),

                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$currentStreak',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 62,
                        fontWeight: FontWeight.w900,
                        shadows: [
                          Shadow(color: _accentColor(), blurRadius: 22),
                        ],
                      ),
                    ),
                    Text(
                      'DAY STREAK',
                      style: TextStyle(
                        color: _accentColor(),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 3,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOuterRing(double size) {
    final progress = 0.25 + (_pulseController.value * 0.5);

    return Transform.rotate(
      angle: _pulseController.value * 2 * pi,
      child: CustomPaint(
        size: Size(size, size),
        painter: StreakRingPainter(
          color: _accentColor(),
          progress: progress,
          opacity: size == 240 ? 0.18 : 0.10,
        ),
      ),
    );
  }

  // ============================================================
  // STATS
  // ============================================================

  Widget _buildStats() {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            Icons.local_fire_department_rounded,
            'CURRENT',
            '$currentStreak DAYS',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _statCard(
            Icons.emoji_events_rounded,
            'BEST',
            '$bestStreak DAYS',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(child: _statCard(Icons.star_rounded, 'TOTAL XP', '$xp')),
      ],
    );
  }

  Widget _statCard(IconData icon, String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Icon(icon, color: _accentColor(), size: 23),
          const SizedBox(height: 7),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.45),
              fontSize: 8,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // WEEKLY ACTIVITY
  // ============================================================

  Widget _buildWeeklyActivity() {
    const days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];

    return _sectionCard(
      title: _weeklyTitle(),
      icon: Icons.calendar_month_rounded,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(7, (index) {
          final completed = index < 6;
          final today = index == 6;

          return Column(
            children: [
              Text(
                days[index],
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.45),
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 7),

              AnimatedContainer(
                duration: Duration(milliseconds: 300 + index * 100),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: completed
                      ? _accentColor()
                      : Colors.black.withValues(alpha: 0.25),
                  border: Border.all(
                    color: today
                        ? _rewardColor()
                        : completed
                        ? _accentColor()
                        : Colors.white12,
                    width: today ? 2 : 1,
                  ),
                  boxShadow: completed
                      ? [
                          BoxShadow(
                            color: _accentColor().withValues(alpha: 0.28),
                            blurRadius: 12,
                          ),
                        ]
                      : [],
                ),
                child: Icon(
                  completed ? Icons.check_rounded : Icons.circle_outlined,
                  size: 18,
                  color: completed ? Colors.black : Colors.white24,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  // ============================================================
  // PROGRESS
  // ============================================================

  Widget _buildProgress() {
    final progress = min(currentStreak / 30, 1.0);

    return _sectionCard(
      title: _progressTitle(),
      icon: _progressIcon(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _progressMessage(),
                style: const TextStyle(color: Colors.white70, fontSize: 11),
              ),
              Text(
                '${(progress * 100).round()}%',
                style: TextStyle(
                  color: _accentColor(),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),

          const SizedBox(height: 9),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.white.withValues(alpha: 0.08),
              valueColor: AlwaysStoppedAnimation<Color>(_accentColor()),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            _nextMilestone(),
            style: const TextStyle(color: Colors.white38, fontSize: 9),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // REWARDS
  // ============================================================

  Widget _buildRewards() {
    return _sectionCard(
      title: _rewardTitle(),
      icon: Icons.card_giftcard_rounded,
      child: SizedBox(
        height: 92,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            _rewardCard(
              milestone: '3',
              icon: _rewardIcon(0),
              label: _rewardName(0),
              unlocked: currentStreak >= 3,
            ),
            _rewardCard(
              milestone: '7',
              icon: _rewardIcon(1),
              label: _rewardName(1),
              unlocked: currentStreak >= 7,
            ),
            _rewardCard(
              milestone: '14',
              icon: _rewardIcon(2),
              label: _rewardName(2),
              unlocked: currentStreak >= 14,
            ),
            _rewardCard(
              milestone: '30',
              icon: _rewardIcon(3),
              label: _rewardName(3),
              unlocked: currentStreak >= 30,
            ),
          ],
        ),
      ),
    );
  }

  Widget _rewardCard({
    required String milestone,
    required IconData icon,
    required String label,
    required bool unlocked,
  }) {
    return Container(
      width: 105,
      margin: const EdgeInsets.only(right: 9),
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: unlocked
            ? _accentColor().withValues(alpha: 0.10)
            : Colors.black.withValues(alpha: 0.20),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: unlocked
              ? _accentColor().withValues(alpha: 0.45)
              : Colors.white10,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            unlocked ? icon : Icons.lock_rounded,
            color: unlocked ? _rewardColor() : Colors.white30,
            size: 25,
          ),
          const SizedBox(height: 5),
          Text(
            '$milestone DAYS',
            style: TextStyle(
              color: unlocked ? Colors.white : Colors.white30,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: unlocked ? _accentColor() : Colors.white24,
              fontSize: 8,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CHALLENGE BUTTON
  // ============================================================

  Widget _buildChallengeButton() {
    return Column(
      children: [
        Text(
          _challengeMessage(),
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white60, fontSize: 11),
        ),

        const SizedBox(height: 12),

        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '🚀 Today\'s challenge will be connected next!',
                  ),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: Icon(_challengeIcon(), color: Colors.black),
            label: Text(
              _challengeButtonText(),
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _accentColor(),
              elevation: 12,
              shadowColor: _accentColor().withValues(alpha: 0.35),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(17),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SECTION CARD
  // ============================================================

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: _accentColor(), size: 18),
              const SizedBox(width: 7),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.black.withValues(alpha: 0.30),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: _accentColor().withValues(alpha: 0.16)),
      boxShadow: [
        BoxShadow(color: Colors.black.withValues(alpha: 0.20), blurRadius: 20),
      ],
    );
  }

  // ============================================================
  // THEME TEXT
  // ============================================================

  String _title() {
    switch (widget.theme) {
      case AppTheme.forest:
        return '🔥 FLAME OF THE FOREST';

      case AppTheme.cyberpunk:
        return '⚡ NEON POWER';

      case AppTheme.kingdom:
        return '👑 THE ROYAL QUEST';
    }
  }

  String _subtitle() {
    switch (widget.theme) {
      case AppTheme.forest:
        return 'Keep the magical flame of your coding journey alive.';

      case AppTheme.cyberpunk:
        return 'Keep coding to keep your system powered.';

      case AppTheme.kingdom:
        return 'Every coding day strengthens your kingdom.';
    }
  }

  String _weeklyTitle() {
    switch (widget.theme) {
      case AppTheme.forest:
        return 'FOREST ACTIVITY';

      case AppTheme.cyberpunk:
        return 'SYSTEM ACTIVITY';

      case AppTheme.kingdom:
        return 'QUEST ACTIVITY';
    }
  }

  String _progressTitle() {
    switch (widget.theme) {
      case AppTheme.forest:
        return 'FOREST GROWTH';

      case AppTheme.cyberpunk:
        return 'SYSTEM POWER';

      case AppTheme.kingdom:
        return 'KINGDOM PROGRESS';
    }
  }

  IconData _progressIcon() {
    switch (widget.theme) {
      case AppTheme.forest:
        return Icons.park_rounded;

      case AppTheme.cyberpunk:
        return Icons.bolt_rounded;

      case AppTheme.kingdom:
        return Icons.castle_rounded;
    }
  }

  String _progressMessage() {
    switch (widget.theme) {
      case AppTheme.forest:
        return 'Your magical world is growing...';

      case AppTheme.cyberpunk:
        return 'System power is increasing...';

      case AppTheme.kingdom:
        return 'Your kingdom grows stronger...';
    }
  }

  String _nextMilestone() {
    if (currentStreak < 3) {
      return '${3 - currentStreak} days until your first reward';
    }

    if (currentStreak < 7) {
      return '${7 - currentStreak} days until the next reward';
    }

    if (currentStreak < 14) {
      return '${14 - currentStreak} days until the next reward';
    }

    if (currentStreak < 30) {
      return '${30 - currentStreak} days until the legendary reward';
    }

    return '🏆 Legendary 30-day streak achieved!';
  }

  String _rewardTitle() {
    switch (widget.theme) {
      case AppTheme.forest:
        return 'FOREST MILESTONES';

      case AppTheme.cyberpunk:
        return 'SYSTEM UPGRADES';

      case AppTheme.kingdom:
        return 'ROYAL REWARDS';
    }
  }

  IconData _rewardIcon(int index) {
    switch (widget.theme) {
      case AppTheme.forest:
        return [
          Icons.local_florist_rounded,
          Icons.local_fire_department_rounded,
          Icons.park_rounded,
          Icons.forest_rounded,
        ][index];

      case AppTheme.cyberpunk:
        return [
          Icons.memory_rounded,
          Icons.bolt_rounded,
          Icons.battery_charging_full_rounded,
          Icons.smart_toy_rounded,
        ][index];

      case AppTheme.kingdom:
        return [
          Icons.shield_rounded,
          Icons.flash_on_rounded,
          Icons.workspace_premium_rounded,
          Icons.castle_rounded,
        ][index];
    }
  }

  String _rewardName(int index) {
    switch (widget.theme) {
      case AppTheme.forest:
        return [
          'Forest Bloom',
          'Magic Campfire',
          'Ancient Tree',
          'Legendary Grove',
        ][index];

      case AppTheme.cyberpunk:
        return ['Circuit', 'Power Core', 'Energy Grid', 'AI Companion'][index];

      case AppTheme.kingdom:
        return ['Knight Shield', 'Royal Torch', 'Crown', 'Castle'][index];
    }
  }

  String _challengeMessage() {
    switch (widget.theme) {
      case AppTheme.forest:
        return 'Complete today\'s challenge to keep your flame alive.';

      case AppTheme.cyberpunk:
        return 'Complete today\'s challenge to recharge your system.';

      case AppTheme.kingdom:
        return 'Complete today\'s quest to continue your royal journey.';
    }
  }

  String _challengeButtonText() {
    switch (widget.theme) {
      case AppTheme.forest:
        return 'CONTINUE THE JOURNEY';

      case AppTheme.cyberpunk:
        return 'POWER UP';

      case AppTheme.kingdom:
        return 'START TODAY\'S QUEST';
    }
  }

  IconData _challengeIcon() {
    switch (widget.theme) {
      case AppTheme.forest:
        return Icons.auto_awesome_rounded;

      case AppTheme.cyberpunk:
        return Icons.bolt_rounded;

      case AppTheme.kingdom:
        return Icons.shield_rounded;
    }
  }

  Color _accentColor() {
    switch (widget.theme) {
      case AppTheme.forest:
        return const Color(0xFF5CFFE0);

      case AppTheme.cyberpunk:
        return const Color(0xFF00E5FF);

      case AppTheme.kingdom:
        return const Color(0xFFFFD166);
    }
  }

  Color _rewardColor() {
    switch (widget.theme) {
      case AppTheme.forest:
        return const Color(0xFFE9FF7A);

      case AppTheme.cyberpunk:
        return const Color(0xFFD66BFF);

      case AppTheme.kingdom:
        return const Color(0xFFFFB347);
    }
  }

  Color _backgroundColor() {
    switch (widget.theme) {
      case AppTheme.forest:
        return const Color(0xFF04120E);

      case AppTheme.cyberpunk:
        return const Color(0xFF05020D);

      case AppTheme.kingdom:
        return const Color(0xFF0D0502);
    }
  }
}

// ============================================================
// THEME BACKGROUND
// ============================================================

class ThemeStreakBackground extends StatelessWidget {
  final AppTheme theme;
  final Animation<double> particleAnimation;

  const ThemeStreakBackground({
    super.key,
    required this.theme,
    required this.particleAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: particleAnimation,
      builder: (context, child) {
        return CustomPaint(
          painter: ThemeParticlePainter(
            theme: theme,
            progress: particleAnimation.value,
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: _backgroundColors(),
              ),
            ),
          ),
        );
      },
    );
  }

  List<Color> _backgroundColors() {
    switch (theme) {
      case AppTheme.forest:
        return const [Color(0xFF09241F), Color(0xFF061612), Color(0xFF020A07)];

      case AppTheme.cyberpunk:
        return const [Color(0xFF0B0524), Color(0xFF10052C), Color(0xFF03020A)];

      case AppTheme.kingdom:
        return const [Color(0xFF30170A), Color(0xFF180B05), Color(0xFF050201)];
    }
  }
}

// ============================================================
// PARTICLES
// ============================================================

class ThemeParticlePainter extends CustomPainter {
  final AppTheme theme;
  final double progress;

  ThemeParticlePainter({required this.theme, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(theme.index + 100);

    Color color;

    switch (theme) {
      case AppTheme.forest:
        color = const Color(0xFFB8FF79);
        break;

      case AppTheme.cyberpunk:
        color = const Color(0xFF00E5FF);
        break;

      case AppTheme.kingdom:
        color = const Color(0xFFFFD166);
        break;
    }

    final paint = Paint();

    for (int i = 0; i < 90; i++) {
      final x = random.nextDouble() * size.width;

      final startY = random.nextDouble() * size.height;

      final travel = progress * (80 + random.nextDouble() * 100);

      final y = (startY - travel) % size.height;

      final opacity = 0.15 + random.nextDouble() * 0.55;

      paint.color = color.withValues(alpha: opacity);

      final radius = 0.7 + random.nextDouble() * 1.8;

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant ThemeParticlePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.theme != theme;
  }
}

// ============================================================
// STREAK RING
// ============================================================

class StreakRingPainter extends CustomPainter {
  final Color color;
  final double progress;
  final double opacity;

  StreakRingPainter({
    required this.color,
    required this.progress,
    required this.opacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final radius = min(size.width, size.height) / 2 - 8;

    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant StreakRingPainter oldDelegate) {
    return true;
  }
}

// ============================================================
// FOREST FLAME
// ============================================================

class MagicalFlame extends StatelessWidget {
  const MagicalFlame({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 130,
      height: 130,
      child: CustomPaint(painter: FlamePainter()),
    );
  }
}

class FlamePainter extends CustomPainter {
  const FlamePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;

    final outer = Paint()
      ..color = const Color(0xFFFF9F43)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9);

    final inner = Paint()
      ..color = const Color(0xFFFFF0A8)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    canvas.drawCircle(Offset(centerX, size.height * 0.62), 30, outer);

    final flame = Path()
      ..moveTo(centerX, size.height * .90)
      ..cubicTo(
        size.width * .15,
        size.height * .70,
        size.width * .42,
        size.height * .58,
        centerX,
        size.height * .10,
      )
      ..cubicTo(
        size.width * .60,
        size.height * .38,
        size.width * .95,
        size.height * .62,
        centerX,
        size.height * .90,
      )
      ..close();

    canvas.drawPath(flame, outer);

    final smallFlame = Path()
      ..moveTo(centerX, size.height * .82)
      ..cubicTo(
        size.width * .35,
        size.height * .68,
        size.width * .47,
        size.height * .55,
        centerX,
        size.height * .30,
      )
      ..cubicTo(
        size.width * .55,
        size.height * .52,
        size.width * .70,
        size.height * .68,
        centerX,
        size.height * .82,
      )
      ..close();

    canvas.drawPath(smallFlame, inner);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

// ============================================================
// CYBER REACTOR
// ============================================================

class EnergyReactor extends StatelessWidget {
  const EnergyReactor({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: const Size(140, 140), painter: ReactorPainter());
  }
}

class ReactorPainter extends CustomPainter {
  const ReactorPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final glow = Paint()
      ..color = const Color(0xFF00E5FF).withValues(alpha: 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);

    canvas.drawCircle(center, 35, glow);

    final outer = Paint()
      ..color = const Color(0xFF00E5FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawCircle(center, 45, outer);

    canvas.drawCircle(center, 30, outer);

    final core = Paint()..color = const Color(0xFFD66BFF);

    canvas.drawCircle(center, 18, core);

    final bolt = Path()
      ..moveTo(center.dx + 5, center.dy - 25)
      ..lineTo(center.dx - 12, center.dy + 2)
      ..lineTo(center.dx - 2, center.dy + 2)
      ..lineTo(center.dx - 8, center.dy + 25)
      ..lineTo(center.dx + 13, center.dy - 5)
      ..lineTo(center.dx + 3, center.dy - 5)
      ..close();

    canvas.drawPath(bolt, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

// ============================================================
// ROYAL SHIELD
// ============================================================

class RoyalShield extends StatelessWidget {
  const RoyalShield({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: const Size(140, 150), painter: ShieldPainter());
  }
}

class ShieldPainter extends CustomPainter {
  const ShieldPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width * .20, size.height * .15)
      ..lineTo(size.width * .80, size.height * .15)
      ..lineTo(size.width * .75, size.height * .60)
      ..cubicTo(
        size.width * .70,
        size.height * .80,
        size.width * .50,
        size.height * .94,
        size.width * .50,
        size.height * .94,
      )
      ..cubicTo(
        size.width * .50,
        size.height * .94,
        size.width * .30,
        size.height * .80,
        size.width * .25,
        size.height * .60,
      )
      ..close();

    final glow = Paint()
      ..color = const Color(0xFFFFD166).withValues(alpha: 0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);

    canvas.drawPath(path, glow);

    final shield = Paint()
      ..color = const Color(0xFF7E421C)
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, shield);

    final border = Paint()
      ..color = const Color(0xFFFFD166)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    canvas.drawPath(path, border);

    final crown = TextPainter(
      text: const TextSpan(
        text: '♛',
        style: TextStyle(
          color: Color(0xFFFFD166),
          fontSize: 43,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    crown.layout();

    crown.paint(
      canvas,
      Offset(size.width / 2 - crown.width / 2, size.height * .33),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
