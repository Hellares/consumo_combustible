# Documentación - Custom Widgets Flutter

Sistema completo de widgets personalizados para formularios con validación en tiempo real, formateo automático y diseño moderno.

## 📋 Tabla de Contenidos

- [CustomTextField](#customtextfield)
- [CustomDate](#customdate) 
- [TimeScrollPicker](#timescrollpicker)
- [Ejemplos de Uso](#ejemplos-de-uso)
- [Configuración](#configuración)

---

## 🔤 CustomTextField

Widget de campo de texto avanzado con validación en tiempo real, formateo automático y múltiples tipos de campo.

### Características Principales

- ✅ **Validación en tiempo real** con indicadores visuales
- 💰 **Formateo automático** para moneda, teléfono, email
- 🌍 **Soporte multi-país** para teléfonos
- 🎨 **Animaciones fluidas** y sombras adaptativas
- 🔐 **Toggle de contraseña** incorporado
- 📱 **Teclados específicos** según tipo de campo

### Tipos de Campo Disponibles

```dart
enum FieldType { 
  text,      // Texto simple
  email,     // Email con validación
  phone,     // Teléfono con formateo
  currency,  // Moneda con separadores
  url        // URL con validación
}
```

### Países Soportados

```dart
enum CountryCode {
  peru('+51', 9),      // Perú: +51 987 654 321
  colombia('+57', 10), // Colombia: +57 321 654 9876
  ecuador('+593', 9),  // Ecuador: +593 987 654 321
  chile('+56', 9)      // Chile: +56 987 654 321
}
```

### Propiedades Principales

| Propiedad | Tipo | Descripción |
|-----------|------|-------------|
| `label` | `String?` | Etiqueta del campo |
| `controller` | `TextEditingController?` | Controlador del texto |
| `fieldType` | `FieldType` | Tipo de campo (text, email, phone, etc.) |
| `validator` | `String? Function(String?)?` | Validador personalizado |
| `enableRealTimeValidation` | `bool` | Habilitar validación en tiempo real |
| `country` | `CountryCode` | País para formateo de teléfono |
| `currencySymbol` | `String` | Símbolo de moneda |
| `borderColor` | `Color?` | Color del borde |
| `height` | `double?` | Altura del campo |

### Ejemplo Básico

```dart
// Campo de texto simple
CustomTextField(
  label: 'Nombre',
  controller: _nameController,
  fieldType: FieldType.text,
  validator: (value) => value?.isEmpty == true ? 'Campo requerido' : null,
)

// Campo de email con validación automática
CustomTextField(
  label: 'Correo electrónico',
  controller: _emailController,
  fieldType: FieldType.email,
  borderColor: Colors.blue,
)

// Campo de teléfono con formateo automático
CustomTextField(
  label: 'Teléfono',
  controller: _phoneController,
  fieldType: FieldType.phone,
  country: CountryCode.peru,
)

// Campo de moneda con validación
CustomTextField(
  label: 'Precio',
  controller: _priceController,
  fieldType: FieldType.currency,
  currencySymbol: 'S/',
)
```

### Helpers Predefinidos

Para facilitar el uso, se incluyen helpers que crean campos preconfigurados:

```dart
// Helper para email
CustomTextFieldHelpers.email(
  label: 'Email',
  controller: _emailController,
  borderColor: Colors.green,
)

// Helper para teléfono
CustomTextFieldHelpers.phone(
  label: 'Teléfono',
  controller: _phoneController,
  country: CountryCode.peru,
)

// Helper para moneda
CustomTextFieldHelpers.currency(
  label: 'Precio',
  controller: _priceController,
  minAmount: 1.0,
  maxAmount: 99999.99,
)

// Helper para contraseña
CustomTextFieldHelpers.password(
  label: 'Contraseña',
  controller: _passwordController,
)
```

### Extensiones del Controlador

Se incluyen extensiones útiles para trabajar con los valores:

```dart
// Para campos de moneda
double precio = _priceController.currencyValue;
_priceController.setCurrencyValue(1250.75);

// Para campos de teléfono
String telefonoBaseDatos = _phoneController.phoneValue(CountryCode.peru);
_phoneController.setPhoneValue('+51987654321', CountryCode.peru);
```

---

## 📅 CustomDate

Widget avanzado para selección de fechas y horas con múltiples modos y validación.

### Tipos de Campo de Fecha

```dart
enum DateFieldType {
  date,      // Solo fecha
  dateTime,  // Fecha y hora
  time,      // Solo hora
  dateRange  // Rango de fechas
}
```

### Modos de Entrada

```dart
enum DateInputMode {
  picker,  // Solo selector visual
  manual   // Entrada manual con formateo
}
```

### Propiedades Principales

| Propiedad | Tipo | Descripción |
|-----------|------|-------------|
| `label` | `String?` | Etiqueta del campo |
| `controller` | `TextEditingController?` | Controlador del texto |
| `dateType` | `DateFieldType` | Tipo de selección de fecha |
| `inputMode` | `DateInputMode` | Modo de entrada |
| `timeMode` | `TimeMode` | Incluir selección de hora |
| `initialDate` | `DateTime?` | Fecha inicial |
| `firstDate` | `DateTime?` | Fecha mínima permitida |
| `lastDate` | `DateTime?` | Fecha máxima permitida |
| `dateFormat` | `String` | Formato de fecha (dd/MM/yyyy, etc.) |
| `onDateSelected` | `void Function(DateTime?)?` | Callback al seleccionar fecha |
| `onDateRangeSelected` | `void Function(DateRange?)?` | Callback para rangos |

### Ejemplos de Uso

```dart
// Selector de fecha simple
CustomDate(
  label: 'Fecha de nacimiento',
  controller: _dateController,
  dateType: DateFieldType.date,
  initialDate: DateTime.now(),
  onDateSelected: (date) => print('Fecha: $date'),
)

// Selector de fecha y hora
CustomDate(
  label: 'Fecha y hora del evento',
  controller: _dateTimeController,
  dateType: DateFieldType.dateTime,
  timeMode: TimeMode.hourMinute,
)

// Solo selector de hora
CustomDate(
  label: 'Hora de inicio',
  controller: _timeController,
  dateType: DateFieldType.time,
  onDateSelected: (time) => print('Hora: ${time?.hour}:${time?.minute}'),
)

// Selector de rango de fechas
CustomDate(
  label: 'Período de vacaciones',
  controller: _rangeController,
  dateType: DateFieldType.dateRange,
  maxRangeDays: 30,
  onDateRangeSelected: (range) {
    print('Desde: ${range?.startDate}');
    print('Hasta: ${range?.endDate}');
    print('Días: ${range?.daysDifference}');
  },
)
```

### Clase DateRange

Para manejar rangos de fechas:

```dart
class DateRange {
  final DateTime? startDate;
  final DateTime? endDate;
  
  bool get isComplete => startDate != null && endDate != null;
  Duration? get duration => isComplete ? endDate!.difference(startDate!) : null;
  int? get daysDifference => duration != null ? duration!.inDays + 1 : null;
}
```

### Validadores de Fecha

```dart
// Validar fecha simple
String? error = DateValidator.validateDate('25/12/2024');

// Validar hora
String? error = DateValidator.validateTime('14:30');

// Validar rango
String? error = DateValidator.validateDateRange(dateRange);
```

---

## ⏰ TimeScrollPicker

Widget de selección de hora con scroll suave y diseño moderno.

### Características

- 🎯 **Scroll preciso** para horas (0-23) y minutos (0-59)
- 🎨 **Diseño moderno** con gradientes y animaciones
- ⚡ **Fácil integración** con otros widgets
- 🔧 **Personalizable** con colores primarios

### Propiedades

| Propiedad | Tipo | Descripción |
|-----------|------|-------------|
| `initialHour` | `int` | Hora inicial (0-23) |
| `initialMinute` | `int` | Minuto inicial (0-59) |
| `primaryColor` | `Color` | Color principal del tema |
| `onTimeSelected` | `void Function(int hour, int minute)` | Callback al seleccionar |

### Ejemplo de Uso

```dart
showDialog(
  context: context,
  builder: (context) => TimeScrollPicker(
    initialHour: 14,
    initialMinute: 30,
    primaryColor: Colors.blue,
    onTimeSelected: (hour, minute) {
      print('Hora seleccionada: $hour:$minute');
      // Actualizar tu estado aquí
    },
  ),
);
```

---

## 📖 Ejemplos de Uso Completos

### Formulario de Registro

```dart
class RegistrationForm extends StatefulWidget {
  @override
  _RegistrationFormState createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _birthdateController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Nombre
          CustomTextFieldHelpers.text(
            label: 'Nombre completo',
            controller: _nameController,
            validator: (value) => value?.isEmpty == true ? 'Campo requerido' : null,
          ),
          
          SizedBox(height: 16),
          
          // Email
          CustomTextFieldHelpers.email(
            label: 'Correo electrónico',
            controller: _emailController,
            borderColor: Colors.blue,
          ),
          
          SizedBox(height: 16),
          
          // Teléfono
          CustomTextFieldHelpers.phone(
            label: 'Teléfono',
            controller: _phoneController,
            country: CountryCode.peru,
            borderColor: Colors.green,
          ),
          
          SizedBox(height: 16),
          
          // Fecha de nacimiento
          CustomDate(
            label: 'Fecha de nacimiento',
            controller: _birthdateController,
            dateType: DateFieldType.date,
            lastDate: DateTime.now(),
            borderColor: Colors.orange,
          ),
          
          SizedBox(height: 16),
          
          // Contraseña
          CustomTextFieldHelpers.password(
            label: 'Contraseña',
            controller: _passwordController,
            borderColor: Colors.red,
          ),
          
          SizedBox(height: 32),
          
          // Botón enviar
          ElevatedButton(
            onPressed: _submitForm,
            child: Text('Registrarse'),
          ),
        ],
      ),
    );
  }
  
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      Map<String, dynamic> formData = {
        'name': _nameController.text,
        'email': _emailController.text,
        'phone': _phoneController.phoneValue(CountryCode.peru),
        'birthdate': _birthdateController.text,
        'password': _passwordController.text,
      };
      
      // Enviar datos a la API
      print('Datos del formulario: $formData');
    }
  }
}
```

### Formulario de Evento

```dart
class EventForm extends StatefulWidget {
  @override
  _EventFormState createState() => _EventFormState();
}

class _EventFormState extends State<EventForm> {
  final _titleController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _priceController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Título del evento
        CustomTextField(
          label: 'Título del evento',
          controller: _titleController,
          fieldType: FieldType.text,
          borderColor: Colors.purple,
        ),
        
        SizedBox(height: 16),
        
        // Fecha y hora de inicio
        CustomDate(
          label: 'Fecha y hora de inicio',
          controller: _startDateController,
          dateType: DateFieldType.dateTime,
          timeMode: TimeMode.hourMinute,
          borderColor: Colors.blue,
        ),
        
        SizedBox(height: 16),
        
        // Solo hora de fin
        CustomDate(
          label: 'Hora de finalización',
          controller: _endDateController,
          dateType: DateFieldType.time,
          borderColor: Colors.orange,
        ),
        
        SizedBox(height: 16),
        
        // Precio del evento
        CustomTextFieldHelpers.currency(
          label: 'Precio de entrada',
          controller: _priceController,
          currencySymbol: 'S/',
          minAmount: 0.0,
          maxAmount: 9999.99,
          borderColor: Colors.green,
        ),
      ],
    );
  }
}
```

---

## ⚙️ Configuración

### Dependencias Requeridas

```yaml
dependencies:
  flutter:
    sdk: flutter
```

### Archivos Necesarios

```
lib/
├── widgets/
│   ├── custom_textfield.dart
│   ├── custom_date.dart
│   └── custom_time.dart
└── core/
    └── theme/
        └── app_colors.dart
```

### AppColors

Asegúrate de tener definidos los colores en `app_colors.dart`:

```dart
class AppColors {
  static const Color blue = Color(0xFF1976D2);
  static const Color white = Color(0xFFFFFFFF);
  // Otros colores...
}
```

### Personalización Global

Puedes personalizar los valores por defecto en `CustomTextFieldConstants`:

```dart
class CustomTextFieldConstants {
  static const Duration defaultValidationDelay = Duration(milliseconds: 800);
  static const double defaultHeight = 40.0;
  static const double defaultBorderRadius = 6.0;
  static const Color defaultBackgroundColor = Colors.white;
  // Otros valores...
}
```

---

## 🎯 Consejos de Uso

### 1. Validación en Tiempo Real

```dart
// Habilitar validación automática
CustomTextField(
  enableRealTimeValidation: true,
  showValidationIndicator: true,
  validationDelay: Duration(milliseconds: 500),
)
```

### 2. Obtener Valores para API

```dart
// Para moneda
double precio = _priceController.currencyValue;

// Para teléfono 
String telefono = _phoneController.phoneValue(CountryCode.peru);

// Para fechas
DateTime? fecha = DateTime.tryParse(_dateController.text);
```

### 3. Personalizar Validadores

```dart
CustomTextField(
  validator: (value) {
    if (value?.isEmpty == true) return 'Campo requerido';
    if (value!.length < 3) return 'Mínimo 3 caracteres';
    return null;
  },
  asyncValidator: (value) async {
    // Validación asíncrona con API
    bool isAvailable = await checkUsernameAvailability(value);
    return isAvailable ? null : 'Usuario no disponible';
  },
)
```

### 4. Temas y Colores

```dart
// Usar colores consistentes
final Color primaryColor = Theme.of(context).primaryColor;

CustomTextField(
  borderColor: primaryColor,
)

CustomDate(
  borderColor: primaryColor,
)
```

---

## 🔧 Métodos Útiles

### TextEditingController Extensions

```dart
// Moneda
double value = controller.currencyValue;
controller.setCurrencyValue(100.50);

// Teléfono
String phone = controller.phoneValue(CountryCode.peru);
controller.setPhoneValue('+51987654321', CountryCode.peru);

// Validaciones
bool isValidCurrency = controller.isValidCurrency;
bool isValidPhone = controller.isValidPhone(CountryCode.peru);
```

### DateRange Utilities

```dart
DateRange range = DateRange(
  startDate: DateTime(2024, 1, 1),
  endDate: DateTime(2024, 1, 15),
);

print(range.isComplete); // true
print(range.daysDifference); // 15
print(range.duration); // Duration object
```

---

## 📱 Compatibilidad

- ✅ **Flutter 3.0+**
- ✅ **Android & iOS**
- ✅ **Web** (con limitaciones en pickers nativos)
- ✅ **Responsive Design**

---

## 🤝 Contribuir

Para contribuir o reportar issues:

1. **Fork** el repositorio
2. **Crea** una rama para tu feature
3. **Haz commit** de tus cambios
4. **Abre** un Pull Request

---

*Documentación generada para Custom Widgets v1.0*