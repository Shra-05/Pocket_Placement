import 'package:flutter/material.dart';
import 'level_selection_screen.dart';

enum AppTheme { forest, cyberpunk, kingdom }

class ThemeSelectionScreen extends StatefulWidget {
  final String topic;

  const ThemeSelectionScreen({super.key, this.topic = 'DSA'});

  @override
  State<ThemeSelectionScreen> createState() => _ThemeSelectionScreenState();
}

class _ThemeSelectionScreenState extends State<ThemeSelectionScreen> {
  AppTheme selectedTheme = AppTheme.forest;

  void continueToGame() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            LevelSelectionScreen(theme: selectedTheme, topic: widget.topic),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07120F),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 950),
              child: Column(
                children: [
                  const SizedBox(height: 35),

                  const Text(
                    'POCKET PLACEMENT',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 4,
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    'CHOOSE YOUR ADVENTURE',
                    style: TextStyle(
                      color: Color(0xFF4DE4FF),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Choose the world where your placement journey begins.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: .6),
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 45),

                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth < 700) {
                        return Column(
                          children: [
                            _themeCard(
                              theme: AppTheme.forest,
                              title: 'ENCHANTED FOREST',
                              subtitle: 'Adventure & Exploration',
                              icon: Icons.forest_rounded,
                              colors: const [
                                Color(0xFF0D5148),
                                Color(0xFF06251F),
                              ],
                            ),
                            const SizedBox(height: 20),
                            _themeCard(
                              theme: AppTheme.cyberpunk,
                              title: 'CYBER CITY',
                              subtitle: 'Technology & Competition',
                              icon: Icons.memory_rounded,
                              colors: const [
                                Color(0xFF4B176E),
                                Color(0xFF101A51),
                              ],
                            ),
                            const SizedBox(height: 20),
                            _themeCard(
                              theme: AppTheme.kingdom,
                              title: 'CODING KINGDOM',
                              subtitle: 'Fantasy RPG & Progression',
                              icon: Icons.castle_rounded,
                              colors: const [
                                Color(0xFF71451C),
                                Color(0xFF321B15),
                              ],
                            ),
                          ],
                        );
                      }

                      return Row(
                        children: [
                          Expanded(
                            child: _themeCard(
                              theme: AppTheme.forest,
                              title: 'ENCHANTED FOREST',
                              subtitle: 'Adventure & Exploration',
                              icon: Icons.forest_rounded,
                              colors: const [
                                Color(0xFF0D5148),
                                Color(0xFF06251F),
                              ],
                            ),
                          ),
                          const SizedBox(width: 18),
                          Expanded(
                            child: _themeCard(
                              theme: AppTheme.cyberpunk,
                              title: 'CYBER CITY',
                              subtitle: 'Technology & Competition',
                              icon: Icons.memory_rounded,
                              colors: const [
                                Color(0xFF4B176E),
                                Color(0xFF101A51),
                              ],
                            ),
                          ),
                          const SizedBox(width: 18),
                          Expanded(
                            child: _themeCard(
                              theme: AppTheme.kingdom,
                              title: 'CODING KINGDOM',
                              subtitle: 'Fantasy RPG & Progression',
                              icon: Icons.castle_rounded,
                              colors: const [
                                Color(0xFF71451C),
                                Color(0xFF321B15),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 45),

                  SizedBox(
                    width: 280,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: continueToGame,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF159BE8),
                        foregroundColor: Colors.white,
                        elevation: 12,
                        shadowColor: const Color(0xFF00D9FF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'CONTINUE',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                          SizedBox(width: 10),
                          Icon(Icons.arrow_forward_rounded),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _themeCard({
    required AppTheme theme,
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> colors,
  }) {
    final isSelected = selectedTheme == theme;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTheme = theme;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        height: 300,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected
                ? Colors.white
                : Colors.white.withValues(alpha: .18),
            width: isSelected ? 3 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? colors.first.withValues(alpha: .45)
                  : Colors.black.withValues(alpha: .35),
              blurRadius: isSelected ? 28 : 15,
              spreadRadius: isSelected ? 3 : 0,
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative circles
            Positioned(
              top: -40,
              right: -30,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: .06),
                ),
              ),
            ),

            Positioned(
              bottom: -50,
              left: -30,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withValues(alpha: .12),
                ),
              ),
            ),

            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withValues(alpha: .25),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: .35),
                      ),
                    ),
                    child: Icon(icon, color: Colors.white, size: 48),
                  ),

                  const SizedBox(height: 25),

                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: .65),
                      fontSize: 12,
                    ),
                  ),

                  const SizedBox(height: 18),

                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: isSelected ? 1 : 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'SELECTED ✓',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
