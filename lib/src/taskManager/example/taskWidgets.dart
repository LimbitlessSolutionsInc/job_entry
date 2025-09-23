import 'package:flutter/material.dart';

class TaskWidgets{
  static Widget iconNote(IconData icon, String text, TextStyle style, double size){
    return SizedBox(
      child: Row(children: [
        Icon(
          icon,
          size:size,
          color: style.color
        ),
        Text(
          ' $text',
          style: style,
        )
      ],),
    );
  }
}