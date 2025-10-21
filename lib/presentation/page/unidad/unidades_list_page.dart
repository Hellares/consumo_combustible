// lib/presentation/page/unidades/unidades_list_page.dart

import 'package:consumo_combustible/core/fonts/app_fonts.dart';
import 'package:consumo_combustible/core/fonts/app_text_widgets.dart';
import 'package:consumo_combustible/core/theme/app_colors.dart';
import 'package:consumo_combustible/core/widgets/appbar/smart_appbar.dart';
import 'package:consumo_combustible/data/api/api_config.dart';
import 'package:consumo_combustible/domain/models/unidad.dart';
import 'package:consumo_combustible/domain/use_cases/auth/auth_use_cases.dart';
import 'package:consumo_combustible/injection.dart';
import 'package:consumo_combustible/presentation/page/gps/conductor/conductor_tracking_page.dart';
import 'package:consumo_combustible/presentation/page/unidad/bloc/unidad_bloc.dart';
import 'package:consumo_combustible/presentation/page/unidad/bloc/unidad_event.dart';
import 'package:consumo_combustible/presentation/page/unidad/bloc/unidad_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UnidadesListPage extends StatefulWidget {
  const UnidadesListPage({super.key});

  @override
  State<UnidadesListPage> createState() => _UnidadesListPageState();
}

