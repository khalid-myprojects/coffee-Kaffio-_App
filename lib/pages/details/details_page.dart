import 'dart:async';

import 'package:flutter/material.dart';
import 'package:starbucks/model/product_model.dart';
import 'package:starbucks/model/size_model.dart';
import 'package:starbucks/pages/details/widgets/details_app_bar.dart';
import 'package:starbucks/pages/details/widgets/product_size.dart';
import 'package:starbucks/widgets/fade_in_down.dart';

class DetailsPage extends StatefulWidget {
  const DetailsPage({Key? key, required this.product}) : super(key: key);

  final ProductModel product;

  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage>
    with TickerProviderStateMixin {
  final List<SizeModel> sizes = [
    SizeModel(name: "Tall", qty: "12 Fl Oz"),
    SizeModel(name: "Grande", qty: "16 Fl Oz"),
    SizeModel(name: "Venti", qty: "24 Fl Oz"),
    SizeModel(name: "Custom", qty: "__ Fl Oz"),
  ];

  int selectedSize = 2;
  int quantity = 1;

  static const int _minQuantity = 1;
  static const int _maxQuantity = 10;

  late final AnimationController _circleController;
  late final Animation<double> _circleScale;

  late final AnimationController _orderBtnController;
  late final Animation<double> _orderBtnScale;

  @override
  void initState() {
    super.initState();

    _circleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _circleScale = CurvedAnimation(
      parent: _circleController,
      curve: Curves.easeOutBack,
    );
    _circleController.forward();

    _orderBtnController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _orderBtnScale = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _orderBtnController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _circleController.dispose();
    _orderBtnController.dispose();
    super.dispose();
  }

  void _incrementQuantity() {
    if (quantity < _maxQuantity) {
      setState(() => quantity++);
    }
  }

  void _decrementQuantity() {
    if (quantity > _minQuantity) {
      setState(() => quantity--);
    }
  }

  Future<void> _handleOrderTap() async {
    await _orderBtnController.forward();
    await _orderBtnController.reverse();

    if (!mounted) return;

    final primary = Theme.of(context).primaryColor;

    // Bara, center-screen animated confirmation card (scale + fade),
    // chote bottom SnackBar ki jagah. Tap kar k ya khud-b-khud
    // thori dair baad band ho jata hai.
    unawaited(showGeneralDialog(
      context: context,
      barrierLabel: "Order confirmed",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.45),
      transitionDuration: const Duration(milliseconds: 450),
      pageBuilder: (context, animation, secondaryAnimation) {
        return const SizedBox.shrink();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
          reverseCurve: Curves.easeIn,
        );
        return Opacity(
          opacity: animation.value.clamp(0.0, 1.0),
          child: Transform.scale(
            scale: curved.value,
            child: _OrderSuccessCard(
              color: primary,
              productName: widget.product.name,
              quantity: quantity,
              sizeName: sizes[selectedSize].name,
            ),
          ),
        );
      },
    ));

