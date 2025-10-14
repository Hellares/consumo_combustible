import 'package:consumo_combustible/core/fonts/app_fonts.dart';
import 'package:consumo_combustible/core/theme/app_colors.dart';
import 'package:consumo_combustible/core/widgets/appbar/smart_appbar.dart';
import 'package:consumo_combustible/presentation/page/grifos/bloc/grifo_bloc.dart';
import 'package:consumo_combustible/presentation/page/grifos/bloc/grifo_event.dart';
import 'package:consumo_combustible/presentation/page/grifos/bloc/grifo_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GrifosListPage extends StatefulWidget {
  const GrifosListPage({super.key});

  @override
  State<GrifosListPage> createState() => _GrifosListPageState();
}

class _GrifosListPageState extends State<GrifosListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GrifoBloc>().add(const LoadGrifosEvent());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: SmartAppBar(
        title: 'Gestión de Grifos',
        showUserInfo: true,
        logoPath: 'assets/img/6.svg',
      ),
      body: BlocBuilder<GrifoBloc, GrifoState>(
        builder: (context, state) {
          if (state.isLoadingGrifos) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.grifos.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<GrifoBloc>().add(const LoadGrifosEvent());
            },
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: state.grifos.length,
              itemBuilder: (context, index) {
                final grifo = state.grifos[index];
                // return Card(
                //   color: AppColors.white,
                //   margin: const EdgeInsets.only(bottom: 12),
                //   elevation: 2,
                //   shape: RoundedRectangleBorder(
                //     borderRadius: BorderRadius.circular(8),
                //   ),
                //   child: ListTile(
                //     // contentPadding: const EdgeInsets.all(16),
                //     leading: CircleAvatar(
                //       backgroundColor: grifo.activo == true
                //           ? Colors.green
                //           : Colors.red,
                //       radius: 14,
                //       child: Icon(
                //         Icons.local_gas_station,
                //         color: Colors.white,
                //         size: 12,
                //       ),
                //     ),
                //     title: Text(
                //       grifo.nombre,
                //       style: AppFont.oxygenBold.style(fontSize: 12),
                //     ),
                //     subtitle: Column(
                //       crossAxisAlignment: CrossAxisAlignment.start,
                //       children: [
                //         const SizedBox(height: 4),
                //         Text(
                //           'Código: ${grifo.codigo ?? "N/A"}',
                //           style: AppFont.oxygenRegular.style(
                //             fontSize: 10,
                //             color: AppColors.grey,
                //           ),
                //         ),
                //         if (grifo.sede != null) ...[
                //           const SizedBox(height: 2),
                //           Row(
                //             children: [
                //               Icon(
                //                 Icons.business_outlined,
                //                 size: 12,
                //                 color: AppColors.blue3,
                //               ),
                //               const SizedBox(width: 4),
                //               Text(
                //                 'Sede: ${grifo.sede!.nombre}',
                //                 style: AppFont.oxygenRegular.style(
                //                   fontSize: 10,
                //                   color: AppColors.blue3,
                //                 ),
                //               ),
                //             ],
                //           ),
                //         ],
                //         if (grifo.sede?.zona != null) ...[
                //           const SizedBox(height: 2),
                //           Row(
                //             children: [
                //               Icon(
                //                 Icons.map_outlined,
                //                 size: 12,
                //                 color: AppColors.grey,
                //               ),
                //               const SizedBox(width: 4),
                //               Text(
                //                 'Zona: ${grifo.sede!.zona!.nombre}',
                //                 style: AppFont.oxygenRegular.style(
                //                   fontSize: 10,
                //                   color: AppColors.grey,
                //                 ),
                //               ),
                //             ],
                //           ),
                //         ],
                //         if (grifo.direccion != null) ...[
                //           const SizedBox(height: 2),
                //           Row(
                //             children: [
                //               Icon(
                //                 Icons.location_on_outlined,
                //                 size: 12,
                //                 color: AppColors.grey,
                //               ),
                //               const SizedBox(width: 4),
                //               Expanded(
                //                 child: Text(
                //                   grifo.direccion!,
                //                   style: AppFont.oxygenRegular.style(
                //                     fontSize: 10,
                //                     color: AppColors.grey,
                //                   ),
                //                   maxLines: 1,
                //                   overflow: TextOverflow.ellipsis,
                //                 ),
                //               ),
                //             ],
                //           ),
                //         ],
                //         if (grifo.horarioApertura != null &&
                //             grifo.horarioCierre != null) ...[
                //           const SizedBox(height: 2),
                //           Row(
                //             children: [
                //               Icon(
                //                 Icons.access_time,
                //                 size: 12,
                //                 color: AppColors.grey,
                //               ),
                //               const SizedBox(width: 4),
                //               Text(
                //                 '${grifo.horarioApertura} - ${grifo.horarioCierre}',
                //                 style: AppFont.oxygenRegular.style(
                //                   fontSize: 10,
                //                   color: AppColors.grey,
                //                 ),
                //               ),
                //             ],
                //           ),
                //         ],
                //       ],
                //     ),
                //     trailing: Column(
                //       mainAxisAlignment: MainAxisAlignment.center,
                //       crossAxisAlignment: CrossAxisAlignment.end,
                //       children: [
                //         InkWell(
                //           onTap: () async {
                //             final result = await Navigator.pushNamed(
                //               context,
                //               'edit-grifo',
                //               arguments: grifo.id,
                //             );

                //             // Si se editó exitosamente, recargar lista
                //             if (result == true) {
                //               if (context.mounted) {
                //                 context.read<GrifoBloc>().add(
                //                   const LoadGrifosEvent(),
                //                 );
                //               }
                //             }
                //           },
                //           child: Container(
                //             padding: const EdgeInsets.all(6),
                //             decoration: BoxDecoration(
                //               color: AppColors.blue3.withValues(alpha: 0.1),
                //               borderRadius: BorderRadius.circular(6),
                //             ),
                //             child: Icon(
                //               Icons.edit,
                //               size: 14,
                //               color: AppColors.blue3,
                //             ),
                //           ),
                //         ),
                //         const SizedBox(height: 4),
                //         Container(
                //           padding: const EdgeInsets.symmetric(
                //             horizontal: 8,
                //             vertical: 4,
                //           ),
                //           decoration: BoxDecoration(
                //             color: grifo.estaAbierto == true
                //                 ? Colors.green.withValues(alpha: 0.1)
                //                 : Colors.red.withValues(alpha: 0.1),
                //             borderRadius: BorderRadius.circular(4),
                //           ),
                //           child: Text(
                //             grifo.estaAbierto == true ? 'Abierto' : 'Cerrado',
                //             style: AppFont.oxygenRegular.style(
                //               fontSize: 8,
                //               color: grifo.estaAbierto == true
                //                   ? Colors.green
                //                   : Colors.red,
                //             ),
                //           ),
                //         ),
                //         const SizedBox(height: 4),
                //         Container(
                //           padding: const EdgeInsets.symmetric(
                //             horizontal: 8,
                //             vertical: 4,
                //           ),
                //           decoration: BoxDecoration(
                //             color: Colors.orange.withValues(alpha: 0.1),
                //             borderRadius: BorderRadius.circular(4),
                //           ),
                //           child: Text(
                //             '${grifo.ticketsAbastecimientoCount ?? 0} tickets',
                //             style: AppFont.oxygenRegular.style(
                //               fontSize: 8,
                //               color: Colors.orange,
                //             ),
                //           ),
                //         ),
                //       ],
                //     ),
                //   ),
                // );
                return Card(
  color: AppColors.white,
  margin: const EdgeInsets.only(bottom: 12),
  elevation: 2,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(8),
  ),
  child: Stack(
    children: [
      // ⭐ CONTENIDO PRINCIPAL DEL CARD
      ListTile(
        contentPadding: const EdgeInsets.fromLTRB(16, 8, 60, 8), // Espacio a la derecha para el botón
        leading: CircleAvatar(
          backgroundColor: grifo.activo == true
              ? Colors.green
              : Colors.red,
          radius: 14,
          child: Icon(
            Icons.local_gas_station,
            color: Colors.white,
            size: 12,
          ),
        ),
        title: Text(
          grifo.nombre,
          style: AppFont.oxygenBold.style(fontSize: 12),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Código: ${grifo.codigo ?? "N/A"}',
              style: AppFont.oxygenRegular.style(
                fontSize: 10,
                color: AppColors.grey,
              ),
            ),
            if (grifo.sede != null) ...[
              const SizedBox(height: 2),
              Row(
                children: [
                  Icon(
                    Icons.business_outlined,
                    size: 12,
                    color: AppColors.blue3,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Sede: ${grifo.sede!.nombre}',
                    style: AppFont.oxygenRegular.style(
                      fontSize: 10,
                      color: AppColors.blue3,
                    ),
                  ),
                ],
              ),
            ],
            if (grifo.sede?.zona != null) ...[
              const SizedBox(height: 2),
              Row(
                children: [
                  Icon(
                    Icons.map_outlined,
                    size: 12,
                    color: AppColors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Zona: ${grifo.sede!.zona!.nombre}',
                    style: AppFont.oxygenRegular.style(
                      fontSize: 10,
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ),
            ],
            if (grifo.direccion != null) ...[
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
                      grifo.direccion!,
                      style: AppFont.oxygenRegular.style(
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
            if (grifo.horarioApertura != null &&
                grifo.horarioCierre != null) ...[
              const SizedBox(height: 2),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 12,
                    color: AppColors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${grifo.horarioApertura} - ${grifo.horarioCierre}',
                    style: AppFont.oxygenRegular.style(
                      fontSize: 10,
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ),
            ],
            // ⭐ BADGES EN LA PARTE INFERIOR
            const SizedBox(height: 6),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: grifo.estaAbierto == true
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    grifo.estaAbierto == true ? 'Abierto' : 'Cerrado',
                    style: AppFont.oxygenRegular.style(
                      fontSize: 8,
                      color: grifo.estaAbierto == true
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${grifo.ticketsAbastecimientoCount ?? 0} tickets',
                    style: AppFont.oxygenRegular.style(
                      fontSize: 8,
                      color: Colors.orange,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      
      // ⭐ BOTÓN DE EDITAR EN LA ESQUINA SUPERIOR DERECHA
      Positioned(
        top: 8,
        right: 8,
        child: InkWell(
          onTap: () async {
            final result = await Navigator.pushNamed(
              context,
              'edit-grifo',
              arguments: grifo.id,
            );
            
            if (result == true && context.mounted) {
              context.read<GrifoBloc>().add(const LoadGrifosEvent());
            }
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.blue3.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              Icons.edit,
              size: 16,
              color: AppColors.blue3,
            ),
          ),
        ),
      ),
    ],
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
            Navigator.pushNamed(context, 'create-grifo');
          },
          backgroundColor: AppColors.blue3,
          icon: const Icon(Icons.add, color: Colors.white, size: 16),
          label: Text(
            'Nuevo Grifo',
            style: AppFont.pirulentBold.style(fontSize: 8, color: Colors.white),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_gas_station_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 24),
            Text(
              'No hay grifos registrados',
              style: AppFont.pirulentBold.style(
                fontSize: 18,
                color: AppColors.grey,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Comienza agregando tu primer grifo',
              style: AppFont.oxygenRegular.style(
                fontSize: 14,
                color: AppColors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, 'create-grifo');
              },
              icon: const Icon(Icons.add),
              label: const Text('Agregar Grifo'),
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
