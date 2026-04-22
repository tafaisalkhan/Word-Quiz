import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';
import '../widgets/shared_widgets.dart';
import 'home_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFDF3FF), Color(0xFFF3E2FF), Color(0xFFE6E1FF)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 40),
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFAE8DFF), Color(0xFFFFC1D6)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6A37D4).withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.menu_book_rounded,
                    size: 50,
                    color: Colors.white,
                  ),
                )
                    .animate()
                    .scale(
                      begin: const Offset(0.8, 0.8),
                      end: const Offset(1, 1),
                      duration: 500.ms,
                      curve: Curves.easeOutBack,
                    ),
                const SizedBox(height: 24),
                Text(
                  'Word Quizz',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    foreground: Paint()
                      ..shader = LinearGradient(
                        colors: [Color(0xFF6A37D4), Color(0xFFB00D6A)],
                      ).createShader(const Rect.fromLTWH(0, 0, 200, 50)),
                  ),
                )
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .moveY(begin: 15, end: 0, duration: 400.ms),
                const SizedBox(height: 8),
                const Text(
                  'Welcome back! Sign in to continue',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF67537C),
                    fontWeight: FontWeight.w500,
                  ),
                )
                    .animate()
                    .fadeIn(delay: 150.ms, duration: 400.ms),
                const SizedBox(height: 48),
                _GoogleLoginButton(
                  onTap: () => _showComingSoon(context, 'Google Sign-In'),
                )
                    .animate()
                    .fadeIn(delay: 300.ms, duration: 400.ms)
                    .moveY(begin: 15, end: 0, duration: 400.ms),
                const SizedBox(height: 24),
                const _Divider(label: 'or')
                    .animate()
                    .fadeIn(delay: 450.ms, duration: 400.ms),
                const SizedBox(height: 24),
                _EmailSignupForm()
                    .animate()
                    .fadeIn(delay: 600.ms, duration: 400.ms)
                    .moveY(begin: 15, end: 0, duration: 400.ms),
                const SizedBox(height: 24),
                _GuestLoginButton(
                  onTap: () {
                    context.read<UserProvider>().loginAsGuest();
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute<void>(builder: (_) => const HomeScreen()),
                    );
                  },
                )
                    .animate()
                    .fadeIn(delay: 750.ms, duration: 400.ms)
                    .moveY(begin: 15, end: 0, duration: 400.ms),
                const SizedBox(height: 32),
                const Text(
                  'By continuing, you agree to our',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9B84B5),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => _showComingSoon(context, 'Terms of Service'),
                      child: const Text(
                        'Terms of Service',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6A37D4),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Text(
                      ' and ',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9B84B5),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _showComingSoon(context, 'Privacy Policy'),
                      child: const Text(
                        'Privacy Policy',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6A37D4),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                )
                    .animate()
                    .fadeIn(delay: 900.ms, duration: 400.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void _showComingSoon(BuildContext context, String feature) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('$feature coming soon'),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}

class _GoogleLoginButton extends StatelessWidget {
  const _GoogleLoginButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE0E0E0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFDB4437),
              ),
              child: const Icon(
                Icons.g_mobiledata,
                size: 18,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Continue with Google',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF5F6368),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: const Color(0xFFD0C0E0).withValues(alpha: 0.5))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF9B84B5),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(child: Divider(color: const Color(0xFFD0C0E0).withValues(alpha: 0.5))),
      ],
    );
  }
}

class _EmailSignupForm extends StatefulWidget {
  const _EmailSignupForm();

  @override
  State<_EmailSignupForm> createState() => _EmailSignupFormState();
}

class _EmailSignupFormState extends State<_EmailSignupForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLogin = true;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      context.read<UserProvider>().loginWithEmail(_emailController.text);
      _showComingSoon(context, _isLogin ? 'Login' : 'Sign Up');
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: _TabButton(
                    label: 'Login',
                    active: _isLogin,
                    onTap: () => setState(() => _isLogin = true),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _TabButton(
                    label: 'Sign Up',
                    active: !_isLogin,
                    onTap: () => setState(() => _isLogin = false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: _inputDecoration(
                label: 'Email',
                icon: Icons.email_outlined,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!value.contains('@')) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: _inputDecoration(
                label: 'Password',
                icon: Icons.lock_outlined,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ).copyWith(hintText: 'At least 6 characters'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
            if (!_isLogin) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscurePassword,
                decoration: _inputDecoration(
                  label: 'Confirm Password',
                  icon: Icons.lock_outlined,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  }
                  if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
            ],
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _handleSubmit,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF6A37D4),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                _isLogin ? 'Login' : 'Sign Up',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFF6A37D4)),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.8),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD0C0E0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD0C0E0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF6A37D4), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE53935)),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: active
              ? const Color(0xFF6A37D4).withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: active ? const Color(0xFF6A37D4) : const Color(0xFFD0C0E0),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: active ? const Color(0xFF6A37D4) : const Color(0xFF9B84B5),
          ),
        ),
      ),
    );
  }
}

class _GuestLoginButton extends StatelessWidget {
  const _GuestLoginButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF6A37D4).withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF6A37D4).withValues(alpha: 0.3)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_outline_rounded,
              color: Color(0xFF6A37D4),
              size: 24,
            ),
            SizedBox(width: 12),
            Text(
              'Continue as Guest',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF6A37D4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
