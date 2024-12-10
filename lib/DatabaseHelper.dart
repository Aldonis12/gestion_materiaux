import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

List WholeDataList = [];

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'gestion_vetement.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  FutureOr<void> _onCreate(Database db, int version) async {
    await db.execute(
        '''
    CREATE TABLE IF NOT EXISTS couleur (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nom TEXT NOT NULL UNIQUE,
      code_couleur TEXT NOT NULL UNIQUE
    )
    '''
    );

    await db.execute(
        '''
    INSERT INTO couleur(nom,code_couleur) VALUES ('Blanc','#ffffff'),('Noir','#000000'),('Gris','#D3D3D3'),('Rouge','#FF0000'),
    ('Vert','#008000'),('Beige','#C8AD7F'),('Jaune','#FFFF00'),('Bleu','#0000FF'); 
    '''
    );

    await db.execute(
        '''
    CREATE TABLE  IF NOT EXISTS types (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nom TEXT NOT NULL UNIQUE
    )
    '''
    );

    await db.execute(
        '''
    INSERT INTO types(nom) VALUES ('T-shirt'),('Pull'),('Chemise'),('Blouson'),('Veste'),('Polo'),('Pantalon'),('Short'),('Chaussure');
    '''
    );

    await db.execute(
        '''
    CREATE TABLE  IF NOT EXISTS materiel (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      details TEXT,
      couleur_id INTEGER NOT NULL,
      types_id INTEGER NOT NULL,
      image_path TEXT NOT NULL,
      inserted TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (couleur_id) REFERENCES couleur(id) ON DELETE CASCADE,
      FOREIGN KEY (types_id) REFERENCES types(id) ON DELETE CASCADE
    )
    '''
    );

    await db.execute(
        '''
    CREATE TABLE IF NOT EXISTS Utilisation (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      materiel_id INTEGER NOT NULL,
      types_id INTEGER NOT NULL,
      inserted TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (materiel_id) REFERENCES materiel(id) ON DELETE CASCADE,
      FOREIGN KEY (types_id) REFERENCES types(id) ON DELETE CASCADE
    )
    '''
    );

    await db.execute(
        '''
    CREATE VIEW IF NOT EXISTS utilisation_materiel AS
      SELECT 
          u.id AS utilisation_id,
          u.inserted AS utilisation_inserted,
          m.image_path,
          m.couleur_id,
          c.nom AS couleur_nom,
          t.id AS type_id,
          t.nom AS type_nom
      FROM 
          Utilisation u
      JOIN 
          materiel m ON u.materiel_id = m.id
      JOIN 
          types t ON m.types_id = t.id
      JOIN 
          couleur c ON m.couleur_id = c.id;
    '''
    );
  }

  Future<void> addColor({required String nom, required String code}) async {
    final db = await database;
    try {
      await db.insert("couleur", {"nom": nom, "code_couleur": code});
      print('Nom: $nom, Code couleur: $code ajouté avec succès');
    } catch (e) {
      throw Exception('Le nom ou code couleur existe déjà.');
    }
  }

  Future<List<Map<String, dynamic>>> readAllColor() async {
    final db = await database;
    final alldata = await db!.query("couleur");
    List<Map<String, dynamic>> colorList = [];
    for (var item in alldata) {
      colorList.add(Map<String, dynamic>.from(item));
    }
    return colorList;
  }

  Future<void> updateColor(
      {required int id, required String nom, required String code}) async {
    final db = await database;
    //print("tonga1");
    await db.update(
        "couleur", {"nom": nom, "code_couleur": code}, where: "id = ?",
        whereArgs: [id]);
    //print("tonga2.$code");
  }

  Future<void> deleteColor(int id) async {
    final db = await database;
    await db.delete("couleur", where: "id = ?", whereArgs: [id]);
  }

  Future<void> addTypes({required String nom}) async {
    final db = await database;
    try {
      await db.insert("types", {"nom": nom});
      print('Nom: $nom ajouté avec succès');
    } catch (e) {
      throw Exception('Le type "$nom" existe déjà.');
    }
  }

  Future deleteBe() async {
    final db = await database;
    await db.execute('Delete from couleur where id > 5');
  }

  Future<List<Map<String, dynamic>>> readAllTypes() async {
    final db = await database;
    final alldata = await db!.query("types");
    List<Map<String, dynamic>> TypesList = [];
    for (var item in alldata) {
      TypesList.add(Map<String, dynamic>.from(item));
    }
    return TypesList;
  }

  Future<void> updateType({required int id, required String nom}) async {
    final db = await database;
    await db.update("types", {"nom": nom}, where: "id = ?", whereArgs: [id]);
  }

  Future<void> deleteType(int id) async {
    final db = await database;
    await db!.delete(
      'types',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> addMatieriel({
    required String details,
    required int couleurId,
    required int typeId,
    required String imagePath,
  }) async {
    final db = await database;
    await db.insert(
      'materiel',
      {
        'details': details,
        'couleur_id': couleurId,
        'types_id': typeId,
        'image_path': imagePath,
      },
    );
  }

  Future<List<Map<String, dynamic>>> readAllMaterials() async {
    final db = await database;
    final List<Map<String, dynamic>> materials = await db.rawQuery(
        'SELECT * FROM materiel where types_id > 0 ORDER BY inserted DESC');
    return materials;
  }

  Future<void> deleteMateriel(int id) async {
    final db = await database;
    await db!.delete(
      'materiel',
      where: 'id = ?',
      whereArgs: [id],
    );
    print('ok');
  }

  Future<int> insertUtilisation(Map<String, dynamic> row) async {
    final db = await database;
    int id = await db.insert('Utilisation', row);
    print('Inserted row with ID: $id');
    print('Inserted data: $row');
    return id;
  }

  Future<List<Map<String, dynamic>>> readUtilisationMateriel() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
        'SELECT * FROM utilisation_materiel');

    if(result.isNotEmpty) {
      result.forEach((row) {
        print(row);
      });
    }else{
      print("TSISY");
    }
    return result;
  }

  Future<void> deleteUtilisationById(int id) async {
    final db = await database;
    await db!.delete(
      'utilisation',
      where: 'id = ?',
      whereArgs: [id],
    );
    print('ok');
  }

  Future<void> updateMaterial(Map<String, dynamic> material) async {
    final db = await database;
    await db.update("materiel", material, where: 'id = ?', whereArgs: [material['id']]);
  }
}