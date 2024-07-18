import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:paws_up_v1/Pages/Main%20Page/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../model/categoria.dart';

class AddPostPage extends StatefulWidget {
  const AddPostPage({Key? key}) : super(key: key);

  @override
  _AddPostPageState createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  GoogleMapController? mapController;
  LatLng? selectedLocation;
  bool isMissingPet = false;
  TextEditingController nameController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  String? selectedSex;
  bool _mapLoading = true;
  List<XFile>? _mediaFiles;
  String userToken = '';
  List<Category> categories = [];
  String? selectedCategoryId;
  String? selectedCategoryNombre;

  final String googleApiKey = 'YOUR_GOOGLE_API_KEY_HERE';

  @override
  void initState() {
    super.initState();
    getUserToken();

    fetchCategories().then((data) {
      setState(() {
        categories = data;
      });
    }).catchError((error) {
      print('Error al obtener las categorías: $error');
    });

    mapController = null;
    selectedLocation = null;
  }

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    descriptionController.dispose();
    locationController.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller;
      _mapLoading = false;
    });
  }

  Future<void> _pickMedia() async {
    final ImagePicker picker = ImagePicker();
    final XFile? media = await picker.pickImage(source: ImageSource.gallery);
    if (media != null) {
      setState(() {
        _mediaFiles = [media];
      });
    }
  }

  Future<List<Prediction>> _fetchPlacePredictions(String input) async {
    final String url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$googleApiKey';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json['status'] == 'OK') {
        return (json['predictions'] as List)
            .map((p) => Prediction.fromJson(p))
            .toList();
      } else {
        throw Exception('Failed to fetch place predictions');
      }
    } else {
      throw Exception('Failed to fetch place predictions');
    }
  }

  Future<LatLng> _getLatLngFromPlaceId(String placeId) async {
    final String url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$googleApiKey';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json['status'] == 'OK') {
        final location = json['result']['geometry']['location'];
        return LatLng(location['lat'], location['lng']);
      } else {
        throw Exception('Failed to fetch place details');
      }
    } else {
      throw Exception('Failed to fetch place details');
    }
  }

  Future<void> _searchLocation() async {
    final LatLng? selectedLocation = await showDialog<LatLng>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Seleccione la ubicación'),
          content: Container(
            height: 300.0,
            width: 300.0,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(
                    14.6622765, -90.4899868), // Cambia la posición inicial aquí
                zoom: 15,
              ),
              onTap: (LatLng latLng) {
                Navigator.of(context).pop(latLng);
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(null);
              },
              child: Text('Cancelar'),
            ),
          ],
        );
      },
    );

    if (selectedLocation != null) {
      setState(() {
        this.selectedLocation = selectedLocation;
        locationController.text =
            '${selectedLocation.latitude}, ${selectedLocation.longitude}';
      });

      mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(selectedLocation, 15.0),
      );
    }
  }

  Future<List<Category>> fetchCategories() async {
    print(
        'Token actual: $userToken'); // Verifica el token actual antes de la solicitud

    final response = await http.get(
      Uri.parse(
          'https://back-paws-up-cloud-rho.vercel.app/Categoria/listCategoryUsuario'),
      headers: {'Authorization': userToken},
    );

    if (response.statusCode == 200) {
      final dynamic data = jsonDecode(response.body);
      print(
          'Respuesta del servidor: $data'); // Verifica la respuesta del servidor

      final categoryData = data['categorys'];
      final category = Category.fromJson(categoryData);
      return [category];
    } else {
      print('Error en la solicitud: ${response.statusCode}');
      throw Exception('Error al obtener las categorías');
    }
  }

  Future<void> getUserToken() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userToken = prefs.getString('token') ?? '';
    });
  }

  void _submitPost({required bool someParameter}) async {
    if (userToken.isEmpty) {
      print('Token no disponible.');
      return;
    }

    if (_mediaFiles == null || _mediaFiles!.isEmpty) {
      print('No se ha seleccionado ninguna imagen o video.');
      return;
    }

    try {
      print(userToken);
      var url = someParameter
          ? Uri.parse(
              'https://back-paws-up-cloud-rho.vercel.app/Publicacion/addPublicacion')
          : Uri.parse(
              'https://back-paws-up-cloud-rho.vercel.app/Mascota/addMascota');

      var request = http.MultipartRequest('POST', url)
        ..fields['descripcion'] = descriptionController.text;

      if (someParameter) {
        request.fields['categoria'] = selectedCategoryId ?? '';
      } else {
        request
          ..fields['nombre'] = nameController.text
          ..fields['edad'] = ageController.text
          ..fields['ubicacion'] = locationController.text
          ..fields['sexo'] = selectedSex ?? '';
      }

      // Agregar los archivos multimedia al cuerpo de la solicitud
      for (var file in _mediaFiles!) {
        String mimeType =
            lookupMimeType(file.path) ?? 'application/octet-stream';
        request.files.add(await http.MultipartFile.fromPath(
          'imagen', // Nombre del campo esperado en el backend para la imagen
          file.path,
          contentType: MediaType.parse(mimeType),
        ));
      }

      request.headers['Authorization'] =
          userToken; // Añade el token de autenticación

      var response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await http.Response.fromStream(response);
        var responseBody = json.decode(responseData.body);
        print('Publicación exitosa: $responseBody');

        // Muestra la burbuja de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('¡Felicidades!, publicación hecha con éxito'),
          ),
        );

        // Redirige a NormalFeedPage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else {
        print('Error al publicar: ${response.statusCode}');
        var responseData = await response.stream.bytesToString();
        print(responseData);
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle heyTextStyle = TextStyle(
      fontFamily: "Hey",
      color: Colors.white, // Puedes ajustar el color aquí si es necesario
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        color: Colors.black,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isMissingPet = true;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 30.0),
                        backgroundColor: isMissingPet
                            ? Color.fromARGB(255, 2, 244, 220)
                            : Colors.grey,
                      ),
                      child: Text('Publicación Normal', style: heyTextStyle),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isMissingPet = false;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 30.0),
                        backgroundColor: !isMissingPet
                            ? Color.fromARGB(255, 2, 244, 220)
                            : Colors.grey,
                      ),
                      child: Text('Mascota Perdida', style: heyTextStyle),
                    ),
                  ],
                ),
                SizedBox(height: 20.0),
                isMissingPet
                    ? Column(
                        children: [
                          TextFormField(
                            controller: descriptionController,
                            decoration: InputDecoration(
                              labelText: 'Descripción',
                              labelStyle: TextStyle(color: Colors.white),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color.fromARGB(255, 2, 244, 220)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                            ),
                            style: TextStyle(color: Colors.white),
                          ),
                          SizedBox(height: 20.0),
                          DropdownButtonFormField<String>(
                            value: selectedCategoryId,
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedCategoryId = newValue;
                                selectedCategoryNombre = categories
                                    .firstWhere(
                                        (category) => category.id == newValue)
                                    .nombre;
                              });
                            },
                            items: categories.map((Category category) {
                              return DropdownMenuItem<String>(
                                value: category.id,
                                child: Text(category.nombre),
                              );
                            }).toList(),
                            decoration: InputDecoration(
                              labelText: 'Categoría',
                              labelStyle: TextStyle(color: Colors.white),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color.fromARGB(255, 2, 244, 220)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                            ),
                            style: TextStyle(color: Colors.white),
                            dropdownColor: Colors.black,
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          TextFormField(
                            controller: nameController,
                            decoration: InputDecoration(
                              labelText: 'Nombre',
                              labelStyle: TextStyle(color: Colors.white),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color.fromARGB(255, 2, 244, 220)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                            ),
                            style: TextStyle(color: Colors.white),
                          ),
                          SizedBox(height: 20.0),
                          TextFormField(
                            controller: ageController,
                            decoration: InputDecoration(
                              labelText: 'Edad',
                              labelStyle: TextStyle(color: Colors.white),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color.fromARGB(255, 2, 244, 220)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                            ),
                            style: TextStyle(color: Colors.white),
                          ),
                          SizedBox(height: 20.0),
                          TextFormField(
                            controller: descriptionController,
                            decoration: InputDecoration(
                              labelText: 'Descripción',
                              labelStyle: TextStyle(color: Colors.white),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color.fromARGB(255, 2, 244, 220)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                            ),
                            style: TextStyle(color: Colors.white),
                          ),
                          SizedBox(height: 20.0),
                          TextFormField(
                            controller: locationController,
                            decoration: InputDecoration(
                              labelText: 'Ubicación',
                              labelStyle: TextStyle(color: Colors.white),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color.fromARGB(255, 2, 244, 220)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                            ),
                            style: TextStyle(color: Colors.white),
                            readOnly: true,
                            onTap: _searchLocation,
                          ),
                          SizedBox(height: 20.0),
                          DropdownButtonFormField<String>(
                            value: selectedSex,
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedSex = newValue;
                              });
                            },
                            items: <String>['Macho', 'Hembra']
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            decoration: InputDecoration(
                              labelText: 'Sexo',
                              labelStyle: TextStyle(color: Colors.white),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color.fromARGB(255, 2, 244, 220)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                            ),
                            style: TextStyle(color: Colors.white),
                            dropdownColor: Colors.black,
                          ),
                        ],
                      ),
                SizedBox(height: 20.0),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: _pickMedia,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 30.0),
                        backgroundColor: Colors.white,
                      ),
                      child: Text('Añadir Imagen/Video',
                          style: TextStyle(color: Colors.black)),
                    ),
                    SizedBox(width: 10.0),
                    _mediaFiles != null && _mediaFiles!.isNotEmpty
                        ? Container(
                            width: 50,
                            height: 50,
                            child: Image.file(
                              File(_mediaFiles![0].path),
                              fit: BoxFit.cover,
                            ),
                          )
                        : Container(),
                  ],
                ),
                SizedBox(height: 20.0),
                Center(
                  child: ElevatedButton(
                    onPressed: () => _submitPost(someParameter: isMissingPet),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
                      backgroundColor: Color.fromARGB(255, 2, 244, 220),
                    ),
                    child: Text('Publicar', style: heyTextStyle),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Prediction {
  final String description;
  final String placeId;

  Prediction({required this.description, required this.placeId});

  factory Prediction.fromJson(Map<String, dynamic> json) {
    return Prediction(
      description: json['description'],
      placeId: json['place_id'],
    );
  }
}

// Esta función puede ayudar a determinar el tipo MIME basado en la extensión del archivo
String lookupMimeType(String path) {
  final extension = path.split('.').last.toLowerCase();
  switch (extension) {
    case 'jpg':
    case 'jpeg':
      return 'image/jpeg';
    case 'png':
      return 'image/png';
    case 'mp4':
      return 'video/mp4';
    case 'avi':
      return 'video/x-msvideo';
    case 'mov':
      return 'video/quicktime';
    default:
      return 'application/octet-stream';
  }
}
