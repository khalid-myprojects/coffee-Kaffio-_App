import 'package:flutter/material.dart';

class TopOvalClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(0, 130); // Move to the left-middle

    // Do control points ka use kiya (cubic bezier) taake curve zyada
    // smooth aur natural oval shape banaye, ek simple quadratic curve
    // ki nisbat.
    path.cubicTo(
      size.width * 0.25,
      70, // pehla control point - curve ko upar khenchta hai
      size.width * 0.75,
      70, // dusra control point - curve ko symmetric rakhta hai
      size.width,
      130, // end point - right-middle
    );

    path.lineTo(size.width, size.height); // Draw a line to the bottom-right
    path.lineTo(0, size.height); // Draw a line to the bottom-left
    path.close(); // Close the path to complete the clip shape
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}