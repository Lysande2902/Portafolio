import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/constants.dart';
import '../../config/theme_colors.dart';

class HireMusicianScreen extends StatefulWidget {
  const HireMusicianScreen({super.key});

  @override
  State<HireMusicianScreen> createState() => _HireMusicianScreenState();
}

class _HireMusicianScreenState extends State<HireMusicianScreen> with SingleTickerProviderStateMixin {
  final _supabase = Supabase.instance.client;
  late TabController _tabController;
  
  List<Map<String, dynamic>> _receivedOffers = [];
  List<Map<String, dynamic>> _sentOffers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadHirings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadHirings() async {
    final myId = _supabase.auth.currentUser?.id;
    if (myId == null) return;

    setState(() => _isLoading = true);

    try {
      // Obtener lista de usuarios bloqueados
      final blockedUsers = await _supabase
          .from('usuarios_bloqueados')
          .select('bloqueado_id')
          .eq('usuario_id', myId)
          .eq('activo', true);
      
      final blockedIds = blockedUsers.map((b) => b['bloqueado_id'] as String).toList();

      // Ofertas recibidas (donde yo soy el músico)
      final received = await _supabase
          .from('contrataciones')
          .select('*, employer:perfiles(nombre_artistico, foto_perfil)')
          .eq('musician_id', myId)
          .order('created_at', ascending: false);

      // Ofertas enviadas (donde yo soy el empleador)
      final sent = await _supabase
          .from('contrataciones')
          .select('*, musician:perfiles(nombre_artistico, foto_perfil)')
          .eq('employer_id', myId)
          .order('created_at', ascending: false);

      if (mounted) {
        // Filtrar ofertas de usuarios bloqueados
        final filteredReceived = (received as List)
            .where((offer) => !blockedIds.contains(offer['employer_id']))
            .toList();
        
        final filteredSent = (sent as List)
            .where((offer) => !blockedIds.contains(offer['musician_id']))
            .toList();

        setState(() {
          _receivedOffers = List<Map<String, dynamic>>.from(filteredReceived);
          _sentOffers = List<Map<String, dynamic>>.from(filteredSent);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading hirings: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _respondToOffer(int hiringId, String action) async {
    try {
      await _supabase
          .from('contrataciones')
          .update({'estado': action})
          .eq('id', hiringId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(action == 'aceptado' ? 'Oferta aceptada' : 'Oferta rechazada'),
            backgroundColor: action == 'aceptado' ? AppConstants.successColor : AppConstants.errorColor,
          ),
        );
        _loadHirings();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al procesar oferta')),
        );
      }
    }
  }

  void _showCreateOfferDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CreateOfferSheet(onCreated: _loadHirings),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('CONTRATACIONES', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, letterSpacing: 2)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppConstants.primaryColor,
          labelColor: AppConstants.primaryColor,
          unselectedLabelColor: ThemeColors.secondaryText(context),
          tabs: [
            Tab(text: 'Recibidas (${_receivedOffers.length})'),
            Tab(text: 'Enviadas (${_sentOffers.length})'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppConstants.primaryColor))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildReceivedList(),
                _buildSentList(),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateOfferDialog,
        backgroundColor: AppConstants.primaryColor,
        icon: const Icon(Icons.add, color: Colors.black),
        label: Text('Nueva Oferta', style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildReceivedList() {
    if (_receivedOffers.isEmpty) {
      return _buildEmptyState('No has recibido ofertas de trabajo');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _receivedOffers.length,
      itemBuilder: (context, index) {
        final offer = _receivedOffers[index];
        final employer = offer['employer'] as Map<String, dynamic>?;
        
        return _OfferCard(
          offer: offer,
          otherUser: employer,
          isReceived: true,
          onAccept: () => _respondToOffer(offer['id'], 'aceptado'),
          onReject: () => _respondToOffer(offer['id'], 'rechazado'),
        );
      },
    );
  }

  Widget _buildSentList() {
    if (_sentOffers.isEmpty) {
      return _buildEmptyState('No has enviado ofertas de trabajo');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _sentOffers.length,
      itemBuilder: (context, index) {
        final offer = _sentOffers[index];
        final musician = offer['musician'] as Map<String, dynamic>?;
        
        return _OfferCard(
          offer: offer,
          otherUser: musician,
          isReceived: false,
        );
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.work_outline, size: 80, color: ThemeColors.disabledText(context)),
          const SizedBox(height: 20),
          Text(message, style: GoogleFonts.outfit(color: ThemeColors.secondaryText(context), fontSize: 16)),
        ],
      ),
    );
  }
}

class _OfferCard extends StatelessWidget {
  final Map<String, dynamic> offer;
  final Map<String, dynamic>? otherUser;
  final bool isReceived;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;

