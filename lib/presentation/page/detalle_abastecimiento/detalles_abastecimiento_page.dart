import 'package:consumo_combustible/core/fonts/app_text_widgets.dart';
import 'package:consumo_combustible/core/theme/app_colors.dart';
import 'package:consumo_combustible/core/widgets/snack.dart';
import 'package:consumo_combustible/domain/models/detalle_abastecimiento.dart';
import 'package:consumo_combustible/domain/use_cases/location/location_use_cases.dart';
import 'package:consumo_combustible/domain/use_cases/archivo/archivo_use_cases.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';
import 'package:consumo_combustible/injection.dart';
import 'package:consumo_combustible/presentation/page/archivo/bloc/archivo_bloc.dart';
import 'package:consumo_combustible/presentation/page/detalle_abastecimiento/bloc/detalle_abastecimiento_bloc.dart';
import 'package:consumo_combustible/presentation/page/detalle_abastecimiento/bloc/detalle_abastecimiento_event.dart';
import 'package:consumo_combustible/presentation/page/detalle_abastecimiento/bloc/detalle_abastecimiento_state.dart';
import 'package:consumo_combustible/presentation/page/detalle_abastecimiento/widgets/archivos_upload_widget.dart';
import 'package:consumo_combustible/presentation/page/detalle_abastecimiento/detalle_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class DetallesAbastecimientoPage extends StatefulWidget {
  const DetallesAbastecimientoPage({super.key});

  @override
  State<DetallesAbastecimientoPage> createState() => _DetallesAbastecimientoPageState();
}

class _DetallesAbastecimientoPageState extends State<DetallesAbastecimientoPage> {
  late final DetalleAbastecimientoBloc _bloc;
  final ScrollController _scrollController = ScrollController();
  int? _grifoId;

