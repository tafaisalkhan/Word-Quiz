import '../../models/word_mode.dart';
import 'mode_screen.dart';
import 'shared_mode_quiz.dart';

class WordSearchScreen extends ModeScreen {
  const WordSearchScreen({super.key})
    : super(
        mode: WordMode.wordSearch,
        body: const ModeQuizBody(
          mode: WordMode.wordSearch,
          modeWord: 'Search',
          prompt: 'Find the hidden word',
          answerStyle: ModeAnswerStyle.hotspotCloud,
        ),
      );
}
