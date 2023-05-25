import 'package:flutter/material.dart';

class Answer extends StatelessWidget {
  final VoidCallback selectHandler;
  final String answerText;

  const Answer(this.selectHandler, this.answerText, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      child: SizedBox(
        width: 250,
        //height: 20,
        child: Text(
          answerText,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.w400,
            color: Color.fromARGB(255, 255, 255, 255),
          ),
        ),
      ),
      style: ButtonStyle(
          elevation: MaterialStateProperty.all(9),
          shadowColor:
              MaterialStateProperty.all(Color.fromARGB(99, 255, 248, 34)),
          backgroundColor: MaterialStateProperty.all(
              const Color.fromARGB(255, 19, 107, 101))),
      onPressed: selectHandler,
    );
  }
}
