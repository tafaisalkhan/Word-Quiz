import '../../models/word_mode.dart';
import 'mode_screen.dart';
import 'shared_mode_quiz.dart';

class WordConnectScreen extends ModeScreen {
  const WordConnectScreen({super.key})
    : super(
        mode: WordMode.wordConnect,
        body: const ModeQuizBody(
          mode: WordMode.wordConnect,
          modeWord: 'Connect',
          prompt: 'Pick the connected word',
          answerStyle: ModeAnswerStyle.dragDrop,
        ),
      );
}
