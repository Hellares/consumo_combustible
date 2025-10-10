// lib/presentation/page/detalle_abastecimiento/widgets/archivos_upload_widget.dart

import 'dart:io';
import 'package:consumo_combustible/domain/utils/resource.dart';
import 'package:consumo_combustible/presentation/page/archivo/bloc/archivo_bloc.dart';
import 'package:consumo_combustible/presentation/page/archivo/bloc/archivo_event.dart';
import 'package:consumo_combustible/presentation/page/archivo/bloc/archivo_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

class ArchivosUploadWidget extends StatefulWidget {
  final int ticketId;

  const ArchivosUploadWidget({
    super.key,
    required this.ticketId,
  });

  @override
  State<ArchivosUploadWidget> createState() => _ArchivosUploadWidgetState();
}

class _ArchivosUploadWidgetState extends State<ArchivosUploadWidget> {
  final ImagePicker _imagePicker = ImagePicker();
  int? _selectedTipoArchivoId;

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
        imageQuality: 85,
      );

      if (images.isNotEmpty) {
        final files = images.map((xFile) => File(xFile.path)).toList();
        if (mounted) {
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
        imageQuality: 85,
      );

      if (photo != null) {
        if (mounted) {
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
            onTipoSelected: (tipoId) {
              setState(() => _selectedTipoArchivoId = tipoId);
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ArchivoBloc, ArchivoState>(
      listener: (context, state) {
        // Mostrar errores
        if (state.errorMessage != null) {
          // showErrorSnackbar(context, state.errorMessage!);
        }

        // Éxito al subir
        if (state.uploadResponse is Success && !state.isUploading) {
          // showSuccessSnackbar(context, '¡Archivos subidos exitosamente!');
          context.read<ArchivoBloc>().add(LoadArchivosByTicket(widget.ticketId));
        }

        // Éxito al eliminar
        if (state.deleteResponse is Success && !state.isDeleting) {
          // showSuccessSnackbar(context, 'Archivo eliminado');
        }
      },
      builder: (context, state) {
        return Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
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
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (state.archivos.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${state.archivos.length}',
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                // Botones de acción
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _pickImages,
                      icon: const Icon(Icons.photo_library, size: 18),
                      label: const Text('Galería'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _pickCamera,
                      icon: const Icon(Icons.camera_alt, size: 18),
                      label: const Text('Cámara'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _pickPDF,
                      icon: const Icon(Icons.picture_as_pdf, size: 18),
                      label: const Text('PDF'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),

                // Archivos seleccionados
                if (state.hasSelectedFiles) ...[
                  const SizedBox(height: 16),
                  const Divider(),
                  _buildSelectedFiles(state),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: state.isUploading ? null : _showUploadDialog,
                      icon: state.isUploading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.cloud_upload),
                      label: Text(
                        state.isUploading
                            ? 'Subiendo...'
                            : 'Subir Archivos',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
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
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...state.selectedFiles.map((file) {
          final fileName = file.path.split('/').last;
          final fileSize = file.lengthSync();
          final fileSizeStr = _formatBytes(fileSize);

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(8),
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
                        style: const TextStyle(fontWeight: FontWeight.w500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        fileSizeStr,
                        style: TextStyle(
                          fontSize: 12,
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
          style: TextStyle(fontWeight: FontWeight.bold),
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
                      archivo.urlThumbnail ?? archivo.url,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildFileIcon(archivo);
                      },
                    )
                  : _buildFileIcon(archivo),
            ),
          ),
          // Botón eliminar
          Positioned(
            top: 4,
            right: 4,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.9),
                shape: BoxShape.circle,
              ),
              child: isDeleting
                  ? const Padding(
                      padding: EdgeInsets.all(8),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : IconButton(
                      icon: const Icon(Icons.delete, size: 16),
                      color: Colors.white,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => _confirmDelete(archivo),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              color: Color(archivo.tipoArchivo.colorCategoria),
              child: Row(
                children: [
                  Text(
                    archivo.tipoArchivo.iconoCategoria,
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      archivo.tipoArchivo.nombre,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            // Imagen o ícono
            if (archivo.esImagen)
              Image.network(
                archivo.url,
                height: 300,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 300,
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: Icon(Icons.error_outline, size: 48),
                    ),
                  );
                },
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
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
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
  final Function(int) onTipoSelected;

  const _UploadDialog({
    required this.ticketId,
    required this.onTipoSelected,
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
        return AlertDialog(
          title: const Text('Subir Archivos'),
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
                const Text('Tipo de archivo:'),
                const SizedBox(height: 8),
                DropdownButtonFormField<int>(
                  initialValue: _selectedTipoId,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items: state.tiposArchivo.map((tipo) {
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
                              style: const TextStyle(fontSize: 14),
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
                    if (value != null) {
                      widget.onTipoSelected(value);
                    }
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