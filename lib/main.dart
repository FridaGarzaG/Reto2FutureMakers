import 'dart:convert';
import 'constants.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'homePage.dart'; // Asegúrate de que este archivo exista

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tüali Login',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFFBE263B)),
        useMaterial3: true,
        textTheme: ThemeData().textTheme.apply(
              bodyColor: Colors.black,
              displayColor: Colors.black,
            ),
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => setState(() {}));
  }

  void _login() async {
    String username = usernameController.text.trim();

    if (username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor ingresa tu nombre de usuario')),
      );
      return;
    }

    try {
      final url = Uri.parse('$backendBaseUrl/api/auth/solicitar-codigo');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'nombre': username}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final mensaje = data['mensaje'];
        final codigo = data['codigo'];

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$mensaje Código recibido: $codigo'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
          ),
        );

        // Puedes ir a otra pantalla si quieres
        // Navigator.push(context, MaterialPageRoute(builder: (context) => const HomePage()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al solicitar el código.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final scale = (width / 400).clamp(0.8, 1.2);
          final double inputWidth = scale * 280;
          final double fontSize = scale * 16;
          final double buttonWidth = scale * 180;

          return Stack(
            children: [
              const GridBackground(),
              Center(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Text(
                        'Bienvenid@ a',
                        style: TextStyle(
                          fontSize: fontSize,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: inputWidth,
                        alignment: Alignment.center,
                        child: Image.asset(
                          'imagenes/Tuali_Logo.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 30),
                      Text(
                        'INICIAR SESIÓN',
                        style: TextStyle(
                          fontSize: fontSize + 4,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: inputWidth,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Usuario',
                              style: TextStyle(
                                fontSize: fontSize,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFBE263B),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.85),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: TextField(
                                controller: usernameController,
                                focusNode: _focusNode,
                                decoration: InputDecoration(
                                  hintText: _focusNode.hasFocus
                                      ? null
                                      : 'Ingresa tu nombre de usuario',
                                  border: const OutlineInputBorder(
                                    borderSide: BorderSide(),
                                  ),
                                ),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: fontSize,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: buttonWidth,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFBE263B),
                            foregroundColor: Colors.white,
                          ),
                          onPressed: _login,
                          child: Text(
                            'Iniciar sesión',
                            style: TextStyle(fontSize: fontSize),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      MouseRegion(
                        onEnter: (_) => setState(() => _isHovering = true),
                        onExit: (_) => setState(() => _isHovering = false),
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: fontSize,
                            ),
                            children: [
                              const TextSpan(text: '¿No tienes cuenta? '),
                              TextSpan(
                                text: 'Regístrate aquí',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFBE263B),
                                  decoration: _isHovering
                                      ? TextDecoration.underline
                                      : TextDecoration.none,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    print('Ir a registro');
                                  },
                              ),
                            ],
                          ),
                        ),
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

// Fondo cuadriculado
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
