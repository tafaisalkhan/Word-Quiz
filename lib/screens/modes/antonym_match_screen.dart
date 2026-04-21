import '../../models/word_mode.dart';
import 'mode_screen.dart';
import 'shared_mode_quiz.dart';

class AntonymMatchScreen extends ModeScreen {
  const AntonymMatchScreen({super.key})
    : super(
        mode: WordMode.antonymMatch,
        body: const ModeQuizBody(
          mode: WordMode.antonymMatch,
          modeWord: 'Antonym',
          prompt: 'Find the antonym',
          answerStyle: ModeAnswerStyle.longPressSelect,
        ),
      );
}
