import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import '../models/http_exception.dart';

class Auth with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId;

  void _setToken(token) {
    print(token);
    _token = token;
  }

  void _setExpiryDate(String expiryDate) {
    _expiryDate = DateTime.now().add(
      Duration(
        seconds: int.parse(expiryDate),
      ),
    );
  }

  bool get isAuth {
    return token != null;
  }

  String get token {
    if (_expiryDate != null &&
        _expiryDate.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  Future<void> _authenticate(
      String email, String password, String urlSegment) async {
    final url =
        "https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyA-y6aSjVFo-u4epqL9rYTKxZpnIj2qYQY";
    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'email': email,
            'password': password,
            'returnSecureToken': true,
          },
        ),
      );

      final responseData = json.decode(response.body);

      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }

      _setToken(responseData['idToken']);
      _setExpiryDate(responseData['expiresIn']);
      _userId = responseData['localId'];
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> signup(String email, String password) async {
    return _authenticate(email, password, 'signUp');
  }

  Future<void> signin(String email, String password) async {
    return _authenticate(email, password, 'signInWithPassword');
    // final url =
    //     "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=AIzaSyA-y6aSjVFo-u4epqL9rYTKxZpnIj2qYQY";
    // try {
    //   final response = await http.post(
    //     url,
    //     body: json.encode(
    //       {
    //         'email': email,
    //         'password': password,
    //         'returnSecureToken': true,
    //       },
    //     ),
    //   );

    //   //set token
    //   final decodedResponseBody =
    //       json.decode(response.body) as Map<String, dynamic>;
    //   _setToken(decodedResponseBody['idToken']);

    //   print(
    //     json.decode(response.body),
    //   );
    // } catch (error) {
    //   throw error;
    // }
  }
}
