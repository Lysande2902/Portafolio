import 'package:flutter/material.dart';
import '../services/profile_service.dart';
import '../config/theme_colors.dart';

/// Widget to display profile completion progress
class ProfileCompletionWidget extends StatelessWidget {
  final int completion;
  final ProfileService profileService;
  final VoidCallback? onTap;

  const ProfileCompletionWidget({
    super.key,
    required this.completion,
    required this.profileService,
    this.onTap,
  });

  Color _getCompletionColor() {
    final colorName = profileService.getCompletionColor(completion);
    switch (colorName) {
      case 'green':
        return Colors.green;
      case 'lightGreen':
        return Colors.lightGreen;
      case 'yellow':
        return Colors.yellow.shade700;
      case 'orange':
        return Colors.orange;
      case 'red':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final category = profileService.getCompletionCategory(completion);
    final color = _getCompletionColor();

    return InkWell(
      onTap: onTap,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.account_circle, color: ThemeColors.primary),
                      const SizedBox(width: 8),
                      const Text(
                        'Completitud del Perfil',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    category,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: completion / 100,
                        minHeight: 12,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '$completion%',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
              if (completion < 100) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Completa tu perfil para mejorar tu visibilidad',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                    if (onTap != null)
                      Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade600),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget to display missing fields suggestions
class MissingFieldsSuggestions extends StatelessWidget {
  final List<Map<String, String>> missingFields;
  final Function(String)? onFieldTap;

  const MissingFieldsSuggestions({
    super.key,
    required this.missingFields,
    this.onFieldTap,
  });

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'alta':
        return Colors.red;
      case 'media':
        return Colors.orange;
      case 'baja':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'básico':
        return Icons.person;
      case 'musical':
        return Icons.music_note;
      case 'disponibilidad':
        return Icons.calendar_today;
      case 'redes':
        return Icons.share;
      case 'tarifas':
        return Icons.attach_money;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (missingFields.isEmpty) {
      return Card(
        color: Colors.green.shade50,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green.shade700, size: 32),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  '¡Perfil completo! 🎉',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Group by priority
    final highPriority = missingFields.where((f) => f['prioridad'] == 'Alta').toList();
    final mediumPriority = missingFields.where((f) => f['prioridad'] == 'Media').toList();
    final lowPriority = missingFields.where((f) => f['prioridad'] == 'Baja').toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.checklist, color: ThemeColors.primary),
                const SizedBox(width: 8),
                const Text(
                  'Campos Pendientes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // High priority
            if (highPriority.isNotEmpty) ...[
              _buildPrioritySection('Alta Prioridad', highPriority, Colors.red),
              const SizedBox(height: 12),
            ],

            // Medium priority
            if (mediumPriority.isNotEmpty) ...[
              _buildPrioritySection('Media Prioridad', mediumPriority, Colors.orange),
              const SizedBox(height: 12),
            ],

            // Low priority
            if (lowPriority.isNotEmpty) ...[
              _buildPrioritySection('Baja Prioridad', lowPriority, Colors.blue),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPrioritySection(String title, List<Map<String, String>> fields, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 8),
        ...fields.map((field) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: onFieldTap != null ? () => onFieldTap!(field['campo']!) : null,
              child: Row(
                children: [
                  Icon(
                    _getCategoryIcon(field['categoria']!),
                    size: 20,
                    color: color,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      field['campo']!,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  if (onFieldTap != null)
                    Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey.shade600),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
