import 'package:flutter/material.dart';
import 'homePage.dart'; // Importa el modelo Product
import 'dart:convert';
import 'dart:html' as html;

class CarritoPage extends StatefulWidget {
  const CarritoPage({super.key});

  @override
  State<CarritoPage> createState() => _CarritoPageState();
}

class _CarritoPageState extends State<CarritoPage> {
  void actualizarCantidad(String nombreProducto, int cambio) {
  setState(() {
    final carritoData = html.window.sessionStorage['carrito'];
    final List<dynamic> decoded = carritoData != null ? jsonDecode(carritoData) : [];
    final List<Map<String, dynamic>> productos = List<Map<String, dynamic>>.from(decoded);

    final index = productos.indexWhere((p) => p['name'] == nombreProducto);
    if (index != -1) {
      productos[index]['cantidad'] += cambio;
      if (productos[index]['cantidad'] <= 0) {
        productos.removeAt(index);
      }
    }

    html.window.sessionStorage['carrito'] = jsonEncode(productos);
  });
}

void eliminarProducto(String nombreProducto) {
  setState(() {
    final carritoData = html.window.sessionStorage['carrito'];
    final List<dynamic> decoded = carritoData != null ? jsonDecode(carritoData) : [];
    final List<Map<String, dynamic>> productos = List<Map<String, dynamic>>.from(decoded);

    productos.removeWhere((p) => p['name'] == nombreProducto);

    html.window.sessionStorage['carrito'] = jsonEncode(productos);
  });
}

  final Color rojoMarca = const Color(0xFFBE263B);
  String? metodoPagoSeleccionado;
  final TextEditingController efectivoController = TextEditingController();

  @override
Widget build(BuildContext context) {
  final String? carritoData = html.window.sessionStorage['carrito'];
  final List<dynamic> decoded = carritoData != null ? jsonDecode(carritoData) : [];
  final List<Map<String, dynamic>> productos = List<Map<String, dynamic>>.from(decoded);

  final double subtotal = productos.fold(0, (sum, item) {
    final price = item['price'];
    return sum + ((price is num) ? price.toDouble() : 0);
  });
  final double iva = subtotal * 0.16;
  final double total = subtotal + iva;

    return Scaffold(
  backgroundColor: const Color(0xFFF5F5F5),
  appBar: PreferredSize(
    preferredSize: const Size.fromHeight(65),
    child: Container(
      height: 65,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              left: 8,
              child: TextButton.icon(
                onPressed: () => Navigator.pop(context, true),
                icon: Icon(Icons.arrow_back, color: rojoMarca),
                label: Text(
                  "Atrás",
                  style: TextStyle(
                    fontSize: 14,
                    color: rojoMarca,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text('Mi Carrito', style: TextStyle(fontSize: 12, color: Colors.grey)),
                Text('Abarrotes Doña Regina', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFBE263B))),
              ],
            ),
          ],
        ),
      ),
    ),
  ),
  body: Column( // ✅ Ahora esto sí está dentro de Scaffold
    children: [
      Expanded(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          children: [
            // tu contenido

                // Forma de pago
                Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final bool isWide = constraints.maxWidth > 500;
                        final paymentWidgets = [
                          ChoiceChip(
                            label: Text('Tarjeta', style: TextStyle(color: metodoPagoSeleccionado == 'tarjeta' ? rojoMarca : Colors.black)),
                            selected: metodoPagoSeleccionado == 'tarjeta',
                            selectedColor: Colors.white,
                            backgroundColor: Colors.white,
                            onSelected: (_) => setState(() => metodoPagoSeleccionado = 'tarjeta'),
                          ),
                          const SizedBox(width: 12),
                          ChoiceChip(
                            label: Text('Efectivo', style: TextStyle(color: metodoPagoSeleccionado == 'efectivo' ? rojoMarca : Colors.black)),
                            selected: metodoPagoSeleccionado == 'efectivo',
                            selectedColor: Colors.white,
                            backgroundColor: Colors.white,
                            onSelected: (_) => setState(() => metodoPagoSeleccionado = 'efectivo'),
                          ),
                        ];

                        final efectivoInput = metodoPagoSeleccionado == 'efectivo'
                          ? SizedBox(
                              width: isWide ? 250 : double.infinity,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: TextField(
                                  controller: efectivoController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Ingrese la cantidad con la que hará el pago',
                                    border: OutlineInputBorder(),
                                  ),
                                  onChanged: (_) => setState(() {}),
                                ),
                              ),
                            )
                          : const SizedBox();

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Forma de pago: (contado)', style: TextStyle(fontSize: 16)),
                            const SizedBox(height: 12),
                            isWide
                                ? Row(
                                    children: [
                                      ...paymentWidgets,
                                      const SizedBox(width: 24),
                                      efectivoInput,
                                    ],
                                  )
                                : Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(children: paymentWidgets),
                                      efectivoInput,
                                    ],
                                  ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Productos
                if (productos.isEmpty)
                  const Center(child: Text('No hay productos en el carrito'))
                else
                  ...productos.map((producto) => Card(
  color: Colors.white,
  elevation: 2,
  margin: const EdgeInsets.symmetric(vertical: 8),
  child: ListTile(
    leading: Image.asset(
      producto['image'],
      width: 40,
      height: 40,
      fit: BoxFit.contain,
    ),
    title: Text(producto['name']),
    subtitle: Text('\$${(producto['price'] as num).toStringAsFixed(2)}'),
    trailing: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.remove),
          onPressed: () => actualizarCantidad(producto['name'], -1),
        ),
        Text('${producto['cantidad']}'),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => actualizarCantidad(producto['name'], 1),
        ),
        IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => eliminarProducto(producto['name']),
        ),
      ],
    ),
  ),
)),

                const SizedBox(height: 20),

                // Resumen
                Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('Total de productos: ${productos.length}', style: const TextStyle(fontSize: 16)),
                        const Divider(),
                        Text('Total sin IVA: \$${subtotal.toStringAsFixed(2)}'),
                        const Divider(),
                        const Text('Fecha de entrega aproximada: 2 días hábiles'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),

          // Footer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -2))],
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final bool isWide = constraints.maxWidth > 500;
                final montoPago = double.tryParse(efectivoController.text) ?? 0;
                final bool pagoValido = metodoPagoSeleccionado == 'tarjeta' || (metodoPagoSeleccionado == 'efectivo' && montoPago >= total);

                final button = ElevatedButton(
                  onPressed: pagoValido
                      ? () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Pedido confirmado ✅")),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: pagoValido ? rojoMarca : Colors.grey,
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    'Confirmar pedido',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                );

                return isWide
                    ? Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Total: \$${total.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                          button,
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Total: \$${total.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          button,
                        ],
                      );
              },
            ),
          ),
        ],
      ),
    );
  }
}
