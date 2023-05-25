import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sub_part_2/answer.dart';
import './question.dart';
import 'package:hexcolor/hexcolor.dart';

class Result extends StatelessWidget {
  final double resultScore;
  final VoidCallback resetHandler;

  const Result(this.resultScore, this.resetHandler, {Key? key})
      : super(key: key);

  String get resultPhrase {
    String resultText;
    final score = num.parse(resultScore.toStringAsFixed(2));

    if (score > 0.00 && score <= 20.00) {
      resultText =
          '🙈Oops! You\'ve tried your best, but your score is only $score. Keep practicing and aim for a higher score next time!';
    } else if (score > 20.00 && score <= 50.00) {
      resultText =
          '👍Nice effort! Your score is $score. You\'re getting there, but there\'s room for improvement. Keep playing and strive for a higher score!';
    } else if (score > 50.00 && score <= 80.00) {
      resultText =
          '😳Great job! Your score is $score. You have a good grasp of the quiz content. Keep up the good work and strive for an even higher score!';
    } else if (score > 80.00 && score <= 90.00) {
      resultText =
          '🙀Excellent performance! You scored $score and came very close to a perfect score. Keep up the amazing work and aim for a perfect score next time';
    } else if (score > 95.00) {
      resultText =
          '🤩🏅Congratulations! You\'ve achieved a perfect score of 100! You\'re a quiz master. Well done!';
    } else {
      resultText = 'Something went wrong, please try again.';
    }

    return resultText;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Align(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: SizedBox(
                width: 360,
                child: Question(
                  resultPhrase,
                ),
              ),
            ),
            ElevatedButton(
              child: SizedBox(
                width: 100,
                child: Text(
                  'Try again',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    color: HexColor("#FEFEFE"),
                  ),
                ),
              ),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(
                  const Color.fromARGB(255, 91, 161, 145),
                ),
              ),
              onPressed: resetHandler,
            ),
          ],
        ),
      ),
    );
  }
}

class Quiz extends StatefulWidget {
  final int catIn;

  const Quiz({
    required this.catIn,
    Key? key,
    required void Function(double score) answerQuestion,
    required int indexQuestion,
    required List data,
  }) : super(key: key);

  @override
  _QuizState createState() => _QuizState();
}

class _QuizState extends State<Quiz> {
  late Future<List<Map<String, Object>>> _questionsFuture;
  int _indexQuestion = 0;
  double _totalScore = 0.0;
  int _killStreak = 0;
  int _timerSeconds = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _questionsFuture = parseJsonResponse(widget.catIn);
    startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerSeconds > 0) {
        setState(() {
          _timerSeconds--;
        });
      } else {
        _timer?.cancel();
        _answerQuestion(0.0); // Time's up, score 0 for this question
      }
    });
  }

  void _answerQuestion(double score) {
    setState(() {
      _indexQuestion++;
      _totalScore += score;
      _timerSeconds = 30;
      _timer?.cancel();
      _killStreak = (score > 0.0) ? _killStreak + 1 : 0;

      // Apply time bonus for kill streak
      if (_killStreak >= 3) {
        _totalScore += (_killStreak * 0.5);
      }
    });
    startTimer();
  }

  void _resetQuiz() {
    setState(() {
      _indexQuestion = 0;
      _totalScore = 0.0;
      _killStreak = 0;
      _timerSeconds = 25;
      _timer?.cancel();
      _questionsFuture = parseJsonResponse(widget.catIn);
    });
    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, Object>>>(
      future: _questionsFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final List<Map<String, Object>> parsedQuestions = snapshot.data!;
          if (_indexQuestion < parsedQuestions.length) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: SizedBox(
                    width: 360,
                    child: Question(
                      parsedQuestions[_indexQuestion]['questionText'] as String,
                    ),
                  ),
                ),
                Text(
                  '⏰Time left: $_timerSeconds seconds',
                  style: const TextStyle(
                    color: Color.fromARGB(255, 255, 255, 255),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ...(parsedQuestions[_indexQuestion]['answers']
                        as List<Map<String, Object>>)
                    .map((answer) {
                  return Answer(
                    () => _answerQuestion(answer['score'] as double),
                    answer['text'] as String,
                  );
                }).toList(),
              ],
            );
          } else {
            return Result(_totalScore, _resetQuiz);
          }
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }
}

List<Map<String, Object>> parseJsonResponseToString(String jsonResponse) {
  final decoded = json.decode(jsonResponse);
  final results = decoded['results'];

  List<Map<String, Object>> parsedQuestions = [];
  for (int i = 0; i < results.length && i < 9; i++) {
    final question = results[i]['question'];
    final correctAnswer = results[i]['correct_answer'];
    final incorrectAnswers = List<String>.from(results[i]['incorrect_answers']);

    final allAnswers = [correctAnswer, ...incorrectAnswers];
    allAnswers.shuffle();

    List<Map<String, Object>> answers = [];
    for (int j = 0; j < allAnswers.length; j++) {
      final answerText = allAnswers[j];
      final score = (answerText == correctAnswer) ? 11.11 : 0.0;
      answers.add({'text': answerText, 'score': score});
    }

    parsedQuestions.add({
      'questionText': question,
      'answers': answers,
    });
  }

  return parsedQuestions;
}

Future<List<Map<String, Object>>> parseJsonResponse(int catIn) async {
  final cat = num.parse(catIn.toStringAsFixed(2));
  var apiUrl = Uri.parse(
      'https://opentdb.com/api.php?amount=9&category=$cat&type=multiple');

  try {
    var response = await http.get(apiUrl);
    if (response.statusCode == 200) {
      String jsonString = response.body;
      return parseJsonResponseToString(jsonString);
    } else {
      throw Exception('Failed to fetch trivia questions');
    }
  } catch (error) {
    throw Exception('Failed to fetch trivia questions');
  }
}
