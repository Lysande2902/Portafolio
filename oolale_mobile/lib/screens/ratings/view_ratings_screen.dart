import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../config/constants.dart';
import '../../config/theme_colors.dart';
import '../../utils/error_handler.dart';
import 'package:intl/intl.dart';

class ViewRatingsScreen extends StatefulWidget {
  final String userId;
  final String userName;

  const ViewRatingsScreen({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  State<ViewRatingsScreen> createState() => _ViewRatingsScreenState();
}

class _ViewRatingsScreenState extends State<ViewRatingsScreen> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _ratings = [];
  bool _isLoading = true;
  double _averageRating = 0.0;
  int _totalRatings = 0;

  @override
  void initState() {
    super.initState();
    _loadRatings();
  }

  Future<void> _loadRatings() async {
    try {
      final data = await _supabase
          .from('referencias')
          .select('*, evaluador:perfiles!referencias_evaluador_id_fkey(id, nombre_artistico, foto_perfil)')
          .eq('evaluado_id', widget.userId)
          .order('created_at', ascending: false);

      if (data.isEmpty) {
        if (mounted) {
          setState(() {
            _ratings = [];
            _averageRating = 0.0;
            _totalRatings = 0;
            _isLoading = false;
          });
        }
        return;
      }

      final ratings = data.map((r) => r['puntuacion'] as int).toList();
      // FIX: Prevenir división por cero
      final average = ratings.isEmpty ? 0.0 : ratings.reduce((a, b) => a + b) / ratings.length;

      if (mounted) {
        setState(() {
          _ratings = List<Map<String, dynamic>>.from(data);
          _averageRating = average;
          _totalRatings = ratings.length;
          _isLoading = false;
        });
      }
    } catch (e) {
      ErrorHandler.logError('ViewRatingsScreen._loadRatings', e);
      if (mounted) {
        setState(() => _isLoading = false);
        ErrorHandler.showErrorDialog(
          context,
          e,
          title: 'Error cargando calificaciones',
          onRetry: _loadRatings,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Calificaciones', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        iconTheme: IconThemeData(color: ThemeColors.icon(context)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppConstants.primaryColor))
          : Column(
              children: [
                _buildRatingSummary(),
                Expanded(
                  child: _ratings.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          onRefresh: _loadRatings,
                          color: AppConstants.primaryColor,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _ratings.length,
                            itemBuilder: (context, index) {
                              return _buildRatingCard(_ratings[index]);
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildRatingSummary() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppConstants.primaryColor.withOpacity(0.2),
            AppConstants.primaryColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppConstants.primaryColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            widget.userName,
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: ThemeColors.primaryText(context),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _averageRating.toStringAsFixed(1),
                style: GoogleFonts.outfit(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.primaryColor,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: List.generate(5, (index) {
                      // FIX: Prevenir error con rating 0
                      final floorRating = _averageRating > 0 ? _averageRating.floor() : 0;
                      return Icon(
                        index < floorRating ? Icons.star : Icons.star_border,
                        color: AppConstants.primaryColor,
                        size: 20,
                      );
                    }),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$_totalRatings calificaciones',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: ThemeColors.secondaryText(context),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildRatingDistribution(),
        ],
      ),
    );
  }

  Widget _buildRatingDistribution() {
    final distribution = <int, int>{};
    for (var rating in _ratings) {
      final score = rating['puntuacion'] as int;
      distribution[score] = (distribution[score] ?? 0) + 1;
    }

    return Column(
      children: List.generate(5, (index) {
        final stars = 5 - index;
        final count = distribution[stars] ?? 0;
        final percentage = _totalRatings > 0 ? (count / _totalRatings) : 0.0;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Text(
                '$stars',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  color: ThemeColors.secondaryText(context),
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.star, size: 12, color: AppConstants.primaryColor),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percentage,
                    backgroundColor: ThemeColors.divider(context),
                    valueColor: const AlwaysStoppedAnimation<Color>(AppConstants.primaryColor),
                    minHeight: 8,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$count',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  color: ThemeColors.secondaryText(context),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.star_border,
              size: 80,
              color: ThemeColors.iconSecondary(context),
            ),
            const SizedBox(height: 20),
            Text(
              'Sin calificaciones aún',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: ThemeColors.primaryText(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Las calificaciones aparecerán aquí',
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: ThemeColors.secondaryText(context),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingCard(Map<String, dynamic> rating) {
    final evaluador = rating['evaluador'];
    final puntuacion = rating['puntuacion'] as int;
    final comentario = rating['comentario'] as String?;
    final verificado = rating['verificado'] as bool? ?? false;
    final createdAt = DateTime.parse(rating['created_at']);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ThemeColors.divider(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppConstants.bgDarkAlt,
                backgroundImage: evaluador['foto_perfil'] != null
                    ? NetworkImage(evaluador['foto_perfil'])
                    : null,
                child: evaluador['foto_perfil'] == null
                    ? const Icon(Icons.person, size: 20, color: Colors.grey)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          evaluador['nombre_artistico'] ?? 'Usuario',
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: ThemeColors.primaryText(context),
                          ),
                        ),
                        if (verificado) ...[
                          const SizedBox(width: 6),
                          const Icon(Icons.verified, size: 14, color: Colors.green),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('dd MMM yyyy').format(createdAt),
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        color: ThemeColors.secondaryText(context),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < puntuacion ? Icons.star : Icons.star_border,
                    color: AppConstants.primaryColor,
                    size: 16,
                  );
                }),
              ),
            ],
          ),
          if (comentario != null && comentario.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              comentario,
              style: GoogleFonts.outfit(
                fontSize: 13,
                color: ThemeColors.secondaryText(context),
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
