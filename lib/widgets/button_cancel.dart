import 'package:flutter/material.dart';
import 'package:gbkyc/utils/file_uitility.dart';

//สำหรับปุ่มปฏิเสธทั้งแอป
class ButtonCancel extends StatelessWidget {
  final void Function() onPressed;
  final String text;
  final double width;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

  const ButtonCancel({
    Key? key,
    required this.onPressed,
    required this.text,
    this.width = double.infinity,
    this.padding = EdgeInsets.zero,
    this.margin = EdgeInsets.zero,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      key: Key('ButtonCancel_plugin_${DateTime.now().toString()}'),
      height: 60,
      width: width,
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: MaterialButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
          side: const BorderSide(color: colorGradientDark),
        ),
        onPressed: onPressed,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(text, style: const TextStyle(color: colorGradientDark)),
        ),
      ),
    );
  }
}
