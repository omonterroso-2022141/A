import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:visibility_detector/visibility_detector.dart';

class Publicacion {
  final String id;
  final String autor;
  final String descripcion;
  final String horaPublicado;
  List<String> imagenes;
  final List<String> likes;
  final List<String> dislikes;
  final List<String> comentarios;

  Publicacion({
    required this.id,
    required this.autor,
    required this.descripcion,
    required this.horaPublicado,
    required this.imagenes,
    required this.likes,
    required this.dislikes,
    required this.comentarios,
  });

  factory Publicacion.fromJson(Map<String, dynamic> json) {
    return Publicacion(
      id: json['id'] ?? '',
      autor: json['autor'] ?? '',
      descripcion: json['descripcion'] ?? '',
      horaPublicado: json['horaPublicado'] ?? '',
      imagenes: json['imagenes'] != null
          ? List<String>.from(json['imagenes'])
          : [],
      likes: json['like'] != null ? List<String>.from(json['like']) : [],
      dislikes:
          json['dislike'] != null ? List<String>.from(json['dislike']) : [],
      comentarios: json['comentarios'] != null
          ? List<String>.from(json['comentarios'])
          : [],
    );
  }
}

Future<String> fetchImagenUrl(String imagen) async {
  final response = await http.get(Uri.parse(
      'https://back-paws-up-cloud-rho.vercel.app/imagen/getImagen/$imagen'));
  if (response.statusCode == 200) {
    final imageUrl = json.decode(response.body)['result'];
    print('Imagen URL recibida: $imageUrl'); // Depuración
    if (isValidImageUrl(imageUrl)) {
      print('URL de imagen válida: $imageUrl'); // Depuración
      return imageUrl;
    } else {
      print('URL de imagen inválida: $imageUrl'); // Depuración
      throw Exception('URL de imagen inválida: $imageUrl');
    }
  } else {
    print('Failed to load imagen URL'); // Depuración
    throw Exception('Failed to load imagen URL');
  }
}

bool isValidImageUrl(String url) {
  return url.startsWith('http://') || url.startsWith('https://');
}

Future<List<Publicacion>> fetchPublicaciones({int page = 1, int limit = 10}) async {
  final response = await http.get(Uri.parse(
      'https://back-paws-up-cloud-rho.vercel.app/Publicacion/viewPublicacion?page=$page&limit=$limit'));
  debugPrint(response.body);

  if (response.statusCode == 200) {
    final List<dynamic> publicacionesJson =
        json.decode(response.body)['publicacionesReestructuradas'];
    List<Publicacion> publicaciones = [];
    for (var json in publicacionesJson) {
      Publicacion publicacion = Publicacion.fromJson(json);
      publicaciones.add(publicacion);
    }
    return publicaciones;
  } else {
    throw Exception('Failed to load publicaciones');
  }
}

class NormalFeedPage extends StatefulWidget {
  const NormalFeedPage({Key? key}) : super(key: key);

  @override
  _NormalFeedPageState createState() => _NormalFeedPageState();
}

