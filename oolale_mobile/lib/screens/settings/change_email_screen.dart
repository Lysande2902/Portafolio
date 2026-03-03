import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../config/constants.dart';
import '../../config/theme_colors.dart';

class ChangeEmailScreen extends StatefulWidget {
  const ChangeEmailScreen({super.key});

  @override
  State<ChangeEmailScreen> createState() => _ChangeEmailScreenState();
}

class _ChangeEmailScreenState extends State<ChangeEmailScreen> {
  final _supabase = Supabase.instance.client;
  final _newEmailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLoading = false;
  bool _passwordVisible = false;
  String? _errorMessage;
  String _currentEmail = '';

  @override
  void initState() {
    super.initState();
    _currentEmail = _supabase.auth.currentUser?.email ?? '';
  }

  @override
  void dispose() {
    _newEmailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _changeEmail() async {
    if (_newEmailController.text.isEmpty) {
      setState(() => _errorMessage = 'Ingresa el nuevo email');
      return;
    }

    if (_passwordController.text.isEmpty) {
      setState(() => _errorMessage = 'Ingresa tu contraseña para confirmar');
      return;
    }

    if (!_newEmailController.text.contains('@')) {
      setState(() => _errorMessage = 'Email inválido');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Verificar contraseña primero
      await _supabase.auth.signInWithPassword(
        email: _currentEmail,
        password: _passwordController.text,
      );

      // Cambiar email
      await _supabase.auth.updateUser(
        UserAttributes(email: _newEmailController.text),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email actualizado. Verifica tu nuevo email para confirmar el cambio.'),
            backgroundColor: AppConstants.primaryColor,
            duration: Duration(seconds: 5),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('Error changing email: $e');
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().contains('Invalid login')
              ? 'Contraseña incorrecta'
              : 'Error al cambiar email. Intenta de nuevo.';
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
        title: Text('CAMBIAR EMAIL', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, letterSpacing: 2)),
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
            _buildSection('CONFIGURACIÓN ACTUAL'),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: ThemeColors.divider(context).withOpacity(0.1)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppConstants.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.email_rounded, color: AppConstants.primaryColor, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Email actual', style: GoogleFonts.outfit(fontSize: 12, color: ThemeColors.secondaryText(context))),
                        const SizedBox(height: 2),
                        Text(
                          _currentEmail,
                          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
            _buildSection('NUEVOS DATOS'),
            
            _buildInputField(
              controller: _newEmailController,
              label: 'Nuevo Email',
              hint: 'ejemplo@correo.com',
              icon: Icons.alternate_email_rounded,
              keyboardType: TextInputType.emailAddress,
            ),

            const SizedBox(height: 16),
            
            _buildInputField(
              controller: _passwordController,
              label: 'Contraseña Actual',
              hint: 'Confirma con tu contraseña',
              icon: Icons.lock_outline_rounded,
              isPassword: true,
              visible: _passwordVisible,
              onToggleVisibility: () => setState(() => _passwordVisible = !_passwordVisible),
            ),

            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 16),
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

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _changeEmail,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                      )
                    : Text('ACTUALIZAR EMAIL', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, letterSpacing: 1)),
              ),
            ),

            const SizedBox(height: 32),
            _buildInfoCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
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

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool visible = false,
    VoidCallback? onToggleVisibility,
    TextInputType? keyboardType,
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
        keyboardType: keyboardType,
        style: GoogleFonts.outfit(fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.outfit(color: ThemeColors.hintText(context), fontSize: 14),
          hintText: hint,
          hintStyle: GoogleFonts.outfit(color: ThemeColors.hintText(context).withOpacity(0.5), fontSize: 14),
          prefixIcon: Icon(icon, color: AppConstants.primaryColor.withOpacity(0.7), size: 20),
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

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppConstants.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppConstants.primaryColor.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, color: AppConstants.primaryColor, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Por motivos de seguridad, te enviaremos un email de confirmación a tu nueva dirección. El cambio no será efectivo hasta que lo verifiques.',
              style: GoogleFonts.outfit(
                color: ThemeColors.secondaryText(context),
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