class _UnidadesListPageState extends State<UnidadesListPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // Cargar unidades al iniciar
    context.read<UnidadBloc>().add(const LoadAllUnidades(refresh: true));

    // Listener para paginación infinita
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<UnidadBloc>().add(const LoadNextPage());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SmartAppBar(
        customHeight: 35,
        title: 'Unidades',
        showLogo: true,
        logoPath: ApiConfig.logoLottiePath,
      ),
      body: BlocConsumer<UnidadBloc, UnidadState>(
        listener: (context, state) {
          // Mostrar mensajes de error
          if (state.status == UnidadStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Error al cargar unidades'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          // Estado inicial o loading completo
          if (state.status == UnidadStatus.loading && state.unidades.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          // Sin datos
          if (state.unidades.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.local_shipping_outlined,
                    size: 60,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay unidades registradas',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Navegar a crear unidad
                      Navigator.pushNamed(context, 'crear-unidad');
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Crear Primera Unidad'),
                  ),
                ],
              ),
            );
          }

          // Lista con datos
          return RefreshIndicator(
            onRefresh: () async {
              context.read<UnidadBloc>().add(
                const LoadAllUnidades(refresh: true),
              );
              // Esperar a que se complete la carga
              await Future.delayed(const Duration(milliseconds: 500));
            },
            child: Column(
              children: [
                // Header con información
                _buildHeader(state),

                // Lista de unidades
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: state.unidades.length + (state.hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      // Mostrar loader al final si hay más páginas
                      if (index >= state.unidades.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final unidad = state.unidades[index];
                      return _buildUnidadCard(context, unidad);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: SizedBox(
        height: 35,
        width: 130,
        child: FloatingActionButton.extended(
          backgroundColor: AppColors.blue3,
          icon: const Icon(Icons.add, color: Colors.white, size: 16),
          onPressed: _navigateToCreateUnidad,
          label: Text(
            'Nueva Unidad',
            style: AppFont.pirulentBold.style(fontSize: 8, color: Colors.white),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(UnidadState state) {
    return Container(
      alignment: Alignment.center,
      height: 35,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        // color: Theme.of(context).primaryColor.withOpacity(0.1),
        border: Border(bottom: BorderSide(color: Colors.grey[300]!, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total: ${state.total} unidades',
                style: const TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Página ${state.currentPage} de ${state.totalPages}',
                style: TextStyle(fontSize: 8, color: Colors.grey[600]),
              ),
            ],
          ),
          IconButton(
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.filter_list, size: 20),
            onPressed: () {
              // TODO: Implementar filtros
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Filtros próximamente')),
              );
            },
          ),
        ],
      ),
    );
  }


  Widget _buildUnidadCard(BuildContext context, Unidad unidad) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Navegar a detalle
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Placa, Modelo y Estado
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.blue3.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.local_shipping,
                        color: AppColors.blue3,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            unidad.placa,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${unidad.marca} ${unidad.modelo}',
                            style: TextStyle(
                              fontSize: 9,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildEstadoChip(unidad.estado),
                  ],
                ),

                const SizedBox(height: 6),

                // Grid de información compacta
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoItem(
                              icon: Icons.person_outline,
                              label: 'Conductor',
                              value: unidad.conductorOperador.nombreCompleto,
                            ),
                          ),
                          SizedBox(width: 7,),
                          Container(
                            width: 1,
                            height: 32,
                            color: Colors.grey[300],
                          ),
                          SizedBox(width: 7,),
                          Expanded(
                            child: _buildInfoItem(
                              icon: Icons.location_on_outlined,
                              label: 'Zona',
                              value: unidad.zonaOperacion.nombre,
                            ),
                          ),
                        ],
                      ),

                      Divider(height: 20, color: Colors.grey[300]),

                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoItem(
                              icon: Icons.local_gas_station_outlined,
                              label: 'Combustible',
                              value: unidad.tipoCombustible,
                            ),
                          ),
                          SizedBox(width: 7,),
                          Container(
                            width: 1,
                            height: 32,
                            color: Colors.grey[300],
                          ),
                          SizedBox(width: 7,),
                          Expanded(
                            child: _buildInfoItem(
                              icon: Icons.water_drop_outlined,
                              label: 'Tanque',
                              value:
                                  '${unidad.capacidadTanque.toStringAsFixed(0)} L',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Estadísticas en línea horizontal
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        icon: Icons.speed,
                        label: 'Km',
                        value: unidad.odometroInicial.toStringAsFixed(0),
                      ),
                    ),
                    Container(width: 1, height: 40, color: Colors.grey[200]),
                    Expanded(
                      child: _buildStatItem(
                        icon: Icons.calendar_today_outlined,
                        label: 'Antigüedad',
                        value: '${unidad.antiguedadAnios} años',
                      ),
                    ),
                    Container(width: 1, height: 40, color: Colors.grey[200]),
                    Expanded(
                      child: _buildStatItem(
                        icon: Icons.build_outlined,
                        label: 'Mantenim.',
                        value: unidad.mantenimientosCount.toString(),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Botón de tracking mejorado
                SizedBox(
                  width: double.infinity,
                  height: 35,
                  child: ElevatedButton(
                    onPressed: () => _navigateToGpsTracking(unidad),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.blue3,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.gps_fixed, size: 16),
                        const SizedBox(width: 8),
                        AppTitle(
                          'Ver Tracking GPS',
                          fontSize: 11,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEstadoChip(String estado) {
    Color color;
    IconData icon;

    switch (estado) {
      case 'OPERATIVO':
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'MANTENIMIENTO':
        color = Colors.orange;
        icon = Icons.build_circle;
        break;
      case 'AVERIADO':
        color = Colors.red;
        icon = Icons.error;
        break;
      default:
        color = Colors.grey;
        icon = Icons.info;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          AppLabelText(estado, fontSize: 8, color: color),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: Colors.grey[500]),
              const SizedBox(width: 6),
              AppSubtitle(label, font: AppFont.oxygenRegular),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w400),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.blue3),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: 9, color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Future<void> _navigateToGpsTracking(Unidad unidad) async {
    try {
      // ✅ Obtener AuthUseCases del locator (igual que en tus otros archivos)
      final authUseCases = locator<AuthUseCases>();

      // ✅ Obtener sesión del storage
      final session = await authUseCases.getUserSession.run();

      // Validar que haya sesión
      if (session?.data?.token == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No hay sesión activa. Por favor, inicia sesión.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final token = session!.data!.token;

      if (!mounted) return;

      // Navegar a la página de tracking
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ConductorTrackingPage(
            unidadId: unidad.id,
            placa: unidad.placa,
            jwtToken: token,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al abrir tracking: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Navegar a crear unidad
  Future<void> _navigateToCreateUnidad() async {
    final result = await Navigator.pushNamed(context, 'crear-unidad');

    // Verificar que el widget sigue montado antes de usar el context
    if (!mounted) return;

    if (result != null) {
      // Recargar lista después de crear
      context.read<UnidadBloc>().add(const LoadAllUnidades(refresh: true));
    }
  }
}
