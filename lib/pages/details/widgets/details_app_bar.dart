import 'package:flutter/material.dart';

class DetailsAppBar extends StatelessWidget {
  const DetailsAppBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: () => Navigator.pop(context),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: const Icon(
                Icons.arrow_back,
                size: 25,
              ),
            ),
          ),
        ),
        const Text(
          "Details",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.3,
          ),
        ),
        AnimatedScale(
          scale: 1.0,
          duration: const Duration(milliseconds: 200),
          child: Image.asset(
            "assets/images/basket.png",
            width: 28,
          ),
        ),
      ],
    );
  }
}