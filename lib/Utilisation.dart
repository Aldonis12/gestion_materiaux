import 'package:flutter/material.dart';
import 'package:gestion_vetement/DatabaseHelper.dart';
import 'package:collection/collection.dart';
import 'dart:io';

class Item {
  final int id;
  final String imagePath;
  final int typeId;
  final int colorId;
  final String details;

  Item({
    required this.id,
    required this.imagePath,
    required this.typeId,
    required this.colorId,
    required this.details,
  });
}

class Utilisation extends StatefulWidget {
  const Utilisation({Key? key}) : super(key: key);

  @override
  _UtilisationState createState() => _UtilisationState();
}

class _UtilisationState extends State<Utilisation> {
  List<Item> items = [];
  List<Item> selectedItems = [];
  List<Map<String, dynamic>> _colors = [];
  List<Map<String, dynamic>> _types = [];

  int? selectedTypeId;
  int? selectedColorId;
  DateTime selectedDate = DateTime.now();
  String filterDetails = '';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() async {
    await _fetchColors();
    await _fetchTypes();
    await _fetchMaterials();
  }

  Future<void> _fetchColors() async {
    List<Map<String, dynamic>> colors = await DatabaseHelper().readAllColor();
    setState(() {
      _colors = colors;
    });
  }

  Future<void> _fetchTypes() async {
    List<Map<String, dynamic>> types = await DatabaseHelper().readAllTypes();
    setState(() {
      _types = types;
    });
  }

  Future<void> _fetchMaterials() async {
    List<Map<String, dynamic>> materials = await DatabaseHelper().readAllMaterials();
    setState(() {
      items = materials.map((material) {
        String imagePath = material['image_path'];
        if (!imagePath.startsWith('/data/user/0/')) {
          imagePath = '/data/user/0/com.gestion.gestion_vetement/app_flutter/.nomedia/$imagePath';
        }
        return Item(
          id: material['id'],
          imagePath: imagePath,
          typeId: material['types_id'],
          colorId: material['couleur_id'],
          details: material['details'],
        );
      }).toList();
    });
  }

  Future<int> insertUtilisation(Map<String, dynamic> row) async {
    try {
      final db = await DatabaseHelper().database;
      int id = await db.insert('Utilisation', row);
      print('Inserted row with ID: $id');
      print('Inserted data: $row');
      return id;
    } catch (e) {
      print('Error inserting data: $e');
      return -1; // Ou une autre valeur de retour pour indiquer une erreur
    }
  }

