import 'package:flutter/material.dart';

class Difficulty extends StatelessWidget {
  final difficultyLeval;

  const Difficulty({required this.difficultyLeval, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.star,
          size: 15,
          color:
              (difficultyLeval >= 1
                  ? Colors.blue
                  : Colors.blue[100]),
        ),
        Icon(
          Icons.star,
          size: 15,
          color:
              (difficultyLeval >= 2
                  ? Colors.blue
                  : Colors.blue[100]),
        ),
        Icon(
          Icons.star,
          size: 15,
          color:
              (difficultyLeval >= 3
                  ? Colors.blue
                  : Colors.blue[100]),
        ),
        Icon(
          Icons.star,
          size: 15,
          color:
              (difficultyLeval >= 4
                  ? Colors.blue
                  : Colors.blue[100]),
        ),
        Icon(
          Icons.star,
          size: 15,
          color:
              (difficultyLeval >= 5
                  ? Colors.blue
                  : Colors.blue[100]),
        ),
      ],
    );
  }
}