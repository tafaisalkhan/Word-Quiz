import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../data/quiz_repository.dart';
import '../../models/quiz_content.dart';
import '../../models/word_mode.dart';
import '../../providers/user_provider.dart';
import '../../services/daily_progress_service.dart';
import '../../widgets/end_interstitial_ad.dart';
import '../../widgets/shared_widgets.dart';
import '../../widgets/user_info_bar.dart';

class ModeQuizQuestion {
  const ModeQuizQuestion({
    required this.word,
    required this.correctAnswer,
    required this.options,
  });

  final String word;
  final String correctAnswer;
  final List<String> options;
}

enum ModeAnswerStyle {
  tapReveal,
  dragDrop,
  typeToMatch,
  hotspotCloud,
  wheelPick,
  pageSwipeUp,
  longPressSelect,
  sliderPick,
}

class ModeQuizBody extends StatefulWidget {
  const ModeQuizBody({
    super.key,
    required this.mode,
    required this.modeWord,
    required this.prompt,
    this.answerStyle = ModeAnswerStyle.longPressSelect,
  });

  final WordMode mode;
  final String modeWord;
  final String prompt;
  final ModeAnswerStyle answerStyle;

  @override
  State<ModeQuizBody> createState() => _ModeQuizBodyState();
}

enum _QuizStatus { inProgress, passed, failed }

class _ModeQuizBodyState extends State<ModeQuizBody> {
  static const int _initialLives = 3;
  static const int _questionsPerRound = 10;
  static const MethodChannel _feedbackChannel =
      MethodChannel('word_quiz/feedback_tones');
  static const String _correctAnswerTone = 'play_correct_answer_tone';
  static const String _wrongAnswerTone = 'play_wrong_answer_tone';
  static const String _completeTone = 'play_complete_tone';

  final Random _random = Random();
  final QuizRepository _quizRepository = QuizRepository.instance;

  late QuizDifficultyPack _questionPack;
  late List<ModeQuizQuestion> _questions;

  int _questionIndex = 0;
  int _score = 0;
  int _lives = _initialLives;
  bool _answered = false;
  bool _showIntro = true;
  String? _selectedAnswer;
  bool _showAnswerPopup = false;
  _QuizStatus _quizStatus = _QuizStatus.inProgress;
  bool _endInterstitialRequested = false;
  late final TextEditingController _textController;
  late final FocusNode _textFocusNode;
  bool _isRevealed = false;
  int _activeOptionIndex = 0;
  double _sliderIndex = 0;
  bool _isLoading = true;
  String? _loadError;

