import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../config/constants.dart';
import '../../config/theme_colors.dart';
import '../../utils/error_handler.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;
  
  // Password strength
  double _passwordStrength = 0.0;
  String _passwordStrengthText = '';
  Color _passwordStrengthColor = Colors.red;


  void _checkPasswordStrength(String password) {
    double strength = 0.0;
    String text = '';
    Color color = Colors.red;

    if (password.isEmpty) {
      setState(() {
        _passwordStrength = 0.0;
        _passwordStrengthText = '';
        _passwordStrengthColor = Colors.red;
      });
      return;
    }

    // Length check
    if (password.length >= 8) strength += 0.25;
    if (password.length >= 12) strength += 0.15;

    // Contains uppercase
    if (password.contains(RegExp(r'[A-Z]'))) strength += 0.2;

    // Contains lowercase
    if (password.contains(RegExp(r'[a-z]'))) strength += 0.2;

    // Contains numbers
    if (password.contains(RegExp(r'[0-9]'))) strength += 0.2;

    // Contains special characters
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength += 0.2;

    // Determine text and color
    if (strength <= 0.3) {
      text = 'Débil';
      color = Colors.red;
    } else if (strength <= 0.6) {
      text = 'Media';
      color = Colors.orange;
    } else if (strength <= 0.8) {
      text = 'Buena';
      color = Colors.yellow[700]!;
    } else {
      text = 'Excelente';
      color = Colors.green;
    }

    setState(() {
      _passwordStrength = strength;
      _passwordStrengthText = text;
      _passwordStrengthColor = color;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Usamos LayoutBuilder para saber la altura disponible y ajustar si es necesario
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Fondo decorativo sutil
          Positioned(
            top: -150,
            left: -100,
            child: CircleAvatar(
              radius: 200,
              backgroundColor: AppConstants.primaryLight.withOpacity(0.07),
            ),
          ),
          
          SafeArea(
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      SizedBox(height: isSmallScreen ? 20 : 40), // Bajamos el header (antes 10:20)
                      
                      // Header con mejor espaciado
                      FadeInDown(
                        duration: const Duration(milliseconds: 800),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () => context.go('/login'),
                              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 22),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.white.withOpacity(0.05),
                                padding: const EdgeInsets.all(10),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'CREAR CUENTA',
                                    style: GoogleFonts.outfit(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -0.5,
                                      color: Colors.white,
                                      height: 1,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Únete a la mayor red de músicos',
                                    style: GoogleFonts.outfit(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Spacer(flex: 2),

                      // Name Field
                      FadeInUp(
                        delay: const Duration(milliseconds: 100),
                        child: _buildErgonomicTextField(
                          controller: _nameController,
                          label: 'NOMBRE ARTÍSTICO',
                          hint: 'Ej: DJ Mike',
                          icon: Icons.person_outline_rounded,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Email Field
                      FadeInUp(
                        delay: const Duration(milliseconds: 200),
                        child: _buildErgonomicTextField(
                          controller: _emailController,
                          label: 'CORREO ELECTRÓNICO',
                          hint: 'tu@correo.com',
                          icon: Icons.alternate_email_rounded,
                          inputType: TextInputType.emailAddress,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Password Field
                      FadeInUp(
                        delay: const Duration(milliseconds: 300),
                        child: _buildErgonomicTextField(
                          controller: _passwordController,
                          label: 'CONTRASEÑA',
                          hint: 'Mínimo 8 caracteres',
                          icon: Icons.lock_outline_rounded,
                          isPassword: true,
                          obscureText: _obscurePassword,
                          onChanged: _checkPasswordStrength,
                          toggleObscure: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      
                      // Strength Indicator
                      if (_passwordController.text.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: _passwordStrength,
                                  backgroundColor: Colors.white.withOpacity(0.05),
                                  valueColor: AlwaysStoppedAnimation<Color>(_passwordStrengthColor),
                                  minHeight: 3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],

                      const SizedBox(height: 16),

                      // Confirm Password Field
                      FadeInUp(
                        delay: const Duration(milliseconds: 400),
                        child: _buildErgonomicTextField(
                          controller: _confirmPasswordController,
                          label: 'CONFIRMAR CONTRASEÑA',
                          hint: 'Repite tu contraseña',
                          icon: Icons.lock_outline_rounded,
                          isPassword: true,
                          obscureText: _obscureConfirmPassword,
                          toggleObscure: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Terms and Conditions - Cómodo de tocar
                      FadeInUp(
                        delay: const Duration(milliseconds: 500),
                        child: GestureDetector(
                          onTap: () => setState(() => _acceptTerms = !_acceptTerms),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: _acceptTerms ? AppConstants.primaryColor.withOpacity(0.08) : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: Checkbox(
                                    value: _acceptTerms, 
                                    onChanged: (v) => setState(() => _acceptTerms = v!),
                                    activeColor: AppConstants.primaryColor,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                    side: const BorderSide(color: Colors.white24, width: 2),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text.rich(
                                    TextSpan(
                                      text: 'Acepto los ',
                                      style: GoogleFonts.outfit(fontSize: 13, color: Colors.white70),
                                      children: [
                                        TextSpan(
                                          text: 'Términos y Condiciones',
                                          style: GoogleFonts.outfit(fontWeight: FontWeight.w700, color: AppConstants.primaryColor),
                                        ),
                                      ],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const Spacer(flex: 3),

                      // Register Button - Grande y cómodo
                      FadeInUp(
                        delay: const Duration(milliseconds: 600),
                        child: _isLoading
                            ? const Center(child: CircularProgressIndicator(color: AppConstants.primaryColor))
                            : SizedBox(
                                width: double.infinity,
                                height: 56, // Altura estándar cómoda
                                child: ElevatedButton(
                                  onPressed: _acceptTerms ? _handleRegister : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppConstants.primaryColor,
                                    foregroundColor: Colors.black,
                                    disabledBackgroundColor: Colors.white.withOpacity(0.05),
                                    disabledForegroundColor: Colors.white24,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                  ),
                                  child: Text(
                                    'CREAR CUENTA',
                                    style: GoogleFonts.outfit(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                ),
                              ),
                      ),

                      const SizedBox(height: 20),

                      // Login Link
                      FadeInUp(
                        delay: const Duration(milliseconds: 700),
                        child: TextButton(
                          onPressed: () => context.go('/login'),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text.rich(
                            TextSpan(
                              text: '¿YA TIENES CUENTA? ',
                              style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 1, color: Colors.white54),
                              children: [
                                TextSpan(
                                  text: 'INICIA SESIÓN',
                                  style: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: AppConstants.primaryColor, letterSpacing: 1),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: isSmallScreen ? 10 : 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget auxiliar ergonómico (ni muy grande ni muy pequeño)
  Widget _buildErgonomicTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    TextInputType inputType = TextInputType.text,
    VoidCallback? toggleObscure,
    void Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            label,
            style: GoogleFonts.outfit(
              color: Colors.white38,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
            ),
          ),
        ),
        SizedBox(
          height: 52, // Altura cómoda
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: inputType,
            style: GoogleFonts.outfit(
              fontSize: 16, // Fuente legible
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
            cursorColor: AppConstants.primaryColor,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.outfit(color: Colors.white24, fontSize: 15),
              prefixIcon: Icon(icon, color: AppConstants.primaryColor.withOpacity(0.6), size: 20),
              suffixIcon: isPassword ? IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                  color: Colors.white38,
                  size: 20,
                ),
                onPressed: toggleObscure,
              ) : null,
              filled: true,
              fillColor: Colors.white.withOpacity(0.03),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.05), width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppConstants.primaryColor, width: 1.5),
              ),
            ),
          ),
        ),
      ],
    );
  }



  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Debes aceptar los términos y condiciones',
            style: GoogleFonts.outfit(),
          ),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    setState(() => _isLoading = true);
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      // Registramos como usuario genérico ('user') ya que los roles específicos fueron eliminados
      final success = await authProvider.register(email, password, name, 'user');

      if (mounted) {
        setState(() => _isLoading = false);
        if (success) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '¡Cuenta creada! Bienvenido a ÓOLALE',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.green[700],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              duration: const Duration(seconds: 3),
            ),
          );
          context.go('/dashboard');
        } else {
          // Use ErrorHandler to show message from Provider
          ErrorHandler.showErrorSnackBar(
            context, 
            authProvider.errorMessage ?? 'Error al crear la cuenta',
            customMessage: authProvider.errorMessage,
          );
        }
      }
    } catch (e) {
      ErrorHandler.logError('RegisterScreen._handleRegister', e);
      if (mounted) {
        setState(() => _isLoading = false);
        ErrorHandler.showErrorSnackBar(context, e, customMessage: 'Error al registrar usuario');
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    super.dispose();
  }
}



