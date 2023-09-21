import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';


void main() => runApp(MyApp());

class CurrencyConverterCubit extends Cubit<double> {
  CurrencyConverterCubit() : super(0.0);

  void convertCurrency(double amount) async {
    final response = await http
        .get(Uri.parse('https://api.exchangerate-api.com/v4/latest/USD'));
    final data = json.decode(response.body);
    final exchangeRate = data['rates']['THB'];
    final convertedAmount = amount * exchangeRate;
    emit(convertedAmount);
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Exchangerate',
      theme: ThemeData(
        primarySwatch: Colors.grey,
        fontFamily: 'Roboto', 
      ),
      home: BlocProvider(
        create: (context) => CurrencyConverterCubit(),
        child: MyHomePage(),
      ),
    );
  }
}


class MyHomePage extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final cubit = BlocProvider.of<CurrencyConverterCubit>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Exchangerate'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white10, Colors.white],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Exchange Rate USD',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 10),
              Container(
                width: 150,
                child: TextField(
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Dollar',
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  final amount = double.tryParse(_controller.text) ?? 0.0;
                  cubit.convertCurrency(amount);
                },
                child: Text('Exchange'),
              ),
              SizedBox(height: 20),
              BlocBuilder<CurrencyConverterCubit, double>(
                builder: (context, state) {
                  return Text(
                    'Exchange Rate to: THB${state.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
