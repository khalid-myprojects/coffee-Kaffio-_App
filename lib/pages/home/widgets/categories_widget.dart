import 'package:flutter/material.dart';
import 'package:starbucks/model/category_nodel.dart';

class CategoriesWidget extends StatefulWidget {
  const CategoriesWidget({super.key});

  @override
  State<CategoriesWidget> createState() => _CategoriesWidgetState();
}

class _CategoriesWidgetState extends State<CategoriesWidget>
    with SingleTickerProviderStateMixin {
  final List<CategoryModel> categories = [
    CategoryModel(name: "HOT COFFEE", icon: "assets/images/coffee.png"),
    CategoryModel(name: "DRINKS", icon: "assets/images/drinks.png"),
    CategoryModel(name: "HOT TEAS", icon: "assets/images/tea.png"),
    CategoryModel(name: "BAKERY", icon: "assets/images/bakery.png"),
  ];

  int selectedIndex = 0;
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return SizedBox(
      width: width,
      // Widget ko top se aur bara kiya gaya hai (214 -> 230) taake circles
      // aur unki shadows kabhi bhi widget ke bilkul top edge se na takrayein.
      height: 230,
      child: Padding(
        // Poori category row ko top se 15px neechay shift kar diya - yehi
        // woh extra top space hai jo circles/shadows ko safe rakhta hai
        // aur unhe bahar jaane/cut hone se rokta hai.
        padding: const EdgeInsets.only(top: 15),
        child: Stack(
          children: [
            for (var i = 0; i < categories.length; i++)
              Positioned(
                // Base top value (110 -> 100) taake bare circles hone ke
                // bawajood row uper wali lighter background zone mein hi
                // rahe - isi se text/icon mazeed clearly visible hote hain.
                top: categories.length / 2 > i
                    ? 100 - (i * 33)
                    : 100 - ((categories.length - 1 - i) * 33),
                left: (i * width) / categories.length,
                child: SizedBox(
                  width: width / categories.length,
                  // Bare circle + bold text ke liye extra height, taake
                  // overflow na ho.
                  height: 108,
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      final start = (i * 0.1).clamp(0.0, 1.0);
                      final end = (start + 0.5).clamp(0.0, 1.0);
                      final animValue = CurvedAnimation(
                        parent: _controller,
                        curve:
                        Interval(start, end, curve: Curves.easeOutBack),
                      ).value;
                      return Opacity(
                        opacity: animValue.clamp(0.0, 1.0),
                        child: Transform.translate(
                          offset: Offset(0, 25 * (1 - animValue)),
                          child: child,
                        ),
                      );
                    },
                    child: _CategoryItem(
                      category: categories[i],
                      isSelected: selectedIndex == i,
                      onTap: () => setState(() => selectedIndex = i),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CategoryItem extends StatefulWidget {
  const _CategoryItem({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  final CategoryModel category;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<_CategoryItem> createState() => _CategoryItemState();
}

class _CategoryItemState extends State<_CategoryItem> {
  double _scale = 1.0;

  void _setScale(double value) => setState(() => _scale = value);

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;

    return GestureDetector(
      onTapDown: (_) => _setScale(0.88),
      onTapUp: (_) {
        _setScale(1.0);
        widget.onTap();
      },
      onTapCancel: () => _setScale(1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              // Circle size bara kiya gaya hai (62/66 -> 70/76) taake
              // icons zyada bare aur clear dikhein.
              width: widget.isSelected ? 76 : 70,
              height: widget.isSelected ? 76 : 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                // Selected hone par accent-colored ring border, warna
                // subtle white ring - dono border pr apna shadow dete hain.
                border: Border.all(
                  color: widget.isSelected
                      ? primary.withOpacity(0.55)
                      : Colors.white.withOpacity(0.9),
                  width: widget.isSelected ? 2.4 : 1.6,
                ),
                boxShadow: [
                  // Depth shadow neechay ki taraf.
                  BoxShadow(
                    color: Colors.black
                        .withOpacity(widget.isSelected ? 0.30 : 0.16),
                    blurRadius: widget.isSelected ? 20 : 12,
                    spreadRadius: widget.isSelected ? 1 : 0,
                    offset: const Offset(0, 7),
                  ),
                  // Ambient glow widget k bilkul top/upar wali taraf - ab
                  // aur zyada prominent, taake border/edge clearly define ho.
                  BoxShadow(
                    color: (widget.isSelected ? primary : Colors.white)
                        .withOpacity(widget.isSelected ? 0.45 : 0.5),
                    blurRadius: 16,
                    spreadRadius: -1,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Center(
                child: Image.asset(
                  widget.category.icon,
                  // Icon size bara kiya gaya hai (36/40 -> 44/50).
                  width: widget.isSelected ? 50 : 44,
                ),
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 250),
              style: TextStyle(
                // Text size bara kiya gaya hai (9.5/10.5 -> 11.5/13) aur
                // drop-shadow add ki hai taake har background par (light
                // ya dark oval dono jagah) text fully visible rahe.
                fontSize: widget.isSelected ? 13 : 11.5,
                color: Colors.white,
                fontWeight:
                widget.isSelected ? FontWeight.w900 : FontWeight.bold,
                letterSpacing: 0.3,
                shadows: const [
                  Shadow(
                    color: Colors.black45,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                widget.category.name,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}