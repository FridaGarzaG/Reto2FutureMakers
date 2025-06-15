import 'package:flutter/material.dart';
import 'homePage.dart'; // Importa el modelo Product

class CarritoPage extends StatelessWidget {
  final List<Product> productosSeleccionados;

  const CarritoPage({super.key, required this.productosSeleccionados});

  @override
  Widget build(BuildContext context) {
    double subtotal = productosSeleccionados.fold(0, (sum, p) => sum + p.price);
    double iva = subtotal * 0.16;
    double total = subtotal + iva;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Carrito'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: productosSeleccionados.length,
                itemBuilder: (context, index) {
                  final producto = productosSeleccionados[index];
                  return ListTile(
                    leading: Image.asset(producto.image, width: 40, height: 40),
                    title: Text(producto.name),
                    trailing: Text('\$${producto.price.toStringAsFixed(2)}'),
                  );
                },
              ),
            ),
            const Divider(),
            Align(
              alignment: Alignment.centerRight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Subtotal (sin IVA): \$${subtotal.toStringAsFixed(2)}'),
                  Text('IVA (16%): \$${iva.toStringAsFixed(2)}'),
                  Text(
                    'Total (con IVA): \$${total.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
