// lib/presentation/page/reportes/widgets/filtros_reporte_widget.dart

import 'package:consumo_combustible/core/fonts/app_fonts.dart';
import 'package:consumo_combustible/core/fonts/app_text_widgets.dart';
import 'package:consumo_combustible/core/theme/app_colors.dart';
import 'package:consumo_combustible/core/widgets/custom_date_textfiels_container/custom_date.dart';
import 'package:consumo_combustible/core/widgets/custom_date_textfiels_container/custom_textfield.dart';
import 'package:consumo_combustible/core/widgets/custom_dropdown/custom_dropdown2.dart';
import 'package:consumo_combustible/core/widgets/custom_dropdown/dropdown_adapters.dart';
import 'package:consumo_combustible/core/widgets/cutom_button/custom_button.dart';
import 'package:consumo_combustible/domain/models/filtros_reporte.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';
import 'package:consumo_combustible/presentation/page/reportes/bloc/reporte_bloc.dart';
import 'package:consumo_combustible/presentation/page/reportes/bloc/reporte_state.dart';
import 'package:consumo_combustible/presentation/page/zona/bloc/zona_bloc.dart';
import 'package:consumo_combustible/presentation/page/zona/bloc/zona_event.dart';
import 'package:consumo_combustible/presentation/page/zona/bloc/zona_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FiltrosReporteWidget extends StatefulWidget {
  final Function(FiltrosReporte) onGenerarReporte;

  const FiltrosReporteWidget({
    super.key,
    required this.onGenerarReporte,
  });

  @override
  State<FiltrosReporteWidget> createState() => _FiltrosReporteWidgetState();
}

