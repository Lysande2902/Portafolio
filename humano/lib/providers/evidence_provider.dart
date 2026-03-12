import 'package:flutter/foundation.dart';
import '../data/models/evidence.dart';
import '../data/providers/evidence_data_provider.dart';
import 'user_data_provider.dart';

/// Provider de evidencias que usa UserDataProvider como fuente de datos
class EvidenceProvider extends ChangeNotifier {
  final UserDataProvider _userDataProvider;
  final EvidenceDataProvider _dataProvider = EvidenceDataProvider();
  
  List<Evidence> _evidences = [];
  bool _isLoading = false;
  String? _error;
  EvidenceType? _selectedFilter;
  String? _selectedArcId;

  EvidenceProvider({required UserDataProvider userDataProvider})
      : _userDataProvider = userDataProvider {
    // Escuchar cambios en UserDataProvider
    _userDataProvider.addListener(_onUserDataChanged);
    _loadEvidences();
  }

  void _onUserDataChanged() {
    // Actualizar estado de evidencias cuando cambian los datos del usuario
    _updateEvidenceUnlockStatus();
    notifyListeners();
  }

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Evidence> get evidences => _evidences;
  EvidenceType? get selectedFilter => _selectedFilter;
  String? get selectedArcId => _selectedArcId;

  /// Carga todas las evidencias del juego
  void _loadEvidences() {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Cargar todas las evidencias estáticas
      _evidences = List.from(EvidenceDataProvider.allEvidences);
      
      // Actualizar estado de desbloqueo
      _updateEvidenceUnlockStatus();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Error al cargar evidencias: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Actualiza el estado de desbloqueo de todas las evidencias
  void _updateEvidenceUnlockStatus() {
    for (var evidence in _evidences) {
      evidence.isUnlocked = _isEvidenceUnlocked(evidence.id, evidence.arcId);
    }
  }

  /// Verifica si una evidencia está desbloqueada
  bool _isEvidenceUnlocked(String evidenceId, String arcId) {
    final arcProgress = _userDataProvider.arcProgress[arcId];
    if (arcProgress == null) return false;
    return arcProgress.evidencesCollected.contains(evidenceId);
  }

  /// Desbloquea una evidencia
  Future<void> unlockEvidence(String evidenceId, String arcId) async {
    try {
      // Usar el método de UserDataProvider
      await _userDataProvider.addEvidence(arcId, evidenceId);
      
      // Actualizar estado local
      final evidence = _evidences.firstWhere(
        (e) => e.id == evidenceId,
        orElse: () => throw Exception('Evidencia no encontrada'),
      );
      evidence.isUnlocked = true;
      
      notifyListeners();
    } catch (e) {
      _error = 'Error al desbloquear evidencia: $e';
      notifyListeners();
    }
  }

  /// Obtiene evidencias filtradas por arc y/o tipo
  List<Evidence> getFilteredEvidences() {
    var filtered = _evidences;
    
    // Filtrar por arco si está seleccionado
    if (_selectedArcId != null) {
      filtered = filtered.where((e) => e.arcId == _selectedArcId).toList();
    }
    
    // Filtrar por tipo si está seleccionado
    if (_selectedFilter != null) {
      filtered = filtered.where((e) => e.type == _selectedFilter).toList();
    }
    
    return filtered;
  }

  /// Establece filtro por tipo
  void setFilter(EvidenceType? type) {
    _selectedFilter = type;
    notifyListeners();
  }

  /// Establece filtro por arco
  void setArcFilter(String? arcId) {
    _selectedArcId = arcId;
    notifyListeners();
  }

  /// Obtiene evidencias por arco
  List<Evidence> getEvidencesByArc(String arcId) {
    return _evidences.where((e) => e.arcId == arcId).toList();
  }

  /// Obtiene evidencias por tipo
  List<Evidence> getEvidencesByType(EvidenceType type) {
    return _evidences.where((e) => e.type == type).toList();
  }

  /// Obtiene el progreso de colección (0.0 - 1.0)
  double getCollectionProgress() {
    if (_evidences.isEmpty) return 0.0;
    final unlocked = _evidences.where((e) => e.isUnlocked).length;
    return unlocked / _evidences.length;
  }

  /// Obtiene el conteo de evidencias desbloqueadas
  int getUnlockedCount() {
    return _evidences.where((e) => e.isUnlocked).length;
  }

  /// Obtiene el conteo total de evidencias
  int getTotalCount() {
    return _evidences.length;
  }

  /// Obtiene el conteo por tipo
  int getCountByType(EvidenceType type) {
    return _evidences.where((e) => e.type == type).length;
  }

  /// Obtiene el conteo de desbloqueadas por tipo
  int getUnlockedCountByType(EvidenceType type) {
    return _evidences
        .where((e) => e.type == type && e.isUnlocked)
        .length;
  }

  /// Obtiene todas las evidencias desbloqueadas de un arco
  List<Evidence> getUnlockedEvidencesByArc(String arcId) {
    return _evidences
        .where((e) => e.arcId == arcId && e.isUnlocked)
        .toList();
  }

  /// Limpia el error actual
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Limpia todos los datos
  void clearData() {
    _evidences.clear();
    _selectedFilter = null;
    _selectedArcId = null;
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _userDataProvider.removeListener(_onUserDataChanged);
    super.dispose();
  }
}
