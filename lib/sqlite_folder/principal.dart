import 'dart:io';

import 'package:eglise_de_ville/contantes.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io' as io;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'extraction.dart';

List<String> oncreate_str = [
  "DROP TABLE IF EXISTS Enseignement;",
  "CREATE TABLE Enseignement (id INTEGER,Titre TEXT,Verset TEXT,Contenu TEXT,Date TEXT,PRIMARY KEY (id AUTOINCREMENT) );",
  "DROP TABLE IF EXISTS Gallery;",
  "CREATE TABLE Gallery (id INTEGER,Lien TEXT,Description TEXT DEFAULT '-',Date TEXT,PRIMARY KEY (id AUTOINCREMENT)) ;",
  "DROP TABLE IF EXISTS Lyrics;",
  "CREATE TABLE Lyrics (id INTEGER ,Titre TEXT,Audio TEXT DEFAULT '',Contenu TEXT,Date TEXT NOT NULL ,PRIMARY KEY (id AUTOINCREMENT)) ;",
  "DROP TABLE IF EXISTS Programme;",
  "CREATE TABLE Programme (id INTEGER ,Titre TEXT,Description TEXT,Date TEXT NOT NULL,Heure_Debut TEXT NOT NULL,Heure_Fin TEXT NOT NULL,Repetition varchar(50)  NOT NULL,Personne_Cible varchar(100)  NOT NULL DEFAULT 'TOUS',PRIMARY KEY (id AUTOINCREMENT)) ;",
  "DROP TABLE IF EXISTS Vision;",
  "CREATE TABLE Vision (id INTEGER ,Contenu TEXT ,Date TEXT,PRIMARY KEY (id AUTOINCREMENT)) ;",
  "DROP TABLE IF EXISTS execution;",
  "CREATE TABLE execution (id INTEGER, Date TEXT, PRIMARY KEY(id AUTOINCREMENT) );",
  "DROP TABLE IF EXISTS Downloaded_Bible;",
  "CREATE TABLE Downloaded_Bible (id INTEGER, Titre TEXT,Chemin TEXT, PRIMARY KEY(id AUTOINCREMENT) );",
  "DROP TABLE IF EXISTS composer_quiz;",
  "CREATE TABLE composer_quiz (id INTEGER, Note INTEGER ,quiz_id INTEGER, user_id INTEGER, Details TEXT, Avis TEXT,Date TEXT DEFAULT 'NULL', PRIMARY KEY(id AUTOINCREMENT) );",
  "DROP TABLE IF EXISTS chapitre_lu;",
  "CREATE TABLE chapitre_lu (id INTEGER, id_chapitre INTEGER, Date TEXT DEFAULT 'NULL', PRIMARY KEY(id AUTOINCREMENT) );",
  "DROP TABLE IF EXISTS users;",
  "CREATE TABLE users ( id TEXT , nom TEXT , email TEXT,photo TEXT DEFAULT '', password TEXT, PRIMARY KEY (id) ) ;",
  "DROP TABLE IF EXISTS Cours",
  "CREATE TABLE Cours ( id INTEGER , Titre TEXT , Description text , Image TEXT , Durée INTEGER NOT NULL, Durée_repos INTEGER NOT NULL, Date TEXT , PRIMARY KEY (id AUTOINCREMENT)) ",
  "DROP TABLE IF EXISTS Chapitre",
  "CREATE TABLE Chapitre (id INTEGER , id_cours INTEGER , num_chapitre INTEGER , Titre TEXT  , Contenu text  , Date TEXT, PRIMARY KEY (id AUTOINCREMENT) ) ; ",
  "DROP TABLE IF EXISTS Dimes",
  "CREATE TABLE Dimes(id INTEGER, Date TEXT, Motif TEXT,Montant INTEGER, status TEXT, PRIMARY KEY (id AUTOINCREMENT))",
  "DROP TABLE IF EXISTS dimes_payer",
  "CREATE TABLE dimes_payer(id INTEGER, user_id TEXT, id_transaction TEXT,Montant INTEGER, Date TEXT,  Archiver TEXT, PRIMARY KEY (id AUTOINCREMENT))",
];
List<String> table_list = [
  "Enseignement",
  "Gallery",
  "Lyrics",
  "Programme",
  "Vision",
  "execution",
  "composer_quiz",
  "chapitre_lu",
  "users",
  "cours",
  "dimes",
  "dimes_payer"
];
Database? db_glob;
Database? db_glob_bible;

