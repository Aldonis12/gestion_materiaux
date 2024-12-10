import 'package:flutter/material.dart';
import 'package:gestion_vetement/DatabaseHelper.dart';

class DataPage extends StatefulWidget {
  @override
  _DataPageState createState() => _DataPageState();
}

class _DataPageState extends State<DataPage> {
  @override
  void initState() {
    super.initState();
    _readAndPrintData();
  }

  void _readAndPrintData() async {
    await DatabaseHelper().readUtilisationMateriel();
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    print('Screen Height: $screenHeight');
    return Scaffold(
      appBar: AppBar(
        title: Text('Données SQLite'),
      ),
      body: Center(
        child: Text('Screen Height: $screenHeight' ),
      ),
    );
  }
}
