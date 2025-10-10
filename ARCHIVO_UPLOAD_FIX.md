# Archivo Upload Widget - Fixes & Features

## Actualizaciones Recientes

### ✅ Funcionalidad de Descarga y Visualización Agregada
Se agregaron botones para descargar y visualizar archivos directamente desde el diálogo de detalles.

**Características**:
- **Descargar**: Todos los tipos de archivos (imágenes, PDFs, documentos)
- **Abrir en navegador**: PDFs y documentos para visualización externa
- **Notificación de descarga**: Con opción para abrir el archivo descargado
- **Manejo de permisos**: Solicitud automática de permisos de almacenamiento en Android
- **Ubicación de descarga**: Carpeta Downloads en Android, Documents en iOS

---

# Fix: Infinite Loop in File Upload Widget

## Problem Identified

The widget was generating excessive logs because of an **infinite loop** caused by the BlocConsumer listener:

```
I/flutter (13395): 📦 [ArchivoRepository] Obteniendo archivos del ticket 48...
I/flutter (13395): 📂 [ArchivoService] Obteniendo archivos del ticket 48...
I/flutter (13395): 🎬 [ArchivoBloc] Cargando archivos del ticket 48...
```

This pattern repeated indefinitely because:

1. After successful file upload → `LoadArchivosByTicket` event was dispatched
2. Loading files triggered state change → `archivosResponse` changed to `Loading()`
3. Listener detected state change → Triggered again
4. Condition `state.uploadResponse is Success` remained true → Dispatched `LoadArchivosByTicket` again
5. **Infinite loop continues...**

## Root Causes

### 1. Missing `listenWhen` in BlocConsumer
The listener was executing on EVERY state change, not just relevant ones.

### 2. Redundant reload after deletion
The bloc was reloading all files from the server after deletion, even though the list was already updated locally.

## Solutions Applied

### Fix 1: Added `listenWhen` to BlocConsumer

**File**: `lib/presentation/page/detalle_abastecimiento/widgets/archivos_upload_widget.dart`

```dart
BlocConsumer<ArchivoBloc, ArchivoState>(
  listenWhen: (previous, current) {
    // Only listen to relevant changes
    return previous.uploadResponse != current.uploadResponse ||
           previous.deleteResponse != current.deleteResponse ||
           previous.errorMessage != current.errorMessage;
  },
  listener: (context, state) {
    // Listener only executes when the above conditions are met
    if (state.uploadResponse is Success && !state.isUploading) {
      context.read<ArchivoBloc>().add(LoadArchivosByTicket(widget.ticketId));
    }
  },
  buildWhen: (previous, current) {
    // Rebuild only when UI-relevant data changes
    return previous.archivos != current.archivos ||
           previous.selectedFiles != current.selectedFiles ||
           previous.isUploading != current.isUploading ||
           previous.isDeleting != current.isDeleting ||
           previous.archivosResponse != current.archivosResponse;
  },
  builder: (context, state) {
    // Widget build logic
  },
)
```

**Benefits**:
- Listener only executes when `uploadResponse`, `deleteResponse`, or `errorMessage` change
- Prevents listener from triggering on `archivosResponse` changes
- Breaks the infinite loop

### Fix 2: Removed redundant server reload after deletion

**File**: `lib/presentation/page/archivo/bloc/archivo_bloc.dart`

**Before**:
```dart
emit(state.copyWith(
  deleteResponse: result,
  isDeleting: false,
  deletingArchivoId: null,
  archivos: updatedArchivos,
  errorMessage: null,
));

// ❌ This caused unnecessary network calls
add(LoadArchivosByTicket(event.ticketId));
```

**After**:
```dart
emit(state.copyWith(
  deleteResponse: result,
  isDeleting: false,
  deletingArchivoId: null,
  archivos: updatedArchivos,
  errorMessage: null,
));

// ✅ No reload needed - list already updated locally
```

**Benefits**:
- Eliminates unnecessary network call
- UI updates instantly from local state
- More efficient and responsive

## Results

✅ **Infinite loop eliminated**
✅ **Reduced network calls**
✅ **Improved performance**
✅ **Better user experience**

## Best Practices Applied

1. **Use `listenWhen` in BlocConsumer**: Always control when listeners should execute
2. **Use `buildWhen` in BlocConsumer**: Control widget rebuilds for better performance
3. **Update state locally when possible**: Avoid unnecessary server requests
4. **Clear separation of concerns**: Listener for side effects, builder for UI

## Nuevas Dependencias Agregadas

```yaml
dependencies:
  url_launcher: ^6.3.1        # Para abrir archivos en navegador
  path_provider: ^2.1.5       # Para obtener rutas de almacenamiento
  permission_handler: ^11.3.1 # Para solicitar permisos
```

## Permisos Configurados (Android)

El `AndroidManifest.xml` incluye queries para:
- Abrir URLs HTTP/HTTPS
- Abrir archivos locales
- Visualizar PDFs
- Visualizar imágenes

## Testing Recommendations

1. **Upload files** → Verify only one load cycle occurs
2. **Delete file** → Verify immediate UI update without reload
3. **Download image** → Check Downloads folder
4. **Download PDF** → Check Downloads folder and open
5. **Open PDF in browser** → Verify external app opens
6. **Monitor logs** → Should see clean, single-cycle operations
7. **Check performance** → Should feel more responsive
8. **Test permissions** → First download should request storage permission