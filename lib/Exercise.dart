import 'package:flutter/material.dart';

class Exercise extends StatefulWidget {
  String title;
  String exerciseExplanation;
  Function pathToVideoSetter;

  Exercise(
      {super.key,
      required this.title,
      required this.exerciseExplanation,
      required this.pathToVideoSetter});

  @override
  State<Exercise> createState() => _ExerciseState();
}

class _ExerciseState extends State<Exercise> {
  late var isEmpty = true;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(widget.exerciseExplanation),
        IconButton(
          iconSize: 40,
          icon: const Icon(
            Icons.video_camera_back_outlined,
          ),
          tooltip: 'Record',
          onPressed: () {
            widget.pathToVideoSetter(widget.title);
          },
        )
      ],
    );
  }
}
