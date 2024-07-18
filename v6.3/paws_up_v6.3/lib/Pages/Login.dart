import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'Main Page/home_page.dart';
import 'RegisterForm.dart';

class Login extends StatelessWidget {
  const Login({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.black,
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height,
              child: Stack(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(
                            'https://github.com/jrosselin-2022050/IMG_PAWSUP/blob/main/fonde.png?raw=true'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    left: MediaQuery.of(context).size.width * 0.03,
                    right: MediaQuery.of(context).size.width * 0.03,
                    top: MediaQuery.of(context).size.height * 0.02,
                    child: Container(
                      alignment: Alignment.topCenter,
                      child: Image.network(
                        'https://github.com/jrosselin-2022050/IMG_PAWSUP/blob/main/logos.png?raw=true',
                        width: MediaQuery.of(context).size.width * 0.5,
                        height: MediaQuery.of(context).size.width * 0.5,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    top: MediaQuery.of(context).size.height * 0.19,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      alignment: Alignment.center,
                      child: Text(
                        'PawsUp',
                        style: TextStyle(
                          color: const Color(0xFFFFFFFF),
                          fontSize: MediaQuery.of(context).size.width * 0.28,
                          fontFamily: 'Meow',
                          letterSpacing: 6.0,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: MediaQuery.of(context).size.height * 0.30,
                    child: Container(
                      padding: const EdgeInsets.all(20.0),
                      color: Colors.transparent,
                      child: const LoginForm(),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: MediaQuery.of(context).size.height * 0.05,
                    child: Container(
                      padding: const EdgeInsets.all(20.0),
                      color: Colors.transparent,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const RegisterForm()),
                          );
                        },
                        child: const Text(
                          '¿No tienes una cuenta? Regístrate',
                          style:
                              TextStyle(color: Colors.white, fontFamily: 'Hey'),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  bool _obscureText = true;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _response = '';

  Future<void> _login() async {
    const String baseUrl = 'https://back-paws-up-cloud-rho.vercel.app';

    final response = await http.post(
      Uri.parse('$baseUrl/User/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': _usernameController.text,
        'email': _usernameController.text,
        'password': _passwordController.text,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _response = 'Login successful: ${data['message']}';
      });

      final token = data['token'];
      print('Token recibido: $token');
      await _saveToken(token);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } else {
      setState(() {
        _response = 'Error: ${response.body}';
      });
    }
  }

  Future<void> _saveToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.25),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          TextField(
            controller: _usernameController,
            style: const TextStyle(color: Colors.black, fontFamily: 'Hey'),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: 'Usuario/Correo Electrónico',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50.0),
                borderSide: const BorderSide(width: 2.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50.0),
                borderSide:
                    const BorderSide(width: 3.0, color: Color(0xFF5BFFD3)),
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.network(
                  'https://github.com/jrosselin-2022050/IMG_PAWSUP/blob/main/userl.png?raw=true',
                  width: 1,
                  height: 1,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20.0),
          TextFormField(
            controller: _passwordController,
            style: const TextStyle(color: Colors.black, fontFamily: 'Hey'),
            obscureText: _obscureText,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: 'Contraseña',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50.0),
                borderSide: const BorderSide(width: 2.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50.0),
                borderSide:
                    const BorderSide(width: 3.0, color: Color(0xFF5BFFD3)),
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.network(
                  'https://github.com/jrosselin-2022050/IMG_PAWSUP/blob/main/pass.png?raw=true',
                  width: 10,
                  height: 10,
                ),
              ),
              suffixIcon: SizedBox(
                width: 40.0,
                height: 40.0,
                child: IconButton(
                  iconSize: 24.0,
                  icon: ImageIcon(
                    NetworkImage(
                      _obscureText
                          ? 'https://github.com/jrosselin-2022050/IMG_PAWSUP/blob/main/off.png?raw=true'
                          : 'https://github.com/jrosselin-2022050/IMG_PAWSUP/blob/main/on.png?raw=true',
                    ),
                    color: const Color(0xFF5BFFD3),
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 25.0),
          Container(
            constraints: const BoxConstraints(maxWidth: 250.0),
            width: double.infinity,
            child: MaterialButton(
              onPressed: _login,
              color: const Color(0xFF5BFFD3),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50.0),
              ),
              child: const Text(
                'Iniciar sesión',
                style: TextStyle(
                  fontSize: 18.0,
                  color: Colors.black,
                  fontFamily: 'Hey',
                ),
              ),
            ),
          ),
          const SizedBox(height: 20.0),
          Text(
            _response,
            style: const TextStyle(color: Colors.red, fontFamily: 'Hey'),
          ),
        ],
      ),
    );
  }
}
