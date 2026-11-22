import 'package:supabase_flutter/supabase_flutter.dart';

/// Thrown when RLS blocks a write. For update/delete, Postgres does not
/// raise an error: the row is simply invisible, so 0 rows change.
class PermissionDeniedException implements Exception {
  const PermissionDeniedException([
    this.message = 'You do not have permission to do that.',
  ]);
  final String message;
  @override
  String toString() => message;
}

/// Services call this on the rows returned by `.update/.delete().select()`.
void ensureChanged(List<dynamic> rows) {
  if (rows.isEmpty) throw const PermissionDeniedException();
}

bool isPermissionDenied(Object error) =>
    error is PermissionDeniedException ||
    (error is PostgrestException &&
        (error.code == '42501' || error.code == 'PGRST301')) ||
    (error is StorageException &&
        (error.statusCode == '403' || error.statusCode == '401'));

/// Turns any error into one sentence a user can act on.
String friendlyError(Object error) {
  if (error is PermissionDeniedException) return error.message;
  if (error is AuthException) return error.message;
  if (error is PostgrestException) {
    switch (error.code) {
      case '42501':
        // place_order raises its own readable 42501 messages.
        return error.message.contains('permission denied') ||
                error.message.contains('row-level security')
            ? 'You do not have permission to do that.'
            : error.message;
      case '23503':
        return 'This item is still in use (for example, a category that '
            'still has products), so it cannot be removed.';
      case '23505':
        return 'That name is already taken.';
      case '23514':
        return 'Some values are not allowed. Check the form and try again.';
      case 'P0001':
      case 'P0002':
      case '22023':
        return error.message; // messages written in place_order()
    }
    return error.message;
  }
  if (error is StorageException) {
    return isPermissionDenied(error)
        ? 'You do not have permission to upload images.'
        : 'Image upload failed: ${error.message}';
  }
  final text = '$error';
  if (text.contains('Failed to fetch') || text.contains('SocketException')) {
    return 'Cannot reach the server. Check your internet connection.';
  }
  return text.replaceFirst(RegExp(r'^(Exception|Bad state): '), '');
}
