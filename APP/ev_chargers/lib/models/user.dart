import 'dart:convert';
import 'dart:io';

import 'package:ev_chargers/models/credit_card.dart';
import 'package:http/io_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class User {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  static const url = 'https://localhost:7222/api';

  User(this.firstName, this.lastName, this.email, this.password);

  static Future<int> register(
      String firstName, String lastname, String email, String password) async {
    bool trustSelfSigned = true;
    HttpClient httpClient = HttpClient()
      ..badCertificateCallback =
          ((X509Certificate cert, String host, int port) => trustSelfSigned);
    IOClient ioClient = IOClient(httpClient);

    var response = await ioClient.post(
      Uri.parse('$url/user'),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
      },
      body: json.encode(
        {
          'firstName': firstName,
          'lastName': lastname,
          'email': email,
          'password': password
        },
      ),
    );
    if (response.statusCode == 200) {
      print(jsonDecode(response.body));
      return jsonDecode(response.body)["Id"];
    } else {
      return -1;
    }
  }

  static Future<bool> registerCard(int? userId, CreditCard card) async {
    bool trustSelfSigned = true;
    HttpClient httpClient = HttpClient()
      ..badCertificateCallback =
          ((X509Certificate cert, String host, int port) => trustSelfSigned);
    IOClient ioClient = IOClient(httpClient);

    var response = await ioClient.put(
      Uri.parse('$url/bankCard'),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
      },
      body: json.encode(
        {
          'userId': userId,
          'cardNumber': card.cardNumber,
          'expiryDate': card.expiryDate,
          'cvvCode': card.cvvCode,
          'cardHolderName': card.cardHolderName
        },
      ),
    );
    return response.statusCode == 200;
  }

  static Future<bool> updatePassword(String password) async {
    bool trustSelfSigned = true;
    HttpClient httpClient = HttpClient()
      ..badCertificateCallback =
          ((X509Certificate cert, String host, int port) => trustSelfSigned);
    IOClient ioClient = IOClient(httpClient);

    var response = await ioClient.put(
      Uri.parse('$url/password'),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
      },
      body: json.encode(
        {'password': password},
      ),
    );
    return response.statusCode == 200;
  }

  static logOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("loggedIn");
  }
}