class _NormalFeedPageState extends State<NormalFeedPage> {
  final ScrollController _scrollController = ScrollController();
  List<Publicacion> _publicaciones = [];
  Map<String, List<String>> _loadedImages = {};
  int _currentPage = 1;
  bool _isLoading = false;
  final int _imagenesPorCarga = 10;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _fetchMorePublicaciones();
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      _fetchMorePublicaciones();
    }
  }

  Future<void> _fetchMorePublicaciones() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final nuevasPublicaciones = await fetchPublicaciones(page: _currentPage);
      setState(() {
        _currentPage++;
        _publicaciones.addAll(nuevasPublicaciones);
      });
    } catch (e) {
      // Manejo de errores
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchMoreImagenes(Publicacion publicacion) async {
    if (_loadedImages.containsKey(publicacion.id)) return;

    try {
      List<String> imagenUrls = publicacion.imagenes.take(_imagenesPorCarga).toList();
      for (int i = 0; i < imagenUrls.length; i++) {
        imagenUrls[i] = await fetchImagenUrl(imagenUrls[i]);
      }
      setState(() {
        _loadedImages[publicacion.id] = imagenUrls;
      });
    } catch (e) {
      // Manejo de errores
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/fondebb.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: _buildPublicacionesList(),
      ),
    );
  }

  Widget _buildPublicacionesList() {
    return ListView.builder(
      controller: _scrollController,
      itemCount: _publicaciones.length + 1,
      itemBuilder: (context, index) {
        if (index == _publicaciones.length) {
          return _isLoading
              ? const Center(child: CircularProgressIndicator())
              : const SizedBox.shrink();
        }
        return VisibilityDetector(
          key: Key(_publicaciones[index].id),
          onVisibilityChanged: (info) {
            if (info.visibleFraction > 0.1) {
              _fetchMoreImagenes(_publicaciones[index]);
            }
          },
          child: PostWidget(
            publicacion: _publicaciones[index],
            imagenes: _loadedImages[_publicaciones[index].id] ?? [],
            onLike: () => _toggleLike(_publicaciones[index]),
            onComment: () => _navigateToComments(context, _publicaciones[index]),
          ),
        );
      },
    );
  }

  void _toggleLike(Publicacion publicacion) {
    setState(() {
      if (publicacion.likes.contains('currentUserId')) {
        publicacion.likes.remove('currentUserId');
      } else {
        publicacion.likes.add('currentUserId');
      }
    });
  }

  void _navigateToComments(BuildContext context, Publicacion publicacion) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CommentsPage(publicacionId: publicacion.id),
      ),
    );
  }
}

class PostWidget extends StatelessWidget {
  final Publicacion publicacion;
  final List<String> imagenes;
  final VoidCallback onLike;
  final VoidCallback onComment;

  const PostWidget({
    Key? key,
    required this.publicacion,
    required this.imagenes,
    required this.onLike,
    required this.onComment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.black,
      margin: const EdgeInsets.all(10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundImage:
                      NetworkImage('https://via.placeholder.com/150'),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      publicacion.autor,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5BFFD3),
                        fontSize: 18,
                        fontFamily: "Hey",
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(publicacion.horaPublicado,
                        style:
                            const TextStyle(fontSize: 12, color: Colors.white)),
                  ],
                ),
                const Spacer(),
                Theme(
                  data: Theme.of(context).copyWith(
                    iconTheme: const IconThemeData(color: Color(0xFF5BFFD3)),
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
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(15)),
            child: Column(
              children: imagenes.map((imagenUrl) {
                return CachedNetworkImage(
                  imageUrl: imagenUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 430,
                  placeholder: (context, url) =>
                      const CircularProgressIndicator(),
                  errorWidget: (context, url, error) =>
                      const Image(
                        image: AssetImage('images/placeholder.png'),
                        width: double.infinity,
                        height: 430,
                        fit: BoxFit.cover,
                      ),
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              publicacion.descripcion,
              style: const TextStyle(
                  fontSize: 16, color: Colors.white, fontFamily: "Hey"),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const FaIcon(FontAwesomeIcons.bone,
                          color: Color(0xFF5BFFD3)),
                      onPressed: onLike,
                    ),
                    Text('${publicacion.likes.length}',
                        style:
                            const TextStyle(fontSize: 16, color: Colors.white)),
                    IconButton(
                      icon: const FaIcon(FontAwesomeIcons.xmark,
                          color: Color(0xFF5BFFD3)),
                      onPressed: () {},
                    ),
                    Text('${publicacion.dislikes.length}',
                        style:
                            const TextStyle(fontSize: 16, color: Colors.white)),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const FaIcon(FontAwesomeIcons.message,
                          color: Color(0xFF5BFFD3)),
                      onPressed: onComment,
                    ),
                    Text('${publicacion.comentarios.length}',
                        style:
                            const TextStyle(fontSize: 16, color: Colors.white)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CommentsPage extends StatelessWidget {
  final String publicacionId;

  const CommentsPage({Key? key, required this.publicacionId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Implementa la lógica de la página de comentarios aquí
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comentarios'),
      ),
      body: Center(
        child: Text('Comentarios para la publicación $publicacionId'),
      ),
    );
  }
}
