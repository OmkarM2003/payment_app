import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  double hg;
  double wg;
  VoidCallback onpressed;
  String display;
  CustomButton({
    super.key,
    required this.hg,
    required this.wg,
    required this.onpressed,
    required this.display,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onpressed,
      child: Container(
        padding: EdgeInsets.all(8),
        height: hg,
        width: wg,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: Color(0xFF720D5D),
          boxShadow: [
            BoxShadow(
              spreadRadius: 2,
              blurRadius: 5,
              color: Colors.black,
              offset: Offset(5, 5),
            ),
          ],
        ),
        child: Center(
          child: Text(
            display,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
