class QuizQuestionData {
  const QuizQuestionData({
    required this.prompt,
    required this.answer,
    this.options = const <String>[],
  });

  factory QuizQuestionData.fromJson(Map<String, dynamic> json) {
    return QuizQuestionData(
      prompt: json['prompt'] as String,
      answer: json['answer'] as String,
      options: (json['options'] as List<dynamic>? ?? const <dynamic>[])
          .cast<String>(),
    );
  }

  final String prompt;
  final String answer;
  final List<String> options;

  String get uniqueKey => '$prompt::$answer';
}

class QuizDifficultyPack {
  const QuizDifficultyPack({
    required this.easy,
    required this.medium,
    required this.hard,
  });

  factory QuizDifficultyPack.fromJson(Map<String, dynamic> json) {
    List<QuizQuestionData> parseList(String key) {
      return (json[key] as List<dynamic>? ?? const <dynamic>[])
          .map(
            (item) => QuizQuestionData.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    }

    return QuizDifficultyPack(
      easy: parseList('easy'),
      medium: parseList('medium'),
      hard: parseList('hard'),
    );
  }

  final List<QuizQuestionData> easy;
  final List<QuizQuestionData> medium;
  final List<QuizQuestionData> hard;
}
