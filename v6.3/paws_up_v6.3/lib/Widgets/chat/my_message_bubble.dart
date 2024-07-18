import 'package:flutter/material.dart';

import '../../domian/message.dart';

class MyMessageBubble extends StatelessWidget {
  final Message message;
  final Color bubbleColor;
  final Color textColor; // Agrega el parámetro textColor

  const MyMessageBubble(
      {Key? key,
      required this.message,
      required this.bubbleColor,
      required this.textColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text(
              message.text,
              style: TextStyle(
                color: textColor, // Usa el color de texto
                fontFamily: 'Hey', // Cambia aquí al nombre de tu tipografía
                fontSize: MediaQuery.of(context).size.width *
                    0.04, // Ajusta el tamaño de la fuente
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
