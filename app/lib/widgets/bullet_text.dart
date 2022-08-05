import 'package:flutter/material.dart';

class BulletText extends StatelessWidget {
  final String txt;

  BulletText(this.txt);

  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('\u2022'),
        SizedBox(width: 5),
        Expanded(child: Text(txt))
      ],
    );
  }
}
