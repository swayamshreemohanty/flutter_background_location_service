import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  final Color? color;
  final double strokeWidth;
  const LoadingIndicator({
    Key? key,
    this.color,
    this.strokeWidth = 4,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Center(
        child: CircularProgressIndicator(
          color: color ?? Colors.red,
          strokeWidth: strokeWidth,
        ),
      );
}
