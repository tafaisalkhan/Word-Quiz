import '../../models/word_mode.dart';
import 'mode_screen.dart';
import 'shared_mode_quiz.dart';

class CompleteWordScreen extends ModeScreen {
  const CompleteWordScreen({super.key})
    : super(
        mode: WordMode.completeWord,
        body: const ModeQuizBody(
          mode: WordMode.completeWord,
          modeWord: 'CompleteWord',
          prompt: 'Choose the right completion',
          answerStyle: ModeAnswerStyle.sliderPick,
        ),
      );
}
