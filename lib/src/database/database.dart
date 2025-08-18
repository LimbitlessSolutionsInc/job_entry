import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_database/firebase_database.dart';

class Database {
  static String _getDatabaseName(String dataBase){
    return dataBase != ''?'-$dataBase':'';
  }
  static Future<bool> updateCheck(String dataBase,{required String children, required String location, dynamic data}) async{
    FirebaseApp team = Firebase.app();
    String fixedName = _getDatabaseName(dataBase);
    DatabaseReference ref = FirebaseDatabase.instanceFor(
      app: team, 
      databaseURL: 'https://limbitless-solutions$fixedName.firebaseio.com/'
    ).ref();

    try{
      await ref.child(children).update({location: data});
      return true;
    }
    catch(e){
      print('database.dart -> update -> Exception $e');
      return false;
    }
  }
  static Future<void> update(String dataBase,{required String children, required String location, dynamic data}) async{
    try{
      FirebaseApp team = Firebase.app();
      String fixedName = _getDatabaseName(dataBase);
      await FirebaseDatabase.instanceFor(
        app: team, 
        databaseURL: 'https://limbitless-solutions$fixedName.firebaseio.com/'
      ).ref().child(children).update({location: data});
    }
    catch(e){
      print('database.dart -> update() -> Exception: $e');
    }
  }
  static Future<String> getLastKey (String dataBase, String children) async {
    FirebaseApp team = Firebase.app();
    String fixedName = _getDatabaseName(dataBase);
    DatabaseReference ref = FirebaseDatabase.instanceFor(
      app: team, 
      databaseURL: 'https://limbitless-solutions$fixedName.firebaseio.com/'
    ).ref();

    try{
      DataSnapshot val = await ref.child(children).get();
      if(val.exists){
        return val.key!;
      }
      else{
        print('database.dart -> getLastKey($children) -> Snapshot does not exist'); 
        return '';
      }
    }
    catch(e){
      print('database.dart -> getLastKey($children) -> Exception $e');
      return '';
    }
  }
  static Future<void> push(String dataBase, {required String children, dynamic data}) async{
    FirebaseApp team = Firebase.app();
    String fixedName = _getDatabaseName(dataBase);
    await FirebaseDatabase.instanceFor(
      app: team, 
      databaseURL: 'https://limbitless-solutions$fixedName.firebaseio.com/'
    ).ref().child(children).push().set(data);
  }
  static Future<dynamic> once(String children,String dataBase) async {
    FirebaseApp team = Firebase.app();
    String fixedName = _getDatabaseName(dataBase);
    DatabaseReference ref = FirebaseDatabase.instanceFor(
      app: team, 
      databaseURL: 'https://limbitless-solutions$fixedName.firebaseio.com/'
    ).ref();

    try{
      DatabaseEvent val = await ref.child(children).once();
      if(val.snapshot.exists){
        return val.snapshot.value;
      }
      else{
        print('database.dart -> once($children) -> Snapshot does not exist'); 
        return {};
      }
    }
    catch(e){
      print('database.dart -> once($children) -> Exception $e');
      return {};
    }
  }
  static Future<dynamic> get(String children,String dataBase) async {
    FirebaseApp team = Firebase.app();
    String fixedName = _getDatabaseName(dataBase);
    DatabaseReference ref = FirebaseDatabase.instanceFor(
      app: team, 
      databaseURL: 'https://limbitless-solutions$fixedName.firebaseio.com/'
    ).ref();
    try{
      DataSnapshot val = await ref.child(children).get();
      if(val.exists){
        return val.value;
      }
      else{ 
        print('database.dart -> get($children) -> Snapshot does not exist'); 
        return {};
      }
    }
    catch(e){
      print('database.dart -> get($children) -> Exception $e');
      return {};
    }
  }
  static Stream<DatabaseEvent> onValue(String children,String dataBase) {
    FirebaseApp team = Firebase.app();
    String fixedName = _getDatabaseName(dataBase);
    return FirebaseDatabase.instanceFor(
      app: team, 
      databaseURL: 'https://limbitless-solutions$fixedName.firebaseio.com/'
    ).ref(children).onValue;
  }
  static DatabaseReference reference(String child, String dataBase) {
    FirebaseApp team = Firebase.app();
    String fixedName = _getDatabaseName(dataBase);
    return FirebaseDatabase.instanceFor(
      app: team, 
      databaseURL: 'https://limbitless-solutions$fixedName.firebaseio.com/'
    ).ref().child(child);
  }
  static String? getKey(String child, String dataBase){
    FirebaseApp team = Firebase.app();
    String fixedName = _getDatabaseName(dataBase);
    return FirebaseDatabase.instanceFor(
      app: team, 
      databaseURL: 'https://limbitless-solutions$fixedName.firebaseio.com/'
    ).ref().child(child).push().key;
  }
  static Future<http.Response> sendToLSI(String url,dynamic data) {
    String info = jsonEncode(data);
    return http.post(Uri.parse(url), body: info);
  }
  static Future<http.Response?> post(String url,dynamic payload,{String type = 'text/json'}) async{
    Map<String, String> requestHeaders = {
      'Content-type': type,
      'Accept': type,
      "Access-Control-Allow-Methods": "POST",
      "Access-Control-Allow-Headers": "Origin, X-Requested-With, Content-Type, Accept",
      'Access-Control-Allow-Origin': '*',
      "Access-Control-Allow-Credentials": "true",
    };

    try{
      print('FCM request for device sent!');
      return await http.post(
        Uri.parse(url), 
        body: payload,
        //headers: requestHeaders
      );
      
    } catch (e) {
      print(e);
    }
  }
}

