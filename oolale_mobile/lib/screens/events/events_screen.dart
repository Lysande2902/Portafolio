import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/event.dart';
import '../../services/api_service.dart';
import '../../config/constants.dart';
import '../../widgets/custom_card.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final ApiService _api = ApiService();
  List<Evento> _events = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    try {
      final response = await _api.get('/eventos');
      if (response is List) {
        setState(() {
          _events = response.map((e) => Evento.fromJson(e)).toList();
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/create-event'),
        backgroundColor: AppConstants.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _events.length,
            itemBuilder: (context, index) {
              final event = _events[index];
              final isAttending = false; // logic needed if API returns 'asistiendo' status
              
              return CustomCard(
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.all(10),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppConstants.primaryColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.event, color: AppConstants.primaryColor),
                      ),
                      title: Text(event.titulo, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                      subtitle: Text('${event.ubicacion} • ${event.fechaHora.day}/${event.fechaHora.month}', style: const TextStyle(color: Colors.white70)),
                    ),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                             TextButton.icon(
                               onPressed: () async {
                                 // Logic to toggle attendance. 
                                 // Assuming POST /eventos/:id/asistir
                                 try {
                                   await _api.post('/eventos/${event.id}/asistir', {}); // Body might be empty
                                   if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('¡Asistencia confirmada!')));
                                 } catch (e) {
                                   // If already attending or error
                                    if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Solicitud enviada')));
                                 }
                               },
                               icon: const Icon(Icons.check_circle_outline, size: 20),
                               label: const Text('Asistir'),
                               style: TextButton.styleFrom(foregroundColor: AppConstants.accentColor),
                             )
                          ],
                        ),
                    )
                  ],
                ),
              );
            },
          ),
    );
  }
}
