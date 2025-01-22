import 'package:meta/meta.dart';

@immutable
class EnhanceBlocState {
  /// Whether to generate the when method
  final bool map;

  /// Whether to generate the maybeWhen method
  final bool mapSome;

  /// Whether to generate the log method
  final bool log;

  const EnhanceBlocState({
    this.map = true,
    this.mapSome = true,
    this.log = true,
  });
}
