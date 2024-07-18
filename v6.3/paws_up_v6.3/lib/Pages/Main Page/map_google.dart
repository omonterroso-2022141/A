import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:paws_up_v1/Pages/Extra%20Page/chat_page.dart'; // Asegúrate de que esta ruta sea correcta
import 'home_page.dart';

// Modelo de Mascota
class Mascota {
  final String nombre;
  final String edad;
  final String ubicacion;
  final String descripcion;
  final String sexo;

  Mascota({
    required this.nombre,
    required this.edad,
    required this.ubicacion,
    required this.descripcion,
    required this.sexo,
  });

  factory Mascota.fromJson(Map<String, dynamic> json) {
    return Mascota(
      nombre: json['nombre'],
      edad: json['edad'],
      ubicacion: json['ubicacion'],
      descripcion: json['descripcion'],
      sexo: json['sexo'],
    );
  }
}

// Función para obtener las mascotas desde el backend
Future<List<Mascota>> fetchMascotas() async {
  final response = await http.get(
      Uri.parse('https://back-paws-up-cloud-rho.vercel.app/Mascota/viewMascota'));

  if (response.statusCode == 200) {
    final List<dynamic> mascotasJson = json.decode(response.body)['mascotas'];
    return mascotasJson.map((json) => Mascota.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load mascotas');
  }
}

// Clave API de Google Maps
const kGoogleApiKey =
    "YOUR_API_KEY"; // Reemplaza con tu clave de API de Google Maps

class AddressSearch extends SearchDelegate<String> {
  final GoogleMapController mapController;

  AddressSearch(this.mapController);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.isEmpty) {
      return const Center(child: Text('Ingrese una dirección.'));
    }

    return FutureBuilder<List<Location>>(
      future: locationFromAddress(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No se encontraron resultados.'));
        } else {
          List<Location> locations = snapshot.data!;
          return ListView.builder(
            itemCount: locations.length,
            itemBuilder: (context, index) {
              Location location = locations[index];
              LatLng latLng = LatLng(location.latitude, location.longitude);
              return ListTile(
                title: Text(query),
                subtitle: Text(
                    'Lat: ${location.latitude}, Lng: ${location.longitude}'),
                onTap: () {
                  close(context, query);
                  mapController.animateCamera(
                    CameraUpdate.newCameraPosition(
                      CameraPosition(
                        target: latLng,
                        zoom: 15,
                      ),
                    ),
                  );
                },
              );
            },
          );
        }
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return const Center(child: Text('Ingrese una dirección.'));
    }

    return FutureBuilder<List<Location>>(
      future: locationFromAddress(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No hay sugerencias.'));
        } else {
          List<Location> locations = snapshot.data!;
          return ListView.builder(
            itemCount: locations.length,
            itemBuilder: (context, index) {
              Location location = locations[index];
              LatLng latLng = LatLng(location.latitude, location.longitude);
              return ListTile(
                title: Text(query),
                subtitle: Text(
                    'Lat: ${location.latitude}, Lng: ${location.longitude}'),
                onTap: () {
                  query = query;
                  showResults(context);
                },
              );
            },
          );
        }
      },
    );
  }
}

// Clase principal del mapa
class MapGoogle extends StatefulWidget {
  const MapGoogle({super.key});

  @override
  _MapGoogleState createState() => _MapGoogleState();
}

