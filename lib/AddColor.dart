import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:gestion_vetement/DatabaseHelper.dart';

class AddColor extends StatefulWidget {
  const AddColor({Key? key}) : super(key: key);

  @override
  _AddColorState createState() => _AddColorState();
}

class _AddColorState extends State<AddColor> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  Color _selectedColor = Colors.black;
  Color _selectedColorUpdate = Colors.black;
  String? _errorMessage;
  String? _validationMessage;
  late List<Map<String, dynamic>> _colorList;

  @override
  void initState() {
    super.initState();
    _colorList = [];
    _fetchColors();
  }

  Future<void> _fetchColors() async {
    List<Map<String, dynamic>> colors = await DatabaseHelper().readAllColor();
    setState(() {
      _colorList = colors;
    });
  }

  void _submitForm() async {
    setState(() {
      _errorMessage = null;
      _validationMessage = null;
    });

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      String nom = _nomController.text;
      String code = '#${_selectedColor.value.toRadixString(16).substring(2).toUpperCase()}';

      try {
        await DatabaseHelper().addColor(nom: nom, code: code);
        setState(() {
          _validationMessage = 'Couleur "$nom" avec code "$code" validée';
          _nomController.clear();
          _selectedColor = Colors.black;
          _fetchColors();
        });
      } catch (e) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    }
  }

  void _deleteColor(int id) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: Text('Êtes-vous sûr de vouloir supprimer cette couleur ?\n'
              'La suppression d\'une couleur peut nuire au filtrage dans la liste.'),
          actions: <Widget>[
            TextButton(
              child: Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Supprimer'),
              onPressed: () async {
                try {
                  Navigator.of(context).pop();
                  await DatabaseHelper().deleteColor(id);
                  setState(() {
                    _validationMessage = 'Couleur supprimée avec succès!';
                    _fetchColors();
                  });
                } catch (e) {
                  setState(() {
                    _errorMessage = e.toString();
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _editColor(int id, String currentNom, String currentCode) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final double screenHeight = MediaQuery.of(context).size.height;
        String editedNom = currentNom;
        Color editedColor = Color(int.parse(currentCode.replaceAll('#', '0xFF')));

        return AlertDialog(
          title: Text('Modifier la couleur'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: currentNom,
                onChanged: (value) {
                  editedNom = value;
                },
                decoration: InputDecoration(
                  labelText: 'Nouveau nom',
                ),
              ),
              SizedBox(height: screenHeight * 0.0092),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _showColorPickerDialogUpdate(editedColor);
                    },
                    child: Text('Cliquer pour la couleur '),
                    style: ElevatedButton.styleFrom(// Text color of the button
                    ),
                  ),
                  SizedBox(width: screenHeight * 0.0092),
                ],
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Enregistrer'),
              onPressed: () async {
                try {
                  String newCode = '#${_selectedColorUpdate.value.toRadixString(16).substring(2).toUpperCase()}';
                  await DatabaseHelper().updateColor(id: id, nom: editedNom, code: newCode);
                  setState(() {
                    _validationMessage = 'Couleur modifiée avec succès!';
                    Navigator.of(context).pop();
                    _fetchColors();
                  });
                } catch (e) {
                  setState(() {
                    //_errorMessage = e.toString();
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showColorPickerDialog(Color initialColor) {
    Color pickedColor = initialColor;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Choisissez une couleur'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: initialColor,
              onColorChanged: (color) {
                setState(() {
                  pickedColor = color;
                });
              },
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text('Valider'),
              onPressed: () {
                setState(() {
                  _selectedColor = pickedColor;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showColorPickerDialogUpdate(Color initialColor) {
    Color pickedColor = initialColor;
    //print("tonga ato volohany $initialColor");
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Choisissez une couleur à modifier'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: initialColor,
              onColorChanged: (color) {
                setState(() {
                  pickedColor = color;
                  //print("tonga ato ndray be $pickedColor");
                });
              },
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text('Valider'),
              onPressed: () {
                setState(() {
                  _selectedColorUpdate = pickedColor; // Update _selectedColor
                  //print("Eto be $pickedColor");
                  //print("Eto kely $_selectedColorUpdate");
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text('Couleur'),
      ),
      body: Padding(
        padding: EdgeInsets.all(screenHeight * 0.0184),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_errorMessage != null)
              Padding(
                padding: EdgeInsets.all(screenHeight * 0.0092),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red),
                ),
              ),
            if (_validationMessage != null)
              Padding(
                padding: EdgeInsets.all(screenHeight * 0.0092),
                child: Text(
                  _validationMessage!,
                  style: TextStyle(color: Colors.green),
                ),
              ),
            SizedBox(height: screenHeight * 0.0184),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ajouter une nouvelle couleur :',
                    style: TextStyle(fontSize: screenHeight * 0.02, fontWeight: FontWeight.bold),
                  ),
                  TextFormField(
                    controller: _nomController,
                    decoration: InputDecoration(
                      labelText: 'Nom',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez ajouter un nom';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: screenHeight * 0.0184),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          _showColorPickerDialog(_selectedColor);
                        },
                        child: Text('Choisir couleur avec Color Picker : '),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _selectedColor, // Background color of the button
                          foregroundColor: Colors.white, // Text color of the button
                        ),
                      ),
                      SizedBox(width: screenHeight * 0.0092),
                      GestureDetector(
                        onTap: () {
                          _showColorPickerDialog(_selectedColor);
                        },
                        child: Container(
                          width: screenHeight * 0.0577,
                          height: screenHeight * 0.0577,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _selectedColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.0184),
                  ElevatedButton(
                    onPressed: _submitForm,
                    child: Text('Valider'),
                  ),
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.0184),
            Text(
              'Liste des couleurs :',
              style: TextStyle(fontSize: screenHeight * 0.02, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _colorList.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: screenHeight * 0.002,
                    child: ListTile(
                      title: Text(_colorList[index]['nom']),
                      subtitle: Container(
                        width: screenHeight * 0.055,
                        height: screenHeight * 0.027,
                        color: Color(int.parse(_colorList[index]['code_couleur'].replaceAll('#', '0xFF'))),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              _editColor(
                                _colorList[index]['id'],
                                _colorList[index]['nom'],
                                _colorList[index]['code_couleur'],
                              );
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              _deleteColor(_colorList[index]['id']);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
