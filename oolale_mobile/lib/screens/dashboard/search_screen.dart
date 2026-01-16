import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../config/constants.dart';
import '../../widgets/custom_card.dart';
import '../hiring/hire_musician_screen.dart';

class UserSearchScreen extends StatefulWidget {
  const UserSearchScreen({super.key});

  @override
  State<UserSearchScreen> createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends State<UserSearchScreen> {
  final ApiService _api = ApiService();
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _results = [];
  bool _isLoading = false;

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) return;
    setState(() => _isLoading = true);
    
    try {
      // GET /api/usuarios/buscar?q=query (Mock endpoint)
      // Fallback is getting all profiles and filtering if search endpoint doesn't exist
      final response = await _api.get('/perfiles'); 
      if (response is List) {
        setState(() {
          _results = response.where((user) {
            final name = user['nombre_artistico']?.toString().toLowerCase() ?? '';
            final role = user['experiencia']?.toString().toLowerCase() ?? '';
            return name.contains(query.toLowerCase()) || role.contains(query.toLowerCase());
          }).toList();
        });
      }
    } catch (e) {
      // Handle error
    } finally {
      if(mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Buscar músicos, bandas...',
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                filled: true,
                fillColor: AppConstants.cardColor,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
              ),
              onSubmitted: _performSearch,
            ),
          ),
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator()) 
              : _results.isEmpty 
                  ? const Center(child: Text('Busca algo para empezar', style: TextStyle(color: Colors.white24)))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _results.length,
                      itemBuilder: (context, index) {
                         final user = _results[index];
                         return CustomCard(
                           child: ListTile(
                             leading: CircleAvatar(
                               backgroundColor: AppConstants.primaryColor,
                               backgroundImage: user['foto_url'] != null ? NetworkImage(user['foto_url']) : null,
                               child: user['foto_url'] == null ? const Icon(Icons.person) : null,
                             ),
                             title: Text(user['nombre_artistico'] ?? 'Usuario', style: const TextStyle(color: Colors.white)),
                             subtitle: Text(user['experiencia'] ?? 'Músico', style: const TextStyle(color: Colors.white54)),
                             trailing: Row(
                               mainAxisSize: MainAxisSize.min,
                               children: [
                                 IconButton(
                                   icon: const Icon(Icons.person_add_alt, color: AppConstants.accentColor),
                                   tooltip: 'Conectar',
                                   onPressed: () {
                                     // Logic to send connection request
                                     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Solicitud enviada')));
                                   },
                                 ),
                                 IconButton(
                                   icon: const Icon(Icons.monetization_on, color: Colors.greenAccent),
                                   tooltip: 'Contratar',
                                   onPressed: () {
                                     Navigator.push(
                                       context, 
                                       MaterialPageRoute(builder: (context) => HireMusicianScreen(
                                          musicianId: user['user_id'] ?? user['id'], // Handle differing ID fields
                                          musicianName: user['nombre_artistico'] ?? 'Músico'
                                       ))
                                     );
                                   },
                                 ),
                               ],
                             ),
                           ),
                         );
                      },
                    ),
          )
        ],
      ),
    );
  }
}
