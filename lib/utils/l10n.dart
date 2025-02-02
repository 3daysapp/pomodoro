import 'package:flutter/material.dart';
import 'package:i18next/i18next.dart';

///
///
///
class L10n {
  final I18Next i18next;

  ///
  ///
  ///
  const L10n(this.i18next);

  ///
  ///
  ///
  L10n.of(final BuildContext context) : i18next = I18Next.of(context)!;

  ///
  ///
  ///
  String t(
    final String key, {
    final String base = 'common',
    final String? context,
    final int? count,
    final Map<String, dynamic>? variables,
  }) =>
      i18next.t(
        '$base:$key',
        context: context,
        count: count,
        variables: variables,
      );

  ///
  ///
  ///
  Map<T, String> tEnum<T>(final List<T> list) => list.asMap().map(
        (final int index, final T value) => MapEntry<T, String>(
          value,
          t(value.toString()),
        ),
      );
}

///
///
///
extension L10nHelper on BuildContext {
  ///
  ///
  ///
  String t(
    final String key, {
    final String base = 'common',
    final String? context,
    final int? count,
    final Map<String, dynamic>? variables,
  }) =>
      L10n.of(this).t(
        key,
        base: base,
        context: context,
        count: count,
        variables: variables,
      );

  ///
  ///
  ///
  Map<T, String> tEnum<T>(final List<T> list) => L10n.of(this).tEnum(list);
}
