import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/constants.dart';
import '../../config/theme_colors.dart';
import '../../providers/auth_provider.dart';

class SuspendAccountScreen extends StatefulWidget {
  const SuspendAccountScreen({super.key});

  @override
  State<SuspendAccountScreen> createState() => _SuspendAccountScreenState();
}

class _SuspendAccountScreenState extends State<SuspendAccountScreen> {
  final _supabase = Supabase.instance.client;
  final _passwordController = TextEditingController();
  
  bool _isLoading = false;
  bool _passwordVisible = false;
  String? _errorMessage;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _suspendAccount() async {
    if (_passwordController.text.isEmpty) {
      setState(() => _errorMessage = 'Ingresa tu contraseña para confirmar');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final messenger = ScaffoldMessenger.of(context);

    try {
      final userId = _supabase.auth.currentUser?.id;
      final email = _supabase.auth.currentUser?.email;

      if (userId == null || email == null) {
        throw Exception('Usuario no autenticado');
      }

      // Verificar contraseña
      try {
        await _supabase.auth.signInWithPassword(
          email: email,
          password: _passwordController.text,
        );
      } catch (e) {
        setState(() {
          _errorMessage = 'Contraseña incorrecta';
          _isLoading = false;
        });
        return;
      }

      // Marcar cuenta como inactiva
      await _supabase
          .from('perfiles')
          .update({
            'is_active': false,
            'suspended_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);

      // Cerrar sesión
      await _supabase.auth.signOut();

      if (mounted) {
        await Provider.of<AuthProvider>(context, listen: false).logout();
        
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Tu cuenta ha sido suspendida. Puedes reactivarla iniciando sesión nuevamente.'),
            backgroundColor: AppConstants.primaryColor,
            duration: Duration(seconds: 5),
          ),
        );

        context.go('/login');
      }
    } catch (e) {
      debugPrint('Error suspending account: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Error al suspender cuenta. Intenta de nuevo.';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('SUSPENDER CUENTA', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, letterSpacing: 2)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(),
            const SizedBox(height: 30),
            
            _buildSection('¿QUÉ SIGNIFICA ESTO?'),
            _buildInfoItem(Icons.visibility_off_rounded, 'Tu perfil ya no será visible para otros músicos'),
            _buildInfoItem(Icons.notifications_off_rounded, 'No recibirás notificaciones ni correos'),
            _buildInfoItem(Icons.history_rounded, 'Toda tu información, fotos y mensajes se guardarán por si decides volver'),
            _buildInfoItem(Icons.vpn_key_rounded, 'Puedes reactivar tu cuenta en cualquier momento simplemente iniciando sesión'),
            
            const SizedBox(height: 30),
            _buildSection('CONFIRMACIÓN'),
            
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: ThemeColors.divider(context)),
              ),
              child: TextField(
                controller: _passwordController,
                obscureText: !_passwordVisible,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  hintText: 'Ingresa tu contraseña para confirmar',
                  prefixIcon: const Icon(Icons.lock_rounded),
                  suffixIcon: IconButton(
                    icon: Icon(_passwordVisible ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _passwordVisible = !_passwordVisible),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),

            if (_errorMessage != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppConstants.errorColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppConstants.errorColor),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: AppConstants.errorColor, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: GoogleFonts.outfit(color: AppConstants.errorColor, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _suspendAccount,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                      )
                    : Text('SUSPENDER MI CUENTA', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
              ),
            ),

            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _isLoading ? null : () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: ThemeColors.primaryText(context),
                  side: BorderSide(color: ThemeColors.divider(context)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text('CANCELAR', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orangeAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orangeAccent, width: 2),
      ),
      child: Row(
        children: [
          const Icon(Icons.pause_circle_filled_rounded, color: Colors.orangeAccent, size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tómate un descanso',
                  style: GoogleFonts.outfit(
                    color: Colors.orangeAccent,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Si necesitas alejarte de la música por un tiempo, esta es la mejor opción.',
                  style: GoogleFonts.outfit(
                    color: ThemeColors.secondaryText(context),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 4),
      child: Text(
        title,
        style: GoogleFonts.outfit(
          color: AppConstants.primaryColor,
          fontSize: 12,
          fontWeight: FontWeight.w900,
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ThemeColors.divider(context)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.orangeAccent, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.outfit(
                color: ThemeColors.secondaryText(context),
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
