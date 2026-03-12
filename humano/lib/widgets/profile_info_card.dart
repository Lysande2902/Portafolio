import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/arc_progress_provider.dart';

class ProfileInfoCard extends StatelessWidget {
  final VoidCallback onLogout;

  const ProfileInfoCard({
    super.key,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final arcProgressProvider = Provider.of<ArcProgressProvider>(context);
    
    final user = authProvider.currentUser;
    final email = user?.email ?? 'Usuario';
    
    // Count completed arcs
    int completedArcs = 0;
    for (int i = 1; i <= 7; i++) {
      final progress = arcProgressProvider.getProgress('arc_${i}_');
      if (progress != null && progress.status.name == 'completed') {
        completedArcs++;
      }
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        border: Border.all(
          color: Colors.grey[800]!,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Email/Username
          Row(
            children: [
              Icon(Icons.person, color: Colors.red[300], size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  email,
                  style: GoogleFonts.courierPrime(
                    fontSize: 14,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 15),
          
          // Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStat('ARCOS', '$completedArcs/7'),
              _buildStat('TIEMPO', '0h 0m'), // Placeholder
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Logout button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onLogout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[900],
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                'CERRAR SESIÓN',
                style: GoogleFonts.courierPrime(
                  fontSize: 14,
                  color: Colors.white,
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.courierPrime(
            fontSize: 10,
            color: Colors.grey[600],
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.courierPrime(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}
