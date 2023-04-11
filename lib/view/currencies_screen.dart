import 'dart:convert';
import 'package:currency_converter/model/currency.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CurrenciesScreen extends StatefulWidget {
  const CurrenciesScreen({Key? key}) : super(key: key);

  @override
  State<CurrenciesScreen> createState() => _CurrenciesScreenState();
}

class _CurrenciesScreenState extends State<CurrenciesScreen> {
  bool loading = true;

  List<Currency> currencies = [];

  @override
  void initState() {
    loadCurrencies();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select Currency")),
      body: !loading ? ListView.builder(
        itemCount: currencies.length,
        itemBuilder: (context, index) {
          final currency = currencies[index];

          return ListTile(
            title: Text(currency.code, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(currency.name),
            leading: Text(currency.flag, style: const TextStyle(fontSize: 28)),
            trailing: Text(currency.symbolNative, style: const TextStyle(fontWeight: FontWeight.bold)),
            onTap: () {
              Navigator.pop(context, currency);
            },
          );
        },
      ) : const Center(child: CircularProgressIndicator()),
    );
  }

  loadCurrencies() async {
    final currenciesJsonFile = await rootBundle.loadString('assets/currencies.json');

    final currenciesJson = jsonDecode(currenciesJsonFile);

    List<Currency> currencies = [];

    if (currenciesJson is List) {
      for (final currencyJson in currenciesJson) {
        currencies.add(
          Currency(
            code: currencyJson["code"],
            name: currencyJson["name"],
            symbol: currencyJson["symbol"],
            symbolNative: currencyJson["symbolNative"],
            flag: currencyJson["flag"],
          ),
        );
      }
    }

    print(currencies.length);

    setState(() {
      this.currencies = currencies;
      loading = false;
    });
  }
}
