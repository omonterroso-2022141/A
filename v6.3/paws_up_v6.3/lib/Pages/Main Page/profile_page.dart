import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../Extra Page/chat_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');

  if (token == null) {
    print('Token is not set');
    // Navegar a la pantalla de inicio de sesión si el token no está presente
    // runApp(LoginApp());
  } else {
    runApp(const MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Profile Page',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ProfilePage(),
    );
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _controller;
  late Animation<double> _fadeInFadeOut;
  Map<String, dynamic>? _userProfile;
  List<dynamic>? _userPublications;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeInFadeOut = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _controller.forward();
      _fetchUserProfile();
      _fetchUserPublications();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        print('Token is null');
        return null;
      }

      final response = await http.get(
        Uri.parse('https://back-paws-up-cloud-rho.vercel.app/User/miPerfil'),
        headers: {'Authorization': token},
      );

      if (response.statusCode == 200) {
        print('Profile data: ${response.body}');
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        print('Failed to load profile: ${response.statusCode}');
        print('Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error fetching profile: $e');
      return null;
    }
  }

  Future<List<dynamic>?> getUserPublications() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        print('Token is null');
        return null;
      }

      final response = await http.get(
        Uri.parse(
            'https://back-paws-up-cloud-rho.vercel.app/Publicacion/viewPublicacionPropia'),
        headers: {'Authorization': token},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body)['publicaciones'] as List<dynamic>;
      } else {
        print('Failed to load publications: ${response.statusCode}');
        print('Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error fetching publications: $e');
      return null;
    }
  }

  void _fetchUserProfile() async {
    Map<String, dynamic>? profile = await getUserProfile();
    if (profile != null) {
      setState(() {
        _userProfile = profile;
      });
    } else {
      print('Failed to fetch profile');
    }
  }

  void _fetchUserPublications() async {
    List<dynamic>? publications = await getUserPublications();
    if (publications != null) {
      setState(() {
        _userPublications = publications;
      });
    } else {
      print('Failed to fetch publications');
    }
  }

  void _selectPage(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _widgetOptions = <Widget>[
      NormalFeedProfile(userPublications: _userPublications),
      const LostDogsProfile(),
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 230,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/fonde.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircleAvatar(
                        radius: 50,
                        backgroundImage: AssetImage('assets/profile_image.jpg'),
                      ),
                      const SizedBox(height: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xFF5BFFD3),
                                width: 2,
                              ),
                            ),
                            child: Text(
                              _userProfile != null
                                  ? _userProfile!['user']['username']
                                  : 'Cargando...',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    automaticallyImplyLeading: false,
                  ),
                ),
              ],
            ),
          ),
          Container(
            color: Colors.black,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.publish,
                    color: _selectedIndex == 0
                        ? const Color(0xFF5BFFD3)
                        : Colors.grey,
                  ),
                  onPressed: () {
                    _selectPage(0);
                  },
                ),
                Container(
                  width: 1,
                  height: 24,
                  color: Colors.grey,
                ),
                IconButton(
                  icon: Icon(
                    Icons.search,
                    color: _selectedIndex == 1
                        ? const Color(0xFF5BFFD3)
                        : Colors.grey,
                  ),
                  onPressed: () {
                    _selectPage(1);
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: FadeTransition(
              opacity: _fadeInFadeOut,
              child: _widgetOptions.elementAt(_selectedIndex),
            ),
          ),
        ],
      ),
    );
  }
}

class NormalFeedProfile extends StatelessWidget {
  final List<dynamic>? userPublications;
  const NormalFeedProfile({Key? key, this.userPublications}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ListView.builder(
        itemCount: userPublications?.length ?? 0,
        itemBuilder: (context, index) {
          final publication = userPublications![index];
          return ListTile(
            title: Text(
              publication['descripcion'],
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              'Publicado el ${publication['fechaPublicacion']} a las ${publication['horaPublicado']}',
              style: const TextStyle(color: Colors.white70),
            ),
          );
        },
      ),
    );
  }
}

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
