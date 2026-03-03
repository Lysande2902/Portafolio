import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/profile_service.dart';
import '../../config/theme_colors.dart';
import '../../utils/error_handler.dart';

/// Screen for editing availability and rates
class EditAvailabilityRatesScreen extends StatefulWidget {
  const EditAvailabilityRatesScreen({super.key});

  @override
  State<EditAvailabilityRatesScreen> createState() =>
      _EditAvailabilityRatesScreenState();
}

class _EditAvailabilityRatesScreenState
    extends State<EditAvailabilityRatesScreen> {
  final _supabase = Supabase.instance.client;
  late final ProfileService _profileService;

  bool _isLoading = true;
  bool _isSaving = false;

  // Availability
  Map<String, bool> _availability = {};

  // Rates
  final _baseRateController = TextEditingController();
  final _minRateController = TextEditingController();
  final _maxRateController = TextEditingController();
  String _selectedCurrency = 'MXN';

  // Event types
  List<String> _selectedEventTypes = [];

  // Event preferences
  bool _acceptsPaid = true;
  bool _acceptsPractice = true;
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _profileService = ProfileService(_supabase);
    _loadData();
  }

  @override
  void dispose() {
    _baseRateController.dispose();
    _minRateController.dispose();
    _maxRateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final userId = _supabase.auth.currentUser!.id;

      // Load availability
      final availabilityData =
          await _profileService.getWeeklyAvailability(userId);
      
      // Initialize availability for all days
      final days = _profileService.getDaysOfWeek();
      for (final day in days) {
        _availability[day] = availabilityData[day]?['disponible'] ?? false;
      }

      // Load rates
      final rates = await _profileService.getUserRates(userId);
      if (rates['tarifa_base'] != null) {
        _baseRateController.text = rates['tarifa_base'].toString();
      }
      if (rates['tarifa_minima'] != null) {
        _minRateController.text = rates['tarifa_minima'].toString();
      }
      if (rates['tarifa_maxima'] != null) {
        _maxRateController.text = rates['tarifa_maxima'].toString();
      }
      _selectedCurrency = rates['moneda'] ?? 'MXN';

      // Load event preferences
      final prefs = await _profileService.getEventPreferences(userId);
      _acceptsPaid = prefs['acepta_eventos_pagados'] ?? true;
      _acceptsPractice = prefs['acepta_eventos_practica'] ?? true;
      _notesController.text = prefs['notas_disponibilidad'] ?? '';
      
      final eventTypes = prefs['tipos_eventos_acepta'] as List<dynamic>?;
      _selectedEventTypes = eventTypes?.map((e) => e.toString()).toList() ?? [];
    } catch (e) {
      ErrorHandler.logError('EditAvailabilityRatesScreen._loadData', e);
      if (mounted) {
        ErrorHandler.showErrorDialog(
          context,
          e,
          title: 'Error al cargar datos',
          onRetry: _loadData,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveData() async {
    setState(() => _isSaving = true);

    try {
      final userId = _supabase.auth.currentUser!.id;

      // Build availability JSON
      final Map<String, dynamic> availabilityJson = {};
      _availability.forEach((day, isAvailable) {
        availabilityJson[day] = {
          'disponible': isAvailable,
          'horarios': [], // Can be extended later
        };
      });

      // Parse rates
      double? baseRate;
      double? minRate;
      double? maxRate;

      if (_baseRateController.text.isNotEmpty) {
        baseRate = double.tryParse(_baseRateController.text);
      }
      if (_minRateController.text.isNotEmpty) {
        minRate = double.tryParse(_minRateController.text);
      }
      if (_maxRateController.text.isNotEmpty) {
        maxRate = double.tryParse(_maxRateController.text);
      }

      // Save all data
      await _profileService.saveAvailabilityAndRates(
        userId: userId,
        availability: availabilityJson,
        baseRate: baseRate,
        minRate: minRate,
        maxRate: maxRate,
        currency: _selectedCurrency,
        eventTypes: _selectedEventTypes,
        acceptsPaid: _acceptsPaid,
        acceptsPractice: _acceptsPractice,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Disponibilidad y tarifas guardadas'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      ErrorHandler.logError('EditAvailabilityRatesScreen._saveData', e);
      if (mounted) {
        ErrorHandler.showErrorDialog(
          context,
          e,
          title: 'Error al guardar cambios',
          onRetry: _saveData,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showEventTypesDialog() {
    final availableTypes = _profileService.getAvailableEventTypes();
    final tempSelected = List<String>.from(_selectedEventTypes);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Tipos de Eventos'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: availableTypes.map((type) {
                final isSelected = tempSelected.contains(type);
                return CheckboxListTile(
                  title: Text(type),
                  value: isSelected,
                  activeColor: ThemeColors.primary,
                  onChanged: (value) {
                    setDialogState(() {
                      if (value == true) {
                        tempSelected.add(type);
                      } else {
                        tempSelected.remove(type);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() => _selectedEventTypes = tempSelected);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeColors.primary,
                foregroundColor: Colors.black,
              ),
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Disponibilidad y Tarifas'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Disponibilidad y Tarifas'),
        actions: [
          if (_isSaving)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _saveData,
              tooltip: 'Guardar',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Weekly Availability
            _buildAvailabilityCard(),
            const SizedBox(height: 16),

            // Rates
            _buildRatesCard(),
            const SizedBox(height: 16),

            // Event Types
            _buildEventTypesCard(),
            const SizedBox(height: 16),

            // Event Preferences
            _buildEventPreferencesCard(),
            const SizedBox(height: 16),

            // Notes
            _buildNotesCard(),
            const SizedBox(height: 32),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeColors.primary,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Guardar Cambios',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailabilityCard() {
    final days = _profileService.getDaysOfWeek();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_today, color: ThemeColors.primary),
                const SizedBox(width: 8),
                const Text(
                  'Disponibilidad Semanal',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Selecciona los días que estás disponible',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ...days.map((day) {
              return CheckboxListTile(
                title: Text(_profileService.getDayDisplay(day)),
                value: _availability[day] ?? false,
                activeColor: ThemeColors.primary,
                onChanged: (value) {
                  setState(() {
                    _availability[day] = value ?? false;
                  });
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildRatesCard() {
    final currencies = _profileService.getAvailableCurrencies();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.attach_money, color: ThemeColors.primary),
                const SizedBox(width: 8),
                const Text(
                  'Tarifas',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Opcional - Solo para eventos pagados',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),

            // Currency selector
            DropdownButtonFormField<String>(
              value: _selectedCurrency,
              decoration: const InputDecoration(
                labelText: 'Moneda',
                border: OutlineInputBorder(),
              ),
              items: currencies.map((currency) {
                return DropdownMenuItem(
                  value: currency,
                  child: Text(
                    '$currency (${_profileService.getCurrencySymbol(currency)})',
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedCurrency = value);
                }
              },
            ),
            const SizedBox(height: 16),

            // Base rate
            TextField(
              controller: _baseRateController,
              decoration: InputDecoration(
                labelText: 'Tarifa Base (por hora)',
                border: const OutlineInputBorder(),
                prefixText: _profileService.getCurrencySymbol(_selectedCurrency),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            // Min and Max rates
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _minRateController,
                    decoration: InputDecoration(
                      labelText: 'Mínima',
                      border: const OutlineInputBorder(),
                      prefixText:
                          _profileService.getCurrencySymbol(_selectedCurrency),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _maxRateController,
                    decoration: InputDecoration(
                      labelText: 'Máxima',
                      border: const OutlineInputBorder(),
                      prefixText:
                          _profileService.getCurrencySymbol(_selectedCurrency),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventTypesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.event, color: ThemeColors.primary),
                const SizedBox(width: 8),
                const Text(
                  'Tipos de Eventos',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Selecciona los tipos de eventos que aceptas',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            if (_selectedEventTypes.isEmpty)
              const Text(
                'No has seleccionado ningún tipo',
                style: TextStyle(color: Colors.grey),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _selectedEventTypes.map((type) {
                  return Chip(
                    label: Text(type),
                    backgroundColor: ThemeColors.primary.withOpacity(0.2),
                    deleteIcon: const Icon(Icons.close, size: 18),
                    onDeleted: () {
                      setState(() {
                        _selectedEventTypes.remove(type);
                      });
                    },
                  );
                }).toList(),
              ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _showEventTypesDialog,
              icon: const Icon(Icons.add),
              label: const Text('Seleccionar Tipos'),
              style: OutlinedButton.styleFrom(
                foregroundColor: ThemeColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventPreferencesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.settings, color: ThemeColors.primary),
                const SizedBox(width: 8),
                const Text(
                  'Preferencias de Eventos',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Acepto eventos pagados'),
              subtitle: const Text('Eventos de contratación/trabajo'),
              value: _acceptsPaid,
              activeColor: ThemeColors.primary,
              onChanged: (value) {
                setState(() => _acceptsPaid = value);
              },
            ),
            SwitchListTile(
              title: const Text('Acepto eventos de práctica'),
              subtitle: const Text('Jam sessions sin pago'),
              value: _acceptsPractice,
              activeColor: ThemeColors.primary,
              onChanged: (value) {
                setState(() => _acceptsPractice = value);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.notes, color: ThemeColors.primary),
                const SizedBox(width: 8),
                const Text(
                  'Notas Adicionales',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Información adicional sobre tu disponibilidad',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                hintText: 'Ej: Disponible solo fines de semana, necesito aviso con 2 días de anticipación, etc.',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
          ],
        ),
      ),
    );
  }
}
