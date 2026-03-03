import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../config/theme_colors.dart';
import '../../config/constants.dart';

/// Pantalla de calificaciones del usuario
/// Muestra: Promedio, distribución, comentarios, badge de reputación
class RatingsScreen extends StatefulWidget {
  final String userId;
  final bool isOwnProfile;

  const RatingsScreen({super.key, 
    required this.userId,
    this.isOwnProfile = false,
  });

  @override
  State<RatingsScreen> createState() => _RatingsScreenState();
}

class _RatingsScreenState extends State<RatingsScreen> {
  late SupabaseClient _supabase;
  late Future<RatingsData> _ratingsDataFuture;

  @override
  void initState() {
    super.initState();
    _supabase = Supabase.instance.client;
    _ratingsDataFuture = _loadRatingsData();
  }

  /// Cargar todas las calificaciones del usuario
  Future<RatingsData> _loadRatingsData() async {
    try {
      // 1. Obtener calificaciones
      final calificacionesResponse = await _supabase
          .from('referencias')
          .select()
          .eq('evaluado_id', widget.userId)
          .order('created_at', ascending: false);

      final List<Calificacion> calificaciones =
          List<Calificacion>.from(calificacionesResponse.map((x) => Calificacion.fromJson(x)));

      // 2. Calcular datos de reputación desde el perfil
      final perfilReputacion = await _supabase
          .from('perfiles')
          .select('created_at')
          .eq('id', widget.userId)
          .maybeSingle();

      // Calcular días en plataforma
      final diasEnPlataforma = perfilReputacion != null
          ? DateTime.now().difference(DateTime.parse(perfilReputacion['created_at'])).inDays
          : 0;

      // Crear objeto de reputación con datos calculados
      final Reputacion reputacion = Reputacion(
        puntuacion_final: calificaciones.isEmpty ? 0.0 : (calificaciones.map((c) => c.estrellas).reduce((a, b) => a + b) / calificaciones.length),
        dias_en_plataforma: diasEnPlataforma,
        tasa_respuesta: 0,
        eventos_completados: 0,
      );

      // 3. Obtener datos del perfil (rating_promedio, total_calificaciones)
      final perfilResponse = await _supabase
          .from('perfiles')
          .select('nombre_artistico, foto_perfil, rating_promedio, total_calificaciones, verificado')
          .eq('id', widget.userId)
          .single();

      return RatingsData(
        calificaciones: calificaciones,
        reputacion: reputacion,
        nombreArtistico: perfilResponse['nombre_artistico'] ?? 'Usuario',
        fotoPerfil: perfilResponse['foto_perfil'],
        ratingPromedio: (perfilResponse['rating_promedio'] ?? 0).toDouble(),
        totalCalificaciones: perfilResponse['total_calificaciones'] ?? 0,
        verificado: perfilResponse['verificado'] ?? false,
      );
    } catch (e) {
      print('Error cargando ratings: $e');
      rethrow;
    }
  }

  /// Calcular distribución de ratings
  Map<int, int> _calculateDistribution(List<Calificacion> calificaciones) {
    final distribution = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    for (final cal in calificaciones) {
      distribution[cal.estrellas] = (distribution[cal.estrellas] ?? 0) + 1;
    }
    return distribution;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Calificaciones'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: FutureBuilder<RatingsData>(
        future: _ratingsDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error cargando calificaciones: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() {
                      _ratingsDataFuture = _loadRatingsData();
                    }),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          final data = snapshot.data!;
          final distribution = _calculateDistribution(data.calificaciones);

