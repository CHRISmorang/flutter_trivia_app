import "package:flutter/material.dart";
import "package:hexcolor/hexcolor.dart";
import './quiz.dart';
//import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  int catIn = 11;

  //static final _data = parsedQuestions;

  var _indexQuestion = 0;
  double _totalScore = 0.00;

  void _answerQuestion(double score) {
    _totalScore += score;

    setState(() {
      _indexQuestion += 1;
    });
  }

  void _restart() {
    setState(() {
      _indexQuestion = 0;
      _totalScore = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Align(
              alignment: Alignment.center,
              child: Text(
                "Trivia App",
                style: TextStyle(
                  fontSize: 23,
                  fontStyle: FontStyle.normal,
                  color: HexColor("#F5FFF0"),
                ),
              ),
            ),
            backgroundColor: const Color.fromARGB(255, 91, 161, 145),
          ),
          body: Align(
              alignment: Alignment.center,
              child: (_indexQuestion <= 8 && _indexQuestion >= 0)
                  ? Quiz(
                      answerQuestion: _answerQuestion,
                      indexQuestion: _indexQuestion,
                      catIn: 11,
                      data: const [],
                    )
                  : Result(_totalScore, _restart))),
    );
  }
}
