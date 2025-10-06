abstract class Resource<T> {}

class Initial extends Resource {}
class Loading<T> extends Resource<T> {}
class Success<T> extends Resource<T> {
  final T data;
  Success(this.data);
}
class Error<T> extends Resource<T> {
  final String message;
  final int? statusCode;
  final String? errorCode;
  final Map<String, dynamic>? details;
  Error(
    this.message, {
    this.statusCode,
    this.errorCode,  // NUEVO
    this.details,    // NUEVO
  });

  bool get isAuthError => 
    errorCode == 'UNAUTHORIZED' || errorCode == 'FORBIDDEN';
  
  bool get isValidationError => 
    errorCode == 'VALIDATION_ERROR' || errorCode == 'BAD_REQUEST';
  
  bool get isNetworkError => 
    errorCode == 'SERVICE_UNAVAILABLE' || 
    errorCode == 'GATEWAY_TIMEOUT' || 
    errorCode == 'NETWORK_ERROR';
  
  bool get isServerError => 
    statusCode != null && statusCode! >= 500;
}
