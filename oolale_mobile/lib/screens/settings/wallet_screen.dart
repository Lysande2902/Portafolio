import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../config/constants.dart';
import '../../config/theme_colors.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final _supabase = Supabase.instance.client;
  
  double _balance = 0.0;
  List<Map<String, dynamic>> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWalletData();
  }

  Future<void> _loadWalletData() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    setState(() => _isLoading = true);

    try {
      // Cargar transacciones del usuario
      final data = await _supabase
          .from('tickets_pagos')
          .select()
          .eq('comprador_id', userId)
          .order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          _transactions = List<Map<String, dynamic>>.from(data);
          // Calcular balance (suma de completados - reembolsados)
          _balance = _transactions.fold(0.0, (sum, t) {
            if (t['estatus'] == 'completado') {
              return sum + (t['monto_total'] as num).toDouble();
            } else if (t['estatus'] == 'reembolsado') {
              return sum - (t['monto_total'] as num).toDouble();
            }
            return sum;
          });
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading wallet: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showAddFundsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text('Agregar Fondos', style: TextStyle(color: ThemeColors.primaryText(context))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Integración de pagos próximamente', style: TextStyle(color: ThemeColors.secondaryText(context))),
            const SizedBox(height: 16),
            Text(
              'MercadoPago • PayPal • Stripe',
              style: GoogleFonts.outfit(color: AppConstants.primaryColor, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido', style: TextStyle(color: AppConstants.primaryColor)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('BILLETERA', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, letterSpacing: 2)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppConstants.primaryColor))
          : Column(
              children: [
                _buildBalanceCard(),
                _buildQuickActions(),
                Expanded(child: _buildTransactionsList()),
              ],
            ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppConstants.primaryColor, AppConstants.aquamarineColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppConstants.primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Balance Disponible',
                style: GoogleFonts.outfit(
                  color: Colors.black54,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Icon(Icons.account_balance_wallet_rounded, color: Colors.black54, size: 24),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '\$${_balance.toStringAsFixed(2)} MXN',
            style: GoogleFonts.outfit(
              color: Colors.black,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_transactions.length} transacciones',
            style: GoogleFonts.outfit(
              color: Colors.black38,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildActionButton(
              'Agregar Fondos',
              Icons.add_rounded,
              AppConstants.primaryColor,
              _showAddFundsDialog,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildActionButton(
              'Retirar',
              Icons.arrow_upward_rounded,
              AppConstants.accentColor,
              () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.outfit(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsList() {
    if (_transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_rounded, size: 80, color: ThemeColors.disabledText(context)),
            const SizedBox(height: 20),
            Text(
              'Sin transacciones aún',
              style: GoogleFonts.outfit(color: ThemeColors.secondaryText(context), fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _transactions.length,
      itemBuilder: (context, index) {
        final transaction = _transactions[index];
        return _TransactionTile(transaction: transaction);
      },
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final Map<String, dynamic> transaction;

  const _TransactionTile({required this.transaction});

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completado':
        return AppConstants.successColor;
      case 'pendiente':
        return AppConstants.warningColor;
      case 'reembolsado':
        return AppConstants.infoColor;
      case 'fallido':
        return AppConstants.errorColor;
      default:
        return AppConstants.textMuted;
    }
  }

  IconData _getIcon(String status) {
    switch (status) {
      case 'completado':
        return Icons.check_circle_rounded;
      case 'pendiente':
        return Icons.access_time_rounded;
      case 'reembolsado':
        return Icons.undo_rounded;
      case 'fallido':
        return Icons.error_rounded;
      default:
        return Icons.receipt_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = transaction['estatus'] ?? 'borrador';
    final amount = (transaction['monto_total'] as num).toDouble();
    final date = DateTime.parse(transaction['created_at']);
    final color = _getStatusColor(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(_getIcon(status), color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status.toUpperCase(),
                  style: GoogleFonts.outfit(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  transaction['pasarela'] ?? 'Pago',
                  style: GoogleFonts.outfit(
                    color: ThemeColors.primaryText(context),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('dd MMM yyyy, HH:mm').format(date),
                  style: TextStyle(color: ThemeColors.hintText(context), fontSize: 11),
                ),
              ],
            ),
          ),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: GoogleFonts.outfit(
              color: status == 'reembolsado' ? AppConstants.infoColor : Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
