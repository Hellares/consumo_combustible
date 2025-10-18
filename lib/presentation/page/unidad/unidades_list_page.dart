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
        title: 'Unidades',
        showLogo: true,
        logoPath: ApiConfig.logoPath,
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
            return const Center(
              child: CircularProgressIndicator(),
            );
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
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Navegar a crear unidad
                      Navigator.pushNamed(context, '/crear-unidad');
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
              context.read<UnidadBloc>().add(const LoadAllUnidades(refresh: true));
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
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
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
          icon: const Icon(Icons.add, color: Colors.white,size: 16,),
          onPressed: _navigateToCreateUnidad,
          label: Text(
              'Nueva Unidad',
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

  Widget _buildHeader(UnidadState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        // color: Theme.of(context).primaryColor.withOpacity(0.1),
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
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
              const SizedBox(height: 4),
              Text(
                'Página ${state.currentPage} de ${state.totalPages}',
                style: TextStyle(
                  fontSize: 8,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
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
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () {
          // Navegar a detalle
          // Navigator.pushNamed(
          //   context,
          //   '/unidad-detalle',
          //   arguments: unidad.id,
          // );
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Placa y Estado
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.local_shipping,
                        color: AppColors.blue3,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            unidad.placa,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${unidad.marca} ${unidad.modelo}',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  _buildEstadoChip(unidad.estado),
                ],
              ),
              
              const Divider(height: 24),
              
              // Información detallada
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      icon: Icons.person,
                      label: 'Conductor',
                      value: unidad.conductorOperador.nombreCompleto,
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      icon: Icons.location_on,
                      label: 'Zona',
                      value: unidad.zonaOperacion.nombre,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      icon: Icons.local_gas_station,
                      label: 'Combustible',
                      value: unidad.tipoCombustible,
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      icon: Icons.water_drop,
                      label: 'Tanque',
                      value: '${unidad.capacidadTanque.toStringAsFixed(0)} L',
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Estadísticas
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    icon: Icons.speed,
                    label: 'Km',
                    value: unidad.odometroInicial.toStringAsFixed(0),
                  ),
                  _buildStatItem(
                    icon: Icons.calendar_today,
                    label: 'Antigüedad',
                    value: '${unidad.antiguedadAnios} años',
                  ),
                  _buildStatItem(
                    icon: Icons.build,
                    label: 'Mantenimientos',
                    value: unidad.mantenimientosCount.toString(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _navigateToGpsTracking(unidad),
                  icon: const Icon(Icons.gps_fixed, size: 18),
                  label: const Text('Ver Tracking GPS'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blue3,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              )
            ],
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
        icon = Icons.build;
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
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color, width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          AppLabelText(estado,fontSize: 8,color: AppColors.green,)
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSubtitle(label, font: AppFont.oxygenRegular,),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, size: 16, color: Colors.grey[700]),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
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