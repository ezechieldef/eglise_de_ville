import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive_io.dart';
import 'package:eglise_de_ville/contantes.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:convert';
// import 'package:path_provider/path_provider.dart';

Future<String> decompresser_bible_db() async {
  var old_file = await DefaultCacheManager().getFileFromCache("bible_sql.sql");
  if (old_file != null && await old_file.file.exists()) {
    return old_file.file.path;
  }
// dupliquer(list)
  ByteData data = await rootBundle.load("assets/bible_sql.zip");
  List<int> bytes =
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  Uint8List bytes_bible_sql = Uint8List(0);

  final archive = ZipDecoder().decodeBytes(bytes);

  if (archive.files.isNotEmpty) {
    var filee = archive.files[0];

    var dest_file = await DefaultCacheManager().putFile(
        "bible_sql", Uint8List(0),
        maxAge: Duration(days: 365 * 10),
        fileExtension: "sql",
        key: "bible_sql.sql",
        eTag: "bible_sql.sql");

    bytes_bible_sql = filee.content;
    final outputStream = OutputFileStream(dest_file.path);
    filee.writeContent(outputStream);
    outputStream.close();
    return dest_file.path;
  }

  return "";
}

Future<Database> executer_transact_sql() async {
  var db = await openDatabase('bibles_edv.db', version: 10,
      onCreate: (Database db, version) async {
    var sql_file_path = await decompresser_bible_db();
    var sql = await File(sql_file_path).readAsString();
    print("hiji upgrade exec ");
    db.transaction((txn) async {
      for (var item in sql.split("dddeeefff")) {
        txn.execute(item);
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
  return db;
}
