import 'dart:async';
import 'dart:isolate';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Isolate Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const IsolateExample(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class IsolateExample extends StatefulWidget {
  const IsolateExample({super.key});

  @override
  _IsolateExampleState createState() => _IsolateExampleState();
}

class _IsolateExampleState extends State<IsolateExample> {
  String _sum = "Tính tổng!";
  String _factorial = "Tính giai thừa!";
  bool _isCalculatingSum = false;
  bool _isCalculatingFactorial = false;

  Future _calculateFactorialInIsolate() async {
    setState(() {
      _isCalculatingFactorial = true;
    });

    final receivePort = ReceivePort();

    await Isolate.spawn(_calculateFactorial, receivePort.sendPort);

    receivePort.listen((data) {
      setState(() {
        _factorial = "Giai thừa là: $data";
        _isCalculatingFactorial = false;
      });
      receivePort.close(); 
    });
  }

  static void _calculateFactorial(SendPort sendPort) {
    double factorial = 1;
    for (int i = 1; i <= 40; i++) {
      factorial *= i;
    }
    sendPort.send(factorial); 
  }

  Future<void> _calculateSumInIsolate() async {
    setState(() {
      _isCalculatingSum = true;
    });

    final receivePort = ReceivePort();

    await Isolate.spawn(_calculateSum, receivePort.sendPort);

    receivePort.listen((data) {
      setState(() {
        _sum = "Tổng là: $data";
        _isCalculatingSum = false;
      });
      receivePort.close(); 
    });
  }

  static void _calculateSum(SendPort sendPort) {
    int sum = 0;
    for (int i = 1; i <= 10000000; i++) {
      sum += i;
    }
    sendPort.send(sum); // Gửi kết quả trở lại
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Isolate Demo"), 
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(_sum),
            Text(_factorial),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isCalculatingSum && _isCalculatingFactorial ? null : () {
                _calculateSumInIsolate();
                _calculateFactorialInIsolate();
              },
              child: Text(_isCalculatingSum ? "Đang tính..." : "Tính tổng 1000000 số đầu và giai thừa 40!"),
            ),
          ],
        ),
      ),
    );
  }
}