  void _insertSelectedItems(DateTime dateToInsert) async {
    if (selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Veuillez sélectionner au moins un élément à utiliser.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final dbHelper = DatabaseHelper();
    try {
      for (final item in selectedItems) {
        await dbHelper.insertUtilisation({
          'materiel_id': item.id,
          'types_id': item.typeId,
          'inserted': dateToInsert.toIso8601String(),
        });
      }
      setState(() {
        selectedItems.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Utilisation enregistrée avec succès.'),
          duration: Duration(seconds: 1),
        ),
      );
    } catch (e) {
      print('Error inserting selected items: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Une erreur est survenue lors de l\'enregistrement.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  String _detailsFilter = '';

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    List<Item> filteredItems = items.where((item) {
      final typeMatches = selectedTypeId == null || selectedTypeId == 0 || item.typeId == selectedTypeId;
      final colorMatches = selectedColorId == null || selectedColorId == 0 || item.colorId == selectedColorId;
      final detailsMatch = item.details.toLowerCase().contains(_detailsFilter.toLowerCase());
      return typeMatches && colorMatches && detailsMatch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Utilisation'),
      ),
      body: Padding(
        padding: EdgeInsets.all(screenHeight * 0.0092),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedTypeId?.toString(),
                    items: _buildTypeDropdownItems(),
                    decoration: InputDecoration(
                      labelText: 'Type',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        selectedTypeId = value == '0' ? null : int.tryParse(value ?? '');
                      });
                    },
                  ),
                ),
                SizedBox(width: screenHeight * 0.0184),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedColorId?.toString(),
                    items: _buildColorDropdownItems(),
                    decoration: InputDecoration(
                      labelText: 'Couleur',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        selectedColorId = value == '0' ? null : int.tryParse(value ?? '');
                      });
                    },
                  ),
                ),
                SizedBox(width: screenHeight * 0.0184),
                Expanded(
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Détails',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                    _detailsFilter = value;
                    });
                  },
                ),
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.0184),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 2 / 3,
                  crossAxisSpacing: screenHeight * 0.0092,
                  mainAxisSpacing: screenHeight * 0.0092,
                ),
                itemCount: filteredItems.length,
                itemBuilder: (context, index) {
                  final item = filteredItems[index];
                  final isSelected = selectedItems.contains(item);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          selectedItems.remove(item);
                        } else {
                          selectedItems.add(item);
                        }
                      });
                    },
                    child: Stack(
                      children: [
                        Card(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: item.imagePath.isNotEmpty
                                    ? Image.file(
                                  File(item.imagePath),
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                )
                                    : Center(child: Text('Pas d\'image')),
                              ),
                              Padding(
                                padding: EdgeInsets.all(screenHeight * 0.0092),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          _getTypeName(item.typeId),
                                          style: TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: screenHeight * 0.004),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Positioned(
                            top: screenHeight * 0.004,
                            right: screenHeight * 0.004,
                            child: Icon(Icons.check_circle, color: Colors.greenAccent),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
            if (selectedItems.isNotEmpty) ...[
              SizedBox(height: screenHeight * 0.0184),
              Text(
                'Éléments sélectionnés :',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: screenHeight * 0.0092),
              Container(
                height: screenHeight * 0.13,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: selectedItems.length,
                  itemBuilder: (context, index) {
                    final item = selectedItems[index];
                    return Container(
                      width: screenHeight * 0.13,
                      margin: EdgeInsets.only(right: screenHeight * 0.0092),
                      child: Card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(
                              alignment: Alignment.topRight,
                              children: [
                                Container(
                                  height: screenHeight * 0.080,
                                  width: double.infinity,
                                  child: item.imagePath.isNotEmpty
                                      ? Image.file(
                                    File(item.imagePath),
                                    fit: BoxFit.cover,
                                  )
                                      : Center(child: Text('Pas d\'image')),
                                ),
                                IconButton(
                                  icon: Icon(Icons.remove_circle, color: Colors.red),
                                  onPressed: () {
                                    setState(() {
                                      selectedItems.remove(item);
                                    });
                                  },
                                ),
                              ],
                            ),
                            Padding(
                              padding: EdgeInsets.all(screenHeight * 0.0092),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _getTypeName(item.typeId),
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: screenHeight * 0.0184),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      final selectedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (selectedDate != null) {
                        setState(() {
                          this.selectedDate = selectedDate;
                        });
                      }
                    },
                    child: Text('Choisir la date'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final dateToInsert = selectedDate;
                      _insertSelectedItems(dateToInsert);
                    },
                    child: Text('Enregistrer Utilisation'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<DropdownMenuItem<String>> _buildTypeDropdownItems() {
    List<DropdownMenuItem<String>> items = [
      DropdownMenuItem(value: '0', child: Text('Tous')),
    ];
    items.addAll(_types.map((type) {
      return DropdownMenuItem(
        value: type['id'].toString(),
        child: Text(type['nom']),
      );
    }).toList());
    return items;
  }

  List<DropdownMenuItem<String>> _buildColorDropdownItems() {
    List<DropdownMenuItem<String>> items = [
      DropdownMenuItem(value: '0', child: Text('Tous')),
    ];
    items.addAll(_colors.map((color) {
      return DropdownMenuItem(
        value: color['id'].toString(),
        child: Text(color['nom']),
      );
    }).toList());
    return items;
  }

  String _getTypeName(int typeId) {
    if (typeId == 0) return 'Tous';
    final type = _types.firstWhereOrNull((type) => type['id'] == typeId);
    return type != null ? type['nom'] : 'Inconnu';
  }

  String _getColorName(int colorId) {
    if (colorId == 0) return 'Toutes';
    final color = _colors.firstWhereOrNull((color) => color['id'] == colorId);
    return color != null ? color['nom'] : 'Inconnue';
  }
}
