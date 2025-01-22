import 'package:build/build.dart';
import 'package:enhance_bloc_state/src/enhance_bloc_state_base_generator.dart';
import 'package:source_gen/source_gen.dart';

/// A custom builder for generating Bloc state extensions.
///
/// This builder processes files ending with '_cubit.dart' or '_bloc.dart'
/// and generates corresponding state extension files.
class BlocStateGenBuilder implements Builder {
  /// Defines the input and output file extensions for the builder.
  ///
  /// Processes files ending with '_cubit.dart' or '_bloc.dart' and
  /// generates '_state.g.dart' files.
  @override
  final buildExtensions = const {
    '.dart': ['.s.dart'],
    // '_bloc.dart': ['_state.g.dart']
  };

  /// Builds the state extensions for the given [buildStep].
  ///
  /// Uses [SharedPartBuilder] internally to generate the extensions.
  /// The generated code includes pattern matching and logging utilities.
  @override
  Future<void> build(BuildStep buildStep) async {
    final sharedBuilder = SharedPartBuilder(
      [EnhanceBlocStateGenerator()],
      'enhance_bloc_state',
    );

    await sharedBuilder.build(buildStep);
  }
}

/// Creates a [Builder] for generating Bloc state extensions.
///
/// Usage in build.yaml:
/// ```yaml
/// targets:
///   $default:
///     builders:
///       enhance_bloc_state:
///         enabled: true
/// ```
Builder enhanceBlocStateBuilder(BuilderOptions options) => BlocStateGenBuilder();
