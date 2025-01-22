# enhance_bloc_state

A powerful Dart package that generates convenient extensions for BLoC/Cubit state classes, offering pattern matching and logging capabilities through simple annotations. Now supports both traditional and inline state class definitions!

## Features

### 🎯 Pattern Matching
- **map**: Complete state pattern matching requiring all cases to be handled
- **mapSome**: Partial pattern matching with default case handling
- Compile-time type safety

### 📝 Logging
- Built-in state logging functionality
- Debug-friendly state information

### 🎨 Flexible State Definition
- Support for both traditional and inline state class definitions
- Automatic state class detection from Bloc/Cubit generic types
- Works with both Bloc and Cubit patterns

## Installation

1. Add `enhance_bloc_state` to your `pubspec.yaml`:

   ```yaml
   dependencies:
     enhance_bloc_state: ^latest_version

   dev_dependencies:
     build_runner: ^latest_version
   ```

2. Update your main cubit class to include the generated file and add annotation `@BlocStateGen()`

   ```dart
   import 'package:flutter_bloc/flutter_bloc.dart';
   import 'package:enhance_bloc_state/enhance_bloc_state.dart';

   part 'search_state.dart';
   part 'search_cubit.s.dart';

   @BlocStateGen()
   class SearchCubit extends Cubit<SearchState> {
     SearchCubit() : super(const SearchInitial());
   }
   ```

3. Run the code generator:

   ```bash
   flutter pub run build_runner build
   ```

4. Ignore generated `.s.dart` files in version control by adding the following to your `.gitignore`:

   ```gitignore
   # Ignore generated files
   *.s.dart
   ```

## Usage

2. Run the code generator:

   ```bash
   flutter pub run build_runner build
   ```

### Feature Usage

#### 1. map - Complete Pattern Matching

Requires handling all possible states:

```dart
Widget buildStateWidget(SearchState state) {
   return state.map(
      searchInitial: () => const StartSearch(),
      searching: (query) => const CircularProgressIndicator(),
      searchResults: (query, results) => DisplayList(items: results),
      noResults: (query) => NoResultsWidget(query: query),
      searchError: (message, query) => ErrorMessage(message: message),
   );
}
```

#### 2. mapSome - Partial Pattern Matching

Handle specific states with a default case:

```dart
String getDisplayText(SearchState state) {
   return state.mapSome(
      searchResults: (query, results) => 'Found ${results.length} results for: $query',
      searchError: (message, query) => 'Error${query != null ? " for $query" : ""}: $message',
      orElse: () => 'Idle...',
   );
}
```

#### 3. log - State Logging

Print state information for debugging:

```dart
void debugState(CounterState state) {
   print(state.log());  // Outputs formatted state information
}
```

### Customizing Generation

You can selectively enable/disable features using the `@BlocStateGen` annotation:

```dart
@BlocStateGen(
   map: true,      // Enable complete pattern matching
   mapSome: true,  // Enable partial pattern matching
   log: true,        // Enable logging functionality
)
class SearchCubit extends Cubit<SearchState> {
   SearchCubit() : super(const SearchInitial());
}

```

## Best Practices

1. **Complete Pattern Matching**
    - Use `map` when you need to handle all possible states
    - Ensures no state is accidentally forgotten
    - Provides compile-time safety

2. **Partial Pattern Matching**
    - Use `mapSome` when you only need to handle specific states
    - Always provide a meaningful `orElse` case
    - Useful for selective state handling

3. **Logging**
    - Enable logging during development for better debugging
    - Use in conjunction with Flutter's debug mode:
```dart
if (kDebugMode) {
print(state.log());
}
```

## Example Project

For a complete working example, check out our [example project](https://github.com/azharbinanwar/enhance_bloc_state/tree/master/example) demonstrating:
- State class definition
- Extension generation
- Usage of all three core features
- Integration with Flutter UI

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
