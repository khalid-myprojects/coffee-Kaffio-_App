import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:starbucks/model/product_model.dart';
import 'package:starbucks/pages/details/details_page.dart';
import 'package:starbucks/pages/home/widgets/categories_widget.dart';
import 'package:starbucks/pages/home/widgets/home_app_bar.dart';
import 'package:starbucks/widgets/top_oval_clipper.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final PageController _textSlideController = PageController();
  final PageController _imageSlideController = PageController(
    viewportFraction: 0.52,
  );

  late final AnimationController _glowController;

  final List<ProductModel> products = [
    ProductModel(
        name: "Caramel Crunch Frappuccino",
        price: 26.90,
        image: "assets/images/products/caramel_crunch_frappuccino.png"),
    ProductModel(
        name: "Vanilla Bean Frappuccino",
        price: 21.50,
        image: "assets/images/products/vanilla_bean_frappuccino.png"),
    ProductModel(
        name: "Matcha Green Tea Frappuccino",
        price: 19.75,
        image: "assets/images/products/matcha_green_tea.png"),
    ProductModel(
        name: "Mocha Fudge Frappuccino",
        price: 31.25,
        image: "assets/images/products/mocha_fudge_frappuccino.png"),
    ProductModel(
        name: "Classic Vanilla Milkshake",
        price: 16.00,
        image: "assets/images/products/classic_vanilla_milkshake.png"),
  ];

  // Har product ka apna background aur accent color - image ke theme
  // ke sath match karta hua.
  final List<Color> productColors = [
    const Color(0xFFB8763A), // Caramel Crunch - caramel amber
    const Color(0xFFD4A65A), // Vanilla Bean - soft golden tan
    const Color(0xFF6FA84B), // Matcha Green Tea - fresh matcha green
    const Color(0xFF5A3E2B), // Mocha Fudge - deep chocolate brown
    const Color(0xFFE29AAE), // Classic Milkshake - soft cherry pink
  ];

  final List<String> productTags = [
    "Fan Favorite",
    "Smooth & Creamy",
    "Fresh Pick",
    "Rich & Bold",
    "Sweet Classic",
  ];

  @override
  void initState() {
    super.initState();

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    // Post-frame callback se ensure hota hai ke PageView pehle attach ho
    // chuka ho, uske baad hi hum animateToPage call karte hain.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (!mounted) return;
        if (_imageSlideController.hasClients) {
          _imageSlideController.animateToPage(1,
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeInOutCubic);
        }
      });
    });
  }

  @override
  void dispose() {
    _imageSlideController.dispose();
    _textSlideController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  Color _currentBackgroundColor() {
    // hasClients check zaroori hai warna controller ke kisi PageView se
    // attach hone se pehle .position access karne par assertion crash hota hai.
    if (!_imageSlideController.hasClients ||
        !_imageSlideController.position.haveDimensions) {
      return productColors[1];
    }
    final page = _imageSlideController.page ?? 1.0;
    final lower = page.floor().clamp(0, products.length - 1);
    final upper = page.ceil().clamp(0, products.length - 1);
    final t = page - page.floor();
    return Color.lerp(
      productColors[lower],
      productColors[upper],
      t,
    ) ??
        productColors[lower];
  }

  int _currentNearestIndex() {
    if (!_imageSlideController.hasClients ||
        !_imageSlideController.position.haveDimensions) {
      return 1;
    }
    final page = _imageSlideController.page ?? 1.0;
    return page.round().clamp(0, products.length - 1);
  }

  // Smooth shared-element navigation: sirf fade transition use hoti hai
  // taake Hero animation (jo product card se DetailsPage tak image ko fly
  // karati hai) hi poori tarah "hero" bane. Extra slide/scale add karne se
  // Hero k sath double-motion lagta hai isliye yahan sirf fade rakha gaya hai.
  void _openDetails(BuildContext context, ProductModel product) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 1000),
        reverseTransitionDuration: const Duration(milliseconds: 1000),
        pageBuilder: (context, animation, secondaryAnimation) =>
            DetailsPage(product: product),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOutCubic,
            reverseCurve: Curves.easeInOutCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    // Cards aur images ka size increase kiya gaya hai.
    final cardSize = (screenWidth * 0.82).clamp(260.0, 340.0);
    final circleSize = cardSize * 0.72;
    final isSmallScreen = screenHeight < 700;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const HomeAppBar(), // Appbar Widget
            Padding(
              padding: const EdgeInsets.only(left: 24, right: 16, top: 12),
              child: SizedBox(
                width: screenWidth * 0.78,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Your Daily Dose\nof Delight",
                    maxLines: 2,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 30 : 34,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.2,
                      height: 1.15,
                      color: Colors.black.withOpacity(0.87),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 24, right: 16),
              child: Text(
                "Handcrafted drinks, made just for you",
                style: TextStyle(
                  fontSize: 17,
                  color: Colors.black.withOpacity(0.68),
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.15,
                  height: 1.25,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ClipPath(
                clipper: TopOvalClipper(),
                child: AnimatedBuilder(
                  animation:
                  Listenable.merge([_imageSlideController, _glowController]),
                  builder: (context, child) {
                    final bgColor = _currentBackgroundColor();
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: screenWidth,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            bgColor,
                            Color.lerp(bgColor, Colors.black, 0.15) ??
                                bgColor,
                          ],
                        ),
                      ),
                      child: Stack(
                        children: [
                          // ---- Decorative advanced background layer ----
                          Positioned(
                            top: -40 + (10 * _glowController.value),
                            right: -50,
                            child: Container(
                              width: 160,
                              height: 160,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(
                                    0.07 + 0.03 * _glowController.value),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 90 - (14 * _glowController.value),
                            left: -60,
                            child: Container(
                              width: 130,
                              height: 130,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.05),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 40,
                            left: 0,
                            right: 0,
                            child: Opacity(
                              opacity: 0.5,
                              child: CustomPaint(
                                size: Size(screenWidth, 60),
                                painter: _DotsPatternPainter(),
                              ),
                            ),
                          ),

                          // Categories widget wrapped with an outer shadow.
                          // NOTE: the chips/text/icons INSIDE this widget
                          // live in categories_widget.dart, which hasn't
                          // been shared, so their own size/border shadow
                          // can't be touched from here without guessing
                          // that file's structure.
                          Container(
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.16),
                                  blurRadius: 22,
                                  spreadRadius: 1,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: const CategoriesWidget(),
                          ), // List of category

                          Positioned(
                            top: 125,
                            bottom: 0,
                            child: ClipPath(
                              clipper: TopOvalClipper(),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                decoration: BoxDecoration(
                                  color: Color.lerp(
                                      bgColor, Colors.black, 0.22) ??
                                      bgColor,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.18),
                                      blurRadius: 20,
                                      offset: const Offset(0, -6),
                                    ),
                                  ],
                                ),
                                width: screenWidth,
                              ),
                            ),
                          ),

                          // Small "tag" badge for the centered product
                          Positioned(
                            top: 180,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: Container(
                                  key: ValueKey(_currentNearestIndex()),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.22),
                                    borderRadius: BorderRadius.circular(30),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.45),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.12),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    productTags[_currentNearestIndex()],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          Positioned(
                            top: 172,
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: PageView.builder(
                              itemCount: products.length,
                              controller: _imageSlideController,
                              physics: const BouncingScrollPhysics(),
                              onPageChanged: (page) {
                                _textSlideController.animateToPage(page,
                                    duration:
                                    const Duration(milliseconds: 800),
                                    curve: Curves.easeInOutCubic);
                              },
                              itemBuilder: (context, index) {
                                double value = 0.0;

                                if (_imageSlideController.hasClients &&
                                    _imageSlideController
                                        .position.haveDimensions) {
                                  value = index.toDouble() -
                                      (_imageSlideController.page ?? 0);
                                  value = (value * 0.7).clamp(-1, 1);
                                }

                                final scale = 1 - (value.abs() * 0.12);
                                final opacity =
                                (1 - value.abs() * 0.5).clamp(0.4, 1.0);

                                return Align(
                                  alignment: Alignment.topCenter,
                                  child: Transform.translate(
                                    offset: Offset(
                                        0, 34 + (value.abs() * 190)),
                                    child: Opacity(
                                      opacity: opacity,
                                      child: Transform.scale(
                                        scale: scale,
                                        child: _ProductCard(
                                          product: products[index],
                                          color: productColors[index],
                                          cardSize: cardSize,
                                          circleSize: circleSize,
                                          tiltValue: value,
                                          onTap: () => _openDetails(
                                              context, products[index]),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          Positioned(
                            bottom: 14,
                            left: 48,
                            right: 48,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  height: 104,
                                  child: PageView.builder(
                                    itemCount: products.length,
                                    controller: _textSlideController,
                                    scrollDirection: Axis.vertical,
                                    physics:
                                    const NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      return Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        children: [
                                          FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Text(
                                              products[index].name,
                                              textAlign: TextAlign.center,
                                              maxLines: 2,
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  height: 1.15,
                                                  color: Colors.white,
                                                  fontWeight:
                                                  FontWeight.w800,
                                                  shadows: [
                                                    Shadow(
                                                      color: Colors.black
                                                          .withOpacity(0.35),
                                                      blurRadius: 8,
                                                      offset:
                                                      const Offset(0, 2),
                                                    ),
                                                  ]),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 8,
                                          ),
                                          FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Container(
                                              padding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 14,
                                                  vertical: 5),
                                              decoration: BoxDecoration(
                                                color: Colors.white
                                                    .withOpacity(0.2),
                                                borderRadius:
                                                BorderRadius.circular(20),
                                              ),
                                              child: Text(
                                                "Rs. ${products[index % products.length].price.toStringAsFixed(2)}",
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                    fontSize: 17,
                                                    color: Colors.white,
                                                    fontWeight:
                                                    FontWeight.w800),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SmoothPageIndicator(
                                  controller: _imageSlideController,
                                  count: products.length,
                                  effect: ScrollingDotsEffect(
                                      spacing: 15.0,
                                      radius: 8.0,
                                      fixedCenter: true,
                                      dotWidth: 6.0,
                                      dotHeight: 6.0,
                                      activeDotScale: 3,
                                      dotColor: Colors.white.withOpacity(0.4),
                                      activeDotColor: Colors.white),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Chhota decorative dotted pattern jo background mein depth add karta hai.
class _DotsPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.25)
      ..style = PaintingStyle.fill;

    const spacing = 18.0;
    for (double x = 10; x < size.width; x += spacing) {
      canvas.drawCircle(const Offset(0, 6) + Offset(x, 0), 1.4, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Advanced 3D Product Card:
/// - `tiltValue` (-1..1, distance from center page) drives a real 3D
///   perspective rotation as the user swipes, so cards tilt like they're
///   sitting on a turntable.
/// - The circle behind the product uses multi-layer, color-matched shadows
///   (a soft colored glow + a darker depth shadow) instead of plain black,
///   so every product's glow matches its own theme color.
/// - A slow floating/breathing loop keeps the card subtly alive even when
///   the user isn't touching it.
/// - Tapping triggers a smooth elastic 3D flip-bounce before navigating.
class _ProductCard extends StatefulWidget {
  const _ProductCard({
    required this.product,
    required this.color,
    required this.cardSize,
    required this.circleSize,
    required this.onTap,
    this.tiltValue = 0.0,
  });

  final ProductModel product;
  final Color color;
  final double cardSize;
  final double circleSize;
  final double tiltValue;
  final VoidCallback onTap;

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard>
    with TickerProviderStateMixin {
  double _pressScale = 1.0;

  // Continuous subtle float + pulse loop.
  late final AnimationController _floatController;
  late final Animation<double> _floatAnimation;

  // One-shot elastic flip-bounce triggered on tap.
  late final AnimationController _flipController;
  late final Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _floatAnimation = CurvedAnimation(
      parent: _floatController,
      curve: Curves.easeInOut,
    );

    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _flipAnimation = CurvedAnimation(
      parent: _flipController,
      curve: Curves.elasticOut,
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    _flipController.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    setState(() => _pressScale = 0.94);
    await _flipController.forward(from: 0);
    setState(() => _pressScale = 1.0);
    if (mounted) widget.onTap();
    _flipController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    // Depth factor: 0 = fully centered/flat, 1 = fully at the edge.
    final depth = widget.tiltValue.abs();
    final swipeTilt = widget.tiltValue * 0.55; // radians-ish, kept gentle

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressScale = 0.94),
      onTapCancel: () => setState(() => _pressScale = 1.0),
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([_floatAnimation, _flipAnimation]),
        builder: (context, child) {
          // Gentle up/down bob so the card feels alive at rest.
          final bob = math.sin(_floatAnimation.value * math.pi) * 4.0;
          // Extra flip rotation layered on top of the swipe tilt on tap.
          final flipRotation = _flipAnimation.value * (2 * math.pi) * 0.06;

          final matrix = Matrix4.identity()
            ..setEntry(3, 2, 0.0016) // perspective
            ..rotateX(0.06 * depth)
            ..rotateY(swipeTilt + flipRotation);

          return Transform(
            alignment: Alignment.center,
            transform: matrix,
            child: Transform.translate(
              offset: Offset(0, bob),
              child: AnimatedScale(
                scale: _pressScale,
                duration: const Duration(milliseconds: 120),
                curve: Curves.easeOut,
                child: child,
              ),
            ),
          );
        },
        child: SizedBox(
          width: widget.cardSize,
          height: widget.cardSize,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              // ---- Outer soft colored glow (ambient light spill) ----
              Container(
                width: widget.circleSize + 30,
                height: widget.circleSize + 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: widget.color.withOpacity(0.5),
                      blurRadius: 48,
                      spreadRadius: 4,
                      offset: const Offset(0, 20),
                    ),
                  ],
                ),
              ),
              // ---- Main 3D circle: gradient body + color-matched shadow ----
              Container(
                width: widget.circleSize,
                height: widget.circleSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    center: const Alignment(-0.3, -0.35),
                    radius: 0.95,
                    colors: [
                      Color.lerp(widget.color, Colors.white, 0.32) ??
                          widget.color,
                      widget.color,
                      Color.lerp(widget.color, Colors.black, 0.28) ??
                          widget.color,
                    ],
                    stops: const [0.0, 0.55, 1.0],
                  ),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.4),
                    width: 1.6,
                  ),
                  boxShadow: [
                    // Depth shadow, tinted by the product's own color.
                    BoxShadow(
                      color: Color.lerp(widget.color, Colors.black, 0.55)!
                          .withOpacity(0.6),
                      blurRadius: 28,
                      spreadRadius: -1,
                      offset: const Offset(0, 16),
                    ),
                    // Soft close-contact colored shadow for a glossy 3D pop.
                    BoxShadow(
                      color: widget.color.withOpacity(0.6),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                    // Subtle inner-feeling highlight shadow (top-left light).
                    BoxShadow(
                      color: Colors.white.withOpacity(0.18),
                      blurRadius: 10,
                      spreadRadius: -6,
                      offset: const Offset(-6, -6),
                    ),
                  ],
                ),
                child: Align(
                  alignment: const Alignment(-0.35, -0.4),
                  child: Container(
                    width: widget.circleSize * 0.4,
                    height: widget.circleSize * 0.22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.16),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 4,
                top: 0,
                // Product image ka size increase kiya gaya hai.
                child: Hero(
                  tag: widget.product.name,
                  child: Image.asset(
                    widget.product.image,
                    fit: BoxFit.contain,
                    height: 300,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}