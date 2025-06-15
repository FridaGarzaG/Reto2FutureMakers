import 'dart:convert';
import 'constants.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'homePage.dart';
import 'registerPage.dart';

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

class _LoginPageState extends State<LoginPage> with WidgetsBindingObserver {
  final List<TextEditingController> _digitControllers =
      List.generate(5, (index) => TextEditingController());
  final List<FocusNode> _digitFocusNodes =
      List.generate(5, (index) => FocusNode());

  final TextEditingController usernameController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool mostrarInputCodigo = false;
  bool _isHoveringRegister = false;
  bool _isHoveringResend = false;
  bool _isLoading = false;
  String usuarioGuardado = '';

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => setState(() {}));
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      for (var controller in _digitControllers) {
        controller.clear();
      }
    }
  }

  void _solicitarCodigo() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    String username = usernameController.text.trim();

    if (username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor ingresa tu nombre de usuario')),
      );
      setState(() => _isLoading = false);
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

        setState(() {
          mostrarInputCodigo = true;
          usuarioGuardado = username;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$mensaje Código recibido: $codigo'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al solicitar el código.'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          mostrarInputCodigo = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() => _isLoading = false);
  }

  void _verificarCodigo() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    String codigo = _digitControllers.map((c) => c.text).join();

    if (codigo.length != 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor ingresa los 5 dígitos del código')),
      );
      setState(() => _isLoading = false);
      return;
    }

    try {
      final url = Uri.parse('$backendBaseUrl/api/auth/verificar-codigo');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'nombre': usuarioGuardado, 'codigo': codigo}),
      );

      if (response.statusCode == 200) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const HomePage()));
      } else {
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['mensaje'] ?? 'Código incorrecto'),
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

    setState(() => _isLoading = false);
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
                      Text('Bienvenid@ a', style: TextStyle(fontSize: fontSize), textAlign: TextAlign.center),
                      const SizedBox(height: 10),
                      Container(
                        width: inputWidth,
                        alignment: Alignment.center,
                        child: Image.asset('imagenes/Tuali_Logo.png', fit: BoxFit.contain),
                      ),
                      const SizedBox(height: 30),
                      Text('INICIAR SESIÓN',
                          style: TextStyle(fontSize: fontSize + 4, fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: inputWidth,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!mostrarInputCodigo) ...[
                              Text('Usuario', style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold, color: const Color(0xFFBE263B))),
                              const SizedBox(height: 6),
                              Container(
                                decoration: BoxDecoration(color: Colors.white.withOpacity(0.85), borderRadius: BorderRadius.circular(4)),
                                child: TextField(
                                  controller: usernameController,
                                  focusNode: _focusNode,
                                  decoration: const InputDecoration(hintText: 'Ingresa tu nombre de usuario', border: OutlineInputBorder()),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: fontSize),
                                ),
                              ),
                            ] else ...[
                              Text('Código de verificación',
                                  style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold, color: const Color(0xFFBE263B))),
                              const SizedBox(height: 10),
                              SizedBox(
                                width: inputWidth,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: List.generate(5, (index) {
                                    return SizedBox(
                                      width: 40,
                                      child: TextField(
                                        controller: _digitControllers[index],
                                        focusNode: _digitFocusNodes[index],
                                        maxLength: 1,
                                        textAlign: TextAlign.center,
                                        keyboardType: TextInputType.number,
                                        style: const TextStyle(fontSize: 20),
                                        decoration: const InputDecoration(
                                          counterText: '',
                                          border: OutlineInputBorder(),
                                          filled: true,
                                          fillColor: Colors.white,
                                        ),
                                        onChanged: (value) {
                                          if (value.isNotEmpty && index < 4) {
                                            FocusScope.of(context).requestFocus(_digitFocusNodes[index + 1]);
                                          }
                                          if (value.isEmpty && index > 0) {
                                            FocusScope.of(context).requestFocus(_digitFocusNodes[index - 1]);
                                          }
                                        },
                                      ),
                                    );
                                  }),
                                ),
                              ),
                              const SizedBox(height: 10),
                              MouseRegion(
                                onEnter: (_) => setState(() => _isHoveringResend = true),
                                onExit: (_) => setState(() => _isHoveringResend = false),
                                child: GestureDetector(
                                  onTap: _solicitarCodigo,
                                  child: Text(
                                    'Volver a enviar código',
                                    style: TextStyle(
                                      fontSize: fontSize * 0.9,
                                      color: const Color(0xFFBE263B),
                                      decoration: _isHoveringResend ? TextDecoration.underline : TextDecoration.none,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextButton.icon(
                                onPressed: () => setState(() => mostrarInputCodigo = false),
                                icon: const Icon(Icons.arrow_back_ios, size: 16, color: Color(0xFFBE263B)),
                                label: const Text('Volver al ingreso de usuario', style: TextStyle(color: Color(0xFFBE263B))),
                              )
                            ]
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
                          onPressed: _isLoading
                              ? null
                              : mostrarInputCodigo
                                  ? _verificarCodigo
                                  : _solicitarCodigo,
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  mostrarInputCodigo ? 'Comenzar' : 'Iniciar sesión',
                                  style: TextStyle(fontSize: fontSize),
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (!mostrarInputCodigo)
                        MouseRegion(
                          onEnter: (_) => setState(() => _isHoveringRegister = true),
                          onExit: (_) => setState(() => _isHoveringRegister = false),
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: TextStyle(color: Colors.black87, fontSize: fontSize),
                              children: [
                                const TextSpan(text: '¿No tienes cuenta? '),
                                TextSpan(
                                  text: 'Regístrate aquí',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFFBE263B),
                                    decoration: _isHoveringRegister ? TextDecoration.underline : TextDecoration.none,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterPage()));
                                    },
                                ),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 30),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 20.0, bottom: 10),
                          child: Image.asset(
                            'imagenes/arca_logo.png',
                            width: 80,
                            fit: BoxFit.contain,
                          )
                        )
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
