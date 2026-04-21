import '../../models/word_mode.dart';
import 'mode_screen.dart';
import 'shared_mode_quiz.dart';

class SpellingChallengeScreen extends ModeScreen {
  const SpellingChallengeScreen({super.key})
    : super(
        mode: WordMode.spellingChallenge,
        body: const ModeQuizBody(
          mode: WordMode.spellingChallenge,
          modeWord: 'Spelling',
          prompt: 'Pick the correct spelling',
          answerStyle: ModeAnswerStyle.typeToMatch,
        ),
      );
}
