import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class About extends StatelessWidget {
  const About({Key? key}) : super(key: key);

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text('À propos'),
      ),
      body: Padding(
        padding: EdgeInsets.all(screenHeight * 0.0092),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.asset(
                'assets/image/logo-g_v.png',
                width: screenHeight * 0.25,
                height: screenHeight * 0.25,
              ),
            ),
            Text(
              'Cette application permet de gérer les matériaux, en particulier les vêtements, en ajoutant des images, des descriptions, ainsi que des types et des couleurs associés. Elle utilise une base de données locale pour une gestion efficace. De plus, elle offre des fonctionnalités historiques permettant de visualiser les détails de l\'utilisation des vêtements.',
              style: TextStyle(fontSize: screenHeight * 0.0184),
            ),
            SizedBox(height: screenHeight * 0.027),
            Text(
              'Créateur :',
              style: TextStyle(fontSize: screenHeight * 0.023, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: screenHeight * 0.0092),
            Text(
              'Nom : HERITRA',
              style: TextStyle(fontSize: screenHeight * 0.0184),
            ),
            Text(
              'Prénom : Aldonis Chryspin Mick Lewis',
              style: TextStyle(fontSize: screenHeight * 0.0184),
            ),
            SizedBox(height: screenHeight * 0.013),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => _launchUrl('whatsapp://send?phone=+261328555033'),
                  child: Image.asset(
                    'assets/image/whatsapp_icon.png',
                    width: screenHeight * 0.103,
                    height: screenHeight * 0.103,
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(width: screenHeight * 0.005),
                GestureDetector(
                  onTap: () => _launchUrl('https://www.linkedin.com/in/aldonis-mick-lewis-heritra-4a7ab2268/'),
                  child: Image.asset(
                    'assets/image/linkedin_icon.png',
                    width: screenHeight * 0.057,
                    height: screenHeight * 0.057,
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(width: screenHeight * 0.023),
                GestureDetector(
                  onTap: () => _launchUrl('https://www.facebook.com/micklewis.aldonis/'),
                  child: Image.asset(
                    'assets/image/facebook_icon.png',
                    width: screenHeight * 0.080,
                    height: screenHeight * 0.080,
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
