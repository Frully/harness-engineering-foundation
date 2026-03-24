import 'dart:convert';
import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';

void main(List<String> args) {
  if (args.length != 2) {
    stderr.writeln('usage: mobile_architecture <root> <policy>');
    exit(1);
  }

  final rootDir = args[0];
  final policyPath = args[1];
  final policy =
      jsonDecode(File(policyPath).readAsStringSync()) as Map<String, dynamic>;
  final mobilePolicy = policy['mobile'] as Map<String, dynamic>;
  final sourceRoot = Directory('$rootDir/${mobilePolicy['sourceRoot']}');
  final layers = (mobilePolicy['layers'] as Map<String, dynamic>).map(
    (key, value) => MapEntry(key, (value as List<dynamic>).cast<String>()),
  );
  final forbiddenCrossRuntimePatterns =
      (mobilePolicy['forbiddenCrossRuntimePatterns'] as List<dynamic>)
          .cast<String>();

  final errors = <String>[];

  for (final entity in sourceRoot.listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) {
      continue;
    }

    final relative = entity.path.substring(sourceRoot.path.length + 1);
    final layer = relative.split(Platform.pathSeparator).first;
    if (!layers.containsKey(layer)) {
      continue;
    }

    final imports = _parseImports(entity.readAsStringSync(), entity.path);
    for (final specifier in imports) {
      if (forbiddenCrossRuntimePatterns.any(specifier.contains)) {
        errors.add(
          '$relative imports forbidden cross-runtime target $specifier',
        );
        continue;
      }

      final targetLayer = _resolveLayer(
        specifier,
        entity,
        sourceRoot,
        layers.keys.toSet(),
      );
      if (targetLayer == null || targetLayer == layer) {
        continue;
      }

      if (!layers[layer]!.contains(targetLayer)) {
        errors.add(
          '$relative ($layer) imports disallowed mobile layer $targetLayer',
        );
      }
    }
  }

  if (errors.isNotEmpty) {
    for (final message in errors) {
      stderr.writeln(message);
    }
    exit(1);
  }
}

List<String> _parseImports(String source, String path) {
  final result = parseString(
    content: source,
    path: path,
    throwIfDiagnostics: false,
  );

  return result.unit.directives
      .whereType<ImportDirective>()
      .map((directive) => directive.uri.stringValue)
      .whereType<String>()
      .toList();
}

String? _resolveLayer(
  String specifier,
  File file,
  Directory sourceRoot,
  Set<String> layers,
) {
  if (specifier.startsWith('package:harness_mobile/')) {
    final relative = specifier.replaceFirst('package:harness_mobile/', '');
    final layer = relative.split('/').first;
    return layers.contains(layer) ? layer : null;
  }

  if (specifier.startsWith('../') || specifier.startsWith('./')) {
    final resolved = File(Uri.file(file.path).resolve(specifier).toFilePath());
    if (!_isWithinRoot(resolved.path, sourceRoot.path)) {
      return null;
    }
    final relative = resolved.path.substring(sourceRoot.path.length + 1);
    final layer = relative.split(Platform.pathSeparator).first;
    return layers.contains(layer) ? layer : null;
  }

  return null;
}

bool _isWithinRoot(String candidatePath, String rootPath) {
  final relative = _relativePath(candidatePath, rootPath);
  return relative != null;
}

String? _relativePath(String candidatePath, String rootPath) {
  final normalizedCandidate = _normalizePath(candidatePath);
  final normalizedRoot = _normalizePath(rootPath);

  if (normalizedCandidate == normalizedRoot) {
    return '';
  }

  final prefix = normalizedRoot.endsWith(Platform.pathSeparator)
      ? normalizedRoot
      : '$normalizedRoot${Platform.pathSeparator}';
  if (!normalizedCandidate.startsWith(prefix)) {
    return null;
  }

  return normalizedCandidate.substring(prefix.length);
}

String _normalizePath(String value) {
  return value.replaceAll('\\', Platform.pathSeparator);
}
