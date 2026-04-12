import 'package:meta/meta.dart';

@immutable
class ZegoError implements Exception {
  const ZegoError(
    this.code,
    this.message, {
    this.cause,
    this.stackTrace,
  });

  final int code;
  final String message;
  final Object? cause;
  final StackTrace? stackTrace;

  @override
  String toString() {
    final buf = StringBuffer('$runtimeType($code, $message');
    if (cause != null) buf.write(', cause: $cause');
    buf.write(')');
    return buf.toString();
  }
}

class ZegoStateError extends ZegoError {
  const ZegoStateError(
    super.code,
    super.message, {
    super.cause,
    super.stackTrace,
  });
}
