import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

// Definição dos nomes das colunas
final String contactTable = "contactTable";
final String idColumn = "idColumn";
final String nameColumn = "nameColumn";
final String emailColumn = "emailColumn";
final String phoneColumn = "phoneColumn";
final String imgColumn = "imgColumn";

class ContactHelper {
  // Singleton para garantir que só exista uma instância de ContactHelper
  static final ContactHelper _instance = ContactHelper.internal();

  factory ContactHelper() => _instance;

  ContactHelper.internal();

  // O banco de dados deve ser nullable, pois pode não estar inicializado
  Database? _db;

  Future<Database> get db async {
    // Verifica se o banco de dados já foi inicializado
    if (_db != null) {
      return _db!;
    } else {
      _db = await initDb();
      return _db!;
    }
  }

  // Inicializa o banco de dados
  Future<Database> initDb() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, "contactsnew.db");

    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int newerVersion) async {
        await db.execute(
          "CREATE TABLE $contactTable("
              "$idColumn INTEGER PRIMARY KEY, "
              "$nameColumn TEXT, "
              "$emailColumn TEXT, "
              "$phoneColumn TEXT, "
              "$imgColumn TEXT)",
        );
      },
    );
  }

  // Salva um contato no banco de dados
  Future<Contact> saveContact(Contact contact) async {
    Database dbContact = await db;
    contact.id = await dbContact.insert(contactTable, contact.toMap());
    return contact;
  }

  // Obtém um contato específico pelo id
  Future<Contact?> getContact(int id) async {
    Database dbContact = await db;
    List<Map<String, dynamic>> maps = await dbContact.query(
      contactTable,
      columns: [idColumn, nameColumn, emailColumn, phoneColumn, imgColumn],
      where: "$idColumn = ?",
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Contact.fromMap(maps.first);
    } else {
      return null;
    }
  }

  // Deleta um contato do banco de dados
  Future<int> deleteContact(int id) async {
    Database dbContact = await db;
    return await dbContact.delete(
      contactTable,
      where: "$idColumn = ?",
      whereArgs: [id],
    );
  }

  // Atualiza um contato existente
  Future<int> updateContact(Contact contact) async {
    Database dbContact = await db;
    return await dbContact.update(
      contactTable,
      contact.toMap(),
      where: "$idColumn = ?",
      whereArgs: [contact.id],
    );
  }

  // Retorna todos os contatos
  Future<List<Contact>> getAllContacts() async {
    Database dbContact = await db;
    List<Map<String, dynamic>> listMap = await dbContact.rawQuery("SELECT * FROM $contactTable");
    List<Contact> listContact = listMap.map((map) => Contact.fromMap(map)).toList();
    return listContact;
  }

  // Retorna o número de contatos no banco de dados
  Future<int?> getNumber() async {
    Database dbContact = await db;
    return Sqflite.firstIntValue(await dbContact.rawQuery("SELECT COUNT(*) FROM $contactTable"));
  }

  // Fecha o banco de dados
  Future<void> close() async {
    Database dbContact = await db;
    dbContact.close();
  }
}

// Classe modelo de contato
class Contact {
  int? id; // O id é opcional, pois pode não estar definido ao criar um novo contato
  String? name;
  String? email;
  String? phone;
  String? img;

  Contact();

  // Construtor que cria um objeto Contact a partir de um Map
  Contact.fromMap(Map<String, dynamic> map) {
    id = map[idColumn];
    name = map[nameColumn];
    email = map[emailColumn];
    phone = map[phoneColumn];
    img = map[imgColumn];
  }

  // Método que converte um objeto Contact em um Map
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      nameColumn: name,
      emailColumn: email,
      phoneColumn: phone,
      imgColumn: img,
    };
    if (id != null) {
      map[idColumn] = id;
    }
    return map;
  }

  @override
  String toString() {
    return "Contact(id: $id, name: $name, email: $email, phone: $phone, img: $img)";
  }
}
