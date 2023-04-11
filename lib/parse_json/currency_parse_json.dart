import 'dart:convert';
import 'package:currency_converter/model/currency.dart';
import 'package:flutter/foundation.dart';

class CurrencyParseJson {
  List<Currency>? currencies(String body) {
    try {
      final json = jsonDecode(body);

      List<Currency> currencies = [];

      if (json is Map) {
        final symbolsJson = json['symbols'];

        if (symbolsJson is Map) {
          symbolsJson.forEach((key, value) {
            currencies.add(
              Currency(
                code: key,
                name: value,
                flag: "",
                symbol: "",
                symbolNative: "",
              ),
            );
          });
        }
      }

      return currencies;
    } catch (ex) {
      if (kDebugMode) {
        print(ex);
      }
    }

    return null;
  }

  double? currencyValue(String body) {
    try {
      final json = jsonDecode(body);

      double? value;

      if (json is Map) {
        final ratesJson = json['rates'];
        if (ratesJson is Map) {
          value = ratesJson.values.first;
        }
      }

      return value;
    } catch (ex) {
      if (kDebugMode) {
        print(ex);
      }
    }

    return null;
  }
}