import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/connection.dart';
import '../../config/constants.dart';
import '../../widgets/custom_card.dart';

class ConnectionsScreen extends StatefulWidget {
  const ConnectionsScreen({super.key});

  @override
  State<ConnectionsScreen> createState() => _ConnectionsScreenState();
}

class _ConnectionsScreenState extends State<ConnectionsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiService _api = ApiService();
  List<Connection> _connections = [];
  List<Connection> _pending = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // Mocked endpoints, adjust to real API
      // GET /api/conexiones (all)
      final response = await _api.get('/conexiones');
      if (response is List) {
        final all = response.map((c) => Connection.fromJson(c)).toList();
        setState(() {
          _connections = all.where((c) => c.status == 'aceptada').toList();
          _pending = all.where((c) => c.status == 'pendiente').toList();
          _isLoading = false;
        });
      } else {
        // Fallback demo data
         setState(() {
          _connections = [
             Connection(id: 1, requesterId: 10, receiverId: 1, status: 'aceptada', createdAt: DateTime.now(), otherUserName: 'Juan Guitarra'),
             Connection(id: 2, requesterId: 1, receiverId: 12, status: 'aceptada', createdAt: DateTime.now(), otherUserName: 'Maria Voz'),
          ];
          _pending = [
             Connection(id: 3, requesterId: 15, receiverId: 1, status: 'pendiente', createdAt: DateTime.now(), otherUserName: 'Pedro Batería'),
          ];
          _isLoading = false;
        });
      }
    } catch (e) {
      if(mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _respondRequest(int connectionId, String action) async {
    try {
      // PUT /api/conexiones/:id/responder { estado: 'aceptada' | 'rechazada' }
      await _api.put('/conexiones/$connectionId', {'estado': action});
      _loadData(); // Reload
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Solicitud $action')));
    } catch (e) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al procesar')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Red de Músicos'),
        backgroundColor: Colors.transparent,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppConstants.primaryColor,
          labelColor: AppConstants.primaryColor,
          unselectedLabelColor: Colors.white54,
          tabs: const [
            Tab(text: 'Mis Conexiones'),
            Tab(text: 'Solicitudes'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildConnectionsList(),
                _buildPendingList(),
              ],
            ),
       floatingActionButton: FloatingActionButton(
        onPressed: () {
           // Navigate to global search to find new people
           // For now just show snackbar
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Usa la pestaña "Buscar" para encontrar músicos')));
        },
        backgroundColor: AppConstants.accentColor,
        child: const Icon(Icons.person_add),
      ),
    );
  }

  Widget _buildConnectionsList() {
    if (_connections.isEmpty) {
      return const Center(child: Text('Aún no tienes conexiones', style: TextStyle(color: Colors.white54)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _connections.length,
      itemBuilder: (context, index) {
        final conn = _connections[index];
        return CustomCard(
          child: ListTile(
            leading: const CircleAvatar(backgroundColor: Colors.grey, child: Icon(Icons.person)),
            title: Text(conn.otherUserName ?? 'Usuario Musical', style: const TextStyle(color: Colors.white)),
            subtitle: const Text('Músico conectado', style: TextStyle(color: Colors.white38)),
            trailing: IconButton(
              icon: const Icon(Icons.chat_bubble_outline, color: AppConstants.primaryColor),
              onPressed: () {
                // Open chat logic
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildPendingList() {
     if (_pending.isEmpty) {
      return const Center(child: Text('No hay solicitudes pendientes', style: TextStyle(color: Colors.white54)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _pending.length,
      itemBuilder: (context, index) {
        final conn = _pending[index];
        return CustomCard(
          child: Column(
            children: [
              ListTile(
                leading: const CircleAvatar(backgroundColor: Colors.orange, child: Icon(Icons.person_outline)),
                title: Text(conn.otherUserName ?? 'Usuario Desconocido', style: const TextStyle(color: Colors.white)),
                subtitle: const Text('Quiere conectar contigo', style: TextStyle(color: Colors.white38)),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => _respondRequest(conn.id, 'rechazada'),
                      child: const Text('Rechazar', style: TextStyle(color: Colors.redAccent)),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () => _respondRequest(conn.id, 'aceptada'),
                      style: ElevatedButton.styleFrom(backgroundColor: AppConstants.primaryColor),
                      child: const Text('Aceptar'),
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