  ModeQuizQuestion get _currentQuestion => _questions[_questionIndex];

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _textFocusNode = FocusNode();
    _loadQuizData();
  }

  @override
  void dispose() {
    _textController.dispose();
    _textFocusNode.dispose();
    super.dispose();
  }

  void _startQuizNow() {
    if (!_showIntro || _isLoading || _loadError != null) return;
    setState(() {
      _showIntro = false;
    });
  }

  Future<void> _loadQuizData() async {
    try {
      final questionPack = await _quizRepository.loadForMode(widget.mode);
      if (!mounted) return;
      setState(() {
        _questionPack = questionPack;
        _startNewQuiz();
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadError = 'Failed to load quiz data.';
        _isLoading = false;
      });
    }
  }

  void _startNewQuiz() {
    _questions = _pickRoundQuestions();
  }

  List<ModeQuizQuestion> _pickRoundQuestions() {
    final picked = <ModeQuizQuestion>[];
    final seen = <String>{};
    final difficulty = context.read<UserProvider>().quizDifficulty.toLowerCase();
    final source = switch (difficulty) {
      'easy' => _questionPack.easy,
      'medium' => _questionPack.medium,
      'hard' => _questionPack.hard,
      _ => _questionPack.easy,
    };

    void takeFrom(List<QuizQuestionData> items, int count) {
      var remaining = count;
      final shuffled = List<QuizQuestionData>.from(items)..shuffle(_random);
      for (final item in shuffled) {
        if (picked.length >= _questionsPerRound || remaining == 0) break;
        if (!seen.add(item.uniqueKey)) continue;
        picked.add(
          ModeQuizQuestion(
            word: item.prompt,
            correctAnswer: item.answer,
            options: item.options,
          ),
        );
        remaining--;
      }
    }

    takeFrom(source, _questionsPerRound);

    if (picked.length < _questionsPerRound) {
      final fallback = List<QuizQuestionData>.from(source)..shuffle(_random);
      for (final item in fallback) {
        if (picked.length >= _questionsPerRound) break;
        if (!seen.add(item.uniqueKey)) continue;
        picked.add(
          ModeQuizQuestion(
            word: item.prompt,
            correctAnswer: item.answer,
            options: item.options,
          ),
        );
      }
    }

    return picked.take(_questionsPerRound).toList();
  }

  Future<void> _selectAnswer(String answer) async {
    if (_answered || _quizStatus != _QuizStatus.inProgress) return;

    final isCorrect = answer == _currentQuestion.correctAnswer;
    _playAnswerFeedback(isCorrect);
    setState(() {
      _selectedAnswer = answer;
      _showAnswerPopup = true;
      _answered = true;
      if (isCorrect) {
        _score++;
      } else {
        _lives--;
      }
    });

    await Future<void>.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    final isLastQuestion = _questionIndex == _questions.length - 1;
    if (_lives <= 0) {
      setState(() {
        _quizStatus = _QuizStatus.failed;
      });
      _showEndInterstitialOnce();
      return;
    }

    if (isLastQuestion) {
      setState(() {
        _quizStatus = _QuizStatus.passed;
      });
      if (widget.mode == WordMode.dailyChallenge) {
        unawaited(DailyProgressService.instance.markCompletedToday());
      }
      _playCompletionChime();
      _showEndInterstitialOnce();
      return;
    }

    setState(() {
      _questionIndex++;
      _selectedAnswer = null;
      _answered = false;
      _isRevealed = false;
      _activeOptionIndex = 0;
      _sliderIndex = 0;
      _textController.clear();
      _showAnswerPopup = false;
    });
  }

  void _playAnswerFeedback(bool isCorrect) {
    if (isCorrect) {
      HapticFeedback.mediumImpact();
      unawaited(_feedbackChannel.invokeMethod<void>(_correctAnswerTone));
      return;
    }

    HapticFeedback.heavyImpact();
    unawaited(_feedbackChannel.invokeMethod<void>(_wrongAnswerTone));
  }

  void _playCompletionChime() {
    HapticFeedback.lightImpact();
    unawaited(_feedbackChannel.invokeMethod<void>(_completeTone));
  }

  void _showEndInterstitialOnce() {
    if (_endInterstitialRequested) return;
    _endInterstitialRequested = true;
    EndInterstitialAd.showIfReady();
  }

  void _restart() {
    setState(() {
      _startNewQuiz();
      _questionIndex = 0;
      _score = 0;
      _lives = _initialLives;
      _answered = false;
      _showIntro = true;
      _selectedAnswer = null;
      _quizStatus = _QuizStatus.inProgress;
      _isRevealed = false;
      _activeOptionIndex = 0;
      _sliderIndex = 0;
      _textController.clear();
      _showAnswerPopup = false;
      _endInterstitialRequested = false;
    });
  }

  String get _interactionHint => switch (widget.answerStyle) {
    ModeAnswerStyle.tapReveal =>
      _isRevealed
          ? 'Tap a revealed card to answer'
          : 'Tap Reveal to show answer cards',
    ModeAnswerStyle.dragDrop => 'Drag one option into the drop zone',
    ModeAnswerStyle.typeToMatch => 'Type an answer exactly from suggestions',
    ModeAnswerStyle.hotspotCloud => 'Tap the floating answer bubble',
    ModeAnswerStyle.wheelPick =>
      'Spin the wheel and double tap center to answer',
    ModeAnswerStyle.pageSwipeUp =>
      'Swipe cards left/right, then swipe up to submit',
    ModeAnswerStyle.longPressSelect => 'Long-press an option to submit',
    ModeAnswerStyle.sliderPick => 'Slide to an option, then release to submit',
  };

  Color _optionAccent(ModeQuizQuestion question, String option, bool active) {
    final isSelected = _selectedAnswer == option;
    final isCorrect = option == question.correctAnswer;
    if (_answered && isSelected && isCorrect) {
      return const Color(0xFF1B8F3A);
    }
    if (_answered && isSelected && !isCorrect) {
      return const Color(0xFFE53935);
    }
    if (active) {
      return const Color(0xFF8E63E8);
    }
    return const Color(0xFF6A37D4);
  }

  void _playInteractionFeedback() {
    switch (widget.answerStyle) {
      case ModeAnswerStyle.dragDrop:
        HapticFeedback.mediumImpact();
        SystemSound.play(SystemSoundType.click);
      case ModeAnswerStyle.typeToMatch:
        HapticFeedback.selectionClick();
      case ModeAnswerStyle.wheelPick:
        HapticFeedback.selectionClick();
      case ModeAnswerStyle.sliderPick:
        HapticFeedback.selectionClick();
      case ModeAnswerStyle.pageSwipeUp:
        HapticFeedback.heavyImpact();
        SystemSound.play(SystemSoundType.click);
      case ModeAnswerStyle.tapReveal:
        HapticFeedback.lightImpact();
      case ModeAnswerStyle.hotspotCloud:
        HapticFeedback.lightImpact();
      case ModeAnswerStyle.longPressSelect:
        HapticFeedback.mediumImpact();
    }
  }

  Widget _buildAnswerInteraction(ModeQuizQuestion question) {
    return switch (widget.answerStyle) {
      ModeAnswerStyle.tapReveal => _buildTapReveal(question),
      ModeAnswerStyle.dragDrop => _buildDragDrop(question),
      ModeAnswerStyle.typeToMatch => _buildTypeToMatch(question),
      ModeAnswerStyle.hotspotCloud => _buildHotspotCloud(question),
      ModeAnswerStyle.wheelPick => _buildWheelPick(question),
      ModeAnswerStyle.pageSwipeUp => _buildPageSwipeUp(question),
      ModeAnswerStyle.longPressSelect => _buildLongPress(question),
      ModeAnswerStyle.sliderPick => _buildSliderPick(question),
    };
  }

  Widget _buildTapReveal(ModeQuizQuestion question) {
    if (!_isRevealed) {
      return GestureDetector(
        onTap: () {
          _playInteractionFeedback();
          setState(() => _isRevealed = true);
        },
        child: GlassPanel(
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 14),
            child: Text(
              'Reveal Options',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
          ),
        ),
      );
    }
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: question.options.map((option) {
        final accent = _optionAccent(question, option, false);
        return GestureDetector(
          onTap: () {
            _playInteractionFeedback();
            _selectAnswer(option);
          },
          child: GlassPanel(
            child: Text(
              option,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: accent,
                fontSize: 20,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDragDrop(ModeQuizQuestion question) {
    return Column(
      children: [
        DragTarget<String>(
          onAcceptWithDetails: (details) {
            _playInteractionFeedback();
            _selectAnswer(details.data);
          },
          builder: (context, candidateData, rejectedData) {
            final isActive = candidateData.isNotEmpty;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFFDCE8FF)
                    : const Color(0xFFF4EEFF),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isActive
                      ? const Color(0xFF0057BD)
                      : const Color(0xFFB39DDB),
                  width: 1.5,
                ),
              ),
              child: const Text(
                'Drop Answer Here',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
            );
          },
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: question.options.map((option) {
            final accent = _optionAccent(question, option, false);
            return Draggable<String>(
              data: option,
              feedback: Material(
                color: Colors.transparent,
                child: _dragChip(option, accent),
              ),
              childWhenDragging: Opacity(
                opacity: 0.35,
                child: _dragChip(option, accent),
              ),
              child: _dragChip(option, accent),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _dragChip(String label, Color accent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: accent.withValues(alpha: 0.12),
        border: Border.all(color: accent),
      ),
      child: Text(
        label,
        style: TextStyle(fontWeight: FontWeight.w800, color: accent),
      ),
    );
  }

  Widget _buildTypeToMatch(ModeQuizQuestion question) {
    final normalized = _textController.text.trim().toLowerCase();
    final filtered = question.options
        .where((o) => o.toLowerCase().contains(normalized))
        .toList();
    return Column(
      children: [
        TextField(
          controller: _textController,
          focusNode: _textFocusNode,
          onChanged: (_) => setState(() {}),
          onSubmitted: (value) {
            if (question.options.any(
              (option) => option.toLowerCase() == value.trim().toLowerCase(),
            )) {
              final exact = question.options.firstWhere(
                (option) => option.toLowerCase() == value.trim().toLowerCase(),
              );
              _playInteractionFeedback();
              _selectAnswer(exact);
            }
          },
          decoration: InputDecoration(
            hintText: 'Type your answer',
            filled: true,
            fillColor: const Color(0xFFF4EEFF),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFB39DDB)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: filtered.map((option) {
            return GestureDetector(
              onTap: () {
                _playInteractionFeedback();
                _textController.text = option;
                setState(() {});
              },
              onLongPress: () {
                _playInteractionFeedback();
                _selectAnswer(option);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: const Color(0xFFEDE7F6),
                ),
                child: Text(option),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildHotspotCloud(ModeQuizQuestion question) {
    final positions = <Alignment>[
      const Alignment(-0.85, -0.7),
      const Alignment(0.85, -0.52),
      const Alignment(-0.66, 0.25),
      const Alignment(0.72, 0.45),
      const Alignment(0, -0.1),
    ];
    return SizedBox(
      height: 220,
      child: Stack(
        children: List.generate(question.options.length, (index) {
          final option = question.options[index];
          final accent = _optionAccent(question, option, false);
          return Align(
            alignment: positions[index % positions.length],
            child: GestureDetector(
              onTap: () {
                _playInteractionFeedback();
                _selectAnswer(option);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: accent),
                ),
                child: Text(
                  option,
                  style: TextStyle(fontWeight: FontWeight.w700, color: accent),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildWheelPick(ModeQuizQuestion question) {
    return Column(
      children: [
        SizedBox(
          height: 160,
          child: ListWheelScrollView.useDelegate(
            itemExtent: 46,
            perspective: 0.002,
            diameterRatio: 1.7,
            onSelectedItemChanged: (index) {
              _playInteractionFeedback();
              setState(() {
                _activeOptionIndex = index;
              });
            },
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: question.options.length,
              builder: (context, index) {
                final option = question.options[index];
                final isActive = index == _activeOptionIndex;
                final accent = _optionAccent(question, option, isActive);
                return Center(
                  child: Text(
                    option,
                    style: TextStyle(
                      fontSize: isActive ? 26 : 19,
                      fontWeight: FontWeight.w800,
                      color: accent,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onDoubleTap: () {
            _playInteractionFeedback();
            _selectAnswer(question.options[_activeOptionIndex]);
          },
          child: const Text(
            'Double tap here to lock answer',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF67537C),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPageSwipeUp(ModeQuizQuestion question) {
    return SizedBox(
      height: 176,
      child: PageView.builder(
        itemCount: question.options.length,
        onPageChanged: (index) => setState(() => _activeOptionIndex = index),
        itemBuilder: (context, index) {
          final option = question.options[index];
          final isActive = index == _activeOptionIndex;
          final accent = _optionAccent(question, option, isActive);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: GestureDetector(
              onVerticalDragEnd: (details) {
                final velocity = details.primaryVelocity ?? 0;
                if (velocity < -300) {
                  _playInteractionFeedback();
                  _selectAnswer(option);
                }
              },
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: accent, width: 1.5),
                  gradient: LinearGradient(
                    colors: [
                      accent.withValues(alpha: 0.18),
                      accent.withValues(alpha: 0.05),
                    ],
                  ),
                ),
                child: Center(
                  child: Text(
                    option,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: accent,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLongPress(ModeQuizQuestion question) {
    return Column(
      children: question.options.map((option) {
        final accent = _optionAccent(question, option, false);
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: GestureDetector(
            onLongPress: () {
              _playInteractionFeedback();
              _selectAnswer(option);
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: accent.withValues(alpha: 0.1),
                border: Border.all(color: accent, width: 1.2),
              ),
              child: Text(
                option,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: accent,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSliderPick(ModeQuizQuestion question) {
    final maxIndex = (question.options.length - 1).toDouble();
    final currentIndex = _sliderIndex.round().clamp(
      0,
      question.options.length - 1,
    );
    final activeOption = question.options[currentIndex];
    return Column(
      children: [
        GlassPanel(
          child: Text(
            activeOption,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: _optionAccent(question, activeOption, true),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Slider(
          value: _sliderIndex.clamp(0, maxIndex),
          min: 0,
          max: maxIndex,
          divisions: question.options.length - 1,
          label: activeOption,
          onChanged: (value) {
            _playInteractionFeedback();
            setState(() => _sliderIndex = value);
          },
          onChangeEnd: (_) {
            _playInteractionFeedback();
            _selectAnswer(activeOption);
          },
        ),
      ],
    );
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
      'Each difficulty must contain at least 50 questions.',
    );
    assert(
      _questions.length >= 5,
      'Quiz round must contain at least 5 questions.',
    );

    if (_showIntro) {
      return _ModeIntroView(
        word: widget.modeWord,
        onStart: _startQuizNow,
        onAnimationDone: _startQuizNow,
      );
    }

    if (_quizStatus != _QuizStatus.inProgress) {
      return _ModeResultView(
        status: _quizStatus,
        score: _score,
        total: _questions.length,
        onPlayAgain: _restart,
      );
    }

    final question = _currentQuestion;
    final progress = _questionIndex / _questions.length;

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              AdBanner(location: 'top'),
              const SizedBox(height: 8),
              const UserInfoBar(horizontal: 16, vertical: 10),
              const SizedBox(height: 12),
              Expanded(
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
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
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '${_questionIndex + 1}/${_questions.length}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
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
                            Text(
                              widget.prompt,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF67537C),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              question.word,
                              style: const TextStyle(
                                fontSize: 44,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                          const SizedBox(height: 20),
                          _buildAnswerInteraction(question)
                              .animate()
                              .fadeIn(duration: 220.ms)
                              .moveY(
                                begin: 12,
                                end: 0,
                                duration: 220.ms,
                                curve: Curves.easeOutCubic,
                              ),
                          const SizedBox(height: 20),
                          if (!_answered) ...[
                            const SizedBox(height: 10),
                            Text(
                              _interactionHint,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFF67537C),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (_showAnswerPopup)
                      Positioned.fill(
                        child: Align(
                          alignment: Alignment.center,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: _AnswerPopup(
                              success: _selectedAnswer == question.correctAnswer,
                              answer: question.correctAnswer,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              AdBanner(location: 'bottom'),
            ],
          ),
        ],
      ),
    );
  }
}

class _AnswerPopup extends StatelessWidget {
  const _AnswerPopup({
    required this.success,
    required this.answer,
  });

  final bool success;
  final String answer;

  @override
  Widget build(BuildContext context) {
    final color = success ? const Color(0xFF1B8F3A) : const Color(0xFFE53935);
    final icon = success ? Icons.check_circle_rounded : Icons.cancel_rounded;
    final label = success ? 'Right' : 'Wrong';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: color),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Answer: $answer',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF67537C),
            ),
          ),
        ],
      ),
    ).animate().scale(
      begin: const Offset(0.9, 0.9),
      end: const Offset(1, 1),
      duration: 180.ms,
    ).fadeIn(duration: 180.ms);
  }
}

class _ModeIntroView extends StatefulWidget {
  const _ModeIntroView({
    required this.word,
    required this.onStart,
    required this.onAnimationDone,
  });

  final String word;
  final VoidCallback onStart;
  final VoidCallback onAnimationDone;

  @override
  State<_ModeIntroView> createState() => _ModeIntroViewState();
}

class _ModeIntroViewState extends State<_ModeIntroView> {
  bool _canStart = false;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 1700), () {
      if (!mounted) return;
      setState(() {
        _canStart = true;
      });
      widget.onAnimationDone();
    });
  }

  @override
  Widget build(BuildContext context) {
    final word = widget.word.replaceAll(' ', '');
    return GestureDetector(
      onTap: _canStart ? widget.onStart : null,
      behavior: HitTestBehavior.opaque,
      child: Container(
        color: Colors.white,
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(word.length, (index) {
            final char = word[index];
            return Text(
                  char,
                  style: const TextStyle(
                    fontSize: 56,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF6A37D4),
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

class _ModeResultView extends StatelessWidget {
  const _ModeResultView({
    required this.status,
    required this.score,
    required this.total,
    required this.onPlayAgain,
  });

  final _QuizStatus status;
  final int score;
  final int total;
  final VoidCallback onPlayAgain;

  @override
  Widget build(BuildContext context) {
    final isPass = status == _QuizStatus.passed;
    final wrongAnswers = total - score;
    final percentage = ((score / total) * 100).round();
    final points = 1000 + ((score / total) * 9000).round();
    final stars = wrongAnswers == 0
        ? 3
        : (wrongAnswers == 1 ? 2 : (wrongAnswers >= 3 ? 1 : 2));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isPass) {
        final pointsEarned = 100 + (stars * 50);
        context.read<UserProvider>().addPoints(pointsEarned);
      }
      _showFullScreenAd(context);
    });

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: GlassPanel(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const _PulseIcon(
                icon: Icons.emoji_events,
                color: Color(0xFF6A37D4),
              ),
              const SizedBox(height: 12),
              Text(
                isPass ? 'Quiz Pass' : 'Quiz Fail',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: isPass
                      ? const Color(0xFF1B8F3A)
                      : const Color(0xFFE53935),
                ),
              ),
              if (!isPass)
                const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Text(
                    'Quiz failed. Try again.',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFE53935),
                    ),
                  ),
                ),
              const SizedBox(height: 10),
              SizedBox(
                height: 130,
                width: 130,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: percentage / 100,
                      strokeWidth: 10,
                      backgroundColor: const Color(0xFFE8D8FF),
                      color: isPass
                          ? const Color(0xFF1B8F3A)
                          : const Color(0xFFE53935),
                    ),
                    Text(
                      '$percentage%',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Number received: $score/$total',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              TweenAnimationBuilder<int>(
                tween: IntTween(begin: 1000, end: points),
                duration: const Duration(milliseconds: 1000),
                builder: (context, value, child) {
                  return Text(
                    'Points: $value',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  3,
                  (index) => Icon(
                    index < stars ? Icons.star : Icons.star_border,
                    color: index < stars
                        ? const Color(0xFFFFB300)
                        : const Color(0xFFB8A57A),
                    size: 30,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: onPlayAgain,
                  child: const Text('Play Again'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _showFullScreenAd(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      Future.delayed(const Duration(seconds: 3), () {
        if (context.mounted) Navigator.of(context).pop();
      });
      return Dialog(
        insetPadding: EdgeInsets.zero,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF6A37D4),
                const Color(0xFFB00D6A),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.celebration,
                size: 100,
                color: Colors.white,
              ),
              const SizedBox(height: 24),
              const Text(
                'Congratulations!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Quiz Completed Successfully',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 32),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              const SizedBox(height: 16),
              const Text(
                'Closing in 3s...',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _PulseIcon extends StatefulWidget {
  const _PulseIcon({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  State<_PulseIcon> createState() => _PulseIconState();
}

class _PulseIconState extends State<_PulseIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
    _scale = Tween<double>(
      begin: 0.9,
      end: 1.1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Icon(widget.icon, size: 72, color: widget.color),
    );
  }
}
