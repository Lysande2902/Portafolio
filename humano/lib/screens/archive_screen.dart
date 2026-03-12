import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:humano/data/models/store_item.dart';
import 'package:humano/data/providers/fragments_provider.dart';
import 'package:humano/data/providers/arc_data_provider.dart';
import 'package:humano/data/providers/store_data_provider.dart';
import 'package:humano/providers/theme_provider.dart';
import 'package:humano/providers/store_provider.dart';
import 'package:humano/providers/audio_provider.dart';
import 'package:humano/screens/case_file_screen.dart';
import 'package:humano/screens/lore_detail_screen.dart';

class ArchiveScreen extends StatefulWidget {
  const ArchiveScreen({super.key});

  @override
  State<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends State<ArchiveScreen>
    with SingleTickerProviderStateMixin {
  bool _isDecrypting = true;
  int _dotCount = 0;
  Timer? _dotTimer;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);

    // Animar los puntos suspensivos
    _dotTimer = Timer.periodic(const Duration(milliseconds: 350), (t) {
      if (mounted) setState(() => _dotCount = (_dotCount + 1) % 4);
    });

    // Cargar fragmentos y mostrar contenido tras 1.8 segundos
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FragmentsProvider>(context, listen: false).loadProgress();
    });

    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) {
        _dotTimer?.cancel();
        setState(() => _isDecrypting = false);
        _fadeController.forward();
      }
    });
  }

  @override
  void dispose() {
    _dotTimer?.cancel();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = Provider.of<AppThemeProvider>(context).currentTheme;
    
    if (_isDecrypting) {
      return Scaffold(
        backgroundColor: appTheme.backgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  border: Border.all(color: appTheme.primaryColor.withOpacity(0.5), width: 1),
                ),
                child: Icon(
                  Icons.folder_special,
                  color: appTheme.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'DESCIFRADO EN CURSO${'.' * _dotCount}',
                style: GoogleFonts.shareTechMono(
                  fontSize: 13,
                  color: Colors.white38,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Accediendo al archivo de evidencias',
                style: GoogleFonts.shareTechMono(
                  fontSize: 9,
                  color: Colors.white12,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return FadeTransition(
      opacity: _fadeAnim,
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: appTheme.backgroundColor,
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(appTheme),
                _buildTabs(appTheme),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildProtocolsList(appTheme),
                      _buildPurchasedLoreList(appTheme),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(appTheme) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: appTheme.primaryColor.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios, color: appTheme.secondaryColor, size: 18),
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                'ARCHIVO DE EVIDENCIAS',
                style: GoogleFonts.shareTechMono(
                  fontSize: 20,
                  color: Colors.white,
                  letterSpacing: 4,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // Progreso global
          Consumer<FragmentsProvider>(
            builder: (context, fragmentsProvider, child) {
              final total = fragmentsProvider.totalUnlockedFragments;
              return FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '[$total]',
                  style: GoogleFonts.shareTechMono(
                    fontSize: 16,
                    color: appTheme.accentColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTabs(appTheme) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: appTheme.primaryColor.withOpacity(0.1))),
      ),
      child: TabBar(
        indicatorColor: appTheme.accentColor,
        labelColor: appTheme.accentColor,
        unselectedLabelColor: Colors.grey[600],
        labelStyle: GoogleFonts.shareTechMono(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 2),
        tabs: const [
          Tab(text: 'EVIDENCIAS'),
          Tab(text: 'RED_OS'),
        ],
      ),
    );
  }

  Widget _buildPurchasedLoreList(appTheme) {
    return Consumer<StoreProvider>(
      builder: (context, storeProvider, child) {
        final purchasedLore = StoreDataProvider.narrativeContent.where(
          (item) => storeProvider.ownsItem(item.id)
        ).toList();

        if (purchasedLore.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_outline, color: appTheme.primaryColor.withOpacity(0.2), size: 40),
                const SizedBox(height: 16),
                Text(
                  'ADQUIERE ARCHIVOS EN LA TIENDA',
                  style: GoogleFonts.shareTechMono(color: appTheme.primaryColor.withOpacity(0.4), fontSize: 10),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: purchasedLore.length,
          itemBuilder: (context, index) {
            final item = purchasedLore[index];
            return _buildLoreCard(item, appTheme);
          },
        );
      },
    );
  }

  Widget _buildLoreCard(StoreItem item, appTheme) {
    return GestureDetector(
      onTap: () {
      HapticFeedback.mediumImpact();
      context.read<AudioProvider>().playSfx('assets/sounds/new-notification-3-398649.mp3');
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => LoreDetailScreen(item: item),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.98, end: 1.0).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
                ),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          border: Border.all(color: appTheme.primaryColor.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(Icons.description_outlined, color: appTheme.accentColor),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: GoogleFonts.shareTechMono(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    item.description,
                    style: GoogleFonts.shareTechMono(color: Colors.grey, fontSize: 10),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: appTheme.primaryColor.withOpacity(0.3)),
          ],
        ),
      ),
    );
  }

  Widget _buildProtocolsList(appTheme) {
    return Consumer<FragmentsProvider>(
      builder: (context, fragmentsProvider, child) {
        // Usar la lista estática directamente
        final arcs = ArcDataProvider.allArcs;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: arcs.length,
          itemBuilder: (context, index) {
            final arc = arcs[index];
            
            // Calcular progreso manualmente
            final unlockedFragments = fragmentsProvider.getFragmentsForArc(arc.id);
            final collectedFragments = unlockedFragments.length;
            
            // Determinar total de fragmentos según el arco
            int totalFragments = 3; 
            if (arc.id == 'arc_0_inicio' || arc.id == 'arc_4_ira') totalFragments = 5;
            
            final isComplete = collectedFragments >= totalFragments;

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildProtocolCard(
                arcId: arc.id,
                title: arc.title,
                subtitle: arc.subtitle,
                collected: collectedFragments,
                total: totalFragments,
                isComplete: isComplete,
                appTheme: appTheme,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildProtocolCard({
    required String arcId,
    required String title,
    required String subtitle,
    required int collected,
    required int total,
    required bool isComplete,
    required dynamic appTheme,
  }) {
    final progress = total > 0 ? (collected / total).clamp(0.0, 1.0) : 0.0;

    return GestureDetector(
      onTap: () {
        if (collected > 0) {
          // Convertir arcId a evidenceId
          final evidenceId = _getEvidenceIdFromArcId(arcId);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CaseFileScreen(evidenceId: evidenceId),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'COMPLETA EL PROTOCOLO PARA DESBLOQUEAR',
                style: GoogleFonts.shareTechMono(),
              ),
              backgroundColor: const Color(0xFF8B0000),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          border: Border.all(
            color: isComplete
                ? appTheme.primaryColor.withOpacity(0.5)
                : Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título del protocolo
            Row(
              children: [
                Expanded(
                  child: Text(
                    title.toUpperCase(),
                    style: GoogleFonts.shareTechMono(
                      fontSize: 16,
                      color: isComplete ? appTheme.accentColor : Colors.white70,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                // Badge de estado
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isComplete
                        ? appTheme.primaryColor.withOpacity(0.2)
                        : Colors.white.withOpacity(0.05),
                    border: Border.all(
                      color: isComplete
                          ? appTheme.secondaryColor
                          : Colors.white24,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    isComplete ? 'COMPLETO' : 'BLOQUEADO',
                    style: GoogleFonts.shareTechMono(
                      fontSize: 8,
                      color: isComplete ? appTheme.accentColor : Colors.white30,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Subtítulo
            Text(
              subtitle,
              style: GoogleFonts.ebGaramond(
                fontSize: 12,
                color: Colors.white38,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 16),
            // Barra de progreso
            Row(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      // Fondo
                      Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      // Progreso
                      FractionallySizedBox(
                        widthFactor: progress,
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: isComplete
                                ? appTheme.primaryColor
                                : Colors.white30,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Contador
                Text(
                  '$collected/$total',
                  style: GoogleFonts.shareTechMono(
                    fontSize: 12,
                    color: isComplete ? appTheme.accentColor : Colors.white30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            // Botón de acción
            if (collected > 0) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '> VER EXPEDIENTE',
                  style: GoogleFonts.shareTechMono(
                    fontSize: 10,
                    color: appTheme.accentColor,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getEvidenceIdFromArcId(String arcId) {
    final mapping = {
      'arc_0_inicio':          'arc_0_inicio_evidence',
      'arc_1_envidia_lujuria': 'arc_1_envidia_lujuria_evidence',
      'arc_2_consumo_codicia': 'arc_2_consumo_codicia_evidence',
      'arc_3_soberbia_pereza': 'arc_3_soberbia_pereza_evidence',
      'arc_4_ira':             'arc_4_ira_evidence',
      // Legado (por si hay datos guardados con los IDs viejos)
      'arc_1_gula':            'arc1_gluttony_evidence',
      'arc_2_greed':           'arc2_greed_evidence',
      'arc_3_envy':            'arc3_envy_evidence',
    };
    return mapping[arcId] ?? 'arc_1_envidia_lujuria_evidence';
  }
}
