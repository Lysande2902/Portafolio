import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../config/constants.dart';
import '../events/events_screen.dart';
import '../profile/profile_screen.dart';
import 'search_screen.dart'; // Import SearchScreen

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      _DashboardView(onTabChange: (index) => setState(() => _currentIndex = index)),
      const UserSearchScreen(), 
      const EventsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [AppConstants.primaryColor, Colors.white],
          ).createShader(bounds),
          child: Text(
            AppConstants.appName,
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: Colors.white,
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => context.push('/notifications'),
            icon: const Icon(Icons.notifications_none_rounded, color: Colors.white70),
          ),
          IconButton(
            onPressed: () => context.push('/messages'),
            icon: const Icon(Icons.chat_bubble_outline_rounded, color: Colors.white70),
          ),
          IconButton(
            onPressed: () => context.push('/settings'),
            icon: const Icon(Icons.settings_outlined, color: AppConstants.primaryColor),
          )
        ],
      ),
      body: screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Colors.white10)),
          color: Color(0xFF141414),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: Colors.transparent,
          selectedItemColor: AppConstants.primaryColor,
          unselectedItemColor: Colors.white38,
          selectedLabelStyle: GoogleFonts.outfit(fontSize: 12),
          unselectedLabelStyle: GoogleFonts.outfit(fontSize: 12),
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_rounded),
              label: 'Inicio',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search_rounded),
              label: 'Buscar',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_rounded),
              label: 'Eventos',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardView extends StatelessWidget {
  final Function(int) onTabChange;
  const _DashboardView({required this.onTabChange});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppConstants.primaryColor.withOpacity(0.15), Colors.transparent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppConstants.primaryColor.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [AppConstants.primaryColor, AppConstants.accentColor],
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 28,
                    backgroundColor: AppConstants.backgroundColor,
                    child: Text(
                      user?.name.substring(0, 1).toUpperCase() ?? 'U',
                      style: GoogleFonts.outfit(
                        color: AppConstants.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '¡Hola de nuevo!',
                        style: GoogleFonts.outfit(
                          color: Colors.white54,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        user?.name ?? 'Usuario',
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppConstants.accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppConstants.accentColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    'PRO',
                    style: GoogleFonts.outfit(
                      color: AppConstants.accentColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              ],
            ),
          ),
          
          const SizedBox(height: 30),
          
          _buildSectionTitle('Explorar Servicios'),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(child: _ActionCard(
                icon: Icons.music_note_rounded, 
                label: 'Eventos', 
                color: AppConstants.primaryColor,
                onTap: () => onTabChange(2),
              )),
              const SizedBox(width: 15),
              Expanded(child: _ActionCard(
                icon: Icons.people_alt_rounded, 
                label: 'Músicos', 
                color: Colors.purpleAccent,
                onTap: () => onTabChange(1),
              )),
            ],
          ),
          
          const SizedBox(height: 30),
          
          _buildSectionTitle('Próximos Eventos'),
          const SizedBox(height: 15),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppConstants.cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              children: [
                const Icon(Icons.calendar_today, size: 40, color: Colors.white24),
                const SizedBox(height: 10),
                Text(
                  'Panel de inicio rápido',
                  style: GoogleFonts.outfit(color: Colors.white60),
                ),
                TextButton(
                  onPressed: () {
                     // Tab controller via context ideally, or just nav
                  },
                  child: Text(
                    'Ver mis eventos',
                    style: GoogleFonts.outfit(color: AppConstants.primaryColor),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120, // Uniform height
        decoration: BoxDecoration(
          color: AppConstants.cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white10),
          gradient: LinearGradient(
            colors: [Colors.white.withOpacity(0.05), Colors.transparent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: color.withOpacity(0.2)),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
