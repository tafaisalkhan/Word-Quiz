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
                _PlayerProfileForm()
                    .animate()
                    .fadeIn(delay: 300.ms, duration: 400.ms)
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

class _PlayerProfileForm extends StatefulWidget {
  const _PlayerProfileForm();

  @override
  State<_PlayerProfileForm> createState() => _PlayerProfileFormState();
}

class _PlayerProfileFormState extends State<_PlayerProfileForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _selectedDifficulty = 'Easy';

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      context.read<UserProvider>().loginWithProfile(
        _nameController.text.trim(),
        _selectedDifficulty,
      );
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
            TextFormField(
              controller: _nameController,
              textInputAction: TextInputAction.next,
              decoration: _inputDecoration(
                label: 'Name',
                icon: Icons.person_outline_rounded,
                hintText: 'Enter your name',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            const SizedBox(height: 18),
            const Text(
              'Select quiz difficulty',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF67537C),
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: ['Easy', 'Medium', 'Hard'].map((difficulty) {
                final selected = _selectedDifficulty == difficulty;
                return ChoiceChip(
                  label: Text(difficulty),
                  selected: selected,
                  onSelected: (_) => setState(() => _selectedDifficulty = difficulty),
                  selectedColor: const Color(0xFF6A37D4).withValues(alpha: 0.16),
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: selected ? const Color(0xFF6A37D4) : const Color(0xFF67537C),
                  ),
                  side: BorderSide(
                    color: selected ? const Color(0xFF6A37D4) : const Color(0xFFD0C0E0),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 22),
            FilledButton(
              onPressed: _handleSubmit,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF6A37D4),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Start Quiz',
                style: TextStyle(
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
    String? hintText,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hintText,
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
