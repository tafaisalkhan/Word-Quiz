import '../../models/word_mode.dart';
import 'mode_screen.dart';
import 'shared_mode_quiz.dart';

class WordSwipeScreen extends ModeScreen {
  const WordSwipeScreen({super.key})
    : super(
        mode: WordMode.wordSwipe,
        body: const ModeQuizBody(
          mode: WordMode.wordSwipe,
          modeWord: 'Swipe',
          prompt: 'Pick the swipe result',
          answerStyle: ModeAnswerStyle.pageSwipeUp,
        ),
      );
}
