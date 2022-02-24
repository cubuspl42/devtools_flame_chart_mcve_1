import 'package:flutter/material.dart';

extension DurationUtils on Duration {
  double get inSecondsDouble => inMicroseconds / Duration.microsecondsPerSecond;
}

void main() {
  runApp(const MyApp());
}

int fib(int n) {
  if (n == 0) {
    return 0;
  } else if (n == 1) {
    return 1;
  } else {
    return fib(n - 1) + fib(n - 2);
  }
}

class MyAppModel {
  final int fibonacciNumber;

  MyAppModel({
    required this.fibonacciNumber,
  });

  // This represents the loading of the "domain model" object, including all
  // necessary asynchronous and synchronous computations.
  static Future<MyAppModel> load() async {
    final timestamp1 = DateTime.now();

    // This delay simulates I/O operations, like reading a crucial user information
    // from a database.
    await Future<void>.delayed(const Duration(seconds: 5));

    final timestamp2 = DateTime.now();

    // This represents  a  far-to-long synchronous computation. In this case, it's
    // an algorithm with O(2^n) time complexity, which could be optimized to O(n).
    // Actually, this is kind of realistic.
    final fibonacciNumber = fib(41);

    final timestamp3 = DateTime.now();

    final ioDuration = timestamp2.difference(timestamp1).inSecondsDouble;
    final syncDuration = timestamp3.difference(timestamp2).inSecondsDouble;

    print(
      "IO duration: $ioDuration seconds, sync computation duration: $syncDuration seconds",
    );

    return MyAppModel(
      fibonacciNumber: fibonacciNumber,
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<MyAppModel>? _myAppModelFuture;

  var _isStarted = false;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // A button for "starting the app". The real app wouldn't, of course,
            // have such. Tt allows to start CPU profiling just at the right
            // time.
            ElevatedButton(
              child: const Text("Start"),
              onPressed: !_isStarted
                  ? () {
                      setState(() {
                        _myAppModelFuture = MyAppModel.load();
                        _isStarted = true;
                      });
                    }
                  : null,
            ),
            Center(
              child: FutureBuilder(
                future: _myAppModelFuture,
                builder: (
                  BuildContext context,
                  AsyncSnapshot<MyAppModel> snapshot,
                ) {
                  final myAppModel = snapshot.data;
                  if (myAppModel != null) {
                    return _ReadyMyApp(
                      myAppModel: myAppModel,
                    );
                  } else {
                    // A loader indicating a state when the app is not really
                    // considered started. It's not yet usable at this point.
                    return const SizedBox(
                      width: 128,
                      height: 128,
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      );
}

// The user interface of the ready (initialized) app
class _ReadyMyApp extends StatelessWidget {
  final MyAppModel myAppModel;

  const _ReadyMyApp({
    Key? key,
    required this.myAppModel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      Text("Fibonacci number: ${myAppModel.fibonacciNumber}");
}
