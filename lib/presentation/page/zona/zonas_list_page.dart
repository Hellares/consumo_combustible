import 'package:consumo_combustible/core/fonts/app_fonts.dart';
import 'package:consumo_combustible/core/fonts/app_text_widgets.dart';
import 'package:consumo_combustible/core/theme/app_colors.dart';
import 'package:consumo_combustible/core/widgets/appbar/smart_appbar.dart';
import 'package:consumo_combustible/presentation/page/zona/bloc/zona_bloc.dart';
import 'package:consumo_combustible/presentation/page/zona/bloc/zona_event.dart';
import 'package:consumo_combustible/presentation/page/zona/bloc/zona_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ZonasListPage extends StatefulWidget {
  const ZonasListPage({super.key});

  @override
  State<ZonasListPage> createState() => _ZonasListPageState();
}

class _ZonasListPageState extends State<ZonasListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ZonaBloc>().add(const LoadZonasEvent());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: SmartAppBar(
        title: 'Gestión de Zonas',
        showUserInfo: true,
        logoPath: "assets/img/6.svg",
        onLeftTap: () => Navigator.pop(context),
      ),
      body: BlocBuilder<ZonaBloc, ZonaState>(
        builder: (context, state) {
          if (state.isLoadingZonas) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state.zonas.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<ZonaBloc>().add(const LoadZonasEvent());
            },
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              itemCount: state.zonas.length,
              itemBuilder: (context, index) {
                final zona = state.zonas[index];
                return Card(
                  color: AppColors.white,
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(10),
                    leading: CircleAvatar(
                      backgroundColor: zona.activo ? Colors.green : Colors.red,
                      radius: 14,
                      child: Text(
                        zona.codigo.substring(0, 2).toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 10
                        ),
                      ),
                    ),
                    title: AppTitle(zona.nombre),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        AppSubtitle('Código: ${zona.codigo}',color: AppColors.blueGrey,),
                        if (zona.descripcion != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            zona.descripcion!,
                            style: AppFont.oxygenBold.style(
                              fontSize: 10,
                              color: AppColors.grey,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: AppLabelText('${zona.sedesCount} sedes', font: AppFont.pirulentBold, fontSize: 6,),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: AppLabelText('${zona.unidadesCount} unidades', font: AppFont.pirulentBold, fontSize: 6,),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: SizedBox(
        height: 35,
        width: 120,
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.pushNamed(context, 'create-zona');
          },
          backgroundColor: AppColors.blue3,
          icon: const Icon(Icons.add, color: Colors.white, size: 16,),
          label: Text(
            'Nueva Zona',
            style: AppFont.pirulentBold.style(
              fontSize: 8,
              color: Colors.white,
            ),
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.map_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 24),
            Text(
              'No hay zonas registradas',
              style: AppFont.pirulentBold.style(
                fontSize: 18,
                color: AppColors.grey,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Comienza agregando tu primera zona geográfica',
              style: AppFont.pirulentBold.style(
                fontSize: 14,
                color: AppColors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, 'create-zona');
              },
              icon: const Icon(Icons.add),
              label: const Text('Agregar Zona'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blue3,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}