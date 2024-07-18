import 'package:flutter/material.dart';

enum FromWho { me, hers }

class Message {
  final String text;
  final String? imageUrl;
  final FromWho fromWho;
  final Color color;

  Message(
      {required this.text,
      this.imageUrl,
      required this.fromWho,
      required this.color});
}