class _MapGoogleState extends State<MapGoogle>
    with SingleTickerProviderStateMixin {
  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};
  LatLng _lastMapPosition = const LatLng(
      14.626115, -90.535328); // Coordenadas de la Ciudad de Guatemala
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  bool _isSatellite = false;
  late Future<List<Mascota>> _futureMascotas;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _futureMascotas = fetchMascotas();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _futureMascotas.then((mascotas) {
      _addMascotasMarkers(mascotas);
    });
  }

  void _onCameraMove(CameraPosition position) {
    _lastMapPosition = position.target;
  }

  Future<BitmapDescriptor> _getMarkerIcon() async {
    final ImageConfiguration config =
        const ImageConfiguration(size: Size(2, 2));
    return await BitmapDescriptor.fromAssetImage(config, 'images/marker.png');
  }

  void _addMascotasMarkers(List<Mascota> mascotas) async {
    final BitmapDescriptor markerIcon = await _getMarkerIcon();

    for (var mascota in mascotas) {
      try {
        LatLng latLng = await _getLatLngFromAddress(mascota.ubicacion);
        _markers.add(
          Marker(
            markerId: MarkerId(latLng.toString()),
            position: latLng,
            infoWindow: InfoWindow(
              title: mascota.nombre,
              snippet: 'Toca para más información',
              onTap: () {
                _showPetDetails(mascota);
              },
            ),
            icon: markerIcon,
          ),
        );
      } catch (e) {
        print('Error getting location for ${mascota.ubicacion}: $e');
      }
    }
    setState(() {});
  }

  Future<LatLng> _getLatLngFromAddress(String address) async {
    if (address.isEmpty) {
      throw Exception('La dirección está vacía.');
    }
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        return LatLng(locations[0].latitude, locations[0].longitude);
      } else {
        throw Exception('No location found for address: $address');
      }
    } catch (e) {
      throw Exception(
          'Error fetching location for address: $address. Details: $e');
    }
  }

  void _showPetDetails(Mascota mascota) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      isScrollControlled: true,
      builder: (context) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 200,
                      width: 150,
                      /*child: Image.network(
                      'https://back-paws-up-cloud-rho.vercel.app/imagen/getImagen/${mascota.imagen}',
                      fit: BoxFit.cover,
                      loadingBuilder: (BuildContext context, Widget child,
                          ImageChunkEvent? loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                    ),*/
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Detalles',
                            style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF5BFFD3),
                                fontFamily: "Hey"),
                          ),
                          RichText(
                            text: TextSpan(
                              text: 'Mascota: ',
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF5BFFD3),
                                  fontFamily: "Hey"),
                              children: <TextSpan>[
                                TextSpan(
                                  text: mascota.nombre,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontFamily: "Hey"),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 0),
                          RichText(
                            text: TextSpan(
                              text: 'Edad: ',
                              style: const TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF5BFFD3),
                                  fontFamily: "Hey"),
                              children: <TextSpan>[
                                TextSpan(
                                  text: mascota.edad,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontFamily: "Hey"),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 1),
                          RichText(
                            text: TextSpan(
                              text: 'Descripción: ',
                              style: const TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF5BFFD3),
                                  fontFamily: "Hey"),
                              children: <TextSpan>[
                                TextSpan(
                                  text: mascota.descripcion,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontFamily: "Hey"),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'images/chat.png', // Ruta de tu imagen
                            width: 30, // Ancho de la imagen
                            height: 30, // Alto de la imagen
                          ),
                          const SizedBox(
                              width: 8), // Espacio entre la imagen y el texto
                          const Text(
                            'Encontrar',
                            style: TextStyle(
                                fontSize: 14, // Tamaño del texto
                                color: Colors.white, // Color del texto
                                fontFamily: "Hey"),
                          ),
                        ],
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ChatPage()),
                        );
                      },
                    )
                  ],
                ),
              ],
            ),
          ),
        );
      },
    ).then((_) {
      _animationController.reverse();
    });
    _animationController.forward();
  }

  Future<void> _handleSearch() async {
    var place = await showSearch(
      context: context,
      delegate: AddressSearch(_mapController),
    );
    if (place != null && place.isNotEmpty) {
      try {
        List<Location> locations = await locationFromAddress(place);
        if (locations.isNotEmpty) {
          final latLng = LatLng(locations[0].latitude, locations[0].longitude);
          _mapController.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: latLng,
                zoom: 15,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('No se encontraron ubicaciones para "$place".')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al buscar la ubicación: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar...',
            style: TextStyle(
              fontFamily: "Hey",
              color: Color(0xFF5BFFD3),
            )), // Color de las letras blancas
        backgroundColor: Colors.black, // Fondo negro
        actions: [
          IconButton(
            icon: const Icon(Icons.search,
                color: Color(0xFF5BFFD3)), // Icono de búsqueda en blanco
            onPressed: _handleSearch,
          ),
          IconButton(
            icon: const Icon(Icons.layers,
                color: Color(0xFF5BFFD3)), // Icono de capas en rojo
            onPressed: () {
              setState(() {
                _isSatellite = !_isSatellite;
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _lastMapPosition,
              zoom: 10,
            ),
            markers: _markers,
            mapType: _isSatellite ? MapType.satellite : MapType.normal,
            onCameraMove: _onCameraMove,
          ),
        ],
      ),
    );
  }
}
