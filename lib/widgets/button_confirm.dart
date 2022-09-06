import 'package:flutter/material.dart';

//สำหรับปุ่มตกลงทั้งแอป
class ButtonConfirm extends StatelessWidget {
  final void Function() onPressed;
  final String text;
  final double radius;
  final double width;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final Color? colorText;
  final Color? colorDisableText;
  final bool enable;

  const ButtonConfirm({
    Key? key,
    required this.onPressed,
    required this.text,
    this.radius = 30,
    this.width = double.infinity,
    this.padding = EdgeInsets.zero,
    this.margin = EdgeInsets.zero,
    this.colorText,
    this.colorDisableText = Colors.black,
    this.enable = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      width: width,
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: enable
            ? const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF115899),
                  Color(0xFF02416D),
                ],
              )
            : const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromARGB(255, 233, 233, 233),
                  Color.fromARGB(255, 197, 197, 197),
                ],
              ),
      ),
      child: MaterialButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
        onPressed: enable ? onPressed : null,
        child: FittedBox(fit: BoxFit.scaleDown, child: Text(text, style: TextStyle(color: enable ? colorText : colorDisableText))),
      ),
    );
  }
}
