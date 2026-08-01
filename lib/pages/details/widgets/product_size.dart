import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:starbucks/model/size_model.dart';

class ProductSize extends StatelessWidget {
  const ProductSize(
      {super.key,
        required this.isSelected,
        required this.sizes,
        required this.iconSize});

  final bool isSelected;
  final SizeModel sizes;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.9, end: isSelected ? 1.0 : 0.92),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutBack,
          builder: (context, scale, child) {
            return Transform.scale(
              scale: scale,
              child: child,
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: 74,
            height: 74,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context)
                  .primaryColor
                  .withOpacity(isSelected ? 1 : 0.15),
              boxShadow: isSelected
                  ? [
                BoxShadow(
                  color: Theme.of(context).primaryColor.withOpacity(0.35),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ]
                  : [],
            ),
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: SvgPicture.asset(
                    'assets/svg/cup.svg',
                    key: ValueKey(isSelected),
                    width: iconSize + 6,
                    height: iconSize + 6,
                    color: isSelected
                        ? Colors.white
                        : Theme.of(context).primaryColor.withOpacity(0.8),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 250),
          style: TextStyle(
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: Colors.black,
          ),
          child: Text(sizes.name),
        ),
        const SizedBox(height: 2),
        Text(
          sizes.qty,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}