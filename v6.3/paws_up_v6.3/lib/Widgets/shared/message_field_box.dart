import 'package:flutter/material.dart';

class MessageFieldBox extends StatefulWidget {
  final ValueChanged<String> onValue;

  const MessageFieldBox({Key? key, required this.onValue}) : super(key: key);

  @override
  _MessageFieldBoxState createState() => _MessageFieldBoxState();
}

class _MessageFieldBoxState extends State<MessageFieldBox> {
  final textController = TextEditingController();
  final focusNode = FocusNode();
  bool isTyping = false;

  @override
  void initState() {
    super.initState();
    textController.addListener(updateTypingStatus);
  }

  @override
  void dispose() {
    textController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  void updateTypingStatus() {
    setState(() {
      isTyping = textController.text.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    final outlineInputBorder = UnderlineInputBorder(
      borderSide: const BorderSide(color: Colors.transparent),
      borderRadius: BorderRadius.circular(40),
    );

    final inputDecoration = InputDecoration(
      hintText: 'Escribe un mensaje, necesita tu ayuda',
      filled: true,
      fillColor: Color(0xFF53C4A6), // Cambia el color del fondo del campo de texto aquí
      enabledBorder: outlineInputBorder,
      focusedBorder: outlineInputBorder,
      suffixIcon: Padding(
        padding: EdgeInsets.only(right: 8.0), // Ajusta el espacio entre el campo de texto y el botón
        child: SizedBox(
          width: 46, // Ancho del botón de enviar
          height: 46, // Alto del botón de enviar
          child: IconButton(
            onPressed: isTyping
                ? () {
              final textValue = textController.value.text;
              widget.onValue(textValue);
              textController.clear();
            }
                : null,
            icon: Image.asset(
              'images/enviar.png', // Ruta de la imagen específica para el botón
              color: isTyping ? Colors.white : Colors.grey.withOpacity(0.5), // Color del icono
            ),
          ),
        ),
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextFormField(
          onTapOutside: (event) {
            focusNode.unfocus();
          },
          focusNode: focusNode,
          controller: textController,
          decoration: inputDecoration,
          style: TextStyle(
            color: isTyping ? Colors.black : Colors.grey,
            fontFamily: 'Hey', // Cambia aquí al nombre de tu tipografía
          ), // Cambia el color del texto mientras escribes
          onFieldSubmitted: (value) {
            widget.onValue(value);
            textController.clear();
            focusNode.requestFocus();
          },
        ),
      ],
    );
  }
}
