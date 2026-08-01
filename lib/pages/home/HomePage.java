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
    // Post-frame callback se ensure hota hai ke PageView pehle attach ho
    // chuka ho, uske baad hi hum animateToPage call karte hain.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (!mounted) return;
        if (_imageSlideController.hasClients) {
          _imageSlideController.animateToPage(1,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOutCubic);
        }
      });
    });
  }

  @override
  void dispose() {
    _imageSlideController.dispose();
    _textSlideController.dispose();
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final cardSize = (screenWidth * 0.72).clamp(230.0, 300.0);
    final circleSize = cardSize * 0.64;
    final isSmallScreen = screenHeight < 700;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const HomeAppBar(), // Appbar Widget
            Padding(
              padding: const EdgeInsets.only(left: 24, right: 16, top: 10),
              child: SizedBox(
                width: screenWidth * 0.72,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Your Daily Dose\nof Delight",
                    maxLines: 2,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 28 : 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.2,
                      height: 1.15,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 24),
              child: Text(
                "Handcrafted drinks, made just for you",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ClipPath(
                clipper: TopOvalClipper(),
                child: AnimatedBuilder(
                  animation: _imageSlideController,
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
                          const CategoriesWidget(), // List of category
                          Positioned(
                            top: 125,
                            bottom: 0,
                            child: ClipPath(
                              clipper: TopOvalClipper(),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                color: Color.lerp(
                                        bgColor, Colors.black, 0.22) ??
                                    bgColor,
                                width: screenWidth,
                              ),
                            ),
                          ),

                          // Small "tag" badge for the centered product
                          Positioned(
                            top: 140,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: Container(
                                  key: ValueKey(_currentNearestIndex()),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.18),
                                    borderRadius: BorderRadius.circular(30),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.35),
                                    ),
                                  ),
                                  child: Text(
                                    productTags[_currentNearestIndex()],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.4,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          Positioned(
                            top: 168,
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
                                        const Duration(milliseconds: 350),
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
                                        0, 40 + (value.abs() * 190)),
                                    child: Opacity(
                                      opacity: opacity,
                                      child: Transform.scale(
                                        scale: scale,
                                        child: _ProductCard(
                                          product: products[index],
                                          color: productColors[index],
                                          cardSize: cardSize,
                                          circleSize: circleSize,
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      DetailsPage(
                                                        product:
                                                            products[index],
                                                      )),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          Positioned(
                            bottom: 12,
                            left: 60,
                            right: 60,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  height: 96,
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
                                              style: const TextStyle(
                                                  fontSize: 18,
                                                  height: 1.15,
                                                  color: Colors.white,
                                                  fontWeight:
                                                      FontWeight.w600),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 6,
                                          ),
                                          FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Text(
                                              "Rs. ${products[index % products.length].price.toStringAsFixed(2)}",
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.white,
                                                  fontWeight:
                                                      FontWeight.w700),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 6),
                                SmoothPageIndicator(
                                  controller: _imageSlideController,
                                  count: products.length,
                                  effect: ScrollingDotsEffect(
                                      spacing: 15.0,
                                      radius: 8.0,
                                      fixedCenter: true,
                                      dotWidth: 5.0,
                                      dotHeight: 5.0,
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

class _ProductCard extends StatefulWidget {
  const _ProductCard({
    required this.product,
    required this.color,
    required this.cardSize,
    required this.circleSize,
    required this.onTap,
  });

  final ProductModel product;
  final Color color;
  final double cardSize;
  final double circleSize;
  final VoidCallback onTap;

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> {
  double _pressScale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressScale = 0.94),
      onTapUp: (_) {
        setState(() => _pressScale = 1.0);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressScale = 1.0),
      child: AnimatedScale(
        scale: _pressScale,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: SizedBox(
          width: widget.cardSize,
          height: widget.cardSize,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                width: widget.circleSize,
                height: widget.circleSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Color.lerp(widget.color, Colors.white, 0.18) ??
                          widget.color,
                      widget.color,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 6,
                top: 0,
                child: Hero(
                  tag: widget.product.name,
                  child: Image.asset(
                    widget.product.image,
                    fit: BoxFit.contain,
                    height: 130,
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