// This is a script to generate an analysis_options.yaml file based on the
// linter rules from the dart-lang/site-www repository.
// ignore_for_file: avoid_print, unreachable_from_main

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:yaml/yaml.dart';

///
///
///
void main() async {
  final Response response = await get(
    Uri.parse('https://raw.githubusercontent.com/dart-lang/site-www'
        '/main/src/_data/linter_rules.json'),
  );

  final List<Rule> rules = fromJsonSafeList(
    json.decode(response.body),
    producer: Rule.fromJson,
  )
    ..retainWhere(
      (final Rule rule) =>
          rule.state != RuleState.removed && rule.state != RuleState.deprecated,
    )
    ..sort((final Rule a, final Rule b) => a.name.compareTo(b.name));

  final YamlDocument doc =
      loadYamlDocument(File('analysis_options.yaml').readAsStringSync());

  final YamlMap yamlContent = doc.contents.value as YamlMap;

  final YamlMap yamlLinter = yamlContent['linter'] as YamlMap;

  final YamlMap yamlRules = yamlLinter['rules'] as YamlMap;

  for (final Rule rule in rules) {
    if (yamlRules.containsKey(rule.name)) {
      rule.active = yamlRules[rule.name].toString().toLowerCase() == 'true';
    }
  }

  for (final Rule rule in rules) {
    if (rule.active && rule.incompatible.isNotEmpty) {
      for (final Rule incompatible in rules) {
        if (rule.incompatible.contains(incompatible.name) &&
            rule.active == incompatible.active) {
          print('Rule ${rule.name} is incompatible with '
              '${incompatible.name} but is active');
        }
      }
    }
  }

  final StringBuffer sb = StringBuffer()
    ..writeln('include: package:flutter_lints/flutter.yaml')
    ..writeln()
    ..writeln('# https://dart.dev/tools/analysis')
    ..writeln()
    ..writeln('# https://dart.dev/tools/linter-rules/all')
    ..writeln('linter:')
    ..writeln('  rules:');

  for (final Rule rule in rules) {
    if (rule.incompatible.isNotEmpty) {
      sb
        ..writeln()
        ..writeln('    # Incompatible with:');
    }

    for (final String incompatible in rule.incompatible) {
      sb.writeln('    # $incompatible');
    }

    sb.writeln('    ${rule.name}: ${rule.active}');

    if (rule.incompatible.isNotEmpty) {
      sb.writeln();
    }
  }

  File('ao.yaml')
    ..createSync(recursive: true)
    ..writeAsStringSync(sb.toString());
}

///
///
///
class Rule {
  ///
  ///
  ///
  Rule({
    required this.name,
    required this.description,
    required this.group,
    required this.state,
    required this.incompatible,
    required this.sets,
    required this.fixStatus,
    required this.details,
    required this.sinceDartSdk,
  });

  ///
  ///
  ///

  factory Rule.fromJson(final dynamic map) => switch (map) {
        Map<dynamic, dynamic> _ => Rule(
            name: map['name']?.toString() ?? '',
            description: map['description']?.toString() ?? '',
            group:
                RuleGroup.values.byName(map['group']?.toString() ?? 'unknown'),
            state:
                RuleState.values.byName(map['state']?.toString() ?? 'unknown'),
            incompatible: fromJsonSafeStringSet(map['incompatible']),
            sets: fromJsonSafeEnumSet(map['sets'], RuleSet.values),
            fixStatus: RuleFixStatus.values.byName(map['fixStatus']),
            details: map['details']?.toString() ?? '',
            sinceDartSdk: map['sinceDartSdk']?.toString() ?? '',
          ),
        _ => throw ArgumentError('map is not a Map'),
      };

  final String name;
  final String description;
  final RuleGroup group;
  final RuleState state;
  final Set<String> incompatible;
  final Set<RuleSet> sets;
  final RuleFixStatus fixStatus;
  final String details;
  final String sinceDartSdk;
  bool active = true;
}

Iterable<T>? _fromJsonRawIterable<T>(
  final Iterable<dynamic>? value, {
  required final T Function(dynamic e) producer,
}) =>
    value?.map<T>(producer);

List<T> fromJsonSafeList<T>(
  final dynamic value, {
  required final T Function(dynamic e) producer,
}) =>
    value == null
        ? <T>[]
        : (value is Iterable)
            ? _fromJsonRawIterable<T>(value, producer: producer)!.toList()
            : <T>[producer(value)];

Set<T> fromJsonSafeSet<T>(
  final dynamic value, {
  required final T Function(dynamic e) producer,
}) =>
    value == null
        ? <T>{}
        : (value is Iterable)
            ? _fromJsonRawIterable<T>(value, producer: producer)!.toSet()
            : <T>{producer(value)};

Set<T> fromJsonSafeEnumSet<T extends Enum>(
  final dynamic value,
  final Iterable<T> values,
) =>
    switch (value) {
      null => <T>{},
      Iterable<dynamic> _ =>
        value.map((final dynamic e) => values.byName(e.toString())).toSet(),
      _ => <T>{values.byName(value.toString())},
    };

Set<String> fromJsonSafeStringSet(final dynamic value) =>
    fromJsonSafeSet<String>(
      value,
      producer: (final dynamic e) => e.toString(),
    );

///
///
///
enum RuleGroup {
  unknown,
  style,
  pub,
  errors;
}

///
///
///
enum RuleState {
  unknown,
  stable,
  deprecated,
  experimental,
  removed;
}

///
///
///
enum RuleFixStatus {
  hasFix,
  noFix,
  needsFix,
  needsEvaluation,
  unregistered;
}

///
///
///
enum RuleSet {
  core,
  recommended,
  flutter;
}
