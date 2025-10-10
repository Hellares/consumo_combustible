// lib/presentation/page/detalle_abastecimiento/widgets/archivos_upload_widget.dart

import 'dart:io';
import 'package:consumo_combustible/core/fonts/app_text_widgets.dart';
import 'package:consumo_combustible/core/theme/app_colors.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';
import 'package:consumo_combustible/presentation/page/archivo/bloc/archivo_bloc.dart';
import 'package:consumo_combustible/presentation/page/archivo/bloc/archivo_event.dart';
import 'package:consumo_combustible/presentation/page/archivo/bloc/archivo_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
/*
  ***************************************************************************************
  Metodo: //!widget para subir imagenes
  Fecha: 10-10-2025
  Descripcion: se debe mejorar para separar responsabilidades
  Autor: James Torres
  ***************************************************************************************
*/
class ArchivosUploadWidget extends StatefulWidget {
  final int ticketId;
  final bool isConcluido;

  const ArchivosUploadWidget({
    super.key,
    required this.ticketId,
    this.isConcluido = false,
  });

  @override
  State<ArchivosUploadWidget> createState() => _ArchivosUploadWidgetState();
}

class _ArchivosUploadWidgetState extends State<ArchivosUploadWidget> {
  final ImagePicker _imagePicker = ImagePicker();
  String? _lastSelectedCategory; // Para rastrear la última categoría seleccionada

