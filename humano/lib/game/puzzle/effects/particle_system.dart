import 'dart:math';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vm;

class Particle {
  vm.Vector2 position;
  vm.Vector2 velocity;
  Color color;
  double size;
  double lifetime;
  double age;
  double opacity;

  Particle({
    required this.position,
    required this.velocity,
    required this.color,
    required this.size,
    required this.lifetime,
    this.age = 0.0,
    this.opacity = 1.0,
  });

  void update(double dt) {
    position += velocity * dt;
    age += dt;

    // Apply gravity
    velocity.y += 500 * dt;

    // Fade out near end of lifetime
    opacity = 1.0 - (age / lifetime);
  }

  bool get isDead => age >= lifetime;
}

class ParticleSystem extends StatefulWidget {
  final List<Particle> particles;

  const ParticleSystem({
    super.key,
    required this.particles,
  });

  @override
  State<ParticleSystem> createState() => _ParticleSystemState();
}

class _ParticleSystemState extends State<ParticleSystem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  DateTime? _lastUpdate;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _controller.addListener(_updateParticles);
  }

  void _updateParticles() {
    final now = DateTime.now();
    if (_lastUpdate != null) {
      final dt = now.difference(_lastUpdate!).inMilliseconds / 1000.0;

      setState(() {
        // Update all particles
        for (var particle in widget.particles) {
          particle.update(dt);
        }

        // Remove dead particles and return to pool
        widget.particles.removeWhere((p) {
          if (p.isDead) {
            ParticleEmitter.returnParticle(p);
            return true;
          }
          return false;
        });
      });
    }
    _lastUpdate = now;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: ParticlePainter(widget.particles),
      child: Container(),
    );
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;

  ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final paint = Paint()
        ..color = particle.color.withOpacity(particle.opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(particle.position.x, particle.position.y),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) => true;
}

class ParticleEmitter {
  static final Random _random = Random();
  static final List<Particle> _particlePool = [];
  static const int _maxPoolSize = 200;

  // Get particle from pool or create new one
  static Particle _getParticle({
    required vm.Vector2 position,
    required vm.Vector2 velocity,
    required Color color,
    required double size,
    required double lifetime,
  }) {
    if (_particlePool.isNotEmpty) {
      final particle = _particlePool.removeLast();
      particle.position = position;
      particle.velocity = velocity;
      particle.color = color;
      particle.size = size;
      particle.lifetime = lifetime;
      particle.age = 0.0;
      particle.opacity = 1.0;
      return particle;
    }
    return Particle(
      position: position,
      velocity: velocity,
      color: color,
      size: size,
      lifetime: lifetime,
    );
  }

  // Return particle to pool
  static void returnParticle(Particle particle) {
    if (_particlePool.length < _maxPoolSize) {
      _particlePool.add(particle);
    }
  }

  // Emit trailing particles during drag
  static List<Particle> emitTrailParticles(Offset position) {
    return List.generate(3, (i) {
      return _getParticle(
        position: vm.Vector2(position.dx, position.dy),
        velocity: vm.Vector2(
          (_random.nextDouble() - 0.5) * 50,
          (_random.nextDouble() - 0.5) * 50,
        ),
        color: Colors.white.withOpacity(0.6),
        size: 4.0,
        lifetime: 0.5,
      );
    });
  }

  // Emit explosion particles on snap
  static List<Particle> emitSnapParticles(Offset position) {
    return List.generate(20, (i) {
      double angle = (i / 20) * 2 * pi;
      return Particle(
        position: vm.Vector2(position.dx, position.dy),
        velocity: vm.Vector2(cos(angle), sin(angle)) * 200,
        color: Colors.green,
        size: 6.0,
        lifetime: 1.0,
        age: 0.0,
      );
    });
  }

  // Emit error particles on incorrect placement
  static List<Particle> emitErrorParticles(Offset position) {
    return List.generate(15, (i) {
      double angle = (i / 15) * 2 * pi;
      return Particle(
        position: vm.Vector2(position.dx, position.dy),
        velocity: vm.Vector2(cos(angle), sin(angle)) * 150,
        color: Colors.red,
        size: 5.0,
        lifetime: 0.8,
        age: 0.0,
      );
    });
  }

  // Emit confetti on completion
  static List<Particle> emitConfettiParticles(Size screenSize) {
    return List.generate(100, (i) {
      return Particle(
        position: vm.Vector2(
          _random.nextDouble() * screenSize.width,
          -20,
        ),
        velocity: vm.Vector2(
          (_random.nextDouble() - 0.5) * 100,
          _random.nextDouble() * 300 + 200,
        ),
        color: [
          Colors.red,
          Colors.blue,
          Colors.yellow,
          Colors.green,
          Colors.purple,
          Colors.orange,
        ][i % 6],
        size: 8.0,
        lifetime: 3.0,
        age: 0.0,
      );
    });
  }

  // Emit proximity glow particles
  static List<Particle> emitProximityParticles(Offset position) {
    return List.generate(5, (i) {
      double angle = (i / 5) * 2 * pi;
      double radius = 30.0;
      return Particle(
        position: vm.Vector2(
          position.dx + cos(angle) * radius,
          position.dy + sin(angle) * radius,
        ),
        velocity: vm.Vector2(cos(angle), sin(angle)) * 20,
        color: Colors.yellow.withOpacity(0.5),
        size: 4.0,
        lifetime: 0.6,
        age: 0.0,
      );
    });
  }
}
