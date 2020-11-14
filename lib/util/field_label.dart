import 'package:flutter/material.dart';

///
///
///
class FieldLabel extends StatelessWidget {
  final String label;

  ///
  ///
  ///
  const FieldLabel(
    this.label, {
    Key key,
  }) : super(key: key);

  ///
  ///
  ///
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 8.0,
        left: 16.0,
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.black45,
        ),
      ),
    );
  }
}
