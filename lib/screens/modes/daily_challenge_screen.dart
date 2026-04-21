import '../../models/word_mode.dart';
import 'mode_screen.dart';
import 'shared_mode_quiz.dart';

class DailyChallengeScreen extends ModeScreen {
  const DailyChallengeScreen({super.key})
    : super(
        mode: WordMode.dailyChallenge,
        body: const ModeQuizBody(
          mode: WordMode.dailyChallenge,
          modeWord: 'DailyChallenge',
          prompt: 'Solve today\'s challenge',
          answerStyle: ModeAnswerStyle.tapReveal,
        ),
      );
}
