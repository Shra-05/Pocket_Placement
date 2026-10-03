import 'package:flutter/material.dart';
import 'package:pocket_placement/survey_screen.dart';
import 'package:pocket_placement/services/api_service.dart';
import 'package:confetti/confetti.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_placement/theme_selection_screen.dart';
import 'package:pocket_placement/features/dsa_world/screens/dsa_world_home_screen.dart';
import 'dart:math' show Random;

void main() {
  runApp(const PocketPlacementApp());
}

class StartupScreen extends StatefulWidget {
  const StartupScreen({super.key});

  @override
  State<StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends State<StartupScreen> {
  @override
  void initState() {
    super.initState();

    checkLogin();
  }

  Future<void> checkLogin() async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString('auth_token');

    final skillTestCompleted = prefs.getBool('skill_test_completed') ?? false;

    if (!mounted) return;

    if (token != null && token.isNotEmpty) {
      if (skillTestCompleted) {
        Navigator.pushReplacement(
          context,

          MaterialPageRoute(builder: (_) => const ThemeSelectionScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,

          MaterialPageRoute(builder: (_) => const SurveyScreen()),
        );
      }
    } else {
      Navigator.pushReplacement(
        context,

        MaterialPageRoute(builder: (_) => const AuthScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

class PocketPlacementApp extends StatelessWidget {
  const PocketPlacementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pocket Placement',
      theme: ThemeData(brightness: Brightness.dark, useMaterial3: true),
      home: const StartupScreen(),
      routes: {'/dsa-world': (context) => const DSAWorldHomeScreen()},
    );
  }
}

// ============================================================*

// AUTH SCREEN*

// ============================================================*

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  // SIGN UP*

  final usernameController = TextEditingController();

  final signupEmailController = TextEditingController();

  final signupPasswordController = TextEditingController();

  final confirmPasswordController = TextEditingController();

  // LOGIN*

  final loginEmailController = TextEditingController();

  final loginPasswordController = TextEditingController();

  final ConfettiController confettiController = ConfettiController(
    duration: const Duration(seconds: 2),
  );

  bool showLogin = false;

  bool hideSignupPassword = true;

  bool hideConfirmPassword = true;

  bool hideLoginPassword = true;

  @override
  void dispose() {
    usernameController.dispose();

    signupEmailController.dispose();

    signupPasswordController.dispose();

    confirmPasswordController.dispose();

    loginEmailController.dispose();

    loginPasswordController.dispose();

    confettiController.dispose();

    super.dispose();
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> createAccount() async {
    if (usernameController.text.trim().isEmpty ||
        signupEmailController.text.trim().isEmpty ||
        signupPasswordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      showMessage('Please complete all fields.');

      return;
    }

    if (signupPasswordController.text != confirmPasswordController.text) {
      showMessage('Passwords do not match.');

      return;
    }

    try {
      final response = await ApiService.signup(
        name: usernameController.text.trim(),

        email: signupEmailController.text.trim(),

        password: signupPasswordController.text,
      );

      if (!mounted) return;

      if (response['success'] == true) {
        final prefs = await SharedPreferences.getInstance();

        // A newly created account has not completed the Skill Quest.

        await prefs.setBool('skill_test_completed', false);

        // If the backend returns a token on signup, save it so the

        // Skill Quest completion can be sent to the protected API.

        final token = response['token'];

        if (token != null && token.toString().isNotEmpty) {
          await prefs.setString('auth_token', token.toString());
        }

        confettiController.play();

        showMessage('🎉 Account created successfully!');

        await Future.delayed(const Duration(seconds: 2));

        if (!mounted) return;

        Navigator.pushReplacement(
          context,

          MaterialPageRoute(builder: (_) => const SurveyScreen()),
        );
      } else {
        showMessage(response['message'] ?? 'Signup failed.');
      }
    } catch (error) {
      if (!mounted) return;

      showMessage('Unable to connect to the server. Please try again.');

      debugPrint('Signup error: $error');
    }
  }

  Future<void> login() async {
    if (loginEmailController.text.trim().isEmpty ||
        loginPasswordController.text.isEmpty) {
      showMessage('Please enter your email and password.');

      return;
    }

    try {
      final response = await ApiService.login(
        email: loginEmailController.text.trim(),

        password: loginPasswordController.text,
      );

      if (!mounted) return;

      if (response['success'] == true) {
        final token = response['token'];

        final user = response['user'];

        final skillTestCompleted =
            user != null && user['skillTestCompleted'] == true;

        if (token != null && token.toString().isNotEmpty) {
          final prefs = await SharedPreferences.getInstance();

          await prefs.setString('auth_token', token.toString());

          await prefs.setBool('skill_test_completed', skillTestCompleted);
        }

        confettiController.play();

        showMessage('🎉 Login successful!');

        await Future.delayed(const Duration(seconds: 2));

        if (!mounted) return;

        if (skillTestCompleted) {
          Navigator.pushReplacement(
            context,

            MaterialPageRoute(builder: (_) => const ThemeSelectionScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,

            MaterialPageRoute(builder: (_) => const SurveyScreen()),
          );
        }
      } else {
        showMessage(response['message'] ?? 'Login failed.');
      }
    } catch (error) {
      if (!mounted) return;

      showMessage('Unable to connect to the server. Please try again.');

      debugPrint('Login error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF06130F),

      body: Stack(
        children: [
          const Positioned.fill(child: FantasyBackground()),

          Align(
            alignment: Alignment.topCenter,

            child: ConfettiWidget(
              confettiController: confettiController,

              blastDirectionality: BlastDirectionality.explosive,

              shouldLoop: false,

              emissionFrequency: 0.05,

              numberOfParticles: 30,

              gravity: 0.25,
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),

              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 650),

                  child: Column(
                    children: [
                      // Back button*

                      Align(
                        alignment: Alignment.centerLeft,

                        child: CircleIconButton(
                          icon: Icons.arrow_back_rounded,

                          onPressed: () {},
                        ),
                      ),

                      const SizedBox(height: 12),

                      // LOGO*
                      const PocketPlacementLogo(),

                      const SizedBox(height: 30),

                      // AUTH PAGE*
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 350),

                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,

                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(.08, 0),

                                end: Offset.zero,
                              ).animate(animation),

                              child: child,
                            ),
                          );
                        },

                        child: showLogin
                            ? LoginPage(
                                key: const ValueKey('login'),

                                emailController: loginEmailController,

                                passwordController: loginPasswordController,

                                hidePassword: hideLoginPassword,

                                onPasswordVisibility: () {
                                  setState(() {
                                    hideLoginPassword = !hideLoginPassword;
                                  });
                                },

                                onLogin: login,

                                onSignup: () {
                                  setState(() {
                                    showLogin = false;
                                  });
                                },

                                onGoogle: () {
                                  showMessage(
                                    'Google login will be added later.',
                                  );
                                },

                                onFacebook: () {
                                  showMessage(
                                    'Facebook login will be added later.',
                                  );
                                },

                                onForgotPassword: () {
                                  showMessage(
                                    'Password recovery will be added later.',
                                  );
                                },
                              )
                            : SignupPage(
                                key: const ValueKey('signup'),

                                usernameController: usernameController,

                                emailController: signupEmailController,

                                passwordController: signupPasswordController,

                                confirmPasswordController:
                                    confirmPasswordController,

                                hidePassword: hideSignupPassword,

                                hideConfirmPassword: hideConfirmPassword,

                                onPasswordVisibility: () {
                                  setState(() {
                                    hideSignupPassword = !hideSignupPassword;
                                  });
                                },

                                onConfirmVisibility: () {
                                  setState(() {
                                    hideConfirmPassword = !hideConfirmPassword;
                                  });
                                },

                                onSignup: createAccount,

                                onLogin: () {
                                  setState(() {
                                    showLogin = true;
                                  });
                                },

                                onGoogle: () {
                                  showMessage(
                                    'Google signup will be added later.',
                                  );
                                },

                                onFacebook: () {
                                  showMessage(
                                    'Facebook signup will be added later.',
                                  );
                                },
                              ),
                      ),

                      const SizedBox(height: 22),

                      Text(
                        'Level up your skills • Level up your career',

                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.20),

                          fontSize: 12,

                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================*

// SIGN UP PAGE*

// ============================================================*

class SignupPage extends StatelessWidget {
  final TextEditingController usernameController;

  final TextEditingController emailController;

  final TextEditingController passwordController;

  final TextEditingController confirmPasswordController;

  final bool hidePassword;

  final bool hideConfirmPassword;

  final VoidCallback onPasswordVisibility;

  final VoidCallback onConfirmVisibility;

  final VoidCallback onSignup;

  final VoidCallback onLogin;

  final VoidCallback onGoogle;

  final VoidCallback onFacebook;

  const SignupPage({
    super.key,

    required this.usernameController,

    required this.emailController,

    required this.passwordController,

    required this.confirmPasswordController,

    required this.hidePassword,

    required this.hideConfirmPassword,

    required this.onPasswordVisibility,

    required this.onConfirmVisibility,

    required this.onSignup,

    required this.onLogin,

    required this.onGoogle,

    required this.onFacebook,
  });

  @override
  Widget build(BuildContext context) {
    return FantasyPanel(
      child: Column(
        children: [
          const AuthHeading(
            title: 'SIGN UP',

            subtitle: 'Begin your placement adventure',
          ),

          const SizedBox(height: 28),

          FantasyTextField(
            controller: usernameController,

            hint: 'Choose Username',

            icon: Icons.person_outline_rounded,
          ),

          const SizedBox(height: 15),

          FantasyTextField(
            controller: emailController,

            hint: 'Email Address',

            icon: Icons.mail_outline_rounded,

            keyboardType: TextInputType.emailAddress,
          ),

          const SizedBox(height: 15),

          FantasyTextField(
            controller: passwordController,

            hint: 'Password',

            icon: Icons.lock_outline_rounded,

            obscureText: hidePassword,

            suffixIcon: IconButton(
              onPressed: onPasswordVisibility,

              icon: Icon(
                hidePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,

                color: const Color(0xFFBCEAD8),
              ),
            ),
          ),

          const SizedBox(height: 15),

          FantasyTextField(
            controller: confirmPasswordController,

            hint: 'Confirm Password',

            icon: Icons.lock_outline_rounded,

            obscureText: hideConfirmPassword,

            suffixIcon: IconButton(
              onPressed: onConfirmVisibility,

              icon: Icon(
                hideConfirmPassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,

                color: const Color(0xFFBCEAD8),
              ),
            ),
          ),

          const SizedBox(height: 17),

          Row(
            children: [
              const Icon(
                Icons.check_box_rounded,

                color: Color(0xFF43DFFF),

                size: 21,
              ),

              const SizedBox(width: 8),

              Expanded(
                child: RichText(
                  text: const TextSpan(
                    style: TextStyle(color: Colors.white70, fontSize: 12),

                    children: [
                      TextSpan(text: 'I agree to the '),

                      TextSpan(
                        text: 'Terms of Service',

                        style: TextStyle(
                          color: Color(0xFF4DE4FF),

                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      TextSpan(text: ' and '),

                      TextSpan(
                        text: 'Privacy Policy',

                        style: TextStyle(
                          color: Color(0xFF4DE4FF),

                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          FantasyButton(
            text: 'SIGN UP',

            icon: Icons.auto_awesome_rounded,

            onPressed: onSignup,
          ),

          const SizedBox(height: 20),

          // THIS OPENS LOGIN PAGE*
          Row(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              const Text(
                'Already have an account? ',

                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),

              GestureDetector(
                onTap: onLogin,

                child: const Text(
                  'LOG IN →',

                  style: TextStyle(
                    color: Color(0xFF4DE4FF),

                    fontWeight: FontWeight.bold,

                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          const OrDivider(),

          const SizedBox(height: 16),

          SocialButton(
            icon: 'G',

            text: 'Continue with Google',

            onPressed: onGoogle,
          ),

          const SizedBox(height: 10),

          SocialButton(
            icon: 'f',

            text: 'Continue with Facebook',

            onPressed: onFacebook,
          ),
        ],
      ),
    );
  }
}

// ============================================================*

// LOGIN PAGE*

// ============================================================*

class LoginPage extends StatelessWidget {
  final TextEditingController emailController;

  final TextEditingController passwordController;

  final bool hidePassword;

  final VoidCallback onPasswordVisibility;

  final VoidCallback onLogin;

  final VoidCallback onSignup;

  final VoidCallback onGoogle;

  final VoidCallback onFacebook;

  final VoidCallback onForgotPassword;

  const LoginPage({
    super.key,

    required this.emailController,

    required this.passwordController,

    required this.hidePassword,

    required this.onPasswordVisibility,

    required this.onLogin,

    required this.onSignup,

    required this.onGoogle,

    required this.onFacebook,

    required this.onForgotPassword,
  });

  @override
  Widget build(BuildContext context) {
    return FantasyPanel(
      child: Column(
        children: [
          const AuthHeading(
            title: 'LOG IN',

            subtitle: 'Welcome back, adventurer',
          ),

          const SizedBox(height: 30),

          FantasyTextField(
            controller: emailController,

            hint: 'Email Address',

            icon: Icons.mail_outline_rounded,

            keyboardType: TextInputType.emailAddress,
          ),

          const SizedBox(height: 16),

          FantasyTextField(
            controller: passwordController,

            hint: 'Password',

            icon: Icons.lock_outline_rounded,

            obscureText: hidePassword,

            suffixIcon: IconButton(
              onPressed: onPasswordVisibility,

              icon: Icon(
                hidePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,

                color: const Color(0xFFBCEAD8),
              ),
            ),
          ),

          const SizedBox(height: 4),

          Align(
            alignment: Alignment.centerRight,

            child: TextButton(
              onPressed: onForgotPassword,

              child: const Text(
                'Forgot your password?',

                style: TextStyle(color: Color(0xFF4DE4FF)),
              ),
            ),
          ),

          const SizedBox(height: 10),

          FantasyButton(
            text: 'LOG IN',

            icon: Icons.login_rounded,

            onPressed: onLogin,
          ),

          const SizedBox(height: 22),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              const Text(
                'New here? ',

                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),

              GestureDetector(
                onTap: onSignup,

                child: const Text(
                  'SIGN UP →',

                  style: TextStyle(
                    color: Color(0xFF4DE4FF),

                    fontWeight: FontWeight.bold,

                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          const OrDivider(),

          const SizedBox(height: 16),

          SocialButton(
            icon: 'G',

            text: 'Continue with Google',

            onPressed: onGoogle,
          ),

          const SizedBox(height: 10),

          SocialButton(
            icon: 'f',

            text: 'Continue with Facebook',

            onPressed: onFacebook,
          ),
        ],
      ),
    );
  }
}

// ============================================================*

// FANTASY PANEL*

// ============================================================*

class FantasyPanel extends StatelessWidget {
  final Widget child;

  const FantasyPanel({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.symmetric(horizontal: 42, vertical: 38),

      decoration: BoxDecoration(
        color: const Color(0xFF071711).withValues(alpha: .88),

        borderRadius: BorderRadius.circular(30),

        border: Border.all(color: const Color(0xFF6CA184), width: 2),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),

            blurRadius: 35,

            spreadRadius: 3,
          ),

          BoxShadow(
            color: const Color(0xFF00D9FF).withValues(alpha: .08),

            blurRadius: 35,

            spreadRadius: 4,
          ),
        ],
      ),

      child: CustomPaint(
        painter: VinePainter(),

        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),

          child: child,
        ),
      ),
    );
  }
}

// ============================================================*

// VINE DECORATION*

// ============================================================*

class VinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF966A35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    final top = Path();

    top.moveTo(0, 10);

    top.cubicTo(
      size.width * .18,

      -3,

      size.width * .32,

      25,

      size.width * .50,

      9,
    );

    top.cubicTo(size.width * .68, -4, size.width * .82, 25, size.width, 8);

    canvas.drawPath(top, paint);

    final bottom = Path();

    bottom.moveTo(0, size.height - 10);

    bottom.cubicTo(
      size.width * .18,

      size.height + 3,

      size.width * .32,

      size.height - 25,

      size.width * .50,

      size.height - 9,
    );

    bottom.cubicTo(
      size.width * .68,

      size.height + 4,

      size.width * .82,

      size.height - 25,

      size.width,

      size.height - 8,
    );

    canvas.drawPath(bottom, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

// ============================================================*

// TEXT FIELD*

// ============================================================*

class FantasyTextField extends StatelessWidget {
  final TextEditingController controller;

  final String hint;

  final IconData icon;

  final bool obscureText;

  final Widget? suffixIcon;

  final TextInputType? keyboardType;

  const FantasyTextField({
    super.key,

    required this.controller,

    required this.hint,

    required this.icon,

    this.obscureText = false,

    this.suffixIcon,

    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,

      obscureText: obscureText,

      keyboardType: keyboardType,

      style: const TextStyle(color: Colors.white, fontSize: 15),

      cursorColor: const Color(0xFF4DE4FF),

      decoration: InputDecoration(
        hintText: hint,

        hintStyle: TextStyle(color: Colors.white.withValues(alpha: .52)),

        prefixIcon: Icon(icon, color: const Color(0xFFBCEAD8)),

        suffixIcon: suffixIcon,

        filled: true,

        fillColor: const Color(0xFF04110C).withValues(alpha: .80),

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,

          vertical: 17,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),

          borderSide: const BorderSide(color: Color(0xFF508B70), width: 1.2),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),

          borderSide: const BorderSide(color: Color(0xFF4DE4FF), width: 1.8),
        ),
      ),
    );
  }
}

// ============================================================*

// BUTTON*

// ============================================================*

class FantasyButton extends StatelessWidget {
  final String text;

  final IconData icon;

  final VoidCallback onPressed;

  const FantasyButton({
    super.key,

    required this.text,

    required this.icon,

    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,

      height: 57,

      child: ElevatedButton(
        onPressed: onPressed,

        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF168FE8),

          foregroundColor: Colors.white,

          elevation: 10,

          shadowColor: const Color(0xFF00D9FF),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),

            side: const BorderSide(color: Color(0xFF62EFFF), width: 1.5),
          ),
        ),

        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Icon(icon, size: 20),

            const SizedBox(width: 9),

            Text(
              text,

              style: const TextStyle(
                fontSize: 17,

                fontWeight: FontWeight.bold,

                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================*

// SOCIAL BUTTON*

// ============================================================*

class SocialButton extends StatelessWidget {
  final String icon;

  final String text;

  final VoidCallback onPressed;

  const SocialButton({
    super.key,

    required this.icon,

    required this.text,

    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,

      width: double.infinity,

      child: OutlinedButton(
        onPressed: onPressed,

        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.black.withValues(alpha: .15),

          side: BorderSide(color: Colors.white.withValues(alpha: .20)),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),

        child: Row(
          children: [
            Container(
              width: 28,

              height: 28,

              alignment: Alignment.center,

              decoration: BoxDecoration(
                shape: BoxShape.circle,

                color: icon == 'G' ? Colors.white : const Color(0xFF1877F2),
              ),

              child: Text(
                icon,

                style: TextStyle(
                  color: icon == 'G' ? Colors.black : Colors.white,

                  fontWeight: FontWeight.bold,

                  fontSize: 15,
                ),
              ),
            ),

            Expanded(
              child: Text(
                text,

                textAlign: TextAlign.center,

                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),

            const SizedBox(width: 28),
          ],
        ),
      ),
    );
  }
}

// ============================================================*

// HEADING*

// ============================================================*

class AuthHeading extends StatelessWidget {
  final String title;

  final String subtitle;

  const AuthHeading({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(height: 1, color: const Color(0xFF47765F)),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),

              child: Icon(
                Icons.auto_awesome,

                size: 16,

                color: Color(0xFF4DE4FF),
              ),
            ),

            Expanded(
              child: Container(height: 1, color: const Color(0xFF47765F)),
            ),
          ],
        ),

        const SizedBox(height: 8),

        Text(
          title,

          style: const TextStyle(
            color: Colors.white,

            fontSize: 31,

            fontWeight: FontWeight.w800,

            letterSpacing: 3,
          ),
        ),

        const SizedBox(height: 5),

        Text(
          subtitle,

          style: TextStyle(
            color: Colors.white.withValues(alpha: .55),

            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

// ============================================================*

// OR DIVIDER*

// ============================================================*

class OrDivider extends StatelessWidget {
  const OrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: const Color(0xFF3D6855))),

        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 13),

          child: Text(
            'OR',

            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ),

        Expanded(child: Container(height: 1, color: Color(0xFF3D6855))),
      ],
    );
  }
}

// ============================================================*

// LOGO*

// ============================================================*

class PocketPlacementLogo extends StatelessWidget {
  const PocketPlacementLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'THE',

          style: TextStyle(
            color: Color(0xFFE8D8BB),

            fontSize: 12,

            letterSpacing: 4,
          ),
        ),

        const SizedBox(height: 2),

        ShaderMask(
          shaderCallback: (bounds) {
            return const LinearGradient(
              colors: [Color(0xFFFFE9C8), Color(0xFFD5F8FF), Color(0xFFFFE9C8)],
            ).createShader(bounds);
          },

          child: const Text(
            'POCKET',

            style: TextStyle(
              color: Colors.white,

              fontSize: 46,

              fontWeight: FontWeight.w300,

              letterSpacing: 4,
            ),
          ),
        ),

        Container(width: 215, height: 1, color: const Color(0xFFE5D0A7)),

        const Text(
          'PLACEMENT',

          style: TextStyle(
            color: Color(0xFFE8D8BB),

            fontSize: 22,

            letterSpacing: 5,
          ),
        ),
      ],
    );
  }
}

// ============================================================*

// BACK BUTTON*

// ============================================================*

class CircleIconButton extends StatelessWidget {
  final IconData icon;

  final VoidCallback onPressed;

  const CircleIconButton({
    super.key,

    required this.icon,

    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: .35),

      shape: const CircleBorder(),

      child: InkWell(
        onTap: onPressed,

        customBorder: const CircleBorder(),

        child: const SizedBox(
          width: 52,

          height: 52,

          child: Icon(Icons.arrow_back_rounded, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}

// ============================================================*

// BACKGROUND*

// ============================================================*

class FantasyBackground extends StatelessWidget {
  const FantasyBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: ForestPainter(),

      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,

            end: Alignment.bottomCenter,

            colors: [
              Color(0xFF17152D),

              Color(0xFF48303D),

              Color(0xFF173331),

              Color(0xFF061610),
            ],

            stops: [0.0, 0.30, 0.62, 1.0],
          ),
        ),
      ),
    );
  }
}

class ForestPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(42);

    // Moon glow*

    final moonPaint = Paint()
      ..shader =
          RadialGradient(
            colors: [
              const Color(0xFFFFC88E).withValues(alpha: .20),

              Colors.transparent,
            ],
          ).createShader(
            Rect.fromCircle(
              center: Offset(size.width * .76, size.height * .13),

              radius: size.width * .32,
            ),
          );

    canvas.drawCircle(
      Offset(size.width * .76, size.height * .13),

      size.width * .32,

      moonPaint,
    );

    // Mountains*

    final mountainPaint = Paint()..color = const Color(0xFF171B2B);

    final mountains = Path()
      ..moveTo(0, size.height * .32)
      ..lineTo(size.width * .22, size.height * .15)
      ..lineTo(size.width * .40, size.height * .30)
      ..lineTo(size.width * .64, size.height * .14)
      ..lineTo(size.width, size.height * .29)
      ..lineTo(size.width, size.height * .47)
      ..lineTo(0, size.height * .47)
      ..close();

    canvas.drawPath(mountains, mountainPaint);

    // Forest trees*

    final treePaint = Paint()..color = const Color(0xFF0B2721);

    for (int i = 0; i < 18; i++) {
      final x = random.nextDouble() * size.width;

      final treeHeight = 80 + random.nextDouble() * 150;

      final tree = Path()
        ..moveTo(x, size.height * .72)
        ..lineTo(x - 42, size.height * .72)
        ..lineTo(x, size.height * .72 - treeHeight)
        ..lineTo(x + 42, size.height * .72)
        ..close();

      canvas.drawPath(tree, treePaint);
    }

    // Fireflies*

    final glowPaint = Paint()
      ..color = const Color(0xFFE7FF73)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    for (int i = 0; i < 45; i++) {
      final x = random.nextDouble() * size.width;

      final y = random.nextDouble() * size.height;

      canvas.drawCircle(Offset(x, y), 2, glowPaint);
    }

    // Bottom foliage*

    final foliagePaint = Paint()..color = const Color(0xFF061711);

    final foliage = Path()
      ..moveTo(0, size.height * .82)
      ..quadraticBezierTo(
        size.width * .25,

        size.height * .72,

        size.width * .5,

        size.height * .84,
      )
      ..quadraticBezierTo(
        size.width * .75,

        size.height * .92,

        size.width,

        size.height * .79,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(foliage, foliagePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
