import 'package:flutter/material.dart';
import 'package:gestion_vetement/About.dart';
import 'package:gestion_vetement/AddColor.dart';
import 'package:gestion_vetement/AddTypes.dart';
import 'package:gestion_vetement/Ajout.dart';
import 'package:gestion_vetement/DataPage.dart';
import 'package:gestion_vetement/Historique.dart';
import 'package:gestion_vetement/Liste.dart';
import 'package:gestion_vetement/Utilisation.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    //866.29
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(screenHeight * 0.02),
              child: Text(
                "Accueil",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: screenHeight * 0.032,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.start,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(screenHeight * 0.013),
              child: Center(
                child: Wrap(
                  spacing: screenHeight * 0.023,
                  runSpacing: screenHeight * 0.023,
                  children: [
                    _buildCard(
                      context,
                      "Ajout",
                      "Ajoutez ici les matériaux que vous souhaitez stocker.",
                      "assets/image/Plus.png",
                      Ajout()
                    ),
                    _buildCard(
                      context,
                      "Liste",
                      "Consultez ici la liste de vos matériaux.",
                      "assets/image/liste.png",
                        Liste()
                    ),
                    _buildCard(
                      context,
                      "Utilisation",
                      "Enregistrez ici les matériaux utilisés à une date précise.",
                      "assets/image/Utilisation.png",
                        Utilisation()
                    ),
                    _buildCard(
                      context,
                      "Historique",
                      "Consultez ici l'historique de vos utilisations.",
                      "assets/image/historique.png",
                        Historique()
                    ),
                    _buildCard(
                        context,
                        "Types",
                        "Ajoutez ici les types de matériaux.",
                        "assets/image/Types.png",
                        AddTypes()
                    ),
                    _buildCard(
                        context,
                        "Couleur",
                        "Ajoutez ici de nouvelles couleurs.",
                        "assets/image/couleur.png",
                        AddColor()
                    ),
                    _buildCard(
                        context,
                        "A propos",
                        "Informations sur l'application et le créateur.",
                        "assets/image/about.png",
                        About()
                    ),
                    /*_buildCard(
                        context,
                        "TEST",
                        "Informations sur l'application et le créateur.",
                        "assets/image/placeholder.png",
                        DataPage()
                    ),*/
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, String title, String description, String imagePath, url) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => url),
        );
      },
      onLongPress: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(description),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          ),
        );
      },
      child: SizedBox(
        width: screenHeight(context) * 0.184,
        height: screenHeight(context) * 0.184,
        child: Card(
          color: Colors.white70,
          elevation: screenHeight(context) * 0.002,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(screenHeight(context) * 0.0092),
          ),
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(screenHeight(context) * 0.0092),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(imagePath, width: screenHeight(context) * 0.073),
                  SizedBox(height: screenHeight(context) * 0.011),
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: screenHeight(context) * 0.023,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

}