class _FiltrosReporteWidgetState extends State<FiltrosReporteWidget> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _placaController = TextEditingController();
  final _fechaInicioController = TextEditingController();
  final _fechaFinController = TextEditingController();

  // Valores seleccionados
  TipoReporte _tipoReporte = TipoReporte.abastecimientos;
  FormatoExportacion _formato = FormatoExportacion.excel;
  DateTime? _fechaInicio;
  DateTime? _fechaFin;
  int? _zonaId; // ✅ NUEVO: ID de zona seleccionada

  @override
  void initState() {
    super.initState();
    // ✅ Cargar zonas al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ZonaBloc>().add(const LoadZonasEvent());
    });
  }

  @override
  void dispose() {
    _placaController.dispose();
    _fechaInicioController.dispose();
    _fechaFinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReporteBloc, ReporteState>(
      builder: (context, state) {
        final isLoading = state.exportarResponse is Loading;

        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card de configuración básica
              _buildCard(
                title: 'Configuración del Reporte',
                icon: Icons.settings,
                children: [
                  _buildTipoReporteDropdown(),
                  const SizedBox(height: 12),
                  _buildFormatoDropdown(),
                ],
              ),

              const SizedBox(height: 10),

              _buildCard(
                title: 'Filtros de Ubicación',
                icon: Icons.location_on,
                children: [
                  _buildZonaDropdown(),
                  const SizedBox(height: 3),
                  _buildInfoText(
                    'Si no seleccionas zona, se incluirán todas las zonas',
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Card de filtros de fecha
              _buildCard(
                title: 'Filtros de Fecha',
                icon: Icons.calendar_today,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: CustomDate(
                          textStyle: TextStyle(fontSize: 9),
                          borderColor: AppColors.blue3,
                          controller: _fechaInicioController,
                          label: 'Fecha Inicio',
                          hintText: 'Seleccionar',
                          onDateSelected: (date) {
                            setState(() => _fechaInicio = date);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomDate(
                          textStyle: TextStyle(fontSize: 9),
                          borderColor: AppColors.blue3,
                          controller: _fechaFinController,
                          label: 'Fecha Fin',
                          hintText: 'Seleccionar',
                          onDateSelected: (date) {
                            setState(() => _fechaFin = date);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Card de filtros opcionales
              _buildCard(
                title: 'Filtros Adicionales',
                icon: Icons.filter_list,
                children: [
                  CustomTextField(
                    borderColor: AppColors.blue3,
                    controller: _placaController,
                    label: 'Placa (Opcional)',
                    hintText: 'Ej: ABC-123',
                    // prefixIcon: Icons.directions_car,
                    prefixIcon: Icon(Icons.directions_car),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Botones de acción
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      borderRadius: 10,
                      text: 'Limpiar',
                      textStyle: TextStyle(fontFamily: AppFonts.getFontFamily(AppFont.pirulentBold),fontSize: 8),
                      onPressed: isLoading ? null : _limpiarFiltros,
                      backgroundColor: AppColors.white,
                      textColor: AppColors.blue3,
                      borderColor: AppColors.blue3,
                      borderWidth: 1,
                      height: 35,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: CustomButton(
                      borderRadius: 10,
                      text: 'Generar Reporte',
                      textStyle: TextStyle(fontFamily: AppFonts.getFontFamily(AppFont.pirulentBold),fontSize: 8),
                      onPressed: isLoading ? null : _generarReporte,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0A4A6B), Color(0xFF065A82)],
                      ),
                      buttonState: isLoading ? ButtonState.loading : ButtonState.idle,
                      loadingText: 'Generando...',
                      height: 35,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  /// Card contenedor reutilizable
  Widget _buildCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.blue3.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header del card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.blue3.withValues(alpha: 0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: AppColors.blue3, size: 18),
                const SizedBox(width: 8),
                AppSubtitle(
                  title,
                  fontSize: 9,
                  color: AppColors.blue3,
                ),
              ],
            ),
          ),
          // Contenido del card
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ NUEVO: Dropdown de zona usando CustomDropdown2
  Widget _buildZonaDropdown() {
    return BlocBuilder<ZonaBloc, ZonaState>(
      builder: (context, zonaState) {
        return CustomDropdown2<ZonaDropdownItem>(
          label: 'Zona (Opcional)',
          hint: 'Todas las zonas',
          selectedId: _zonaId,
          items: zonaState.zonas.map((zona) => ZonaDropdownItem(zona)).toList(),
          isLoading: zonaState.isLoadingZonas,
          borderColor: AppColors.blue3,
          iconColor: AppColors.blue3,
          itemTextStyle: AppFont.oxygenRegular.style(fontSize: 10),
          codeTextStyle: AppFont.oxygenBold.style(
            fontSize: 8,
            color: AppColors.grey,
          ),
          onChanged: (id) {
            setState(() => _zonaId = id);
          },
        );
      },
    );
  }

  /// Dropdown de tipo de reporte usando CustomDropdown2
  Widget _buildTipoReporteDropdown() {
    return CustomDropdown2<TipoReporteDropdownItem>(
      label: 'Tipo de Reporte',
      hint: 'Seleccionar tipo',
      selectedId: _tipoReporte.index,
      items: TipoReporte.values.map((tipo) => TipoReporteDropdownItem(tipo)).toList(),
      borderColor: AppColors.blue3,
      iconColor: AppColors.blue3,
      itemTextStyle: AppFont.oxygenRegular.style(fontSize: 10),
      codeTextStyle: AppFont.oxygenBold.style(
        fontSize: 8,
        color: AppColors.grey,
      ),
      onChanged: (id) {
        if (id != null) {
          setState(() => _tipoReporte = TipoReporte.values[id]);
        }
      },
    );
  }

  /// Dropdown de formato usando CustomDropdown2
  Widget _buildFormatoDropdown() {
    return CustomDropdown2<FormatoExportacionDropdownItem>(
      label: 'Formato de Exportación',
      hint: 'Seleccionar formato',
      selectedId: _formato.index,
      items: FormatoExportacion.values.map((formato) => FormatoExportacionDropdownItem(formato)).toList(),
      borderColor: AppColors.blue3,
      iconColor: AppColors.blue3,
      itemTextStyle: AppFont.oxygenRegular.style(fontSize: 10),
      codeTextStyle: AppFont.oxygenBold.style(
        fontSize: 8,
        color: AppColors.grey,
      ),
      onChanged: (id) {
        if (id != null) {
          setState(() => _formato = FormatoExportacion.values[id]);
        }
      },
    );
  }

  /// Texto informativo
  Widget _buildInfoText(String text) {
   return AppCaption(
    fontSize: 8,
      items: [
        CaptionItem(icon: Icons.info_outline, text: text)
      ],
    );
  }

  /// Generar reporte
  void _generarReporte() {
    if (_formKey.currentState?.validate() ?? false) {
      final filtros = FiltrosReporte(
        tipoReporte: _tipoReporte,
        formato: _formato,
        fechaInicio: _fechaInicio,
        fechaFin: _fechaFin,
        zonaId: _zonaId, // ✅ Incluir zona seleccionada (puede ser null)
        placa: _placaController.text.trim().isEmpty
            ? null
            : _placaController.text.trim(),
      );

      widget.onGenerarReporte(filtros);
    }
  }

  /// Limpiar filtros
  void _limpiarFiltros() {
    setState(() {
      _fechaInicioController.clear();
      _fechaFinController.clear();
      _placaController.clear();
      _fechaInicio = null;
      _fechaFin = null;
      _zonaId = null; // ✅ Limpiar zona
      _tipoReporte = TipoReporte.abastecimientos;
      _formato = FormatoExportacion.excel;
    });
  }



}