import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../data/quiz_repository.dart';
import '../../models/quiz_content.dart';
import '../../models/word_mode.dart';
import '../../widgets/shared_widgets.dart';
import 'mode_screen.dart';

class CrosswordScreen extends ModeScreen {
  const CrosswordScreen({super.key})
    : super(mode: WordMode.crossword, body: const _CrosswordQuizBody());
}

class _CrosswordQuizBody extends StatefulWidget {
  const _CrosswordQuizBody();

  @override
  State<_CrosswordQuizBody> createState() => _CrosswordQuizBodyState();
}

class _CrosswordQuizBodyState extends State<_CrosswordQuizBody> {
  static const int _initialLives = 3;
  static const int _questionsPerRound = 8;

  final Random _random = Random();
  final QuizRepository _quizRepository = QuizRepository.instance;

  late QuizDifficultyPack _questionPack;
  late List<_CrosswordQuestion> _questions;
  late List<String> _entrySlots;
  late List<String> _letterBank;
  late Set<int> _prefilledIndexes;

  int _questionIndex = 0;
  int _score = 0;
  int _lives = _initialLives;
  bool _showIntro = true;
  bool _answered = false;
  String? _submittedAnswer;
  _CrosswordStatus _status = _CrosswordStatus.inProgress;
  bool _isLoading = true;
  String? _loadError;

  _CrosswordQuestion get _currentQuestion => _questions[_questionIndex];

  @override
  void initState() {
    super.initState();
    _loadQuizData();
  }

  void _startQuizNow() {
    if (!_showIntro || _isLoading || _loadError != null) return;
    setState(() => _showIntro = false);
  }

  Future<void> _loadQuizData() async {
    try {
      final questionPack = await _quizRepository.loadForMode(
        WordMode.crossword,
      );
      if (!mounted) return;
      setState(() {
        _questionPack = questionPack;
        _startNewQuiz();
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadError = 'Failed to load crossword data.';
        _isLoading = false;
      });
    }
  }

  void _startNewQuiz() {
    _questions = _pickRoundQuestions();
    _prepareQuestionState();
  }

  List<_CrosswordQuestion> _pickRoundQuestions() {
    final picked = <_CrosswordQuestion>[];
    final seen = <String>{};

    void takeFrom(List<QuizQuestionData> source, int count) {
      var remaining = count;
      final shuffled = List<QuizQuestionData>.from(source)..shuffle(_random);
      for (final item in shuffled) {
        if (picked.length >= _questionsPerRound || remaining == 0) break;
        if (!seen.add(item.uniqueKey)) continue;
        picked.add(_CrosswordQuestion(clue: item.prompt, answer: item.answer));
        remaining--;
      }
    }

    takeFrom(_questionPack.easy, 3);
    takeFrom(_questionPack.medium, 3);
    takeFrom(_questionPack.hard, 2);

    if (picked.length < _questionsPerRound) {
      final fallback = [
        ..._questionPack.easy,
        ..._questionPack.medium,
        ..._questionPack.hard,
      ]..shuffle(_random);
      for (final item in fallback) {
        if (picked.length >= _questionsPerRound) break;
        if (!seen.add(item.uniqueKey)) continue;
        picked.add(_CrosswordQuestion(clue: item.prompt, answer: item.answer));
      }
    }

    return picked.take(_questionsPerRound).toList();
  }

  void _prepareQuestionState() {
    final answer = _currentQuestion.answer;
    _entrySlots = List<String>.filled(answer.length, '');
    _prefilledIndexes = _pickPrefilledIndexes(answer.length);

    for (final index in _prefilledIndexes) {
      _entrySlots[index] = answer[index];
    }

    final extraCount = max(2, min(4, answer.length ~/ 2));
    final extras = List<String>.generate(extraCount, (_) {
      return String.fromCharCode(65 + _random.nextInt(26));
    });

    _letterBank = [
      for (var i = 0; i < answer.length; i++)
        if (!_prefilledIndexes.contains(i)) answer[i],
      ...extras,
    ]..shuffle(_random);
  }

  Set<int> _pickPrefilledIndexes(int answerLength) {
    if (answerLength <= 2) {
      return {0};
    }

    final revealCount = max(1, min(3, answerLength ~/ 3));
    final indexes = <int>{0};
    while (indexes.length < revealCount) {
      indexes.add(_random.nextInt(answerLength));
    }
    return indexes;
  }

