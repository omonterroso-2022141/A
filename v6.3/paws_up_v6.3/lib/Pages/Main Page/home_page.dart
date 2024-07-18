import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:paws_up_v1/Pages/Main%20Page/profile_page.dart';
import 'package:paws_up_v1/Pages/Publication%20Pages/add_post_page.dart';
import '../Page Profile/Settings.dart';
import 'category_page.dart';
import 'lost_dogs_feed_page.dart';
import 'map_google.dart';
import 'normal_feed_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  bool _showLostDogsOnly = false;
  late final AnimationController _controller;
  late final Animation<double> _fadeInFadeOut;
  String _appBarTitle = 'PawsUp'; // Título inicial

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
    SchedulerBinding.instance!.addPostFrameCallback((_) {
      _controller.forward();
    });
  }

  void _onItemTapped(int index) {
    _controller.reverse().then((_) {
      setState(() {
        _selectedIndex = index;
        // Cambiar el título cuando se selecciona el índice 1 (PawsMap)
        _appBarTitle = index == 1 ? 'PawsMap' : 'PawsUp';
      });
      _controller.forward();
    });
  }

  void _toggleLostDogsOnly(bool value) {
    setState(() {
      _showLostDogsOnly = value;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _widgetOptions = <Widget>[
      _showLostDogsOnly ? const LostDogsFeedPage() : const NormalFeedPage(),
      const MapGoogle(),
      const AddPostPage(),
      const CategoryPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text(
          _appBarTitle, // Usar el título dinámico
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'Meow',
            fontSize: 45,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
        actions: _selectedIndex == 4
            ? [
                IconButton(
                  icon: const Icon(Icons.settings, color: Color(0xFF5BFFD3)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SettingsPage()),
                    );
                  },
                ),
              ]
            : [
                IconButton(
                  icon:
                      const Icon(Icons.pets_outlined, color: Color(0xFF5BFFD3)),
                  onPressed: () => _toggleLostDogsOnly(!_showLostDogsOnly),
                ),

                /*IconButton(
                  icon: const Icon(Icons.message_rounded,
                      color: Color(0xFF5BFFD3)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ChatPage()),
                    );
                  },
                ),*/
              ],
      ),
      body: FadeTransition(
        opacity: _fadeInFadeOut,
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.black,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_location_sharp),
            label: 'PawsMap',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box_outlined),
            label: 'Publicar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_awesome_mosaic_rounded),
            label: 'Categorias',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF5BFFD3),
        unselectedItemColor: Colors.white,
        onTap: _onItemTapped,
      ),
    );
  }
}
