import 'dart:convert';
import 'dart:io';
import 'package:ev_chargers/models/credit_card.dart';
import 'package:http/io_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helper.dart';

class User {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final double accountBalance;

  User(this.id, this.firstName, this.lastName, this.email, this.password,
      this.accountBalance);

  static Future<String> register(
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
      var userData = jsonDecode(response.body);
      user = User(userData['id'], userData['firstName'], userData['lastName'],
          userData['email'], userData['password'], 0.0);
      return jsonDecode(response.body)["id"];
    } else {
      return "";
    }
  }

  static Future<bool> registerCard(String? userId, CreditCard card) async {
    bool trustSelfSigned = true;
    HttpClient httpClient = HttpClient()
      ..badCertificateCallback =
          ((X509Certificate cert, String host, int port) => trustSelfSigned);
    IOClient ioClient = IOClient(httpClient);

    var response = await ioClient.put(
      Uri.parse('$url/user/bankCard'),
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

  static Future getPersonalInformations(String? userId) async {
    bool trustSelfSigned = true;
    HttpClient httpClient = HttpClient()
      ..badCertificateCallback =
          ((X509Certificate cert, String host, int port) => trustSelfSigned);
    IOClient ioClient = IOClient(httpClient);

    var response = await ioClient.get(
      Uri.parse('$url/user/getbyId?id=$userId'),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
      },
    );
    var userData = jsonDecode(response.body);
    user = User(userData['id'], userData['firstName'], userData['lastName'],
        userData['email'], userData['password'], userData['accountBalance']);
  }

  static Future<String> logIn(String email, String password) async {
    bool trustSelfSigned = true;
    HttpClient httpClient = HttpClient()
      ..badCertificateCallback =
          ((X509Certificate cert, String host, int port) => trustSelfSigned);
    IOClient ioClient = IOClient(httpClient);

    var response = await ioClient.get(
      Uri.parse('$url/user/login?email=$email&password=$password'),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
      },
    );
    if (response.statusCode == 200) {
      var userData = jsonDecode(response.body);
      user = User(userData['id'], userData['firstName'], userData['lastName'],
          userData['email'], userData['password'], 0.0);
      return jsonDecode(response.body)["id"];
    } else {
      return "";
    }
  }

  static Future<bool> addCash(String? userId, int? value) async {
    bool trustSelfSigned = true;
    HttpClient httpClient = HttpClient()
      ..badCertificateCallback =
          ((X509Certificate cert, String host, int port) => trustSelfSigned);
    IOClient ioClient = IOClient(httpClient);

    var response = await ioClient.put(
      Uri.parse('$url/addCash?id=$userId&amount=$value'),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
      },
    );
    return response.statusCode == 200;
  }

  static void payForCharging(double progress) {}
}
