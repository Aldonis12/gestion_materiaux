import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gestion_vetement/DatabaseHelper.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class Historique extends StatefulWidget {
  const Historique({Key? key}) : super(key: key);

  @override
  _HistoriqueState createState() => _HistoriqueState();
}

class _HistoriqueState extends State<Historique> {
  List<Map<String, dynamic>> _historiqueData = [];
  List<Map<String, dynamic>> _filteredData = [];
  List<String> _dates = [];

  List<Map<String, dynamic>> _types = [];
  List<Map<String, dynamic>> _colors = [];

  String? _selectedDate;
  int? _selectedType;
  int? _selectedColor;
  Directory? appDocDir;

  @override
  void initState() {
    super.initState();
    _initializeAppDirectory();
    _fetchHistoriqueData();
    _fetchFiltersData();
  }

  Future<void> _initializeAppDirectory() async {
    appDocDir = await getApplicationDocumentsDirectory();
  }

  Future<void> _fetchHistoriqueData() async {
    List<Map<String, dynamic>> utilisations = await DatabaseHelper().readUtilisationMateriel();
    List<String> dates = utilisations.map((entry) {
      DateTime date = DateTime.parse(entry['utilisation_inserted'] as String);
      return DateFormat('yyyy-MM-dd').format(date);
    }).toSet().toList();

    setState(() {
      _historiqueData = utilisations;
      _filteredData = utilisations;
      _dates = dates..sort((a, b) => b.compareTo(a));
    });
  }

  Future<void> _fetchFiltersData() async {
    List<Map<String, dynamic>> types = await DatabaseHelper().readAllTypes();
    List<Map<String, dynamic>> colors = await DatabaseHelper().readAllColor();
    setState(() {
      _types = types;
      _colors = colors;
    });
  }

  void _filterData() {
    List<Map<String, dynamic>> filtered = _historiqueData;

    if (_selectedDate != null) {
      filtered = filtered.where((entry) {
        DateTime entryDate = DateTime.parse(entry['utilisation_inserted'] as String);
        String formattedEntryDate = DateFormat('yyyy-MM-dd').format(entryDate);
        return formattedEntryDate == _selectedDate;
      }).toList();
    }

    if (_selectedType != null && _selectedType != -1) {
      filtered = filtered.where((entry) => entry['type_id'] == _selectedType).toList();
    }

    if (_selectedColor != null && _selectedColor != -1) {
      filtered = filtered.where((entry) => entry['couleur_id'] == _selectedColor).toList();
    }

    setState(() {
      _filteredData = filtered;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = DateFormat('yyyy-MM-dd').format(picked);
      });
    } else {
      setState(() {
        _selectedDate = null;
      });
    }
    _filterData();
  }

  void _deleteUtilisation(int id) async {
    await DatabaseHelper().deleteUtilisationById(id);
    _fetchHistoriqueData();
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text('Historique'),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(screenHeight * 0.0092),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectDate(context),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.017, horizontal: screenHeight * 0.011),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(screenHeight * 0.005),
                      ),
                      child: Text(
                        _selectedDate == null ? 'Date' : _selectedDate!,
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: screenHeight * 0.0092),
                Expanded(
                  child: DropdownButton<int>(
                    hint: Text('Type'),
                    value: _selectedType,
                    items: [-1, ..._types.map((type) => type['id'] as int)].map((id) {
                      return DropdownMenuItem<int>(
                        value: id,
                        child: Row(
                          children: [
                            Text(id == -1 ? "Tous" : _types.firstWhere((type) => type['id'] == id)['nom'] as String),
                            SizedBox(width: screenHeight * 0.0092),
                            GestureDetector(
                              onTap: () {
                                // Implement action on type tap if needed
                              },
                              child: Icon(Icons.add, color: Colors.white),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedType = value;
                      });
                      _filterData();
                    },
                  ),
                ),
                SizedBox(width: screenHeight * 0.0092),
                Expanded(
                  child: DropdownButton<int>(
                    hint: Text('Couleur'),
                    value: _selectedColor,
                    items: [-1, ..._colors.map((color) => color['id'] as int)].map((id) {
                      return DropdownMenuItem<int>(
                        value: id,
                        child: Text(id == -1 ? "Tous" : _colors.firstWhere((color) => color['id'] == id)['nom'] as String),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedColor = value;
                      });
                      _filterData();
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _dates.map((date) {
                  final dateEntries = _filteredData.where((entry) {
                    DateTime entryDate = DateTime.parse(entry['utilisation_inserted'] as String);
                    return DateFormat('yyyy-MM-dd').format(entryDate) == date;
                  }).toList();

                  if (dateEntries.isEmpty) return SizedBox.shrink();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(screenHeight * 0.0092),
                        child: Text(
                          date,
                          style: TextStyle(fontSize: screenHeight * 0.02, fontWeight: FontWeight.bold),
                        ),
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: dateEntries.map((subEntry) {
                            String imagePath = subEntry['image_path'] as String;
                            if (!imagePath.startsWith('/data/user/0/')) {
                              imagePath = '/data/user/0/com.gestion.gestion_vetement/app_flutter/.nomedia/$imagePath';
                            }

                            return Padding(
                              padding: EdgeInsets.all(screenHeight * 0.0092),
                              child: SizedBox(
                                width: screenHeight * 0.13,
                                height: screenHeight * 0.185,
                                child: Stack(
                                  children: [
                                    Card(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            width: screenHeight * 0.103,
                                            height: screenHeight * 0.103,
                                            child: imagePath.isNotEmpty && File(imagePath).existsSync()
                                                ? Image.file(
                                              File(imagePath),
                                              fit: BoxFit.cover,
                                            )
                                                : Image.asset(
                                              'assets/placeholder.png',
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.all(screenHeight * 0.0092),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      subEntry['type_nom'] as String,
                                                      style: TextStyle(fontWeight: FontWeight.bold),
                                                    ),
                                                    SizedBox(width: screenHeight * 0.0092),
                                                    GestureDetector(
                                                      onTap: () {
                                                        showDialog(
                                                          context: context,
                                                          builder: (BuildContext context) {
                                                            return AlertDialog(
                                                              title: Text("Confirmation"),
                                                              content: Text("Voulez-vous supprimer cet élément de l'historique ?"),
                                                              actions: [
                                                                TextButton(
                                                                  onPressed: () {
                                                                    Navigator.of(context).pop();
                                                                  },
                                                                  child: Text("Annuler"),
                                                                ),
                                                                TextButton(
                                                                  onPressed: () {
                                                                    _deleteUtilisation(subEntry['utilisation_id'] as int);
                                                                    Navigator.of(context).pop();
                                                                  },
                                                                  child: Text("Supprimer"),
                                                                ),
                                                              ],
                                                            );
                                                          },
                                                        );
                                                      },
                                                      child: Icon(Icons.delete, color: Colors.black26),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: screenHeight * 0.004),
                                                Text(
                                                  subEntry['couleur_nom'] as String,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.0184),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