  void _addLetter(String letter) {
    if (_answered || _status != _CrosswordStatus.inProgress) return;
    final emptyIndex = _entrySlots.indexOf('');
    if (emptyIndex == -1) return;

    HapticFeedback.selectionClick();
    setState(() {
      _entrySlots[emptyIndex] = letter;
      _letterBank.removeAt(_letterBank.indexOf(letter));
    });
  }

  void _removeLetterAt(int index) {
    if (_answered || _status != _CrosswordStatus.inProgress) return;
    if (_prefilledIndexes.contains(index)) return;
    final letter = _entrySlots[index];
    if (letter.isEmpty) return;

    HapticFeedback.lightImpact();
    setState(() {
      _entrySlots[index] = '';
      _letterBank.add(letter);
    });
  }

  Future<void> _submitGuess() async {
    if (_answered || _status != _CrosswordStatus.inProgress) return;
    if (_entrySlots.contains('')) return;

    final guess = _entrySlots.join();
    final isCorrect = guess == _currentQuestion.answer;

    HapticFeedback.mediumImpact();
    setState(() {
      _submittedAnswer = guess;
      _answered = true;
      if (isCorrect) {
        _score++;
      } else {
        _lives--;
      }
    });

    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;

    final isLastQuestion = _questionIndex == _questions.length - 1;
    if (_lives <= 0) {
      setState(() => _status = _CrosswordStatus.failed);
      return;
    }

    if (isLastQuestion) {
      setState(() => _status = _CrosswordStatus.passed);
      return;
    }

    setState(() {
      _questionIndex++;
      _answered = false;
      _submittedAnswer = null;
      _prepareQuestionState();
    });
  }

  void _clearEntry() {
    if (_answered || _status != _CrosswordStatus.inProgress) return;
    HapticFeedback.lightImpact();
    setState(() {
      for (var index = 0; index < _entrySlots.length; index++) {
        final letter = _entrySlots[index];
        if (!_prefilledIndexes.contains(index) && letter.isNotEmpty) {
          _letterBank.add(letter);
        }
      }
      _entrySlots = List<String>.filled(_currentQuestion.answer.length, '');
      for (final index in _prefilledIndexes) {
        _entrySlots[index] = _currentQuestion.answer[index];
      }
    });
  }

  void _restart() {
    setState(() {
      _questionIndex = 0;
      _score = 0;
      _lives = _initialLives;
      _showIntro = true;
      _answered = false;
      _submittedAnswer = null;
      _status = _CrosswordStatus.inProgress;
      _startNewQuiz();
    });
  }