    // Dialog khud-b-khud band ho jaye agar user ne khud tap na kiya ho.
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).maybePop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    final totalPrice = widget.product.price * quantity;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F9),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const DetailsAppBar(),
              const SizedBox(height: 16),

              // ---- 3D hero image with glossy gradient circle ----
              SizedBox(
                height: 300,
                width: MediaQuery.of(context).size.width,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    ScaleTransition(
                      scale: _circleScale,
                      child: Container(
                        width: 210,
                        height: 210,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            center: const Alignment(-0.3, -0.35),
                            colors: [
                              Color.lerp(primary, Colors.white, 0.25) ??
                                  primary,
                              primary,
                              Color.lerp(primary, Colors.black, 0.2) ??
                                  primary,
                            ],
                            stops: const [0.0, 0.55, 1.0],
                          ),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.4),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: primary.withOpacity(0.45),
                              blurRadius: 36,
                              spreadRadius: 2,
                              offset: const Offset(0, 18),
                            ),
                            BoxShadow(
                              color: Color.lerp(primary, Colors.black, 0.5)!
                                  .withOpacity(0.35),
                              blurRadius: 22,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // NOTE: Image seedha Hero ka child hai, koi n
                    // entrance-animation (fade/translate) nahi hai
                    // pehle yahan thi lekin Hero ki apni shared-el
                    // flight animation k sath overlap/clash kar ra
                    // jis se transition jerky lagta tha. Ab sir
                    // khud image ko HomePage se yahan tak smoot
                    // aata hai.
                    Positioned(
                      bottom: 5,
                      top: 0,
                      child: Hero(
                        tag: widget.product.name,
                        child: Image.asset(
                          widget.product.image,
                          height: 1000,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ---- Name + animated total price ----
              FadeInDown(
                delay: const Duration(milliseconds: 200),
                duration: const Duration(milliseconds: 500),
                from: 50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.58,
                      child: Text(
                        widget.product.name,
                        style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.2,
                            height: 1.15),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0, end: totalPrice),
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, child) {
                            return Text(
                              "\$${value.toStringAsFixed(2)}",
                              style: TextStyle(
                                  fontSize: 26,
                                  color: primary,
                                  fontWeight: FontWeight.bold),
                            );
                          },
                        ),
                        const Text(
                          "Best Sale",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ---- Description card with 3D colored shadow ----
              FadeInDown(
                delay: const Duration(milliseconds: 300),
                duration: const Duration(milliseconds: 500),
                from: 50,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: primary.withOpacity(0.12)),
                    boxShadow: [
                      BoxShadow(
                        color: primary.withOpacity(0.14),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    "Indulge in a rich, handcrafted blend made with the finest ingredients — velvety layers of flavor, a smooth and creamy texture, and the perfect balance of sweetness in every single sip. Freshly crafted just for you, this drink is the ultimate treat to brighten your day, any time you need a little moment of joy.",
                    style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.black.withOpacity(0.82),
                      height: 1.5,
                      letterSpacing: 0.15,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 22),

              // ---- Size Options ----
              FadeInDown(
                delay: const Duration(milliseconds: 400),
                duration: const Duration(milliseconds: 500),
                from: 50,
                child: const Text(
                  "Size Options",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              FadeInDown(
                delay: const Duration(milliseconds: 600),
                duration: const Duration(milliseconds: 500),
                from: 50,
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      for (var i = 0; i < sizes.length; i++)
                        _AnimatedTapWrapper(
                          onTap: () => setState(() {
                            selectedSize = i;
                          }),
                          child: ProductSize(
                              isSelected: selectedSize == i,
                              iconSize: 25 + (i * 5),
                              sizes: sizes[i]),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 26),

              // ---- Quantity stepper (increment / decrement) ----
              FadeInDown(
                delay: const Duration(milliseconds: 700),
                duration: const Duration(milliseconds: 500),
                from: 50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Quantity",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Container(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: primary.withOpacity(0.15)),
                        boxShadow: [
                          BoxShadow(
                            color: primary.withOpacity(0.16),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          _QuantityButton(
                            icon: Icons.remove_rounded,
                            enabled: quantity > _minQuantity,
                            color: primary,
                            onTap: _decrementQuantity,
                          ),
                          SizedBox(
                            width: 34,
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 220),
                              transitionBuilder: (child, anim) =>
                                  ScaleTransition(scale: anim, child: child),
                              child: Text(
                                '$quantity',
                                key: ValueKey<int>(quantity),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          _QuantityButton(
                            icon: Icons.add_rounded,
                            enabled: quantity < _maxQuantity,
                            color: primary,
                            onTap: _incrementQuantity,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 26),

              // ---- Order Now button ----
              // Professional 3-stop diagonal gradient + glossy top highlight
              // + softer layered shadow, instead of a flat 2-color gradient.
              FadeInDown(
                delay: const Duration(milliseconds: 800),
                duration: const Duration(milliseconds: 500),
                from: 50,
                child: AnimatedBuilder(
                  animation: _orderBtnScale,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _orderBtnScale.value,
                      child: child,
                    );
                  },
                  child: GestureDetector(
                    onTap: _handleOrderTap,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: primary.withOpacity(0.35),
                            blurRadius: 28,
                            spreadRadius: -2,
                            offset: const Offset(0, 14),
                          ),
                          BoxShadow(
                            color: Color.lerp(primary, Colors.black, 0.6)!
                                .withOpacity(0.25),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color.lerp(primary, Colors.white, 0.12) ??
                                      primary,
                                  primary,
                                  Color.lerp(primary, Colors.black, 0.35) ??
                                      primary,
                                ],
                                stops: const [0.0, 0.5, 1.0],
                              ),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.14),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.shopping_bag_outlined,
                                    color: Colors.white, size: 20),
                                const SizedBox(width: 10),
                                const Text(
                                  "Order Now",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Glossy highlight strip along the top edge for a
                          // more premium, glass-like finish.
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            child: ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              ),
                              child: Container(
                                height: 18,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.white.withOpacity(0.22),
                                      Colors.white.withOpacity(0.0),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bara, center-screen order-confirmation card jo `showGeneralDialog` k
/// zariye scale+fade animation k sath pop hota hai. SnackBar ki jagah
/// istemal hota hai taake confirmation clearly visible ho.
class _OrderSuccessCard extends StatelessWidget {
  const _OrderSuccessCard({
    required this.color,
    required this.productName,
    required this.quantity,
    required this.sizeName,
  });

  final Color color;
  final String productName;
  final int quantity;
  final String sizeName;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 36),
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 26),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.35),
                blurRadius: 40,
                spreadRadius: 2,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color.lerp(color, Colors.white, 0.15) ?? color,
                      color,
                      Color.lerp(color, Colors.black, 0.25) ?? color,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.5),
                      blurRadius: 22,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 46,
                ),
              ),
              const SizedBox(height: 22),
              const Text(
                "Order Placed!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Thank you! Your $quantity x $productName ($sizeName) is on the way.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w500,
                  color: Colors.black.withOpacity(0.6),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedTapWrapper extends StatefulWidget {
  const _AnimatedTapWrapper({
    required this.onTap,
    required this.child,
  });

  final VoidCallback onTap;
  final Widget child;

  @override
  State<_AnimatedTapWrapper> createState() => _AnimatedTapWrapperState();
}

class _AnimatedTapWrapperState extends State<_AnimatedTapWrapper> {
  double _scale = 1.0;

  void _setScale(double value) => setState(() => _scale = value);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _setScale(0.9),
      onTapUp: (_) {
        _setScale(1.0);
        widget.onTap();
      },
      onTapCancel: () => _setScale(1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

/// Small circular increment / decrement button with press-scale feedback
/// and a disabled (dimmed) state at the min/max quantity limits.
class _QuantityButton extends StatefulWidget {
  const _QuantityButton({
    required this.icon,
    required this.enabled,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final Color color;
  final VoidCallback onTap;

  @override
  State<_QuantityButton> createState() => _QuantityButtonState();
}

class _QuantityButtonState extends State<_QuantityButton> {
  double _scale = 1.0;

  void _setScale(double value) {
    if (!widget.enabled) return;
    setState(() => _scale = value);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _setScale(0.85),
      onTapUp: (_) {
        _setScale(1.0);
        if (widget.enabled) widget.onTap();
      },
      onTapCancel: () => _setScale(1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: AnimatedOpacity(
          opacity: widget.enabled ? 1.0 : 0.35,
          duration: const Duration(milliseconds: 200),
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  widget.color,
                  Color.lerp(widget.color, Colors.black, 0.2) ?? widget.color,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.color.withOpacity(0.45),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(widget.icon, color: Colors.white, size: 18),
          ),
        ),
      ),
    );
  }
}