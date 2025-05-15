import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomButton extends StatelessWidget {
  final double hg;
  final double wg;
  final VoidCallback onpressed;
  final String display;
  const CustomButton({
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
          color: Color(0xFFE1FF8A),
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
            style: GoogleFonts.lato(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
