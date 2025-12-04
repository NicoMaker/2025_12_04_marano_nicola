class Exercise {
  final String name;
  final int score;
  final DateTime submittedAt;

  Exercise({
    required this.name,
    required this.score,
    required this.submittedAt,
  });

  bool get isPassed => score >= 60;

  @override
  String toString() {
    return 'Exercise(name: $name, score: $score, isPassed: $isPassed)';
  }
}

List<Exercise> passedOnly(List<Exercise> exercises) {
  return exercises.where((e) => e.isPassed).toList();
}

double averageScore(List<Exercise> exercises) {
  if (exercises.isEmpty) {
    return 0.0;
  }

  int totalScore = exercises.fold(0, (sum, e) => sum + e.score);

  return totalScore / exercises.length;
}

String? bestStudent(List<Exercise> exercises) {
  if (exercises.isEmpty) {
    return null;
  }

  Exercise best = exercises.reduce((currentBest, e) {
    return e.score > currentBest.score ? e : currentBest;
  });
  return best.name;
}

void main() {
  final studentExercises = [
    Exercise(
      name: 'Alice',
      score: 85,
      submittedAt: DateTime.now().subtract(Duration(hours: 10)),
    ),
    Exercise(
      name: 'Bob',
      score: 55,
      submittedAt: DateTime.now().subtract(Duration(hours: 8)),
    ),
    Exercise(
      name: 'Charlie',
      score: 92,
      submittedAt: DateTime.now().subtract(Duration(hours: 5)),
    ),
    Exercise(
      name: 'David',
      score: 70,
      submittedAt: DateTime.now().subtract(Duration(hours: 2)),
    ),
    Exercise(
      name: 'Eve',
      score: 40,
      submittedAt: DateTime.now().subtract(Duration(hours: 1)),
    ),
  ];

  print('Esercizi totali:');
  studentExercises.forEach(print);
  print('---');

  final passed = passedOnly(studentExercises);
  print('Esercizi con sufficienza (>= 60):');
  passed.forEach(print);
  print('---');

  final average = averageScore(studentExercises);
  print('Punteggio medio: ${average.toStringAsFixed(2)}');
  print('---');

  final bestName = bestStudent(studentExercises);
  print('Studente con il punteggio più alto: $bestName');
}
