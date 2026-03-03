import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../config/constants.dart';
import '../../config/theme_colors.dart';

class DataUsageScreen extends StatefulWidget {
  const DataUsageScreen({super.key});

  @override
  State<DataUsageScreen> createState() => _DataUsageScreenState();
}

class _DataUsageScreenState extends State<DataUsageScreen> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  
  int _totalConnections = 0;
  int _totalMessages = 0;
  int _totalEvents = 0;
  int _totalMedia = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final connections = await _supabase
          .from('conexiones')
          .select()
          .eq('usuario_id', userId)
          .count();
      
      final messages = await _supabase
          .from('conversaciones')
          .select()
          .eq('remitente_id', userId)
          .count();
      
      final events = await _supabase
          .from('eventos')
          .select()
          .eq('organizador_id', userId)
          .count();
      
      final media = await _supabase
          .from('archivos_multimedia')
          .select()
          .eq('profile_id', userId)
          .count();

      if (mounted) {
        setState(() {
          _totalConnections = connections.count;
          _totalMessages = messages.count;
          _totalEvents = events.count;
          _totalMedia = media.count;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading stats: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('USO DE DATOS', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, letterSpacing: 2)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppConstants.primaryColor))
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildSection('ESTADÍSTICAS'),
                _buildStatCard('Conexiones', _totalConnections, Icons.people_rounded, Colors.blue),
                _buildStatCard('Mensajes Enviados', _totalMessages, Icons.message_rounded, Colors.green),
                _buildStatCard('Eventos Creados', _totalEvents, Icons.event_rounded, Colors.orange),
                _buildStatCard('Archivos Multimedia', _totalMedia, Icons.photo_library_rounded, Colors.purple),
                
                const SizedBox(height: 30),
                _buildInfoCard(),
              ],
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
          fontSize: 12,
          fontWeight: FontWeight.w900,
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, int count, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ThemeColors.divider(context)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: ThemeColors.secondaryText(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  count.toString(),
                  style: GoogleFonts.outfit(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppConstants.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppConstants.primaryColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: AppConstants.primaryColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Estas estadísticas muestran tu actividad en la plataforma.',
              style: GoogleFonts.outfit(
                color: ThemeColors.secondaryText(context),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
