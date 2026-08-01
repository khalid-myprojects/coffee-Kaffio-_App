import 'package:flutter/material.dart';
import 'package:starbucks/styles.dart';

class HomeAppBar extends StatefulWidget {
  const HomeAppBar({
    super.key,
  });

  @override
  State<HomeAppBar> createState() => _HomeAppBarState();
}

class _HomeAppBarState extends State<HomeAppBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  double _basketScale = 1.0;
  double _cupScale = 1.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(-0.2, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          FadeTransition(
            opacity: _fade,
            child: SlideTransition(
              position: _slide,
              child: Row(
                children: [
                  // ---- Cup icon inside a 3D gradient badge ----
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.6, end: 1.0),
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.elasticOut,
                    builder: (context, scale, child) {
                      return Transform.scale(scale: scale, child: child);
                    },
                    child: GestureDetector(
                      onTapDown: (_) => setState(() => _cupScale = 0.88),
                      onTapUp: (_) => setState(() => _cupScale = 1.0),
                      onTapCancel: () => setState(() => _cupScale = 1.0),
                      child: AnimatedScale(
                        scale: _cupScale,
                        duration: const Duration(milliseconds: 120),
                        curve: Curves.easeOut,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                Color.lerp(primary, Colors.white, 0.35) ??
                                    primary,
                                primary,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: primary.withOpacity(0.45),
                                blurRadius: 14,
                                spreadRadius: 1,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Image.asset(
                            "assets/images/cup.png",
                            width: 26,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ---- Brand name: bigger, bolder, gradient-shaded ----
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [
                            primary,
                            Color.lerp(primary, Colors.black, 0.35) ??
                                primary,
                          ],
                        ).createShader(bounds),
                        child: const Text(
                          "Brewberry",
                          style: TextStyle(
                            fontSize: 22,
                            fontFamily: Fonts.gilroy,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                            height: 1.05,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Text(
                        "Brew Happiness",
                        style: TextStyle(
                          fontSize: 13,
                          fontFamily: Fonts.gilroy,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                          color: Colors.black.withOpacity(0.55),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // ---- Basket icon inside a soft-shadow 3D card ----
          GestureDetector(
            onTapDown: (_) => setState(() => _basketScale = 0.85),
            onTapUp: (_) => setState(() => _basketScale = 1.0),
            onTapCancel: () => setState(() => _basketScale = 1.0),
            child: AnimatedScale(
              scale: _basketScale,
              duration: const Duration(milliseconds: 120),
              curve: Curves.easeOut,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: primary.withOpacity(0.15)),
                  boxShadow: [
                    BoxShadow(
                      color: primary.withOpacity(0.25),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Image.asset(
                  "assets/images/basket.png",
                  width: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}