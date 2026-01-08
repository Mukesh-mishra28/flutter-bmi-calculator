import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WidgetButton extends StatelessWidget {
  final String btnName;
  final Icon? icon;
  final Color? bgColor;
  final TextStyle? textStyle;
  final VoidCallback? callBack;

  WidgetButton({
    required this.btnName,
    this.icon,
    this.bgColor = Colors.indigoAccent,
    this.textStyle,
    this.callBack,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        callBack!();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        shadowColor: bgColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(50),
          )
        )
      ),
      child: icon != null
          ? Row(
        mainAxisAlignment: MainAxisAlignment.center,
              children: [
                icon!,
                Container(
                  width: 11,
                ),
                Text(btnName, style: textStyle),
              ],
            )
          : Text(btnName,
          style: textStyle),
    );
  }
}
