import 'package:flame/components.dart';

/// Base class for all game components
/// Provides common functionality for components in the game
abstract class GameComponent extends PositionComponent {
  /// Whether this component is active and should update
  bool isActive = true;

  /// Queue of actions to execute safely after the component's update completes.
  /// This helps avoid modifying children during the update traversal.
  final List<void Function()> _deferredActions = [];

  /// Enqueue an action to be executed after update finishes this tick.
  void deferAction(void Function() action) {
    _deferredActions.add(action);
  }

  @override
  void update(double dt) {
    if (!isActive) return;
    super.update(dt);
    updateComponent(dt);

    // Execute any deferred actions safely after the update completes.
    if (_deferredActions.isNotEmpty) {
      final actions = List<void Function()>.from(_deferredActions);
      _deferredActions.clear();
      for (final action in actions) {
        try {
          action();
        } catch (_) {
          // Ignore failures in deferred actions to avoid breaking game loop.
        }
      }
    }
  }

  /// Update logic for this component - to be implemented by subclasses
  void updateComponent(double dt);

  /// Activate this component
  void activate() {
    isActive = true;
  }

  /// Deactivate this component
  void deactivate() {
    isActive = false;
  }
}
