import 'package:flutter/material.dart';

class HerMmessageBubble extends StatelessWidget {
  final Color bubbleColor;
  final Color textColor;

  const HerMmessageBubble({Key? key, required this.bubbleColor, required this.textColor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text(
              'Hola Mundo',
              style: TextStyle(
                color: textColor,
                fontFamily: 'Hey', // Cambia aquí al nombre de tu tipografía
                fontSize: MediaQuery.of(context).size.width * 0.04, // Ajusta el tamaño de la fuente
              ),
            ),
          ),
        ),
        const SizedBox(height: 5),
        _ImageBubble(bubbleColor: bubbleColor),
        const SizedBox(height: 10),
      ],
    );
  }
}

class _ImageBubble extends StatelessWidget {
  final Color bubbleColor;

  const _ImageBubble({Key? key, required this.bubbleColor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      color: bubbleColor, // Usa el color del mensaje
      child: const Text('Image Bubble'),
    );
  }
}
