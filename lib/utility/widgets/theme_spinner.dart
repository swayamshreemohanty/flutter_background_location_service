import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ThemeSpinner extends StatelessWidget {
  final Color? color;
  final double size;
  final double? height;
  final double? width;

  const ThemeSpinner({
    Key? key,
    this.color,
    this.size = 25,
    this.height,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: SpinKitCircle(
        color: color ?? Colors.red,
        size: size,
      ),
    );
  }
}
