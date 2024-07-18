import 'package:flutter/material.dart';

class InformationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Información',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.black,
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionTitle('Términos y Condiciones'),
              SizedBox(height: 20),
              SubSectionTitle('1. Introducción'),
              SizedBox(height: 10),
              SectionContent(
                '¡Bienvenido a PawsUp! Estamos encantados de que hayas decidido unirte a nuestra comunidad dedicada a ayudar a encontrar perros perdidos y reunirlos con sus dueños. Antes de comenzar a utilizar nuestra aplicación, es importante que leas y comprendas nuestros términos y condiciones. Estos términos establecen los derechos y responsabilidades tanto para ti como usuario de PawsUp, como para nosotros, los desarrolladores de la aplicación.',
              ),
              SizedBox(height: 20),
              SubSectionTitle('2. Aceptación de los Términos'),
              SizedBox(height: 10),
              SubSectionContentTitle('Uso de la Aplicación:'),
              SectionContent(
                'PawsUp es una plataforma diseñada para ayudar a encontrar perros perdidos mediante la ubicación en tiempo real y la información proporcionada por los usuarios. Te comprometes a utilizar la aplicación de manera responsable y de acuerdo con estos términos.',
              ),
              SizedBox(height: 10),
              SubSectionContentTitle('Información Personal:'),
              SectionContent(
                'Para utilizar PawsUp, podrías ser requerido/a a proporcionar información personal, como tu nombre y detalles de contacto. Esta información se utilizará únicamente con el propósito de facilitar la reunión de perros perdidos con sus dueños y se gestionará de acuerdo con nuestra política de privacidad.',
              ),
              SizedBox(height: 10),
              SubSectionContentTitle('Responsabilidad del Usuario:'),
              SectionContent(
                'Eres responsable de la exactitud de la información que compartas a través de PawsUp y del uso que hagas de la aplicación. No deberás usar la aplicación de manera que interfiera con los derechos de otros usuarios o terceros.',
              ),
              SizedBox(height: 10),
              SubSectionContentTitle('Privacidad:'),
              SectionContent(
                'Nos comprometemos a proteger tu privacidad y a manejar tu información personal de acuerdo con nuestra política de privacidad. Al utilizar PawsUp, aceptas la recopilación, uso y almacenamiento de tu información personal de acuerdo con esta política.',
              ),
              SizedBox(height: 10),
              SubSectionContentTitle('Finalización del Uso:'),
              SectionContent(
                'Tienes derecho a dejar de utilizar PawsUp en cualquier momento. Nos reservamos el derecho de suspender o cancelar tu acceso si incumples estos términos y condiciones o si consideramos que tu conducta puede ser perjudicial para otros usuarios o para nuestra plataforma.',
              ),
              SizedBox(height: 10),
              SectionContent(
                'Al utilizar PawsUp, confirmas que has leído, entendido y aceptado estos términos y condiciones. Si no estás de acuerdo con alguno de estos términos, te rogamos que no utilices nuestra aplicación.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFF5BFFD3),
        fontSize: 24.0,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class SubSectionTitle extends StatelessWidget {
  final String title;

  const SubSectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFF5BFFD3),
        fontSize: 20.0,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class SubSectionContentTitle extends StatelessWidget {
  final String title;

  const SubSectionContentTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFF5BFFD3),
        fontSize: 16.0,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class SectionContent extends StatelessWidget {
  final String content;

  const SectionContent(this.content);

  @override
  Widget build(BuildContext context) {
    return Text(
      content,
      textAlign: TextAlign.justify,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16.0,
      ),
    );
  }
}
