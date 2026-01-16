import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../config/constants.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final ApiService _api = ApiService();
  bool _isLoading = true;
  List<dynamic> _transactions = [];
  final double _balance = 0.0;

  @override
  void initState() {
    super.initState();
    _loadWalletData();
  }

  Future<void> _loadWalletData() async {
    try {
      // Mock fetching wallet data if API is not fully ready
      // In real app: GET /pagos
      final response = await _api.get('/pagos');
      if (response != null && response is Map && response.containsKey('pagos')) {
         setState(() {
           _transactions = response['pagos'];
           _isLoading = false;
         });
      } else {
        // Fallback for demo parity request
        setState(() {
          _transactions = [
            {'fecha_creacion': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(), 'descripcion': 'Contratación Guitarrista', 'monto': 550.00, 'tipo_transaccion': 'pago_servicio', 'estado': 'completado'},
            {'fecha_creacion': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(), 'descripcion': 'Membresía PRO', 'monto': 9.99, 'tipo_transaccion': 'membresia', 'estado': 'completado'},
          ];
          _isLoading = false;
        });
      }
    } catch (e) {
      if(mounted) setState(() => _isLoading = false);
    }
  }

  Color _getStatusColor(String status) {
    if (status == 'completado') return Colors.green;
    if (status == 'pendiente') return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Billetera e Historial'),
        backgroundColor: AppConstants.backgroundColor,
        elevation: 0,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Column(
          children: [
            // Balance Card
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppConstants.primaryColor, AppConstants.primaryColor.withOpacity(0.6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight
                ),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [BoxShadow(color: Colors.black45, blurRadius: 10, offset: const Offset(0, 5))]
              ),
              child: Column(
                children: [
                  const Text('Saldo Disponible', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 5),
                  const Text('\$0.00', style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)), // Mock balance
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildActionButton(Icons.add, 'Depositar'),
                      _buildActionButton(Icons.arrow_upward, 'Retirar'),
                    ],
                  )
                ],
              ),
            ),
            
            // Transactions Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: const [
                  Icon(Icons.history, color: AppConstants.accentColor, size: 20),
                  SizedBox(width: 10),
                  Text('Movimientos Recientes', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),

            // List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                itemCount: _transactions.length,
                itemBuilder: (context, index) {
                  final t = _transactions[index];
                  final isNegative = t['tipo_transaccion'] != 'ingreso'; // Simple logic
                  return Card(
                    color: AppConstants.cardColor,
                    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppConstants.backgroundColor,
                        child: Icon(
                          isNegative ? Icons.arrow_outward : Icons.arrow_downward,
                          color: isNegative ? Colors.orange : Colors.green,
                          size: 20,
                        ),
                      ),
                      title: Text(t['descripcion'] ?? 'Transacción', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                      subtitle: Text(
                        t['fecha_creacion'].toString().split('T')[0], 
                        style: const TextStyle(color: Colors.white38, fontSize: 12)
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${isNegative ? '-' : '+'}\$${t['monto']}', 
                            style: TextStyle(color: isNegative ? Colors.white : Colors.greenAccent, fontWeight: FontWeight.bold)
                          ),
                          Text(
                            t['estado']?.toString().toUpperCase() ?? '',
                            style: TextStyle(color: _getStatusColor(t['estado']), fontSize: 10)
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
    );
  }

  Widget _buildActionButton(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: Colors.white),
        ),
        const SizedBox(height: 5),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12))
      ],
    );
  }
}
