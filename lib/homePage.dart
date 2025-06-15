import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'carrito.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: HomePage(),
  ));
}

class Product {
  final String name;
  final String image;
  final double price;

  Product(this.name, this.image, this.price);

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        json['nombre'],
        Product.getImageForProduct(json['nombre']),
        (json['precio'] as num).toDouble(),
      );

  static String getImageForProduct(String name) {
    switch (name.toLowerCase()) {
      case 'coca-cola regular':
        return 'imagenes/original.jpg';
      case 'del valle':
        return 'imagenes/del_valle.jpg';
      case 'coca-cola light':
        return 'imagenes/light.jpg';
      case 'del valle mango':
        return 'imagenes/mangojpg.jpg';
      case 'coca-cola sin azúcar':
        return 'imagenes/sin_azucar.jpg';
      case 'santa clara entera':
        return 'imagenes/entera.jpg';
      case 'ciel natural':
        return 'imagenes/agua.jpg';
      case 'santa clara deslactosada':
        return 'imagenes/deslactosada.jpg';
      case 'power ade 4 moras':
        return 'imagenes/power.jpg';
      case 'joya ponche':
        return 'imagenes/ponche.jpg';
      case 'fuzetea mango y manzanilla':
        return 'imagenes/fuze_tea.jpg';
      default:
        return 'imagenes/default.png';
    }
  }

  Map<String, dynamic> toJson() => {
        'nombre': name,
        'imagen': image,
        'precio': price,
      };
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int contadorCarrito = 0;
  final Color rojoMarca = const Color(0xFFBE263B);

  List<Product> productosSeleccionados = [];

  late AnimationController fallController;
  late AnimationController fillController;
  late Animation<double> dotY;
  bool mostrarAnimacion = false;
  bool listoParaRellenar = false;
  bool relleno = false;

  List<Product> productos = [];
  List<Product> productosFiltrados = [];
  String filtro = '';

  @override
  void initState() {
    super.initState();
    fetchProductos();
    productosFiltrados = productos;

    final carritoData = html.window.sessionStorage['carrito'];
    if (carritoData != null) {
      final productos = List<Map<String, dynamic>>.from(jsonDecode(carritoData));
      final totalCantidad = productos.fold<int>(0, (sum, p) => sum + ((p['cantidad'] ?? 1) as int));
      contadorCarrito = totalCantidad;
    }

    fallController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    dotY = Tween<double>(begin: -10, end: 12).animate(
      CurvedAnimation(parent: fallController, curve: Curves.bounceOut),
    );

    fillController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  Future<void> fetchProductos() async {
    final response = await http.get(Uri.parse('http://localhost:5017/api/productos'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        productos = data.map<Product>((item) => Product.fromJson(item)).toList();
        productosFiltrados = productos;
      });
    }
  }

  void agregarProducto(Product producto) {
    final String? carritoData = html.window.sessionStorage['carrito'];
    List<Map<String, dynamic>> productos = carritoData != null
        ? List<Map<String, dynamic>>.from(jsonDecode(carritoData))
        : [];

    final index = productos.indexWhere((p) => p['name'] == producto.name);
    if (index != -1) {
      productos[index]['cantidad'] = (productos[index]['cantidad'] ?? 1) + 1;
    } else {
      productos.add({
        'name': producto.name,
        'price': producto.price,
        'image': producto.image,
        'cantidad': 1,
      });
    }

    html.window.sessionStorage['carrito'] = jsonEncode(productos);

    final totalCantidad = productos.fold<int>(0, (sum, p) => sum + ((p['cantidad'] ?? 1) as int));
    setState(() {
      contadorCarrito = totalCantidad;
    });
  }

  void iniciarAnimacionCarrito() async {
  setState(() => mostrarAnimacion = true);
  await fallController.forward();
  setState(() => listoParaRellenar = true);
  await fillController.forward();

  await Future.delayed(const Duration(milliseconds: 600));

  if (!mounted) return;

  final result = await Navigator.of(context).push(
    MaterialPageRoute(builder: (context) => const CarritoPage()),
  );

  if (result == true) {
    final carritoData = html.window.sessionStorage['carrito'];
    final List<dynamic> productos = carritoData != null ? jsonDecode(carritoData) : [];
    final totalCantidad = productos.fold<int>(0, (sum, p) {
      final cantidad = p['cantidad'];
      return sum + (cantidad is int ? cantidad : (cantidad as num).toInt());
    });

    setState(() {
      contadorCarrito = totalCantidad;
    });
  }

  setState(() {
    mostrarAnimacion = false;
    listoParaRellenar = false;
    relleno = false;
    fallController.reset();
    fillController.reset();
  });
}


  void filtrarProductos(String query) {
    setState(() {
      filtro = query;
      productosFiltrados = productos
          .where((producto) => producto.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  void dispose() {
    fallController.dispose();
    fillController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // build original UI (omitido por brevedad)
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(65),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: SafeArea(
            child: SizedBox.expand(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8, right: 8),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () => Navigator.pop(context),
                      tooltip: "Atrás",
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text('Punto de venta',
                            style: TextStyle(fontSize: 14, color: Colors.grey)),
                        Text('Abarrotes Doña Regina',
                            style: TextStyle(
                                fontSize: 18,
                                color: Colors.black87,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      bool isMobile = constraints.maxWidth < 600;
                      return isMobile
                          ? Padding(
                              padding: const EdgeInsets.all(8),
                              child: Container(
                                width: 40,
                                child: TextField(
                                  onChanged: filtrarProductos,
                                  decoration: InputDecoration(
                                    hintText: '',
                                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(color: Colors.grey),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: Container(
                                width: 200,
                                child: TextField(
                                  onChanged: filtrarProductos,
                                  decoration: InputDecoration(
                                    hintText: 'Buscar producto',
                                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(color: Colors.grey),
                                    ),
                                  ),
                                ),
                              ),
                            );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: mostrarAnimacion
                          ? Stack(
                              alignment: Alignment.center,
                              key: const ValueKey('animacion'),
                              children: [
                                Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border:
                                        Border.all(color: Colors.grey, width: 2),
                                  ),
                                ),
                                AnimatedBuilder(
                                  animation: dotY,
                                  builder: (_, __) => Positioned(
                                    top: dotY.value,
                                    child: Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: rojoMarca,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  child: AnimatedBuilder(
                                    animation: fillController,
                                    builder: (_, __) {
                                      return ClipOval(
                                        child: Align(
                                          alignment: Alignment.bottomCenter,
                                          heightFactor: fillController.value,
                                          child: Container(
                                            width: 30,
                                            height: 30,
                                            color: rojoMarca,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            )
                          : GestureDetector(
                              onTap: () {
                                if (contadorCarrito > 0) iniciarAnimacionCarrito();
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 400),
                                padding: contadorCarrito > 0
                                    ? const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4)
                                    : EdgeInsets.zero,
                                decoration: contadorCarrito > 0
                                    ? BoxDecoration(
                                        color: rojoMarca,
                                        borderRadius: BorderRadius.circular(20),
                                      )
                                    : null,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.shopping_cart,
                                      size: 20,
                                      color: contadorCarrito > 0
                                          ? Colors.white
                                          : rojoMarca,
                                    ),
                                    if (contadorCarrito > 0) ...[
                                      const SizedBox(width: 4),
                                      Text('$contadorCarrito',
                                          style: const TextStyle(
                                              color: Colors.white, fontSize: 12)),
                                    ]
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
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: productosFiltrados.length,
        itemBuilder: (context, index) {
          final producto = productosFiltrados[index];
          return Card(
            color: Colors.white,
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: InkWell(
              onTap: () => agregarProducto(producto),
              borderRadius: BorderRadius.circular(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    producto.image,
                    width: MediaQuery.of(context).size.width * 0.18,
                    height: MediaQuery.of(context).size.width * 0.18,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    producto.name,
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.04,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${producto.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.035,
                      color: Colors.green[800],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      backgroundColor: Colors.white,
    );
  }
}
