import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/user_data_provider.dart';
import '../widgets/coin_display.dart';

class BattlePassScreen extends StatefulWidget {
  const BattlePassScreen({super.key});

  @override
  State<BattlePassScreen> createState() => _BattlePassScreenState();
}

class _BattlePassScreenState extends State<BattlePassScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  final List<int> _rewards = [
    100, 150, 200, 200, 250,   // Niveles 1-5: 900 SEGS
    200, 250, 300, 300, 400,   // Niveles 6-10: 1,450 SEGS
    300, 300, 350, 350, 500,   // Niveles 11-15: 1,800 SEGS
    300, 350, 400, 400, 1000,  // Niveles 16-20: 2,450 SEGS
  ]; // Total: 6,600 SEGS

  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userDataProvider = Provider.of<UserDataProvider>(context);
    final inventory = userDataProvider.inventory;
    final hasPass = userDataProvider.hasActiveBattlePass;
    final currentLevel = inventory.battlePassLevel;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Latido de Conciencia de fondo
          Center(
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                final scale = 1.0 + (_pulseController.value * 0.1);
                final opacity = 0.02 + (_pulseController.value * 0.03);
                return Container(
                  width: 400 * scale,
                  height: 400 * scale,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(opacity),
                        blurRadius: 150,
                        spreadRadius: 80,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Scanlines
          Positioned.fill(
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.12,
                child: CustomPaint(
                  painter: ScanlinePainter(),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildHeader(context, hasPass, currentLevel),
                if (!hasPass) _buildPurchaseBanner(userDataProvider),
                Expanded(
                  child: _buildLevelsList(userDataProvider),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool hasPass, int level) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.red[900]!.withOpacity(0.5))),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ACCESO TOTAL',
                  style: GoogleFonts.shareTechMono(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                Text(
                  hasPass ? 'ESTADO: TESTIGO PREMIUM (ACTIVO)' : 'ESTADO: TESTIGO (INACTIVO)',
                  style: GoogleFonts.shareTechMono(
                    fontSize: 12,
                    color: hasPass ? Colors.green : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          if (hasPass)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.red[900]!.withOpacity(0.3),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.red[900]!),
              ),
              child: Column(
                children: [
                  Text(
                    'NIVEL',
                    style: GoogleFonts.shareTechMono(fontSize: 10, color: Colors.white70),
                  ),
                  Text(
                    '$level',
                    style: GoogleFonts.shareTechMono(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPurchaseBanner(UserDataProvider provider) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[900]!.withOpacity(0.15),
        border: Border.all(color: Colors.red[900]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            'ADQUIRIR ACCESO TOTAL',
            style: GoogleFonts.shareTechMono(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Desbloquea 6,600 SEGS extra + Beneficios de tienda',
            textAlign: TextAlign.center,
            style: GoogleFonts.shareTechMono(fontSize: 12, color: Colors.white70),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 45,
            child: ElevatedButton(
              onPressed: _isProcessing ? null : () => _confirmPurchase(provider),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[900],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
              child: _isProcessing
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('COMPRAR POR '),
                        const SizedBox(width: 4),
                        CoinDisplay(amount: 2500, size: CoinDisplaySize.small),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelsList(UserDataProvider provider) {
    final inventory = provider.inventory;
    final currentLevel = inventory.battlePassLevel;
    final hasPass = provider.hasActiveBattlePass;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 20,
      itemBuilder: (context, index) {
        final level = index + 1;
        final reward = _rewards[index];
        final isUnlocked = currentLevel >= level;
        final isClaimed = inventory.claimedBattlePassRewards.contains(level);
        final canClaim = hasPass && isUnlocked && !isClaimed;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isUnlocked ? Colors.red[900]!.withOpacity(0.1) : Colors.white.withOpacity(0.05),
            border: Border.all(
              color: isUnlocked ? Colors.red[900]! : Colors.white10,
              width: isUnlocked ? 1.5 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              // Level number
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isUnlocked ? Colors.red[900] : Colors.grey[900],
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$level',
                    style: GoogleFonts.shareTechMono(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Reward info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'RECOMPENSA',
                      style: GoogleFonts.shareTechMono(fontSize: 10, color: Colors.white60),
                    ),
                    CoinDisplay(
                      amount: reward,
                      size: CoinDisplaySize.medium,
                      textColor: Colors.white,
                    ),
                  ],
                ),
              ),

              // Action button
              if (isClaimed)
                const Icon(Icons.check_circle, color: Colors.green, size: 28)
              else if (canClaim)
                ElevatedButton(
                  onPressed: _isProcessing ? null : () => _claimReward(provider, level, reward),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                  child: Text('RECLAMAR', style: GoogleFonts.shareTechMono(fontSize: 12)),
                )
              else
                Column(
                  children: [
                    Icon(
                      isUnlocked ? Icons.lock_open : Icons.lock,
                      color: isUnlocked ? Colors.white38 : Colors.white10,
                      size: 20,
                    ),
                    Text(
                      isUnlocked ? 'PREMIUM' : 'BLOQUEADO',
                      style: GoogleFonts.shareTechMono(
                        fontSize: 8,
                        color: isUnlocked ? Colors.white38 : Colors.white10,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmPurchase(UserDataProvider provider) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text('CONFIRMAR ADQUISICIÓN', style: GoogleFonts.shareTechMono(color: Colors.white)),
        content: Text(
          '¿Estás seguro de adquirir el ACCESO TOTAL por 2,500 SEGS?',
          style: GoogleFonts.shareTechMono(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('CANCELAR', style: GoogleFonts.shareTechMono(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('CONFIRMAR', style: GoogleFonts.shareTechMono(color: Colors.red)),
          ),
        ],
      ),
    );

    if (result == true) {
      if (provider.inventory.coins < 2500) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('SEGS INSUFICIENTES', style: GoogleFonts.shareTechMono())),
        );
        return;
      }

      setState(() => _isProcessing = true);
      final success = await provider.purchaseBattlePass(2500);
      setState(() => _isProcessing = false);

      if (success && mounted) {
        _showSuccessAnimation('ACCESO TOTAL ACTIVADO');
      }
    }
  }

  Future<void> _claimReward(UserDataProvider provider, int level, int amount) async {
    setState(() => _isProcessing = true);
    final success = await provider.claimBattlePassReward(level, amount);
    setState(() => _isProcessing = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green[800],
          content: Text('RECOMPENSA RECLAMADA: $amount SEGS', style: GoogleFonts.shareTechMono()),
        ),
      );
    }
  }

  void _showSuccessAnimation(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red[900],
        content: Row(
          children: [
            const Icon(Icons.stars, color: Colors.white),
            const SizedBox(width: 12),
            Text(message, style: GoogleFonts.shareTechMono()),
          ],
        ),
      ),
    );
  }
}

class ScanlinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 0.5;

    for (double i = 0; i < size.height; i += 4) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
