import 'package:consumo_combustible/core/fonts/app_fonts.dart';
import 'package:consumo_combustible/core/fonts/app_text_widgets.dart';
import 'package:consumo_combustible/core/theme/app_colors.dart';
import 'package:consumo_combustible/core/widgets/appbar/smart_appbar.dart';
import 'package:consumo_combustible/presentation/page/sedes/bloc/sede_bloc.dart';
import 'package:consumo_combustible/presentation/page/sedes/bloc/sede_event.dart';
import 'package:consumo_combustible/presentation/page/sedes/bloc/sede_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SedesListPage extends StatefulWidget {
  const SedesListPage({super.key});

  @override
  State<SedesListPage> createState() => _SedesListPageState();
}

class _SedesListPageState extends State<SedesListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SedeBloc>().add(const LoadSedesEvent());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: SmartAppBar(
        title: 'Gestión de Sedes',
        showUserInfo: true,
        logoPath: 'assets/img/6.svg',
        // onLeftTap: () => Navigator.pop(context),
      ),
      body: BlocBuilder<SedeBloc, SedeState>(
        builder: (context, state) {
          if (state.isLoadingSedes) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state.sedes.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<SedeBloc>().add(const LoadSedesEvent());
            },
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: state.sedes.length,
              itemBuilder: (context, index) {
                final sede = state.sedes[index];
                return Card(
                  color: AppColors.white,
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListTile(
                    // contentPadding: const EdgeInsets.all(10),
                    leading: CircleAvatar(
                      backgroundColor: sede.activo == true 
                          ? Colors.green 
                          : Colors.red,
                      radius: 14,
                      child: Text(
                        sede.codigo.substring(0, 2).toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 10
                        ),
                      ),
                    ),
                    title: AppTitle(sede.nombre),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppSubtitle('Código: ${sede.codigo}',color: AppColors.blueGrey,),
                        if (sede.zona != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.map_outlined,
                                size: 10,
                                color: AppColors.grey,
                              ),
                              const SizedBox(width: 4),
                              AppSubtitle('Zona: ${sede.zona!.nombre}',color: AppColors.grey,)
                            ],
                          ),
                        ],
                        if (sede.direccion != null) ...[
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 12,
                                color: AppColors.grey,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  sede.direccion!,
                                  style: AppFont.oxygenBold.style(
                                    fontSize: 10,
                                    color: AppColors.grey,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (sede.telefono != null) ...[
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(
                                Icons.phone_outlined,
                                size: 12,
                                color: AppColors.grey,
                              ),
                              const SizedBox(width: 4),
                              AppSubtitle(sede.telefono!,color: AppColors.grey)
                            ],
                          ),
                        ],
                      ],
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${sede.grifosCount ?? 0} grifos',
                        style: AppFont.pirulentBold.style(
                          fontSize: 6,
                          color: Colors.orange,
                        ),
                      ),
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
            Navigator.pushNamed(context, 'create-sede');
          },
          backgroundColor: AppColors.blue3,
          icon: const Icon(Icons.add, color: Colors.white,size: 16,),
          label: Text(
            'Nueva Sede',
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
              Icons.business_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 24),
            Text(
              'No hay sedes registradas',
              style: AppFont.pirulentBold.style(
                fontSize: 18,
                color: AppColors.grey,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Comienza agregando tu primera sede',
              style: AppFont.pirulentBold.style(
                fontSize: 14,
                color: AppColors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, 'create-sede');
              },
              icon: const Icon(Icons.add),
              label: const Text('Agregar Sede'),
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