  @override
  void initState() {
    super.initState();
    _bloc = context.read<DetalleAbastecimientoBloc>();
    _loadGrifoId();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadGrifoId() async {
    final locationUseCases = locator<LocationUseCases>();
    final location = await locationUseCases.getSelectedLocation.run();

    if (location != null) {
      setState(() => _grifoId = location.grifo.id);
      _bloc.add(LoadDetallesAbastecimiento(grifoId: location.grifo.id));
    } else {
      if (mounted) {
        SnackBarHelper.showError(context, 'No hay grifo seleccionado');
      }
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _bloc.add(const LoadMoreDetalles());
    }
  }

  // ✅ NUEVO: Mostrar modal de archivos
  void _showArchivosModal(DetalleAbastecimiento detalle) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocProvider(
        create: (context) => ArchivoBloc(locator<ArchivoUseCases>()),
        child: DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  // Header del modal
                  Container(
                    padding: const EdgeInsets.only(left: 20),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.attachment, color: Colors.blue, size: 20,),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Archivos de Ticket',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade900,
                                ),
                              ),
                              Text(
                                detalle.ticket.numeroTicket,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 20,),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  // Widget de archivos
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: ArchivosUploadWidget(
                        ticketId: detalle.ticket.id,
                        isConcluido: detalle.estado == 'CONCLUIDO', // ✅ Pasar estado
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: 25,
            padding: const EdgeInsets.only(left: 16, right: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AppTitle('Detalles de Abastecimiento'),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.refresh, size: 20, color: Colors.blue),
                  onPressed: (){
                    if (_grifoId != null ) {
                      _bloc.add(LoadDetallesAbastecimiento(grifoId: _grifoId!));
                    }
                  },
                ),
              ],
            ),
          ),

          Expanded(
            child: BlocConsumer<DetalleAbastecimientoBloc, DetalleAbastecimientoState>(
              bloc: _bloc,
              listener: (context, state) {
                if (state.actualizarResponse is Success) {
                  SnackBarHelper.showSuccess(context, 'Detalle actualizado exitosamente');
                  _bloc.add(const ResetDetallesState());
                } else if (state.actualizarResponse is Error) {
                  final error = state.actualizarResponse as Error;
                  SnackBarHelper.showError(context, error.message);
                }
            
                if (state.concluirResponse is Success) {
                  SnackBarHelper.showSuccess(context, 'Detalle concluido exitosamente');
                  _bloc.add(const ResetDetallesState());
                } else if (state.concluirResponse is Error) {
                  final error = state.concluirResponse as Error;
                  SnackBarHelper.showError(context, error.message);
                }
              },
              builder: (context, state) {
                if (state.detallesResponse is Loading && state.detalles.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
            
                if (state.detallesResponse is Error && state.detalles.isEmpty) {
                  final error = state.detallesResponse as Error;
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          error.message,
                          style: const TextStyle(fontSize: 16, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            if (_grifoId != null) {
                              _bloc.add(LoadDetallesAbastecimiento(grifoId: _grifoId!));
                            }
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  );
                }
            
                if (state.detalles.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No hay detalles de abastecimiento',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }
            
                return Column(
                  children: [
                    _buildHeader(state),
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: state.detalles.length + (state.isLoadingMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == state.detalles.length) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
            
                          final detalle = state.detalles[index];
                          return _buildDetalleCard(detalle);
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(DetalleAbastecimientoState state) {
    return Container(
      padding: EdgeInsets.only(left: 14,right: 14,top: 3, bottom: 3),
      color: Colors.blue.shade50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSubtitle('Total de Detalles',color: AppColors.blueGrey,),
              AppTitle('${state.meta?.total ?? 0}', color: AppColors.orange,fontSize: 12,)
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AppSubtitle('Página',color: AppColors.blueGrey,),
              AppSubtitle('${state.currentPage} de ${state.meta?.totalPages ?? 0}')
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetalleCard(DetalleAbastecimiento detalle) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final timeFormat = DateFormat('HH:mm');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetalleDetailPage(detalle: detalle),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: AppTitle(detalle.ticket.numeroTicket),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: detalle.estadoColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: detalle.estadoColor),
                    ),
                    child: Text(
                      detalle.estadoTexto,
                      style: TextStyle(
                        color: detalle.estadoColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildInfoRow(
                Icons.local_shipping,
                'Unidad',
                '${detalle.ticket.placaUnidad} - ${detalle.ticket.unidadDescripcion}',
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                Icons.person,
                'Conductor',
                detalle.ticket.conductorNombre,
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                Icons.local_gas_station,
                'Grifo',
                detalle.ticket.grifoNombre,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoRow(
                      Icons.calendar_today,
                      'Fecha',
                      dateFormat.format(detalle.ticket.fecha),
                    ),
                  ),
                  Expanded(
                    child: _buildInfoRow(
                      Icons.access_time,
                      'Hora',
                      timeFormat.format(detalle.ticket.hora),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoRow(
                      Icons.local_gas_station,
                      'Solicitado',
                      '${detalle.ticket.cantidad.toStringAsFixed(2)} ${detalle.unidadMedida}',
                    ),
                  ),
                  if (detalle.cantidadAbastecida != null)
                    Expanded(
                      child: _buildInfoRow(
                        Icons.check_circle,
                        'Abastecido',
                        '${detalle.cantidadAbastecida!.toStringAsFixed(2)} ${detalle.unidadMedida}',
                      ),
                    ),
                ],
              ),
              if (detalle.motivoDiferencia != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber, size: 16, color: Colors.orange.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Diferencia: ${detalle.motivoDiferencia}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange.shade900,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (detalle.costoTotal != '0') ...[
                const Divider(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppTitle('Costo Total', color: AppColors.blueGrey,),
                    Text(
                      'S/ ${detalle.costoTotal}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
              if (detalle.aprobadoPor != null) ...[
                const Divider(height: 18),
                Row(
                  children: [
                    const Icon(Icons.check_circle, size: 14, color: Colors.lightGreen),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Aprobado por: ${detalle.aprobadoPor!.nombreCompleto}',
                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ],
              
              //!Subir archivos: Botón de Archivos
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 32,
                child: OutlinedButton.icon(
                  onPressed: () => _showArchivosModal(detalle),
                  icon: const Icon(Icons.attach_file, size: 16),
                  // label: const Text('Ver/Adjuntar Archivos'),
                  label: AppSubtitle('Ver/Adjuntar Archivos'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.grey,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    side: BorderSide(color: AppColors.blue3),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        AppLabelText('$label:  ', color: AppColors.blueGrey,),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 10),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}