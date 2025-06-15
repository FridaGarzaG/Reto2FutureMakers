import 'package:flutter/material.dart';

class LoadingAnimationPage extends StatefulWidget {
  const LoadingAnimationPage({super.key});

  @override
  State<LoadingAnimationPage> createState() => _LoadingAnimationPageState();
}

class _LoadingAnimationPageState extends State<LoadingAnimationPage>
    with TickerProviderStateMixin {
  late AnimationController fallController;
  late AnimationController fillController;
  late Animation<double> dotY;

  bool readyToFill = false;
  bool filled = false;

  @override
  void initState() {
    super.initState();

    fallController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    dotY = Tween<double>(begin: -50, end: 40).animate(
      CurvedAnimation(parent: fallController, curve: Curves.bounceOut),
    );

    fillController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    fallController.forward().whenComplete(() {
      setState(() {
        readyToFill = true;
      });
    });
  }

  @override
  void dispose() {
    fallController.dispose();
    fillController.dispose();
    super.dispose();
  }

  void startFill() {
    if (!filled) {
      fillController.forward();
      setState(() {
        filled = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const double circleSize = 120;
    const double borderWidth = 6;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: GestureDetector(
          onTap: readyToFill ? startFill : null,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Fondo gris: borde externo completo
              Container(
                width: circleSize,
                height: circleSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey, width: borderWidth),
                ),
              ),

              // Simulación de relleno del borde: va creciendo de abajo hacia arriba
              if (filled)
                AnimatedBuilder(
                  animation: fillController,
                  builder: (_, __) {
                    return ClipOval(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        heightFactor: fillController.value,
                        child: Container(
                          width: circleSize,
                          height: circleSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFBE263B),
                              width: borderWidth,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

              // Punto rojo que cae
              AnimatedBuilder(
                animation: dotY,
                builder: (_, __) => Positioned(
                  top: dotY.value,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: Color(0xFFBE263B),
                      shape: BoxShape.circle,
                    ),
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
