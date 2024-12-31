import 'package:flutter/material.dart';

class MySeparator extends StatelessWidget {
  const MySeparator({Key? key, this.height = 1, this.color = Colors.black})
      : super(key: key);
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(100~/10, (index) => Expanded(
        child: Container(
          width: 2,

          color: index%2==0?Colors.transparent
              : color,
        ),
      )),
    );
  }
}