  const _OfferCard({
    required this.offer,
    required this.otherUser,
    required this.isReceived,
    this.onAccept,
    this.onReject,
  });

  Color _getStatusColor(String estado) {
    switch (estado) {
      case 'aceptado':
        return AppConstants.successColor;
      case 'rechazado':
        return AppConstants.errorColor;
      case 'completado':
        return AppConstants.successColor;
      default:
        return AppConstants.infoColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final estado = offer['estado'] ?? 'pendiente';
    final isPending = estado == 'pendiente';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _getStatusColor(estado).withOpacity(0.3)),
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              radius: 28,
              backgroundColor: AppConstants.primaryColor.withOpacity(0.2),
              child: Text(
                (otherUser?['nombre_artistico'] ?? 'U')[0].toUpperCase(),
                style: const TextStyle(color: AppConstants.primaryColor, fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
            title: Text(
              otherUser?['nombre_artistico'] ?? 'Usuario',
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  offer['tipo_trabajo']?.toString().toUpperCase() ?? 'TRABAJO',
                  style: const TextStyle(color: AppConstants.primaryColor, fontSize: 11, fontWeight: FontWeight.bold),
                ),
                if (offer['presupuesto'] != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '\$${offer['presupuesto']}',
                    style: const TextStyle(color: AppConstants.successColor, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],
              ],
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _getStatusColor(estado).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                estado.toUpperCase(),
                style: TextStyle(color: _getStatusColor(estado), fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          if (offer['descripcion'] != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  offer['descripcion'],
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ),
            ),
          if (isReceived && isPending)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onReject,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white54,
                        side: const BorderSide(color: Colors.white24),
                      ),
                      child: const Text('Rechazar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onAccept,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.primaryColor,
                        foregroundColor: Colors.black,
                      ),
                      child: const Text('Aceptar'),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _CreateOfferSheet extends StatefulWidget {
  final VoidCallback onCreated;

  const _CreateOfferSheet({required this.onCreated});

  @override
  State<_CreateOfferSheet> createState() => _CreateOfferSheetState();
}

class _CreateOfferSheetState extends State<_CreateOfferSheet> {
  final _supabase = Supabase.instance.client;
  final _descController = TextEditingController();
  final _budgetController = TextEditingController();
  String _selectedType = 'session';
  final bool _isCreating = false;

  final List<String> _types = ['session', 'tour', 'event', 'recording'];

  @override
  void dispose() {
    _descController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _createOffer() async {
    // Por ahora, esto requeriría seleccionar un músico
    // Simplificado para demostración
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Primero selecciona un músico desde Discovery o Conexiones')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(30),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nueva Oferta de Trabajo', style: GoogleFonts.outfit(color: ThemeColors.primaryText(context), fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              initialValue: _selectedType,
              dropdownColor: AppConstants.backgroundColor,
              decoration: const InputDecoration(labelText: 'Tipo de Trabajo'),
              items: _types.map((t) => DropdownMenuItem(value: t, child: Text(t.toUpperCase()))).toList(),
              onChanged: (v) => setState(() => _selectedType = v!),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Descripción'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _budgetController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Presupuesto (\$)', prefixText: '\$ '),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isCreating ? null : _createOffer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isCreating
                    ? const CircularProgressIndicator(color: Colors.black)
                    : const Text('Crear Oferta'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