  Color _slotAccent(int index) {
    if (!_answered) {
      if (_prefilledIndexes.contains(index)) {
        return const Color(0xFF0057BD);
      }
      return _entrySlots[index].isEmpty
          ? const Color(0xFFB39DDB)
          : const Color(0xFF6A37D4);
    }

    final answerChar = _currentQuestion.answer[index];
    final isCorrect = _entrySlots[index] == answerChar;
    return isCorrect ? const Color(0xFF1B8F3A) : const Color(0xFFE53935);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_loadError != null) {
      return Center(
        child: GlassPanel(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 56,
                color: Color(0xFFE53935),
              ),
              const SizedBox(height: 12),
              Text(
                _loadError!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _loadError = null;
                  });
                  _loadQuizData();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    assert(
      _questionPack.easy.length >= 50 &&
          _questionPack.medium.length >= 50 &&
          _questionPack.hard.length >= 50,
      'Each crossword difficulty must contain at least 50 questions.',
    );

    if (_showIntro) {
      return _CrosswordIntroView(
        onStart: _startQuizNow,
        onAnimationDone: _startQuizNow,
      );
    }

    if (_status != _CrosswordStatus.inProgress) {
      return _CrosswordResultView(
        status: _status,
        score: _score,
        total: _questions.length,
        onPlayAgain: _restart,
      );
    }

    final question = _currentQuestion;
    final progress = _questionIndex / _questions.length;
    final isFilled = !_entrySlots.contains('');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Score: $_score',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              Row(
                children: [
                  Text(
                    'Lives: $_lives',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${_questionIndex + 1}/${_questions.length}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: const Color(0xFFE8D8FF),
            ),
          ),
          const SizedBox(height: 24),
          GlassPanel(
            child: Column(
              children: [
                const Text(
                  'Solve the clue by filling the answer slots',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF67537C),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  question.clue,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  '${question.answer.length} letters',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF67537C),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: List.generate(_entrySlots.length, (index) {
              return GestureDetector(
                onTap: () => _removeLetterAt(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 48,
                  height: 56,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _slotAccent(index), width: 2),
                  ),
                  child: Text(
                    _entrySlots[index].isEmpty ? ' ' : _entrySlots[index],
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: _slotAccent(index),
                    ),
                  ),
                ),
              );
            }),
          ).animate().fadeIn(duration: 220.ms).moveY(begin: 12, end: 0),
          const SizedBox(height: 18),
          GlassPanel(
            child: Column(
              children: [
                const Text(
                  'Letter Bank',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 14),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 10,
                  runSpacing: 10,
                  children: _letterBank.map((letter) {
                    return InkWell(
                      onTap: () => _addLetter(letter),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        width: 46,
                        height: 46,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF7C4DFF), Color(0xFF4E8DFF)],
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          letter,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _entrySlots.every((letter) => letter.isEmpty)
                      ? null
                      : _clearEntry,
                  child: const Text('Clear'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: isFilled ? _submitGuess : null,
                  child: const Text('Check'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_answered)
            GlassPanel(
                  child: Column(
                    children: [
                      Icon(
                        _submittedAnswer == question.answer
                            ? Icons.check_circle
                            : Icons.cancel,
                        size: 56,
                        color: _submittedAnswer == question.answer
                            ? const Color(0xFF1B8F3A)
                            : const Color(0xFFE53935),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _submittedAnswer == question.answer
                            ? 'Correct'
                            : 'Answer: ${question.answer}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: _submittedAnswer == question.answer
                              ? const Color(0xFF1B8F3A)
                              : const Color(0xFFE53935),
                        ),
                      ),
                    ],
                  ),
                )
                .animate()
                .scale(
                  begin: const Offset(0.96, 0.96),
                  end: const Offset(1, 1),
                  duration: 220.ms,
                )
                .fadeIn(duration: 200.ms)
          else
            const Text(
              'Blue letters are fixed. Tap letters to fill the empty slots.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF67537C),
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }
}

class _CrosswordQuestion {
  const _CrosswordQuestion({required this.clue, required this.answer});

  final String clue;
  final String answer;
}

enum _CrosswordStatus { inProgress, passed, failed }

class _CrosswordIntroView extends StatefulWidget {
  const _CrosswordIntroView({
    required this.onStart,
    required this.onAnimationDone,
  });

  final VoidCallback onStart;
  final VoidCallback onAnimationDone;

  @override
  State<_CrosswordIntroView> createState() => _CrosswordIntroViewState();
}

class _CrosswordIntroViewState extends State<_CrosswordIntroView> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 1700), () {
      if (!mounted) return;
      widget.onAnimationDone();
    });
  }

  @override
  Widget build(BuildContext context) {
    const word = 'CROSSWORD';
    return GestureDetector(
      onTap: widget.onStart,
      behavior: HitTestBehavior.opaque,
      child: Container(
        color: Colors.white,
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(word.length, (index) {
            return Text(
                  word[index],
                  style: const TextStyle(
                    fontSize: 56,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0057BD),
                  ),
                )
                .animate(delay: Duration(milliseconds: index * 120))
                .fadeIn(duration: 240.ms)
                .moveY(begin: 14, end: 0, duration: 260.ms)
                .then(delay: 450.ms)
                .fadeOut(duration: 260.ms);
          }),
        ),
      ),
    );
  }
}

class _CrosswordResultView extends StatelessWidget {
  const _CrosswordResultView({
    required this.status,
    required this.score,
    required this.total,
    required this.onPlayAgain,
  });

  final _CrosswordStatus status;
  final int score;
  final int total;
  final VoidCallback onPlayAgain;

  @override
  Widget build(BuildContext context) {
    final passed = status == _CrosswordStatus.passed;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: GlassPanel(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                passed ? Icons.emoji_events_rounded : Icons.refresh_rounded,
                size: 72,
                color: passed
                    ? const Color(0xFF1B8F3A)
                    : const Color(0xFFE53935),
              ),
              const SizedBox(height: 12),
              Text(
                passed ? 'Grid cleared' : 'Crossword failed',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Score $score / $total',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF67537C),
                ),
              ),
              const SizedBox(height: 18),
              FilledButton(
                onPressed: onPlayAgain,
                child: const Text('Play Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
