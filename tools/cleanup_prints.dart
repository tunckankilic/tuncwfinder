// A simple tool to clean up `print` usages in Dart files.
// Usage:
//   dart tools/cleanup_prints.dart           # dry-run, only reports
//   dart tools/cleanup_prints.dart --apply   # rewrites print(...) -> log(...)
//
// What it does:
// - Scans lib/ and test/ for .dart files (skips generated files and build/.dart_tool).
// - Replaces `print(` with `log(`.
// - Ensures `import 'dart:developer';` is present when replacements are applied.
//
// Caveats:
// - Simple text replacement; it will not detect commented-out prints.
// - Skips files ending with .g.dart or .freezed.dart to avoid touching generated code.

import 'dart:developer';
import 'dart:io';

void main(List<String> args) async {
  final apply = args.contains('--apply');
  final root = Directory.current;
  final targets = ['lib', 'test'];
  var totalFound = 0;
  var totalChanged = 0;

  for (final dirName in targets) {
    final dir = Directory('${root.path}/$dirName');
    if (!await dir.exists()) continue;

    await for (final entity in dir.list(recursive: true, followLinks: false)) {
      if (entity is! File) continue;
      if (!entity.path.endsWith('.dart')) continue;
      if (_isGenerated(entity.path)) continue;
      if (entity.path.contains(
          '${Platform.pathSeparator}build${Platform.pathSeparator}')) {
        continue;
      }
      if (entity.path.contains(
          '${Platform.pathSeparator}.dart_tool${Platform.pathSeparator}')) {
        continue;
      }

      final content = await entity.readAsString();
      final matches = _printPattern.allMatches(content).length;
      if (matches == 0) continue;
      totalFound += matches;

      if (!apply) {
        log('[DRY-RUN] ${entity.path} : $matches print()');
        continue;
      }

      final updated = _replacePrints(content);
      if (updated != content) {
        await entity.writeAsString(updated);
        totalChanged += matches;
        log('[FIXED] ${entity.path} : $matches print() -> log()');
      }
    }
  }

  if (apply) {
    log('Cleanup complete. Replaced $totalChanged occurrences of print().');
  } else {
    log('Dry run complete. Found $totalFound occurrences of print(). Run with --apply to rewrite.');
  }
}

final RegExp _printPattern = RegExp(r'\bprint\s*\(');

bool _isGenerated(String path) {
  return path.endsWith('.g.dart') ||
      path.endsWith('.freezed.dart') ||
      path.contains(
          '${Platform.pathSeparator}generated${Platform.pathSeparator}');
}

String _replacePrints(String content) {
  var updated = content.replaceAll(_printPattern, 'log(');

  // Ensure dart:developer is imported when log() is used.
  if (updated.contains('log(') && !_hasDeveloperImport(updated)) {
    final importPattern =
        RegExp(r'''import\s+['"][^'"]+['"];\s*''', multiLine: true);
    final match = importPattern.firstMatch(updated);
    if (match != null) {
      final insertPos = match.end;
      updated = updated.replaceRange(
        insertPos,
        insertPos,
        "import 'dart:developer';\n",
      );
    } else {
      // No imports found; insert at top.
      updated = "import 'dart:developer';\n$updated";
    }
  }

  return updated;
}

bool _hasDeveloperImport(String content) {
  final pattern =
      RegExp(r'''import\s+['"]dart:developer['"];''', multiLine: true);
  return pattern.hasMatch(content);
}
