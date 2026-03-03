import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/constants.dart';
import '../../config/theme_colors.dart';
import '../../providers/auth_provider.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final _supabase = Supabase.instance.client;
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  
  bool _isLoading = false;
  bool _passwordVisible = false;
  bool _agreedToTerms = false;
  String? _errorMessage;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _deleteAccount() async {
    if (!_agreedToTerms) {
      setState(() => _errorMessage = 'Debes aceptar los términos para continuar');
      return;
    }

    if (_passwordController.text.isEmpty) {
      setState(() => _errorMessage = 'Ingresa tu contraseña para confirmar');
      return;
    }

    if (_confirmController.text != 'ELIMINAR') {
      setState(() => _errorMessage = 'Debes escribir "ELIMINAR" para confirmar');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

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

      // Marcar cuenta como eliminada (soft delete)
      await _supabase
          .from('perfiles')
          .update({
            'deleted_at': DateTime.now().toIso8601String(),
            'is_active': false,
          })
          .eq('id', userId);

      // Cerrar sesión
      await _supabase.auth.signOut();

      if (mounted) {
        await Provider.of<AuthProvider>(context, listen: false).logout();
        
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Tu cuenta ha sido eliminada exitosamente'),
            backgroundColor: AppConstants.primaryColor,
            duration: Duration(seconds: 3),
          ),
        );

        context.go('/login');
      }
    } catch (e) {
      debugPrint('Error deleting account: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Error al eliminar cuenta. Intenta de nuevo.';
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
        title: Text('ELIMINAR CUENTA', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, letterSpacing: 2)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: ThemeColors.icon(context)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWarningCard(),
            const SizedBox(height: 32),
            
            _buildSection('¿QUÉ SUCEDERÁ CON TU INFO?'),
            _buildInfoItem(Icons.person_remove_rounded, 'Perfil e identidad artística eliminados'),
            _buildInfoItem(Icons.auto_awesome_motion_rounded, 'Galería, fotos y videos borrados'),
            _buildInfoItem(Icons.forum_rounded, 'Conversaciones y mensajes perdidos'),
            _buildInfoItem(Icons.star_half_rounded, 'Tu reputación y ratings se perderán'),
            
            const SizedBox(height: 32),
            _buildSection('CONFIRMAR ACCIÓN PERMANENTE'),
            
            _buildInputField(
              controller: _passwordController,
              label: 'Tu Contraseña',
              hint: 'Confirma tu identidad',
              icon: Icons.lock_outline_rounded,
              isPassword: true,
              visible: _passwordVisible,
              onToggleVisibility: () => setState(() => _passwordVisible = !_passwordVisible),
            ),

            const SizedBox(height: 16),

            _buildInputField(
              controller: _confirmController,
              label: 'Confirmación de Seguridad',
              hint: 'Escribe "ELIMINAR"',
              icon: Icons.security_rounded,
            ),

            const SizedBox(height: 20),

            _buildCheckboxTile(),

            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppConstants.errorColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppConstants.errorColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: AppConstants.errorColor, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: GoogleFonts.outfit(color: AppConstants.errorColor, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _deleteAccount,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.errorColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Text('ELIMINAR MI CUENTA DE FORMA PERMANENTE', 
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1)),
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton(
                onPressed: _isLoading ? null : () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: ThemeColors.primaryText(context),
                  side: BorderSide(color: ThemeColors.divider(context).withOpacity(0.2)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text('CANCELAR Y VOLVER', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWarningCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppConstants.errorColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppConstants.errorColor.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        children: [
          const Icon(Icons.report_problem_rounded, color: AppConstants.errorColor, size: 48),
          const SizedBox(height: 16),
          Text(
            'ZONA DE PELIGRO',
            style: GoogleFonts.outfit(
              color: AppConstants.errorColor,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Estás a punto de borrar tu carrera en Óolale. Esta acción no se puede deshacer y perderás todas tus conexiones y reputación acumulada.',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              color: ThemeColors.secondaryText(context),
              fontSize: 13,
              height: 1.5,
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
          fontSize: 11,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppConstants.errorColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppConstants.errorColor, size: 18),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.outfit(
                color: ThemeColors.secondaryText(context),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool visible = false,
    VoidCallback? onToggleVisibility,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ThemeColors.divider(context).withOpacity(0.1)),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && !visible,
        style: GoogleFonts.outfit(fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.outfit(color: ThemeColors.hintText(context), fontSize: 13),
          hintText: hint,
          hintStyle: GoogleFonts.outfit(color: ThemeColors.hintText(context).withOpacity(0.4), fontSize: 13),
          prefixIcon: Icon(icon, color: AppConstants.errorColor.withOpacity(0.6), size: 20),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(visible ? Icons.visibility_off : Icons.visibility, size: 20),
                  onPressed: onToggleVisibility,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          filled: false,
        ),
      ),
    );
  }

  Widget _buildCheckboxTile() {
    return InkWell(
      onTap: () => setState(() => _agreedToTerms = !_agreedToTerms),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _agreedToTerms ? AppConstants.errorColor.withOpacity(0.05) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _agreedToTerms ? AppConstants.errorColor.withOpacity(0.2) : ThemeColors.divider(context).withOpacity(0.1),
          ),
        ),
        child: Row(
          children: [
            Checkbox(
              value: _agreedToTerms,
              onChanged: (val) => setState(() => _agreedToTerms = val ?? false),
              activeColor: AppConstants.errorColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
            Expanded(
              child: Text(
                'Entiendo que esta acción es definitiva y borra toda mi carrera en la plataforma.',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  color: _agreedToTerms ? ThemeColors.primaryText(context) : ThemeColors.secondaryText(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