class TrialsNoteData{
  TrialsNoteData({
    required this.title,
    required this.text,
    this.respond = 'gotoPage',
    this.type = 'report',
    this.screen = 'devices'
  });

  String respond;
  String type;
  String text;
  String title;
  String screen;

  Map<String,dynamic> get toMap => {
    'text': text,
    'viewed': false,
    'type': type,
    'title': title,
    'respond': respond,
    'screen': screen,
    'date': DateTime.now().toString()
  };
}

class Storage{
  static String? _getDatabaseName(String dataBase){
    return dataBase != ''?'gs://limbitless-solutions-$dataBase':null;
  }
  static Future<Uint8List?> downloadBytesFromUrl(String url, String bucket) async {
    FirebaseApp team = Firebase.app();
    String? fixedName = _getDatabaseName(bucket);
    Reference ref = FirebaseStorage.instanceFor(app: team, bucket: fixedName).refFromURL(url);
    return await ref.getData();
  }
  static Future<Uint8List?> downloadBytesFromPath(String path, String bucket) async {
    FirebaseApp team = Firebase.app();
    String? fixedName = _getDatabaseName(bucket);
    Reference ref = FirebaseStorage.instanceFor(app: team, bucket: fixedName).ref();//.refFromURL(url);
    return await ref.getData();
  }
  static Future<void> deleteFile(String url, String bucket) async {
    FirebaseApp team = Firebase.app();
    String? fixedName = _getDatabaseName(bucket);
    Reference ref = FirebaseStorage.instanceFor(app: team,bucket: fixedName).refFromURL(url);
    try{
      await ref.delete();
    }catch(e){
      print(e);
    }
  }
  
  static Future<String> get localPath async{
    Directory? dir;
    dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }
  Future<File> get localFile async{
    final path = await localPath;
    return File('$path/db.txt');
  }
  Future<String> readData() async{
    try{
      final file = await localFile;
      String body = await file.readAsString();
      return body;
    }
    catch(e){
      return e.toString();
    }
  }
  static Future<String> getDownloadURL({
    required String child, 
    required String fileName,
    required String bucket
  }) async{
    FirebaseApp team = Firebase.app();
    String? fixedName = _getDatabaseName(bucket);
    final Reference firebaseStorageRef = FirebaseStorage.instanceFor(app: team,bucket: fixedName).ref().child(child).child(fileName);
    return await firebaseStorageRef.getDownloadURL();
  }

  static Future<String> storeDataFile({
    required String child, 
    required String contentType, 
    required Uint8List file,
    required String fileName,
    required String bucket
  }) async{
    FirebaseApp team = Firebase.app();
    String? fixedName = _getDatabaseName(bucket);
    final Reference firebaseStorageRef = FirebaseStorage.instanceFor(app: team,bucket: fixedName).ref().child(child).child(fileName);

    final metadata = SettableMetadata(
      contentType: contentType
    );

    UploadTask task = firebaseStorageRef.putData(file, metadata);

    String? url;
    await task.whenComplete(() async{
      url = await firebaseStorageRef.getDownloadURL();
    });
    return url!;
  }
  static Future<String> storeStringFile({
    required String child, 
    required String contentType, 
    required String file,
    required String fileName,
    required String bucket,
    PutStringFormat format = PutStringFormat.raw
  }) async{
    FirebaseApp team = Firebase.app();
    String? fixedName = _getDatabaseName(bucket);
    final Reference firebaseStorageRef = FirebaseStorage.instanceFor(app: team,bucket: fixedName).ref().child(child).child(fileName);

    final metadata = SettableMetadata(
      contentType: contentType
    );

    UploadTask task = firebaseStorageRef.putString(file, format:format, metadata: metadata);

    String? url;
    await task.whenComplete(() async{
      url = await firebaseStorageRef.getDownloadURL();
    });

    return url!;
  }
}