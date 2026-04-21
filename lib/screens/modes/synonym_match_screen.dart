import '../../models/word_mode.dart';
import 'mode_screen.dart';
import 'shared_mode_quiz.dart';

class SynonymMatchScreen extends ModeScreen {
  const SynonymMatchScreen({super.key})
    : super(
        mode: WordMode.synonymMatch,
        body: const ModeQuizBody(
          mode: WordMode.synonymMatch,
          modeWord: 'Synonym',
          prompt: 'Find the synonym',
          answerStyle: ModeAnswerStyle.pageSwipeUp,
        ),
      );
}
