// lib/presentation/page/licencias/licencias_page.dart

import 'package:consumo_combustible/core/fonts/app_text_widgets.dart';
import 'package:consumo_combustible/core/theme/app_colors.dart';
import 'package:consumo_combustible/core/theme/app_gradients.dart';
import 'package:consumo_combustible/core/theme/gradient_container.dart';
import 'package:consumo_combustible/core/widgets/appbar/smart_appbar.dart';
import 'package:consumo_combustible/core/widgets/snack.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';
import 'package:consumo_combustible/presentation/page/licencias/bloc/licencia_bloc.dart';
import 'package:consumo_combustible/presentation/page/licencias/bloc/licencia_event.dart';
import 'package:consumo_combustible/presentation/page/licencias/bloc/licencia_state.dart';
import 'package:consumo_combustible/presentation/page/licencias/create_licencia_page.dart';
import 'package:consumo_combustible/presentation/page/licencias/widgets/licencia_card.dart';
import 'package:consumo_combustible/presentation/page/licencias/widgets/licencia_filter_chips.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LicenciasPage extends StatefulWidget {
  const LicenciasPage({super.key});

  @override
  State<LicenciasPage> createState() => _LicenciasPageState();
}

class _LicenciasPageState extends State<LicenciasPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Cargar licencias después de que el widget esté montado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LicenciaBloc>().add(const LoadLicencias());
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      context.read<LicenciaBloc>().add(const LoadMoreLicencias());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SmartAppBar(title: 'Licencias de Conducir', showUserInfo: true, logoPath: "assets/img/6.svg",),
      body: BlocConsumer<LicenciaBloc, LicenciaState>(
        listener: (context, state) {
          if (state.response is Error) {
            final error = state.response as Error;
            SnackBarHelper.showError(context, error.message);
          }
        },
        builder: (context, state) {
          return GradientContainer(
            gradient: AppGradients.custom(
              startColor: AppColors.white,
              middleColor: AppColors.white,
              endColor: const Color.fromARGB(255, 175, 213, 250),
              stops: const [0.0, 0.5, 1.0],
            ),
            child: Column(
              children: [
                // Buscador
                _buildSearchBar(context),

                // Estadísticas rápidas
                _buildStatsRow(state),

                // Filtros por estado
                LicenciaFilterChips(
                  onFilterChanged: (filtro) {
                    // Limpiar búsqueda cuando se cambia de filtro
                    _searchController.clear();
                    
                    final bloc = context.read<LicenciaBloc>();
                    // Limpiar filtro de búsqueda en el bloc
                    bloc.add(const FilterLicencias(''));
                    
                    switch (filtro) {
                      case 'TODAS':
                        bloc.add(const LoadLicencias());
                        break;
                      case 'VIGENTES':
                        bloc.add(const LoadLicencias());
                        break;
                      case 'VENCIDAS':
                        bloc.add(const LoadLicenciasVencidas());
                        break;
                      case 'PROXIMAS':
                        bloc.add(const LoadLicenciasProximasVencer());
                        break;
                    }
                  },
                ),

                // Lista de licencias
                Expanded(child: _buildLicenciasList(state)),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CreateLicenciaPage(),
            ),
          );
          
          // Si se creó exitosamente, recargar la lista
          if (result == true && mounted) {
            context.read<LicenciaBloc>().add(const LoadLicencias(page: 1));
          }
        },
        backgroundColor: AppColors.blue3,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Buscar por número, nombre, DNI...',
        prefixIcon: const Icon(Icons.search, size: 18,),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  context.read<LicenciaBloc>().add(const FilterLicencias(''));
                },
              )
            : null,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        hintStyle: TextStyle(fontSize: 11),
        isDense: true
      ),
      onChanged: (query) {
        context.read<LicenciaBloc>().add(FilterLicencias(query));
      },
    );
  }

  Widget _buildStatsRow(LicenciaState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatCard(
            icon: Icons.check_circle,
            label: 'Vigentes',
            value: state.vigentesCount.toString(),
            color: Colors.green,
          ),
          _buildStatCard(
            icon: Icons.warning_amber,
            label: 'Próximas',
            value: state.proximasCount.toString(),
            color: Colors.orange,
          ),
          _buildStatCard(
            icon: Icons.cancel,
            label: 'Vencidas',
            value: state.vencidasCount.toString(),
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return GradientContainer(
      shadowStyle: ShadowStyle.neumorphic,
      gradient: AppGradients.sinfondo,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 4),
          AppCaption(label, fontSize: 10, color: Colors.grey[600]),
          const SizedBox(height: 2),
          AppSubtitle(value, fontSize: 14, color: color),
        ],
      ),
    );
    
  }

  Widget _buildLicenciasList(LicenciaState state) {
    if (state.isLoading && state.licencias.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            AppSubtitle(
              'No hay licencias registradas',
              color: Colors.grey[600],
            ),
            const SizedBox(height: 8),
            AppCaption(
              'Presiona el botón + para agregar una',
              color: Colors.grey[500],
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<LicenciaBloc>().add(const RefreshLicencias());
        await Future.delayed(const Duration(seconds: 1));
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount:
            state.displayLicencias.length + (state.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.displayLicencias.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final licencia = state.displayLicencias[index];
          return LicenciaCard(
            licencia: licencia,
            onTap: () {
              // TODO: Navegar a detalle de licencia
              // Navigator.push(context, MaterialPageRoute(
              //   builder: (_) => LicenciaDetailPage(licencia: licencia),
              // ));
            },
          );
        },
      ),
    );
  }
}
