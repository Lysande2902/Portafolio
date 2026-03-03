import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../config/constants.dart';
import '../../config/theme_colors.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  String _selectedRol = 'musico';
  bool _isLoading = false;
  bool _showPassword = false;
  bool _showConfirmPassword = false;

  final Map<String, String> _roles = {
    'musico': 'Músico',
    'banda': 'Banda',
    'productor': 'Productor',
    'promotor': 'Promotor',
    'staff': 'Staff',
  };

  final Map<String, IconData> _roleIcons = {
    'musico': Icons.music_note_rounded,
    'banda': Icons.groups_rounded,
    'productor': Icons.tune_rounded,
    'promotor': Icons.event_rounded,
    'staff': Icons.engineering_rounded,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildHeader(),
                const SizedBox(height: 40),
                _buildRegisterForm(),
                const SizedBox(height: 20),
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return FadeInDown(
      duration: const Duration(milliseconds: 800),
      child: Column(
        children: [
          Text(
            AppConstants.appName,
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 40,
              fontWeight: FontWeight.w900,
              color: ThemeColors.primaryText(context),
            ),
          ),
          Text(
            AppConstants.appTagline,
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 12,
              color: AppConstants.primaryColor,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterForm() {
    return FadeInUp(
      delay: const Duration(milliseconds: 400),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFormGroup(
            label: 'Nombre Completo o Artístico',
            child: _buildTextField(
              controller: _nameController,
              hint: 'Tu nombre...',
              icon: Icons.person_outline,
            ),
          ),
          const SizedBox(height: 28),
          _buildFormGroup(
            label: 'Correo Electrónico',
            child: _buildTextField(
              controller: _emailController,
              hint: 'Tu correo...',
              icon: Icons.email_outlined,
            ),
          ),
          const SizedBox(height: 28),
          _buildRoleSelector(),
          const SizedBox(height: 28),
          _buildFormGroup(
            label: 'Contraseña',
            child: _buildTextField(
              controller: _passwordController,
              hint: 'Crea una contraseña segura...',
              icon: Icons.lock_outline,
              isPassword: true,
              showPassword: _showPassword,
              onTogglePassword: () => setState(() => _showPassword = !_showPassword),
            ),
          ),
          const SizedBox(height: 28),
          _buildFormGroup(
            label: 'Confirmar Contraseña',
            child: _buildTextField(
              controller: _confirmPasswordController,
              hint: 'Repite tu contraseña...',
              icon: Icons.lock_outline,
              isPassword: true,
              showPassword: _showConfirmPassword,
              onTogglePassword: () => setState(() => _showConfirmPassword = !_showConfirmPassword),
            ),
          ),
          const SizedBox(height: 40),
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildFormGroup({
    required String label,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Roboto',
              color: ThemeColors.secondaryText(context),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        child,
      ],
    );
  }

  Widget _buildRoleSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Tu rol en la escena',
            style: TextStyle(
              fontFamily: 'Roboto',
              color: ThemeColors.secondaryText(context),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          decoration: BoxDecoration(
            color: AppConstants.cardColor.withOpacity(0.8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppConstants.primaryColor.withOpacity(0.25),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppConstants.primaryColor.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedRol,
              isExpanded: true,
              dropdownColor: AppConstants.cardColor,
              icon: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppConstants.primaryColor.withOpacity(0.7),
                  size: 26,
                ),
              ),
              style: TextStyle(
                fontFamily: 'Roboto',
                color: ThemeColors.primaryText(context),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              items: _roles.entries.map((e) {
                return DropdownMenuItem<String>(
                  value: e.key,
                  child: Row(
                    children: [
                      Icon(
                        _roleIcons[e.key],
                        color: AppConstants.primaryColor.withOpacity(0.8),
                        size: 22,
                      ),
                      const SizedBox(width: 14),
                      Text(
                        e.value,
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          color: ThemeColors.primaryText(context),
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedRol = val);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool showPassword = false,
    VoidCallback? onTogglePassword,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppConstants.cardColor.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppConstants.primaryColor.withOpacity(0.25),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppConstants.primaryColor.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && !showPassword,
        style: TextStyle(
          fontFamily: 'Roboto',
          color: ThemeColors.primaryText(context),
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            fontFamily: 'Roboto',
            color: ThemeColors.hintText(context),
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 16, right: 12),
            child: Icon(
              icon,
              color: AppConstants.primaryColor.withOpacity(0.7),
              size: 22,
            ),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 50, minHeight: 50),
          suffixIcon: isPassword
              ? GestureDetector(
                  onTap: onTogglePassword,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Icon(
                      showPassword
                          ? Icons.visibility_rounded
                          : Icons.visibility_off_rounded,
                      color: AppConstants.primaryColor.withOpacity(0.7),
                      size: 22,
                    ),
                  ),
                )
              : null,
          suffixIconConstraints: const BoxConstraints(minWidth: 50, minHeight: 50),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 0,
            vertical: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleRegister,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 10,
          shadowColor: AppConstants.primaryColor.withOpacity(0.4),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
              )
            : const Text(
                'UNIRME A LA ESCENA',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 1.5,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Widget _buildFooter() {
    return FadeIn(
      delay: const Duration(milliseconds: 600),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '¿Ya tienes acreditación?',
            style: TextStyle(
              fontFamily: 'Roboto',
              color: Colors.white30,
            ),
          ),
          TextButton(
            onPressed: () => context.go('/login'),
            child: Text(
              'Inicia Sesión',
              style: TextStyle(
                fontFamily: 'Roboto',
                color: AppConstants.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleRegister() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirm.isEmpty) {
      _showError('Por favor llena todos los campos');
      return;
    }

    if (password != confirm) {
      _showError('Las contraseñas no corresponden');
      return;
    }

    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.register(email, password, name, _selectedRol);

    setState(() => _isLoading = false);

    if (success) {
      if (mounted) context.go('/dashboard');
    } else {
      if (mounted) _showError(authProvider.errorMessage ?? 'Error al registrarse');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontFamily: 'Roboto')),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
