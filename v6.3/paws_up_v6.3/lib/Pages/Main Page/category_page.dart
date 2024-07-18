import 'package:flutter/material.dart';

class CategoryPage extends StatelessWidget {
  const CategoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus(); // Desenfoca el teclado
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                  'https://github.com/jrosselin-2022050/IMG_PAWSUP/blob/main/fondebb.png?raw=true'), // Ruta de la imagen local
              fit: BoxFit.cover,
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    style: const TextStyle(
                      color: Colors.white, // Color del texto de búsqueda
                    ),
                    decoration: InputDecoration(
                      hintText: 'Buscar...',
                      hintStyle: TextStyle(
                        color: Colors.white
                            .withOpacity(0.8), // Color del texto de sugerencia
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Colors.white, // Color del icono de búsqueda
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.black,
                    ),
                  ),
                ),
                const CategorySection(
                  title: 'Restaurantes',
                  posts: [
                    PostCard(
                      user: 'LUIS MONTERROSO',
                      time: '6h',
                      content: 'Este café es muy bueno, 100% recomendado',
                      imageUrl: 'https://via.placeholder.com/150',
                    ),
                    PostCard(
                      user: 'LUIS MONTERROSO',
                      time: '6h',
                      content: 'Este lugar es Pet Friendly 🐾',
                      imageUrl: 'https://via.placeholder.com/150',
                    ),
                    PostCard(
                      user: 'LUIS MONTERROSO',
                      time: '6h',
                      content: 'Sus comidas son muy buenas',
                      imageUrl: 'https://via.placeholder.com/150',
                    ),
                  ],
                ),
                const CategorySection(
                  title: 'Tienda de productos de mascotas',
                  posts: [
                    PostCard(
                      user: 'LUIS MONTERROSO',
                      time: '6h',
                      content: 'Hay muchas productos interesantes',
                      imageUrl: 'https://via.placeholder.com/150',
                    ),
                    PostCard(
                      user: 'LUIS MONTERROSO',
                      time: '6h',
                      content: 'Los precios están algo elevados 🤑',
                      imageUrl: 'https://via.placeholder.com/150',
                    ),
                    PostCard(
                      user: 'LUIS MONTERROSO',
                      time: '6h',
                      content: 'Gran variedad de productos',
                      imageUrl: 'https://via.placeholder.com/150',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CategorySection extends StatelessWidget {
  final String title;
  final List<PostCard> posts;

  const CategorySection({
    required this.title,
    required this.posts,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white, // Texto blanco
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: posts,
          ),
        ),
      ],
    );
  }
}

class PostCard extends StatelessWidget {
  final String user;
  final String time;
  final String content;
  final String imageUrl;

  const PostCard({
    required this.user,
    required this.time,
    required this.content,
    required this.imageUrl,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.black, // Fondo negro
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            child: Image.network(
              imageUrl,
              height: 100,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  user,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Color(0xFF5BFFD3), // Texto de color
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  time,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12, // Texto blanco
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white, // Texto blanco
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white), // Línea blanca
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.info,
                    size: 20,
                    color: Color(0xFF5BFFD3), // Icono de color
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.share,
                    size: 20,
                    color: Color(0xFF5BFFD3), // Icono de color
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