          return SingleChildScrollView(
            child: Column(
              children: [
                // Header con recuadro de rating
                _buildHeader(data),

                // Distribución de stars
                _buildStarDistribution(distribution, data.totalCalificaciones),

                const SizedBox(height: 16),

                // Comentarios
                if (data.calificaciones.isNotEmpty)
                  _buildCommentsSection(data.calificaciones)
                else
                  _buildEmptyState(),

                // Botón para dejar calificación
                if (widget.isOwnProfile)
                  const SizedBox()
                else
                  _buildLeaveRatingButton(),

                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Header con info principal
  Widget _buildHeader(RatingsData data) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          decoration: BoxDecoration(
            color: AppConstants.primaryColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star, color: Colors.black, size: 32),
              const SizedBox(width: 8),
              Text(
                data.ratingPromedio.toStringAsFixed(1),
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Distribución de stars
  Widget _buildStarDistribution(Map<int, int> distribution, int total) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Distribución',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate(5, (index) {
            final stars = 5 - index;
            final count = distribution[stars] ?? 0;
            final percentage = total > 0 ? (count / total * 100).toStringAsFixed(0) : '0';

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  // Stars
                  Row(
                    children: List.generate(
                      stars,
                      (i) => Icon(Icons.star, color: AppConstants.primaryColor, size: 16),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Barra de progreso
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: total > 0 ? count / total : 0,
                        minHeight: 8,
                        backgroundColor: Colors.grey[700],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color.fromARGB(
                            255,
                            // FIX: Prevenir NaN/Infinity con validación
                            total > 0 ? (255 * (1 - count / total)).toInt() : 255,
                            total > 0 ? (255 * (count / total)).toInt() : 0,
                            0,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Porcentaje y count
                  SizedBox(
                    width: 50,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '$percentage%',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '($count)',
                          style: TextStyle(color: Colors.grey[400], fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  /// Sección de comentarios
  Widget _buildCommentsSection(List<Calificacion> calificaciones) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: const Text(
            'Comentarios',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        ...calificaciones.map((cal) {
          return Card(
            color: Theme.of(context).cardColor,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          ...List.generate(
                            cal.estrellas,
                            (i) => Icon(Icons.star, color: AppConstants.primaryColor, size: 16),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            cal.estrellas.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        cal.formattedDate,
                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Comentario
                  if (cal.comentario.isNotEmpty)
                    Text(
                      cal.comentario,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  /// Empty state
  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(Icons.star_outline, size: 64, color: ThemeColors.disabledText(context)),
          const SizedBox(height: 16),
          Text(
            'Sin calificaciones aún',
            style: TextStyle(color: ThemeColors.secondaryText(context), fontSize: 16),
          ),
        ],
      ),
    );
  }

  /// Botón para dejar calificación
  Widget _buildLeaveRatingButton() {
    final currentUserId = _supabase.auth.currentUser?.id;
    
    // No mostrar botón si es tu propio perfil
    if (currentUserId == widget.userId) {
      return const SizedBox();
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => LeaveRatingScreen(
                  userId: widget.userId,
                  onRatingSubmitted: () {
                    setState(() {
                      _ratingsDataFuture = _loadRatingsData();
                    });
                  },
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppConstants.primaryColor,
            foregroundColor: Colors.black,
          ),
          child: const Text('Dejar calificación'),
        ),
      ),
    );
  }
}

/// Pantalla para dejar calificación
class LeaveRatingScreen extends StatefulWidget {
  final String userId;
  final VoidCallback onRatingSubmitted;

  const LeaveRatingScreen({super.key, 
    required this.userId,
    required this.onRatingSubmitted,
  });

  @override
  State<LeaveRatingScreen> createState() => _LeaveRatingScreenState();
}

class _LeaveRatingScreenState extends State<LeaveRatingScreen> {
  late SupabaseClient _supabase;
  final _commentController = TextEditingController();
  int selectedStars = 5;
  String selectedInteractionType = 'colaboracion';
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _supabase = Supabase.instance.client;
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitRating() async {
    final currentUserId = _supabase.auth.currentUser?.id;
    if (currentUserId == null) return;

    setState(() => isSubmitting = true);

    try {
      await _supabase.from('referencias').insert({
        'evaluador_id': currentUserId,
        'evaluado_id': widget.userId,
        'puntuacion': selectedStars,
        'comentario': _commentController.text,
        'verificado': false,
        'created_at': DateTime.now().toIso8601String(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Calificación guardada')),
        );
        widget.onRatingSubmitted();
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Dejar calificación'),
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Selecciona tus estrellas',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            // Stars selector
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return GestureDetector(
                  onTap: () => setState(() => selectedStars = index + 1),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(
                      Icons.star,
                      color: index < selectedStars ? AppConstants.primaryColor : Colors.grey,
                      size: 48,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 32),
            // Tipo de interacción
            const Text(
              'Tipo de interacción',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButton<String>(
              value: selectedInteractionType,
              isExpanded: true,
              dropdownColor: Colors.grey[850],
              style: const TextStyle(color: Colors.white),
              onChanged: (newValue) {
                setState(() => selectedInteractionType = newValue!);
              },
              items: ['colaboracion', 'evento', 'jam_session', 'clases'].map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            // Comentario
            const Text(
              'Comentario (opcional)',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _commentController,
              maxLines: 4,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Cuéntale más a otros músicos...',
                hintStyle: TextStyle(color: Colors.grey[600]),
                filled: true,
                fillColor: Colors.grey[850],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Botón de envío
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isSubmitting ? null : _submitRating,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrangeAccent,
                ),
                child: isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Enviar calificación'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Models

class RatingsData {
  final List<Calificacion> calificaciones;
  final Reputacion reputacion;
  final String nombreArtistico;
  final String? fotoPerfil;
  final double ratingPromedio;
  final int totalCalificaciones;
  final bool verificado;

  RatingsData({
    required this.calificaciones,
    required this.reputacion,
    required this.nombreArtistico,
    required this.fotoPerfil,
    required this.ratingPromedio,
    required this.totalCalificaciones,
    required this.verificado,
  });
}

class Calificacion {
  final String id;
  final int estrellas;
  final String comentario;
  final String tipo_interaccion;
  final DateTime createdAt;

  Calificacion({
    required this.id,
    required this.estrellas,
    required this.comentario,
    required this.tipo_interaccion,
    required this.createdAt,
  });

  String get formattedDate => '${createdAt.day}/${createdAt.month}/${createdAt.year}';

  factory Calificacion.fromJson(Map<String, dynamic> json) {
    return Calificacion(
      id: json['id'].toString(),
      estrellas: json['puntuacion'] ?? json['estrellas'] ?? 5, // CORREGIDO: usar 'puntuacion' de la BD
      comentario: json['comentario'] ?? '',
      tipo_interaccion: json['tipo_interaccion'] ?? 'evento',
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class Reputacion {
  final double puntuacion_final;
  final int dias_en_plataforma;
  final double tasa_respuesta;
  final int eventos_completados;

  Reputacion({
    required this.puntuacion_final,
    required this.dias_en_plataforma,
    required this.tasa_respuesta,
    required this.eventos_completados,
  });

  factory Reputacion.fromJson(Map<String, dynamic> json) {
    return Reputacion(
      puntuacion_final: (json['puntuacion_final'] ?? 0).toDouble(),
      dias_en_plataforma: json['dias_en_plataforma'] ?? 0,
      tasa_respuesta: (json['tasa_respuesta'] ?? 0).toDouble(),
      eventos_completados: json['eventos_completados'] ?? 0,
    );
  }
}
