import 'dart:io';
import 'package:currency_converter/http/http_error.dart';
import 'package:currency_converter/model/currency.dart';
import 'package:currency_converter/parse_json/currency_parse_json.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:tuple/tuple.dart';

class CurrencyHttp {
  final _fixerApiKey = 'ntOx6OLFWQ6Iy6AYKnI9beFTLaPrw6fe';

  final _parseJson = CurrencyParseJson();

  getCurrencies() async {
    final url = Uri.https(
      'api.apilayer.com',
      'fixer/symbols',
    );

    try {
      final response = await http.get(
        url,
        headers: {
          'apikey': _fixerApiKey,
        },
      );

      print('Response status: ${response.statusCode}');

      if (response.statusCode == HttpStatus.ok) {
        final currencies = _parseJson.currencies(response.body);

        print(currencies?.length);
      }
    } catch (ex) {
      if (kDebugMode) {
        print(ex);
      }
    }
  }

  Future<Tuple2<double?, HttpError?>> getCurrencyValue({required Currency fromCurrency, required Currency toCurrency}) async {
    final url = Uri.https(
      'api.apilayer.com',
      'fixer/latest',
      {
        'base': fromCurrency.code,
        'symbols': toCurrency.code
      },
    );

    try {
      final response = await http.get(
        url,
        headers: {
          'apikey': _fixerApiKey,
        },
      );

      if (response.statusCode == HttpStatus.ok) {
        final currencyValue = _parseJson.currencyValue(response.body);

        if (currencyValue != null) {
          return Tuple2(currencyValue, null);
        }

        return Tuple2(null, HttpError(statusCode: 1001, message: ""));
      }
      else {
        return Tuple2(null, HttpError(statusCode: response.statusCode, message: response.body));
      }
    } catch (ex) {
      if (kDebugMode) {
        print(ex);
      }

      return Tuple2(null, HttpError(statusCode: 1000, message: ""));
    }
  }
}