Future<Database> ouvrirDB() async {
  if (db_glob != null) {
    if (db_glob!.isOpen) {
      // print("sqlite database path " + db_glob!.path);
      // File f1 = File(db_glob!.path);
      // f1.copySync("/storage/sdcard/" + db_glob!.path.split("/").last);
      return db_glob!;
    }
  }

  var db =
      await openDatabase('my_db.db', version: 10, onOpen: (Database db) async {
    try {
      for (var item in table_list) {
        await db.rawQuery(" SELECT * FROM $item");
      }
    } catch (e) {
      for (var item in oncreate_str) {
        await db.rawQuery(item);
      }
    }
  }, onCreate: (Database db, version) async {
    for (var item in oncreate_str) {
      await db.rawQuery(item);
    }
  }, onUpgrade: (Database db, int olld, int neww) async {
    print("upgrade db");
    for (var item in oncreate_str) {
      await db.rawQuery(item);
    }
  });
  db_glob = db;
  // print("sqlite database path " + db.path);

  return db;
}

Future<Database> ouvrirDB_bible() async {
  if (db_glob_bible != null) {
    if (db_glob_bible!.isOpen) {
      // print("sqlite database path " + db_glob!.path);
      // File f1 = File(db_glob!.path);
      // f1.copySync("/storage/sdcard/" + db_glob!.path.split("/").last);
      return db_glob_bible!;
    }
  }
  var db = await openDatabase('bibles_edv.db', version: 12,
      onCreate: (Database db, version) async {
    var sql_file_path = await decompresser_bible_db();
    var sql = await File(sql_file_path).readAsString();
    print("hiji upgrade exec ");
    db.transaction((txn) async {
      for (var item in sql.split("dddeeefff")) {
        txn.execute(item);
        print("grecu execution");
      }
    });
  }, onUpgrade: (db, old, new_v) async {
    var sql_file_path = await decompresser_bible_db();
    var sql = await File(sql_file_path).readAsString();
    print("hiji upgrade exec ");
    db.transaction((txn) async {
      print('hiji longueur ' + sql.length.toString());
      for (var item in sql.split("dddeeefff")) {
        txn.execute(item);
      }
    });
  });

  db_glob_bible = db;
  // print("sqlite database path " + db.path);

  return db;
}

Future<void> inserer_local(String table, Map<String, dynamic> data) async {
  var db = await ouvrirDB();
  Map<String, dynamic>? t = purger_int_map(data);

  await db.insert(table, t, conflictAlgorithm: ConflictAlgorithm.replace);

  // print("sqlite inserer succes $table id=" + t["id"].toString());
}

Future<void> raw_query_local(String query) async {
  var db = await ouvrirDB();

  await db.rawQuery(query);
}

Future<void> inserer_local_list(
    String table, List<Map<String, dynamic>> list_data) async {
  for (var data in list_data) {
    await inserer_local(table, data);
  }
}

Future<List<Map<String, dynamic>>> select_local_sqlite(
    String query, List<dynamic> params) async {
  var db = await ouvrirDB();
  var t = await db.rawQuery(query);
  return t;
}

Future<List<Map<String, dynamic>>> select_local_sqlite_bible(
    String query, List<dynamic> params) async {
  var db = await ouvrirDB_bible();
  var t = await db.rawQuery(query, params);
  return t;
}

Future<void> preparerCustomisation() async {
  var rep = await select_local_sqlite_bible("""
CREATE TABLE IF NOT EXISTS "Customisation" (
	"Livre"	INTEGER,
	"Chapitre"	INTEGER,
	"Verset"	INTEGER,
	"Cle"	TEXT,
	"Valeur"	TEXT,
	UNIQUE("Livre","Chapitre","Verset","Cle")
);
""", []);
}

bool compare_list_diff(List<dynamic> l1, List<dynamic> l2) {
  if (l1.length != l2.length) {
    return false;
  }

  if (l1.toString() != l2.toString()) {
    return false;
  }
  return true;
}

List<dynamic> get_difference(List<dynamic> l1, List<dynamic> newl) {
  List<dynamic> diff = [];
  var l1str = l1.map((e) => e.toString()).toList();
  // var l2str = newl.map((e) => e.toString()).toList();
  // for (var i = 0; i < l1.length; i++) {
  //   if (!l2str.contains(l1[i].toString())) {
  //     diff.add(l1[i]);
  //   }
  // }
  // print("difference1 $l1");
  // print("difference2 $newl");
  for (var i = 0; i < newl.length; i++) {
    if (!l1str.contains(newl[i].toString())) {
      diff.add(newl[i]);
      // print("difference3 trouvé " + newl[i].toString());
    }
  }
  return diff;
}
