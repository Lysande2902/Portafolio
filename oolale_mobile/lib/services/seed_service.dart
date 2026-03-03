import 'dart:math';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SeedService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final Random _random = Random();

  final List<String> _firstNames = [
    'Alejandro', 'Sofia', 'Mateo', 'Valentina', 'Santiago', 'Isabella', 'Diego', 'Camila',
    'Luis', 'Mariana', 'Gabriel', 'Ana', 'Carlos', 'Lucia', 'Andres', 'Fernanda',
    'Javier', 'Elena', 'Ricardo', 'Daniela', 'Fernando', 'Gabriela', 'Roberto', 'Paula'
  ];

  final List<String> _lastNames = [
    'Garcia', 'Rodriguez', 'Martinez', 'Hernandez', 'Lopez', 'Gonzalez', 'Perez', 'Sanchez',
    'Ramirez', 'Torres', 'Flores', 'Rivera', 'Gomez', 'Diaz', 'Reyes', 'Morales',
    'Cruz', 'Ortiz', 'Gutierrez', 'Chavez'
  ];

  final List<String> _instruments = [
    'Guitarra', 'Batería', 'Bajo', 'Voz', 'Teclado', 'Saxofón', 'Violín', 'Trompeta',
    'DJ', 'Productor', 'Ukulele', 'Acordeón'
  ];

  final List<String> _genres = [
    'Rock', 'Pop', 'Jazz', 'Blues', 'Metal', 'Reggae', 'Salsa', 'Cumbia', 'Electrónica',
    'Hip Hop', 'R&B', 'Funk', 'Indie', 'Folk'
  ];

  final List<String> _cities = [
    'CDMX', 'Guadalajara', 'Monterrey', 'Puebla', 'Querétaro', 'Mérida', 'Cancún',
    'Tijuana', 'León', 'Toluca', 'Morelia', 'Veracruz'
  ];

  Future<void> seedUsers({int count = 20}) async {
    debugPrint('SEED: Iniciando creación de $count usuarios...');
    
    for (int i = 0; i < count; i++) {
        // Generar datos falsos
        final firstName = _firstNames[_random.nextInt(_firstNames.length)];
        final lastName = _lastNames[_random.nextInt(_lastNames.length)];
        final email = '${firstName.toLowerCase()}.${lastName.toLowerCase()}${_random.nextInt(9999)}@toolale.test';
        final password = 'password123';
        final artisticName = _random.nextBool() ? '$firstName $lastName' : 'The $lastName Project';

        try {
          // 1. Crear Auth User
          final authResponse = await _supabase.auth.signUp(
            email: email,
            password: password,
            data: {'nombre_artistico': artisticName}, 
          );

          if (authResponse.user == null) continue;
          final userId = authResponse.user!.id;

          // 2. Actualizar Perfil (triggered automatically usually, but we update explicit fields)
          // Nota: Supabase a veces tarda en crear el perfil via trigger. Esperamos un poco o hacemos upsert.
          await Future.delayed(const Duration(milliseconds: 500));

          final instrument = _instruments[_random.nextInt(_instruments.length)];
          final location = _cities[_random.nextInt(_cities.length)];
          
          await _supabase.from('perfiles').upsert({
            'id': userId,
            'nombre_artistico': artisticName, 
            'instrumento_principal': instrument,
            'ubicacion': location,
            'ubicacion_base': location,
            'bio': 'Músico apasionado por el $instrument. Buscando proyectos serios.',
            'years_experience': _random.nextInt(15) + 1,
            'base_rate': (_random.nextInt(20) + 1) * 100.0,
            'verificado': _random.nextDouble() > 0.8, // 20% verified
            'open_to_work': _random.nextBool(),
            'foto_perfil': 'https://api.dicebear.com/7.x/avataaars/png?seed=$userId', // Avatar aleatorio
            'rating_promedio': (_random.nextDouble() * 2.0) + 3.0, // 3.0 to 5.0
            'total_calificaciones': _random.nextInt(50),
            'currency': 'MXN'
          });

          // 3. Géneros
          final userGenres = <String>{};
          final genreCount = _random.nextInt(3) + 1;
          while (userGenres.length < genreCount) {
            userGenres.add(_genres[_random.nextInt(_genres.length)]);
          }

          for (var g in userGenres) {
            await _supabase.from('generos_perfil').insert({
              'profile_id': userId,
              'genre': g
            });
          }

          debugPrint('SEED: Usuario creado $email');

        } catch (e) {
          debugPrint('SEED: Error creando usuario $email: $e');
        }
    }
    debugPrint('SEED: Finalizado.');
  }

  Future<void> seedEvents({int count = 10}) async {
    // Necesitamos IDs de usuarios existentes para ser organizadores
    final users = await _supabase.from('perfiles').select('id').limit(20);
    if (users.isEmpty) return;

    for (int i = 0; i < count; i++) {
       final organizer = users[_random.nextInt(users.length)];
       final city = _cities[_random.nextInt(_cities.length)];
       final type = ['jam_session', 'ensayo', 'concierto', 'taller'][_random.nextInt(4)];
       final daysFuture = _random.nextInt(30);
       final date = DateTime.now().add(Duration(days: daysFuture));

       await _supabase.from('eventos').insert({
         'organizador_id': organizer['id'],
         'titulo_bolo': 'Gran $type en $city',
         'tipo': type,
         'fecha_gig': date.toIso8601String().split('T')[0],
         'hora_soundcheck': '20:00:00',
         'lugar_nombre': 'Bar $city Centro',
         'resumen_setlist': 'Evento de prueba generado automáticamente. ¡Únete!',
         'estatus_bolo': 'programado',
         'presupuesto_total': (_random.nextInt(50) + 5) * 100.0,
       });
    }
    debugPrint('SEED: $count eventos creados.');
  }
}
