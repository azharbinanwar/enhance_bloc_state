import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:enhance_bloc_state/src/annotations.dart';
import 'package:source_gen/source_gen.dart';

/// A code generator that creates state management extensions for Bloc classes.
/// This generator processes classes annotated with [EnhanceBlocState] and generates
/// helper methods for state handling, including pattern matching and logging.
class EnhanceBlocStateGenerator extends GeneratorForAnnotation<EnhanceBlocState> {
  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    try {
      _validateElement(element);
      final buffer = StringBuffer();
      final stateClass = _findStateClass(element as ClassElement);

      if (stateClass == null) {
        throw InvalidGenerationSourceError(
          'Could not find state class in ${element.name}.',
          element: element,
          todo: 'Make sure your Bloc/Cubit properly defines a state type',
        );
      }

      _writeFileHeader(buffer, buildStep.inputId.pathSegments.last);
      _generateExtension(
        buffer: buffer,
        element: stateClass,
        className: stateClass.name,
        annotation: annotation,
      );

      return buffer.toString();
    } catch (e) {
      throw InvalidGenerationSourceError(
        'Failed to generate extension for ${element.name}: $e',
        element: element,
        todo: 'Check the class structure and annotation parameters',
      );
    }
  }

  /// Finds the state class by examining the generic type arguments of Bloc/Cubit
  ClassElement? _findStateClass(ClassElement blocClass) {
    final supertype = blocClass.supertype;
    if (supertype == null) return null;

    /// For Bloc<Event, State>
    if (supertype.element.name == 'Bloc') {
      if (supertype.typeArguments.length != 2) return null;
      final stateType = supertype.typeArguments[1];
      return _getClassElementFromType(stateType);
    }

    /// For HydratedBloc<Event, State>
    if (supertype.element.name == 'HydratedBloc') {
      if (supertype.typeArguments.length != 2) return null;
      final stateType = supertype.typeArguments[1];
      return _getClassElementFromType(stateType);
    }

    /// For ReplayBloc<Event, State>
    if (supertype.element.name == 'ReplayBloc') {
      if (supertype.typeArguments.length != 2) return null;
      final stateType = supertype.typeArguments[1];
      return _getClassElementFromType(stateType);
    }

    /// For Cubit<State>
    if (supertype.element.name == 'Cubit') {
      if (supertype.typeArguments.isEmpty) return null;
      final stateType = supertype.typeArguments[0];
      return _getClassElementFromType(stateType);
    }

    /// For HydratedCubit<State>
    if (supertype.element.name == 'HydratedCubit') {
      if (supertype.typeArguments.isEmpty) return null;
      final stateType = supertype.typeArguments[0];
      return _getClassElementFromType(stateType);
    }

    /// For ReplayCubit<State>
    if (supertype.element.name == 'ReplayCubit') {
      if (supertype.typeArguments.isEmpty) return null;
      final stateType = supertype.typeArguments[0];
      return _getClassElementFromType(stateType);
    }

    return null;
  }

  /// Helper method to get ClassElement from DartType
  ClassElement? _getClassElementFromType(DartType type) {
    if (type is InterfaceType) {
      final element = type.element;
      if (element is ClassElement) {
        return element;
      }
    }
    return null;
  }

  /// Validates that the annotated element is a Bloc or Cubit class
  void _validateElement(Element element) {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
        'EnhanceBlocState can only be applied to classes.',
        element: element,
        todo: 'Apply @EnhanceBlocState annotation to a Bloc or Cubit class',
      );
    }

    if (element.isPrivate) {
      throw InvalidGenerationSourceError(
        'EnhanceBlocState cannot be applied to private classes.',
        element: element,
        todo: 'Make the class public by removing the underscore prefix',
      );
    }

    final supertype = element.supertype;
    if (supertype == null || (!supertype.element.name.contains('Bloc') && !supertype.element.name.contains('Cubit'))) {
      throw InvalidGenerationSourceError(
        'EnhanceBlocState must be applied to a class that extends Bloc or Cubit.',
        element: element,
        todo: 'Make sure your class extends either Bloc or Cubit',
      );
    }

    if (supertype.typeArguments.isEmpty) {
      throw InvalidGenerationSourceError(
        'Missing generic type arguments in ${element.name}.',
        element: element,
        todo: 'Specify the state type in your Bloc/Cubit class declaration',
      );
    }
  }

  /// Writes the file header with necessary imports and part declarations
  void _writeFileHeader(StringBuffer buffer, String fileName) {
    buffer.writeln('// GENERATED CODE - DO NOT MODIFY BY HAND');
    buffer.writeln('// ignore_for_file: unused_element, deprecated_member_use, unused_local_variable, non_constant_identifier_names');
    buffer.writeln();
    buffer.writeln('part of \'$fileName\';');
    buffer.writeln();
  }

  /// Gets all subclasses of the state class
  List<ClassElement> _getSubclasses(ClassElement element) {
    final allClasses = element.library.topLevelElements.whereType<ClassElement>();
    final parentBloc = element.enclosingElement;
    List<ClassElement> nestedClasses = [];

    if (parentBloc is ClassElement) {
      nestedClasses = parentBloc.children.whereType<ClassElement>().toList();
    }

    return [...allClasses, ...nestedClasses].where((e) {
      final supertype = e.supertype;
      return supertype != null && supertype.element == element;
    }).toList();
  }

  /// Gets the constructor parameters for a class
  List<ParameterElement> _getConstructorParameters(ClassElement element) {
    final constructor = element.constructors.where((c) => c.name.isEmpty).firstOrNull;
    return constructor?.parameters.where((param) => !param.isPrivate).toList() ?? [];
  }

  /// Converts a class name to a parameter name in camelCase
  String _getParameterName(String className) {
    if (className.isEmpty) return '';

    final cleanName = className.replaceAll(RegExp(r'State$'), '').replaceAll(RegExp(r'Bloc$'), '').replaceAll(RegExp(r'Cubit$'), '');

    if (cleanName.endsWith('Initial')) return 'onInitial';
    if (cleanName.endsWith('Loading')) return 'onLoading';
    if (cleanName.endsWith('Success')) return 'onSuccess';
    if (cleanName.endsWith('Failure')) return 'onFailure';
    if (cleanName.endsWith('Error')) return 'onError';
    if (cleanName.endsWith('Empty')) return 'onEmpty';
    if (cleanName.endsWith('NoResults')) return 'onEmpty';

    final parentClassRegex = RegExp(r'^(\w+?)(Loading|Success|Error|State|Initial|Empty|NoResults|Failure)$');
    final map = parentClassRegex.firstMatch(cleanName);
    if (map != null) {
      final baseState = map.group(1);
      if (baseState != null) {
        return 'on${baseState[0].toUpperCase()}${baseState.substring(1)}';
      }
    }

    return 'on${cleanName[0].toUpperCase()}${cleanName.substring(1)}';
  }

  /// Generates the main extension class with all requested methods
  void _generateExtension({
    required StringBuffer buffer,
    required ClassElement element,
    required String className,
    required ConstantReader annotation,
  }) {
    final subclasses = _getSubclasses(element);

    if (subclasses.isEmpty) {
      throw InvalidGenerationSourceError(
        'No subclasses found for $className.',
        element: element,
        todo: 'Create at least one subclass of $className to represent different states',
      );
    }

    buffer.writeln('/// Extension methods for $className state management');
    buffer.writeln('extension ${className}Extension on $className {');

    _generateRequestedMethods(
      buffer: buffer,
      className: className,
      subclasses: subclasses,
      annotation: annotation,
    );

    buffer.writeln('}');
  }

  /// Generates methods based on annotation configurations
  void _generateRequestedMethods({
    required StringBuffer buffer,
    required String className,
    required List<ClassElement> subclasses,
    required ConstantReader annotation,
  }) {
    if (annotation.read('map').boolValue) {
      _generateMatchMethod(buffer, className, subclasses);
    }

    if (annotation.read('mapSome').boolValue) {
      _generateMatchSomeMethod(buffer, className, subclasses);
    }

    if (annotation.read('log').boolValue) {
      _generateLogMethod(buffer, className);
    }
  }

  /// Generates the map method for exhaustive pattern matching
  void _generateMatchMethod(
    StringBuffer buffer,
    String className,
    List<ClassElement> subclasses,
  ) {
    buffer.writeln('''
    /// Matches the current state against provided handlers and returns a value of type [T].
    ///
    /// Requires handlers for all possible state types. This ensures exhaustive pattern matching.
    /// Throws [StateError] if an unknown state is encountered.
    T map<T>({''');

    for (final subclass in subclasses) {
      final fields = _getConstructorParameters(subclass);
      final paramName = _getParameterName(subclass.name);

      buffer.writeln('    /// Handler for ${subclass.name} state');
      if (fields.isEmpty) {
        buffer.writeln('    required T Function() $paramName,');
      } else {
        final params = fields.map((f) => '${f.type} ${f.name}').join(', ');
        buffer.writeln('    required T Function($params) $paramName,');
      }
    }

    buffer.writeln('  }) {');

    for (final subclass in subclasses) {
      final subclassName = subclass.name;
      final paramName = _getParameterName(subclassName);
      final fields = _getConstructorParameters(subclass);

      buffer.writeln('    if (this is $subclassName) {');
      if (fields.isEmpty) {
        buffer.writeln('      return $paramName();');
      } else {
        final params = fields.map((f) => '(this as $subclassName).${f.name}').join(', ');
        buffer.writeln('      return $paramName($params);');
      }
      buffer.writeln('    }');
    }

    buffer.writeln('''
      throw StateError(
        'Unknown state type: \$runtimeType. '
        'This might happen if you forgot to handle a state type in the map method.'
      );
    }''');
  }

  /// Generates the mapSome method for partial pattern matching
  void _generateMatchSomeMethod(
    StringBuffer buffer,
    String className,
    List<ClassElement> subclasses,
  ) {
    buffer.writeln('''
    /// Pattern matches on the state type with optional handlers.
    ///
    /// Allows partial matching with a required [orElse] handler for unhandled cases.
    T mapSome<T>({''');

    for (final subclass in subclasses) {
      final fields = _getConstructorParameters(subclass);
      final paramName = _getParameterName(subclass.name);

      buffer.writeln('    /// Optional handler for ${subclass.name} state');
      if (fields.isEmpty) {
        buffer.writeln('    T Function()? $paramName,');
      } else {
        final params = fields.map((f) => '${f.type} ${f.name}').join(', ');
        buffer.writeln('    T Function($params)? $paramName,');
      }
    }

    buffer.writeln('''
      /// Handler for unmatched states
      required T Function() orElse,
    }) {''');

    for (final subclass in subclasses) {
      _generateMatchSomeCase(buffer, subclass);
    }

    buffer.writeln('''
      return orElse();
    }''');
  }

  /// Generates a single case for the mapSome method
  void _generateMatchSomeCase(StringBuffer buffer, ClassElement subclass) {
    final subclassName = subclass.name;
    final paramName = _getParameterName(subclassName);
    final fields = _getConstructorParameters(subclass);

    buffer.writeln('    if (this is $subclassName && $paramName != null) {');
    if (fields.isEmpty) {
      buffer.writeln('      return $paramName();');
    } else {
      final params = fields.map((f) => '(this as $subclassName).${f.name}').join(', ');
      buffer.writeln('      return $paramName($params);');
    }
    buffer.writeln('    }');
  }

  /// Generates the log method for state logging.
  void _generateLogMethod(StringBuffer buffer, String className) {
    buffer.writeln('''
  /// Logs the current state with optional timestamp.
  ///
  /// [showTime] - Whether to include timestamp in the log
  /// [onLog] - Custom log handler (defaults to print)
  void log({
    bool showTime = false,
    void Function(String message)? onLog,
  }) {
    final logger = onLog ?? print;
    final timestamp = showTime ? '[\${DateTime.now().toIso8601String()}] ' : '';
    final stateInfo = toString();
    
    logger('\${timestamp}Current State: \$stateInfo');
  }''');
  }
}
