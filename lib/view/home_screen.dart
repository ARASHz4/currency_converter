import 'package:currency_converter/http/currency_http.dart';
import 'package:currency_converter/model/currency.dart';
import 'package:currency_converter/view/currencies_screen.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:digit_to_persian_word/digit_to_persian_word.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final formKey = GlobalKey<FormState>();
  TextEditingController fromCurrencyTextEditingController = TextEditingController(text: '0');

  Currency? fromCurrency;
  Currency? toCurrency;

  double? currencyValue;
  bool currencyValueLoading = false;

  String fromValueText = "";

  double? convertedCurrencyValue;
  String convertedCurrencyValueText = "";

  final numberFormat = intl.NumberFormat.currency(symbol: "")
  ..maximumFractionDigits = 12
  ..minimumFractionDigits = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Currency Converter"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              buildCurrencyValue(),
              Column(
                children: [
                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          title: const Text("From"),
                          trailing: Text(fromCurrency?.name ?? ""),
                          onTap: () async {
                            final response = await Navigator.push(context, MaterialPageRoute(builder: (context) => const CurrenciesScreen()));

                            if (response is Currency) {
                              if (fromCurrency?.symbol != response.symbol) {
                                setState(() {
                                  fromCurrency = response;
                                  currencyValue = null;
                                  convertedCurrencyValue = null;
                                });

                                if (fromCurrency != null && toCurrency != null) {
                                  getCurrencyValue();
                                }
                              }
                            }
                          },
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
                          child: TextFormField(
                            controller: fromCurrencyTextEditingController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              CurrencyTextInputFormatter(symbol: "", decimalDigits: 0)
                            ],
                            validator: (value) {
                              if (fromCurrency == null) {
                                return "Please Select Your Currency";
                              }

                              if (value?.isEmpty ?? true) {
                                return "Please Enter Your Value";
                              }

                              return null;
                            },
                            decoration: InputDecoration(
                              label: Text(fromCurrency?.name ?? ""),
                              suffix: Text(fromCurrency?.symbolNative ?? "", style: const TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            onChanged: (value) {
                              setState(() {
                                value = value.replaceAll(',', '');

                                //fromValueText = NumberToWordsEnglish.convert(int.tryParse(value) ?? 0);
                                fromValueText = DigitToWord.toWord(value, StrType.StrWord);

                                if (formKey.currentState!.validate()) {
                                  convertCurrency();
                                }
                              });
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 16),
                          child: Text("$fromValueText ${fromCurrency?.symbolNative ?? ""}"),
                        ),
                      ],
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20, bottom: 20),
                      child: IconButton(
                        onPressed: () {
                          final fromCurrencyBackup = fromCurrency;

                          setState(() {
                            currencyValue = null;
                            convertedCurrencyValue = null;

                            fromCurrency = toCurrency;
                            toCurrency = fromCurrencyBackup;
                          });

                          if (fromCurrency != null && toCurrency != null) {
                            getCurrencyValue();
                          }
                        },
                        icon: const RotatedBox(
                          quarterTurns: 1,
                          child: Icon(
                            Icons.compare_arrows,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          title: const Text("To"),
                          trailing: Text(toCurrency?.name ?? ""),
                          onTap: () async {
                            final response = await Navigator.push(context, MaterialPageRoute(builder: (context) => const CurrenciesScreen()));

                            if (response is Currency) {
                              if (toCurrency?.symbol != response.symbol) {
                                setState(() {
                                  toCurrency = response;
                                  currencyValue = null;
                                  convertedCurrencyValue = null;
                                });

                                if (fromCurrency != null && toCurrency != null) {
                                  getCurrencyValue();
                                }
                              }
                            }
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(convertedCurrencyValue != null ? numberFormat.format(convertedCurrencyValue!) : ""),
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 16),
                          child: Text("$convertedCurrencyValueText ${toCurrency?.symbolNative ?? ""}"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Widget buildCurrencyValue() {
    if (currencyValueLoading) {
      return const CircularProgressIndicator();
    }

    if (fromCurrency == null || toCurrency == null) {
      return const Text("Please select your currency");
    }

    if (currencyValue != null) {
      return Text("${numberFormat.format(1)} ${fromCurrency!.name} equal to ${numberFormat.format(currencyValue)} ${toCurrency!.name}");
    }

    return Container();
  }

  getCurrencyValue() async {
    setState(() {
      currencyValueLoading = true;
    });

    var response = await CurrencyHttp().getCurrencyValue(fromCurrency: fromCurrency!, toCurrency: toCurrency!);

    var value = response.item1;
    final error = response.item2;

    setState(() {
      currencyValueLoading = false;
    });

    if (error != null) {
      if (kDebugMode) {
        print("getCurrencyValue fail ${error.statusCode}");
      }

      return;
    }

    if (value == null) {
      if (kDebugMode) {
        print("getCurrencyValue fail unknown error");
      }

      return;
    }

    if (fromCurrency?.symbol == "IRT") {
      value = value * 10;
    }

    setState(() {
      currencyValue = value;
    });

    if (formKey.currentState!.validate()) {
      convertCurrency();
    }
  }

  convertCurrency() {
    if (currencyValue != null) {
      var fromCurrencyText = fromCurrencyTextEditingController.text;

      fromCurrencyText = fromCurrencyText.replaceAll(',', '');

      final from = double.tryParse(fromCurrencyText);
      if (from != null) {
        setState(() {
          convertedCurrencyValue = from * currencyValue!;
          convertedCurrencyValueText = DigitToWord.toWord(convertedCurrencyValue!.toInt().toString(), StrType.StrWord);
        });
      }
    }
  }
}
