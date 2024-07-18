import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:paws_up_v1/Pages/Extra%20Page/chat_page.dart';

class LostDogsProfile extends StatelessWidget {
  const LostDogsProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("images/fondebb.png"), // Ruta a tu imagen de fondo
          fit: BoxFit.cover,
        ),
      ),
      child: ListView.builder(
        itemCount: 10,
        itemBuilder: (BuildContext context, int index) {
          return const PostWidget();
        },
      ),
    );
  }
}

class PostWidget extends StatefulWidget {
  const PostWidget({super.key});

  @override
  _PostWidgetState createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeInFadeOut;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _fadeInFadeOut =
        Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
            .animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeInFadeOut,
      child: SlideTransition(
        position: _slideAnimation,
        child: Card(
          color: Colors.black,
          margin: const EdgeInsets.all(8), // Margen reducido
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Radio de borde reducido
          ),
          elevation: 4, // Elevación ligeramente reducida
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    const CircleAvatar(
                      backgroundImage:
                          NetworkImage('https://via.placeholder.com/150'),
                      radius: 18, // Radio reducido
                    ),
                    const SizedBox(
                        width: 10), // Espacio reducido entre elementos
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Lo publique yo',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 18, // Tamaño de fuente reducido
                            fontFamily: "Hey",
                          ),
                        ),
                        SizedBox(height: 0), // Espacio reducido entre textos
                        Text(
                          '6 h',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Theme(
                      data: Theme.of(context).copyWith(
                        iconTheme: const IconThemeData(
                            color:
                                Color(0xFF5BFFD3)), // Cambia el color a verde
                      ),
                      child: PopupMenuButton<String>(
                        onSelected: (String value) {},
                        itemBuilder: (BuildContext context) {
                          return {'Reportar', 'Ocultar'}.map((String choice) {
                            return PopupMenuItem<String>(
                              value: choice,
                              child: Text(choice),
                            );
                          }).toList();
                        },
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(0)), // Radio de borde reducido
                  child: Image.network(
                    'https://via.placeholder.com/400x300',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 250, // Altura significativamente reducida
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(12.0), // Relleno reducido
                child: Text(
                  'Laky, se perdió hace 5 horas es una perrita de...',
                  style: TextStyle(
                    fontSize: 14, // Tamaño de fuente reducido
                    color: Colors.white,
                    fontFamily: "Hey",
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8.0), // Relleno horizontal reducido
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const FaIcon(FontAwesomeIcons.bone,
                              color: Color(0xFF5BFFD3)),
                          onPressed: () {},
                        ),
                        const Text(
                          '123',
                          style: TextStyle(
                            fontSize: 14, // Tamaño de fuente reducido
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(
                            width: 12), // Espacio reducido entre iconos
                        IconButton(
                          icon: const Icon(Icons.comment_outlined,
                              color: Color(0xFF5BFFD3)),
                          onPressed: () {},
                        ),
                        const Text(
                          '45',
                          style: TextStyle(
                            fontSize: 14, // Tamaño de fuente reducido
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon:
                              const Icon(Icons.info, color: Color(0xFF5BFFD3)),
                          onPressed: () {
                            const ChatPage();
                          },
                        ),
                        IconButton(
                          icon:
                              const Icon(Icons.share, color: Color(0xFF5BFFD3)),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
