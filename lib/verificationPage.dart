import 'package:flutter/material.dart';

class VerificationPage extends StatefulWidget {
  const VerificationPage({super.key});

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  final List<TextEditingController> controllers =
      List.generate(5, (_) => TextEditingController());

  @override
  void dispose() {
    for (var controller in controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _verifyCode() {
    String code = controllers.map((c) => c.text).join();
    if (code.length == 5) {
      print("Código ingresado: $code");
      // Aquí iría la lógica para verificar
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa los 5 dígitos del código')),
      );
    }
  }

  Widget _buildCodeBox(int index, double boxSize) {
    return SizedBox(
      width: boxSize,
      child: TextField(
        controller: controllers[index],
        keyboardType: TextInputType.number,
        maxLength: 1,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 20),
        decoration: const InputDecoration(
          counterText: '',
          border: OutlineInputBorder(),
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < 4) {
            FocusScope.of(context).nextFocus();
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;
          final width = constraints.maxWidth;
          final scale = (width / 400).clamp(0.8, 1.2);
          final double fontSize = scale * 18;
          final double buttonWidth = scale * 180;
          final double boxSize = isWide ? 45 : 40;
          final double spacing = isWide ? 12 : 8;

          return Stack(
            children: [
              const GridBackground(), // cuadrícula de fondo
              Positioned(
                top: 20,
                left: 20,
                child: Image.asset(
                  'imagenes/Tuali_Logo.png',
                  width: 100,
                ),
              ),
              Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 80),
                      Text(
                        'Ingresa la clave que llegó a\nla aplicación de mensajes',
                        style: TextStyle(
                          fontSize: fontSize + 4,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(5, (i) {
                            return Padding(
                              padding: EdgeInsets.symmetric(horizontal: spacing / 2),
                              child: _buildCodeBox(i, boxSize),
                            );
                          }),
                        ),
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: buttonWidth,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD42027),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: _verifyCode,
                          child: Text(
                            'Enviar',
                            style: TextStyle(fontSize: fontSize),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Image.asset(
                        'imagenes/arca_logo.png',
                        width: 100,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// Cuadrícula igual que en el LoginPage
class GridBackground extends StatelessWidget {
  const GridBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: GridPainter(),
      size: MediaQuery.of(context).size,
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const double step = 40;
    final Paint paint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..strokeWidth = 1;

    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
