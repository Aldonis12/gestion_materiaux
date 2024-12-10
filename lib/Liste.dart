import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gestion_vetement/DatabaseHelper.dart';
import 'package:collection/collection.dart';

class Item {
  final int id;
  final String imagePath;
  int typeId;
  int colorId;
  String details;

  Item({
    required this.id,
    required this.imagePath,
    required this.typeId,
    required this.colorId,
    required this.details,
  });
}

class Liste extends StatefulWidget {
  const Liste({Key? key}) : super(key: key);

  @override
  _ListeState createState() => _ListeState();
}

class _ListeState extends State<Liste> {

  double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  List<Item> items = [];
  List<Map<String, dynamic>> _colors = [];
  List<Map<String, dynamic>> _types = [];

  int? selectedTypeId;
  int? selectedColorId;
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
    List<Map<String, dynamic>> materials =
    await DatabaseHelper().readAllMaterials();
    setState(() {
      items = materials.map((material) {
        String imagePath = material['image_path'];
        if (!imagePath.startsWith('/data/user/0/')) {
          imagePath =
          '/data/user/0/com.gestion.gestion_vetement/app_flutter/.nomedia/$imagePath';
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

  Future<void> _deleteMateriel(int id) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: Text('Voulez-vous vraiment supprimer cet élément ?'),
          actions: <Widget>[
            TextButton(
              child: Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Supprimer'),
              onPressed: () async {
                await DatabaseHelper().deleteMateriel(id);
                setState(() {
                  items.removeWhere((item) => item.id == id);
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateMateriel(int id) async {
    selectedTypeId = items.firstWhere((item) => item.id == id).typeId;
    selectedColorId = items.firstWhere((item) => item.id == id).colorId;
    String details = items.firstWhere((item) => item.id == id).details;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Modification'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    DropdownButtonFormField<int>(
                      value: selectedTypeId,
                      items: _buildTypeDropdownItemsInt(),
                      onChanged: (int? value) {
                        setState(() {
                          selectedTypeId = value;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Type',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: screenHeight(context) * 0.018),
                    DropdownButtonFormField<int>(
                      value: selectedColorId,
                      items: _buildColorDropdownItemsInt(),
                      onChanged: (int? value) {
                        setState(() {
                          selectedColorId = value;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Couleur',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: screenHeight(context) * 0.018),
                    TextField(
                      onChanged: (value) {
                        setState(() {
                          details = value;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Nouveau détail',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Modifier'),
              onPressed: () async {
                try {
                  await DatabaseHelper().updateMaterial({
                    'id': id,
                    'types_id': selectedTypeId,
                    'couleur_id': selectedColorId,
                    'details': details,
                  });

                  setState(() {
                    items.firstWhere((item) => item.id == id).typeId =
                    selectedTypeId!;
                    items.firstWhere((item) => item.id == id).colorId =
                    selectedColorId!;
                    items.firstWhere((item) => item.id == id).details = details;
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Matériel modifié avec succès.'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                } catch (e) {
                  print('Error updating material: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                      Text('Une erreur est survenue lors de la modification.'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                }

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  List<DropdownMenuItem<int>> _buildTypeDropdownItemsInt() {
    List<DropdownMenuItem<int>> items = _types.map((type) {
      return DropdownMenuItem<int>(
        value: type['id'],
        child: Text(type['nom']),
      );
    }).toList();
    return items;
  }

  List<DropdownMenuItem<int>> _buildColorDropdownItemsInt() {
    List<DropdownMenuItem<int>> items = _colors.map((color) {
      return DropdownMenuItem<int>(
        value: color['id'],
        child: Text(color['nom']),
      );
    }).toList();
    return items;
  }

  void _showDetailsDialog(Item item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Détails'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Type : ${_getTypeName(item.typeId)}'),
              Text('Couleur : ${_getColorName(item.colorId)}'),
              Text('Description : ${item.details}'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Fermer'),
              onPressed: () {
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
    List<Item> filteredItems = items.where((item) {
      final typeMatches =
          selectedTypeId == null || selectedTypeId == 0 || item.typeId == selectedTypeId;
      final colorMatches = selectedColorId == null ||
          selectedColorId == 0 ||
          item.colorId == selectedColorId;
      final detailsMatch =
      item.details.toLowerCase().contains(filterDetails.toLowerCase());
      return typeMatches && colorMatches && detailsMatch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Liste'),
      ),
      body: Padding(
        padding: EdgeInsets.all(screenHeight(context) * 0.0092),
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
                SizedBox(width: screenHeight(context) * 0.018),
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
                SizedBox(width: screenHeight(context) * 0.018),
                Expanded(
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        filterDetails = value;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Détails',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: screenHeight(context) * 0.018),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 2 / 3,
                  crossAxisSpacing: screenHeight(context) * 0.0092,
                  mainAxisSpacing: screenHeight(context) * 0.0092,
                ),
                itemCount: filteredItems.length,
                itemBuilder: (context, index) {
                  final item = filteredItems[index];
                  return GestureDetector(
                    onTap: () {
                      _showDetailsDialog(item);
                    },
                    child: Card(
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
                            padding: EdgeInsets.all(screenHeight(context) * 0.0092),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      _getTypeName(item.typeId),
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    Spacer(),
                                    IconButton(
                                      icon: Icon(Icons.edit),
                                      onPressed: () {
                                        _updateMateriel(item.id);
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete),
                                      onPressed: () {
                                        _deleteMateriel(item.id);
                                      },
                                    ),
                                  ],
                                ),
                                SizedBox(height: screenHeight(context) * 0.004),
                                Text(_getColorName(item.colorId)),
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
    final color = _colors.firstWhereOrNull((color) => color['id'] == colorId);
    return color != null ? color['nom'] : 'Inconnu';
  }
}
