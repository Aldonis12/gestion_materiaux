import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gestion_vetement/DatabaseHelper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class Ajout extends StatefulWidget {
  const Ajout({Key? key}) : super(key: key);

  @override
  _AjoutState createState() => _AjoutState();
}

class _AjoutState extends State<Ajout> {
  final _formKey = GlobalKey<FormState>();
  final _detailsController = TextEditingController();
  String? _selectedColor;
  String? _selectedType;
  File? _selectedImage;

  List<Map<String, dynamic>> _colors = [];
  List<Map<String, dynamic>> _types = [];

  @override
  void initState() {
    super.initState();
    _fetchColors();
    _fetchTypes();
  }

  void _fetchColors() async {
    List<Map<String, dynamic>> colors = await DatabaseHelper().readAllColor();
    setState(() {
      _colors = colors;
    });
  }

  void _fetchTypes() async {
    List<Map<String, dynamic>> types = await DatabaseHelper().readAllTypes();
    setState(() {
      _types = types;
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Galerie'),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Caméra'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _createNoMediaFile() async {
    try {
      Directory appDocDir = await getApplicationDocumentsDirectory();
      File noMediaFile = File('${appDocDir.path}/.nomedia');
      if (!(await noMediaFile.exists())) {
        await noMediaFile.create();
      }
    } catch (e) {
      print('Erreur lors de la création du fichier .nomedia: $e');
    }
  }

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajout'),
      ),
      body: Padding(
        padding: EdgeInsets.all(screenHeight * 0.0184),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              GestureDetector(
                onTap: _showImageSourceDialog,
                child: Container(
                  color: Colors.grey[200],
                  height: screenHeight * 0.23,
                  child: _selectedImage == null
                      ? Center(child: Text('Appuyez pour ajouter une image'))
                      : Image.file(
                    _selectedImage!,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.0184),
              DropdownButtonFormField<String>(
                value: _selectedColor,
                onChanged: (String? value) {
                  setState(() {
                    _selectedColor = value;
                  });
                },
                items: _colors.map((color) {
                  return DropdownMenuItem<String>(
                    value: color['nom'],
                    child: Text(color['nom']),
                  );
                }).toList(),
                decoration: InputDecoration(
                  labelText: 'Couleur',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null) {
                    return 'Veuillez sélectionner une couleur';
                  }
                  return null;
                },
              ),
              SizedBox(height: screenHeight * 0.0184),
              DropdownButtonFormField<String>(
                value: _selectedType,
                onChanged: (String? value) {
                  setState(() {
                    _selectedType = value;
                  });
                },
                items: _types.map((types) {
                  return DropdownMenuItem<String>(
                    value: types['nom'],
                    child: Text(types['nom']),
                  );
                }).toList(),
                decoration: InputDecoration(
                  labelText: 'Type',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null) {
                    return 'Veuillez sélectionner un type';
                  }
                  return null;
                },
              ),
              SizedBox(height: screenHeight * 0.0184),
              TextFormField(
                controller: _detailsController,
                decoration: InputDecoration(
                  labelText: 'Détails',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: screenHeight * 0.0184),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate() && _selectedImage != null) {
                    try {
                      await DatabaseHelper().addMatieriel(
                        details: _detailsController.text,
                        couleurId: _colors.firstWhere((c) => c['nom'] == _selectedColor)['id'],
                        typeId: _types.firstWhere((t) => t['nom'] == _selectedType)['id'],
                        imagePath: _selectedImage!.path,
                      );

                      await _createNoMediaFile();

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Matériel ajouté avec succès')),
                      );

                      setState(() {
                        _detailsController.clear();
                        _selectedColor = null;
                        _selectedType = null;
                        _selectedImage = null;
                      });
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Erreur lors de l\'ajout du matériel: $e')),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Veuillez remplir les champs obligatoires (image, couleur, type)')),
                    );
                  }
                },
                child: Text('Ajouter'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
