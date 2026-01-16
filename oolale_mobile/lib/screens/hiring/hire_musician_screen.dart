import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../config/constants.dart';

class HireMusicianScreen extends StatefulWidget {
  final int musicianId;
  final String musicianName;

  const HireMusicianScreen({super.key, required this.musicianId, required this.musicianName});

  @override
  State<HireMusicianScreen> createState() => _HireMusicianScreenState();
}

class _HireMusicianScreenState extends State<HireMusicianScreen> {
  final _amountController = TextEditingController();
  final _descController = TextEditingController();
  bool _isLoading = false;
  double _commission = 0.0;
  double _total = 0.0;

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_updateCalculations);
  }

  @override
  void dispose() {
    _amountController.removeListener(_updateCalculations);
    super.dispose();
  }

  void _updateCalculations() {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    setState(() {
      _commission = amount * 0.10;
      _total = amount + _commission;
    });
  }

  Future<void> _processHiring() async {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    if (amount < 100) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('El monto mínimo es \$100 MXN')));
      return;
    }
    if (_descController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor describe el servicio')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final api = ApiService();
      await api.post('/contrataciones/solicitar', {
        'id_musico': widget.musicianId,
        'monto_total': amount, // Sending the base amount or total? JS sends 'monto_total: monto' (input value).
        // JS: const monto = document.getElementById('montoContratacion').value;
        // JS: body: { ..., monto_total: monto, ... }
        // So it sends the user input amount, not the calculated total with commission? 
        // Logic in JS display: "Total a pagar: calcTotal". But API receives 'monto' as 'monto_total'. 
        // I will send the input amount to match JS.
        'descripcion_servicio': _descController.text
      });

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppConstants.cardColor,
            title: const Text('¡Solicitud Enviada!', style: TextStyle(color: Colors.white)),
            content: const Text('El pago ha sido procesado y retenido en garantía (Escrow). El músico ha sido notificado.', style: TextStyle(color: Colors.white70)),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx); // Close dialog
                  Navigator.pop(context); // Close screen
                },
                child: const Text('ENTENDIDO', style: TextStyle(color: AppConstants.primaryColor)),
              )
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Contratación Segura'),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: AppConstants.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppConstants.primaryColor)
              ),
              child: Row(
                children: [
                  const Icon(Icons.security, color: AppConstants.primaryColor, size: 30),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Contratando a ${widget.musicianName}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        const Text('Tu dinero se retiene seguro hasta que recibas el trabajo.', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 25),
            const Text('Monto a Depositar (MXN)', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 10),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white, fontSize: 20),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.attach_money, color: Colors.white54),
                hintText: '0.00',
                filled: true,
                fillColor: AppConstants.cardColor,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Descripción del Servicio', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 10),
            TextField(
              controller: _descController,
              maxLines: 4,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Ej: Grabación de guitarra para 2 canciones...',
                filled: true,
                fillColor: AppConstants.cardColor,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 30),
            
            // Receipt
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white10)
              ),
              child: Column(
                children: [
                  _buildReceiptRow('Subtotal', _amountController.text.isEmpty ? '0.00' : _amountController.text),
                  const SizedBox(height: 10),
                  _buildReceiptRow('Comisión de Seguridad (10%)', _commission.toStringAsFixed(2)),
                  const Divider(color: Colors.white24, height: 30),
                  _buildReceiptRow('TOTAL A PAGAR', _total.toStringAsFixed(2), isTotal: true),
                ],
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              height: 55,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _processHiring,
                icon: const Icon(Icons.credit_card),
                label: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('PAGAR Y ABRIR ESCROW', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, // Money color
                  foregroundColor: Colors.white,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: isTotal ? Colors.greenAccent : Colors.white54, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal, fontSize: isTotal ? 16 : 14)),
        Text('\$$value', style: TextStyle(color: isTotal ? Colors.greenAccent : Colors.white, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal, fontSize: isTotal ? 18 : 14)),
      ],
    );
  }
}
