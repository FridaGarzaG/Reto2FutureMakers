import 'package:flutter/material.dart';
import 'homePage.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final FocusNode _focusUser = FocusNode();
  final FocusNode _focusPhone = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusUser.addListener(() => setState(() {}));
    _focusPhone.addListener(() => setState(() {}));
  }

  void _register() {
    String username = usernameController.text.trim();
    String phone = phoneController.text.trim();

    if (username.isNotEmpty && phone.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor completa todos los campos')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD42027),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final scale = (width / 400).clamp(0.8, 1.2);
          final double inputWidth = scale * 280;
          final double fontSize = scale * 16;
          final double buttonWidth = scale * 180;

          return Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text(
                    'Bienvenid@ a',
                    style: TextStyle(
                      fontSize: fontSize,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: inputWidth,
                    alignment: Alignment.center,
                    child: Image.asset(
                      'imagenes/logotipo_blanco.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    'REGÍSTRATE',
                    style: TextStyle(
                      fontSize: fontSize + 4,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
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
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: usernameController,
                          focusNode: _focusUser,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Ingresa tu nombre de usuario',
                            hintStyle: const TextStyle(color: Colors.white70),
                            enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white, width: 2),
                            ),
                            filled: false,
                          ),
                          textAlign: TextAlign.start,
                        ),
                        const SizedBox(height: 15),
                        Text(
                          'Número telefónico',
                          style: TextStyle(
                            fontSize: fontSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
                          focusNode: _focusPhone,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Ingresa tu número telefónico',
                            hintStyle: const TextStyle(color: Colors.white70),
                            enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white, width: 2),
                            ),
                            filled: false,
                          ),
                          textAlign: TextAlign.start,
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
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFFD42027),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: _register,
                      child: Text(
                        'Registrarse',
                        style: TextStyle(fontSize: fontSize),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      '¿Ya tienes cuenta? Inicia sesión aquí',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Image.asset(
                    'imagenes/arca_blanco.png',
                    width: 100,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
