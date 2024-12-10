import 'package:flutter/material.dart';
import 'package:gestion_vetement/DatabaseHelper.dart';

class AddTypes extends StatefulWidget {
  const AddTypes({Key? key}) : super(key: key);

  @override
  _AddTypesState createState() => _AddTypesState();
}

class _AddTypesState extends State<AddTypes> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  String? _errorMessage;
  String? _validationMessage;
  late List<Map<String, dynamic>> _typesList;

  @override
  void initState() {
    super.initState();
    _typesList = [];
    _fetchTypes();
  }

  Future<void> _fetchTypes() async {
    List<Map<String, dynamic>> types = await DatabaseHelper().readAllTypes();
    setState(() {
      _typesList = types;
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
      try {
        await DatabaseHelper().addTypes(nom: nom);
        setState(() {
          _validationMessage = 'Le type est ajouté avec succès!';
          _nomController.clear();
          _fetchTypes();
        });
      } catch (e) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    }
  }

  void _deleteType(int id) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: Text('Voulez-vous vraiment supprimer ce type ?\n'
              'La suppression d\'un type peut nuire au filtrage dans la liste.'),
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
                  await DatabaseHelper().deleteType(id);
                  setState(() {
                    _validationMessage = 'Le type a été supprimé avec succès!';
                    Navigator.of(context).pop();
                    _fetchTypes();
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

  void _editType(int id, String currentNom) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String editedNom = currentNom;
        return AlertDialog(
          title: Text('Modifier le type'),
          content: TextFormField(
            initialValue: currentNom,
            onChanged: (value) {
              editedNom = value;
            },
            decoration: InputDecoration(
              labelText: 'Nouveau nom',
            ),
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
                  await DatabaseHelper().updateType(id: id, nom: editedNom);
                  setState(() {
                    _validationMessage = 'Le type a été modifié avec succès!';
                    Navigator.of(context).pop();
                    _fetchTypes();
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

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text('Types'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: GridView.builder(
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: screenHeight * 0.011,
                mainAxisSpacing: screenHeight * 0.011,
                childAspectRatio: 1.7,
              ),
              itemCount: _typesList.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: screenHeight * 0.002,
                  child: Padding(
                    padding: EdgeInsets.all(screenHeight * 0.0092),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _typesList[index]['nom'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: screenHeight * 0.0184,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.0092),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                _editType(
                                  _typesList[index]['id'],
                                  _typesList[index]['nom'],
                                );
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                _deleteType(_typesList[index]['id']);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(screenHeight * 0.0184),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
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
                  Text(
                    "Ajouter un type",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: screenHeight * 0.023,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.start,
                  ),
                  SizedBox(height: screenHeight * 0.0184),
                  TextFormField(
                    controller: _nomController,
                    maxLength: 9,
                    decoration: InputDecoration(
                      labelText: 'Nom',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez ajouter un nom de type';
                      }
                      return null;
                    },


                  ),
                  SizedBox(height: screenHeight * 0.0184),
                  ElevatedButton(
                    onPressed: _submitForm,
                    child: Text('Valider'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