  @override
  void initState() {
    super.initState();
    // Cargar tipos de archivo y archivos existentes
    context.read<ArchivoBloc>().add(LoadTiposArchivo());
    context.read<ArchivoBloc>().add(LoadArchivosByTicket(widget.ticketId));
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage(
        imageQuality: 100, // ✅ Calidad máxima
      );

      if (images.isNotEmpty) {
        final files = images.map((xFile) => File(xFile.path)).toList();
        if (mounted) {
          setState(() => _lastSelectedCategory = 'IMAGEN'); // ✅ Registrar categoría
          context.read<ArchivoBloc>().add(SelectArchivos(files));
        }
      }
    } catch (e) {
      if (mounted) {
        // showErrorSnackbar(context, 'Error al seleccionar imágenes: $e');
      }
    }
  }

  Future<void> _pickCamera() async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 100, // ✅ Calidad máxima
      );

      if (photo != null) {
        if (mounted) {
          setState(() => _lastSelectedCategory = 'IMAGEN'); // ✅ Registrar categoría
          context.read<ArchivoBloc>().add(SelectArchivos([File(photo.path)]));
        }
      }
    } catch (e) {
      if (mounted) {
        // showErrorSnackbar(context, 'Error al tomar foto: $e');
      }
    }
  }

  Future<void> _pickPDF() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final files = result.files.map((file) => File(file.path!)).toList();
        if (mounted) {
          setState(() => _lastSelectedCategory = 'PDF'); // ✅ Categoría especial para PDFs
          context.read<ArchivoBloc>().add(SelectArchivos(files));
        }
      }
    } catch (e) {
      if (mounted) {
        // showErrorSnackbar(context, 'Error al seleccionar PDFs: $e');
      }
    }
  }

  void _showUploadDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return BlocProvider.value(
          value: context.read<ArchivoBloc>(),
          child: _UploadDialog(
            ticketId: widget.ticketId,
            selectedCategory: _lastSelectedCategory, // ✅ Pasar categoría
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ArchivoBloc, ArchivoState>(
      listenWhen: (previous, current) {
        // Solo escuchar cambios en uploadResponse o deleteResponse
        return previous.uploadResponse != current.uploadResponse ||
               previous.deleteResponse != current.deleteResponse ||
               previous.errorMessage != current.errorMessage;
      },
      listener: (context, state) {
        // Mostrar errores
        if (state.errorMessage != null) {
          // showErrorSnackbar(context, state.errorMessage!);
        }

        // Éxito al subir - solo se ejecuta una vez debido a listenWhen
        if (state.uploadResponse is Success && !state.isUploading) {
          // showSuccessSnackbar(context, '¡Archivos subidos exitosamente!');
          // Recargar archivos
          context.read<ArchivoBloc>().add(LoadArchivosByTicket(widget.ticketId));
        }

        // Éxito al eliminar - no necesita recargar porque el bloc ya actualiza la lista
        if (state.deleteResponse is Success && !state.isDeleting) {
          // showSuccessSnackbar(context, 'Archivo eliminado');
        }
      },
      buildWhen: (previous, current) {
        // Reconstruir cuando cambian datos relevantes para la UI
        return previous.archivos != current.archivos ||
               previous.selectedFiles != current.selectedFiles ||
               previous.isUploading != current.isUploading ||
               previous.isDeleting != current.isDeleting ||
               previous.archivosResponse != current.archivosResponse;
      },
      builder: (context, state) {
        return Card(
          color: AppColors.white,
          elevation: 2,
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Archivos Adjuntos',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (state.archivos.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${state.archivos.length}',
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.bold,
                            fontSize: 10
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                // Botones de acción
                if (widget.isConcluido) ...[
                  // ✅ Mensaje cuando está concluido
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.lock, size: 20, color: Colors.orange.shade700),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'El detalle está concluido. No se pueden agregar más archivos.',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.orange.shade900,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  // ✅ Botones habilitados cuando no está concluido
                  Center(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        SizedBox(
                          height: 30,
                          child: ElevatedButton.icon(
                            onPressed: _pickImages,
                            icon: const Icon(Icons.photo_library, size: 14),
                            label: const Text('Galería'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              textStyle: TextStyle(fontSize: 10)
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 30,
                          child: ElevatedButton.icon(
                            onPressed: _pickCamera,
                            icon: const Icon(Icons.camera_alt, size: 14),
                            label: const Text('Cámara'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              textStyle: TextStyle(fontSize: 10)
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 30,
                          child: ElevatedButton.icon(
                            onPressed: _pickPDF,
                            icon: const Icon(Icons.picture_as_pdf, size: 14),
                            label: const Text('PDF'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              textStyle: TextStyle(fontSize: 10)
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Archivos seleccionados
                if (state.hasSelectedFiles) ...[
                  const SizedBox(height: 16),
                  const Divider(),
                  _buildSelectedFiles(state),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 35,
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: state.isUploading ? null : _showUploadDialog,
                      icon: state.isUploading
                          ? const SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.cloud_upload, size: 14,),
                      label: Text(
                        state.isUploading
                            ? 'Subiendo...'
                            : 'Subir Archivos',
                        style: TextStyle(fontSize: 10),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ],

                // Archivos subidos
                if (state.archivosResponse is Loading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (state.archivos.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Divider(),
                  _buildUploadedFiles(state),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSelectedFiles(ArchivoState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Archivos seleccionados (${state.selectedFilesCount}):',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
        ),
        const SizedBox(height: 8),
        ...state.selectedFiles.map((file) {
          final fileName = file.path.split('/').last;
          final fileSize = file.lengthSync();
          final fileSizeStr = _formatBytes(fileSize);

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.only(left: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Icon(
                  _getFileIcon(fileName),
                  color: Colors.blue.shade700,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fileName,
                        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        fileSizeStr,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () {
                    context.read<ArchivoBloc>().add(RemoveSelectedArchivo(file));
                  },
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildUploadedFiles(ArchivoState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Archivos subidos:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1,
          ),
          itemCount: state.archivos.length,
          itemBuilder: (context, index) {
            final archivo = state.archivos[index];
            return _buildArchivoCard(archivo, state);
          },
        ),
      ],
    );
  }

  Widget _buildArchivoCard(dynamic archivo, ArchivoState state) {
    final isDeleting = state.isDeleting && state.deletingArchivoId == archivo.id;

    return GestureDetector(
      onTap: () => _showArchivoDetails(archivo),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: archivo.esImagen
                  ? Image.network(
                      archivo.url, // ✅ Usar URL completa, no thumbnail
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      filterQuality: FilterQuality.high, // ✅ Alta calidad de renderizado
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return _buildFileIcon(archivo);
                      },
                    )
                  : _buildFileIcon(archivo),
            ),
          ),
          // Botón eliminar (solo si NO está concluido)
          if (!widget.isConcluido)
            Positioned(
              top: 4,
              right: 4,
              height: 25,
              width: 25,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                ),
                child: isDeleting
                    ? const Padding(
                        padding: EdgeInsets.all(4),
                        child: SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : IconButton(
                        icon: const Icon(Icons.delete, size: 14),
                        color: Colors.white,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => _confirmDelete(archivo),
                        iconSize: 30,
                      ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFileIcon(dynamic archivo) {
    return Container(
      color: Colors.grey.shade200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              archivo.esPdf ? Icons.picture_as_pdf : Icons.insert_drive_file,
              size: 32,
              color: archivo.esPdf ? Colors.red : Colors.grey.shade600,
            ),
            const SizedBox(height: 4),
            Text(
              archivo.extension.toUpperCase().replaceAll('.', ''),
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showArchivoDetails(dynamic archivo) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // Bordes redondeados
        ),
        clipBehavior: Clip.antiAlias, // Recortar contenido a los bordes
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.only(left: 18, ),
              color: Color(archivo.tipoArchivo.colorCategoria),
              child: Row(
                children: [
                  Text(
                    archivo.tipoArchivo.iconoCategoria, //icono de la categoria, viene del modelo
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          archivo.tipoArchivo.nombre,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (archivo.esImagen)
                          const Text(
                            '🔍 Pellizca para hacer zoom',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 8,
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 20,),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            // SizedBox(height: 5,),
            // Imagen o ícono
            if (archivo.esImagen)
              Container(
                height: 300,
                color: Colors.black,
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Center(
                    child: Image.network(
                      archivo.url,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 300,
                          color: Colors.grey.shade200,
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 300,
                          color: Colors.grey.shade200,
                          child: const Center(
                            child: Icon(Icons.error_outline, size: 48),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              )
            else
              Container(
                height: 200,
                color: Colors.grey.shade200,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.picture_as_pdf,
                        size: 64,
                        color: Colors.red.shade700,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        archivo.extension.toUpperCase(),
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            // Detalles
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow('Nombre:', archivo.nombreOriginal),
                  _buildDetailRow('Tamaño:', archivo.tamanoLegible),
                  if (archivo.descripcion != null)
                    _buildDetailRow('Descripción:', archivo.descripcion!),
                  if (archivo.subidoPor != null)
                    _buildDetailRow('Subido por:', archivo.subidoPor!.nombreCompleto),
                ],
              ),
            ),
            // Botones de acción
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  if (archivo.esPdf)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _openInBrowser(archivo.url),
                        icon: const Icon(Icons.open_in_browser, size: 18),
                        label: const Text('Abrir'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  if (archivo.esPdf) const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _downloadFile(archivo),
                      icon: const Icon(Icons.download, size: 18),
                      label: const Text('Descargar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Abrir archivo en el navegador
  Future<void> _openInBrowser(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se puede abrir el archivo')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al abrir: $e')),
        );
      }
    }
  }

  // Descargar archivo
  Future<void> _downloadFile(dynamic archivo) async {
    try {
      // Mostrar diálogo de descarga
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Descargando...'),
            ],
          ),
        ),
      );

      // Solicitar permisos en Android
      if (Platform.isAndroid) {
        final status = await Permission.storage.request();
        if (!status.isGranted) {
          if (mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Permiso de almacenamiento denegado')),
            );
          }
          return;
        }
      }

      // Obtener directorio de descargas
      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory == null) {
        throw Exception('No se pudo acceder al directorio de descargas');
      }

      // Construir ruta del archivo
      final fileName = archivo.nombreOriginal;
      final filePath = '${directory.path}/$fileName';

      // Descargar archivo
      final dio = Dio();
      await dio.download(archivo.url, filePath);

      if (mounted) {
        Navigator.pop(context); // Cerrar diálogo de progreso
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Descargado: $fileName'),
            action: SnackBarAction(
              label: 'Abrir',
              onPressed: () => _openInBrowser(filePath),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Cerrar diálogo de progreso
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al descargar: $e')),
        );
      }
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 75,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
            ),
          ),
          Expanded(
            //child: Text(value),
            child: AppSubtitle(value),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(dynamic archivo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar archivo'),
        content: Text('¿Está seguro de eliminar "${archivo.nombreOriginal}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              this.context.read<ArchivoBloc>().add(
                    DeleteArchivo(
                      archivoId: archivo.id,
                      ticketId: widget.ticketId,
                    ),
                  );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  IconData _getFileIcon(String fileName) {
    final extension = fileName.toLowerCase().split('.').last;
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }
}

// ============================================
// DIALOG PARA SUBIR ARCHIVOS
// ============================================
class _UploadDialog extends StatefulWidget {
  final int ticketId;
  final String? selectedCategory;

  const _UploadDialog({
    required this.ticketId,
    this.selectedCategory,
  });

  @override
  State<_UploadDialog> createState() => _UploadDialogState();
}

class _UploadDialogState extends State<_UploadDialog> {
  int? _selectedTipoId;
  final _descripcionController = TextEditingController();

  @override
  void dispose() {
    _descripcionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ArchivoBloc, ArchivoState>(
      builder: (context, state) {
        // ✅ Filtrar tipos según la categoría seleccionada
        final tiposFiltrados = widget.selectedCategory != null
            ? widget.selectedCategory == 'PDF'
                // Para PDFs: incluir DOCUMENTO y COMPROBANTE
                ? state.tiposArchivo.where((tipo) =>
                    tipo.categoria == 'DOCUMENTO' || tipo.categoria == 'COMPROBANTE'
                  ).toList()
                // Para otros: filtrar por categoría exacta
                : state.tiposArchivo.where((tipo) => tipo.categoria == widget.selectedCategory).toList()
            : state.tiposArchivo;

        return AlertDialog(
          title: Text(
            widget.selectedCategory == 'IMAGEN'
                ? 'Subir Imágenes'
                : widget.selectedCategory == 'PDF'
                    ? 'Subir Documentos PDF'
                    : 'Subir Archivos',
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Se subirán ${state.selectedFilesCount} archivo(s)',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                
                // Selector de tipo de archivo
                Text(
                  widget.selectedCategory == 'IMAGEN'
                      ? 'Tipo de imagen:'
                      : widget.selectedCategory == 'PDF'
                          ? 'Tipo de documento/comprobante:'
                          : 'Tipo de archivo:',
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<int>(
                  initialValue: _selectedTipoId,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                  items: tiposFiltrados.map((tipo) {
                    return DropdownMenuItem(
                      value: tipo.id,
                      child: Row(
                        mainAxisSize: MainAxisSize.min, // ✅ FIX: Limitar tamaño del Row
                        children: [
                          Text(tipo.iconoCategoria),
                          const SizedBox(width: 8),
                          Flexible( // ✅ FIX: Cambiar Expanded a Flexible
                            child: Text(
                              tipo.nombre,
                              style: const TextStyle(fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (tipo.requerido) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'REQ',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedTipoId = value);
                  },
                  validator: (value) {
                    if (value == null) return 'Seleccione un tipo';
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Descripción opcional
                TextField(
                  controller: _descripcionController,
                  decoration: const InputDecoration(
                    labelText: 'Descripción (opcional)',
                    border: OutlineInputBorder(),
                    hintText: 'Ej: Foto tomada en el grifo X',
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                context.read<ArchivoBloc>().add(ClearSelection());
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: _selectedTipoId == null
                  ? null
                  : () {
                      context.read<ArchivoBloc>().add(
                            UploadArchivos(
                              ticketId: widget.ticketId,
                              tipoArchivoId: _selectedTipoId!,
                              descripcion: _descripcionController.text.isEmpty
                                  ? null
                                  : _descripcionController.text,
                            ),
                          );
                      Navigator.pop(context);
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Subir'),
            ),
          ],
        );
      },
    );
  }
}