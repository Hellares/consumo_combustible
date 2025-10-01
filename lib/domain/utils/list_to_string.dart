// String listToString(dynamic data) {
//   String message = "";
//   if (data is List<dynamic>) {
//     message = (data as List<dynamic>).join(" ");
//   }
//   else if(data is String) {
//     message = data;
//   }
//   return message;
// }

String listToString(Object? data) {
  if (data is List<Object?>) {
    return data.whereType<Object>().join(" ");
  } else if (data is String) {
    return data;
  } 
  // else if (data is num) {
  //   return data.toString();
  // }
  return '';
}