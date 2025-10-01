// class BlocFormItem {

//   final String value;
//   final String? error;

//   const BlocFormItem({ this.value = '', this.error });

//   BlocFormItem copyWith({String? value, String? error}) {
//     return BlocFormItem(
//       value: value ?? this.value,
//       error: error ?? this.error,
//     );
//   }
// }

class BlocFormItem {
  final String value;
  final String? error;

  const BlocFormItem({ this.value = '', this.error });

  BlocFormItem copyWith({
    String? value, 
    String? error,
    bool clearError = false, // ← Parámetro explícito para limpiar
  }) {
    return BlocFormItem(
      value: value ?? this.value,
      error: clearError ? null : (error ?? this.error),
    );
  }
}