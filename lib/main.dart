import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final fitCrimson = Color.fromARGB(255, 119, 0, 0);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: fitCrimson,
            dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
          ),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  Map<dynamic, dynamic>? _data;
  bool _isLoading = true;

  // Getter for data
  Map<dynamic, dynamic>? get data => _data;

  // Getter for loading state
  bool get isLoading => _isLoading;

  MyAppState() {
    // Fetch data when state is initialized
    fetchData();
  }

  // Fetches all data from the database
  Future<void> fetchData() async {
    _isLoading = true;
    notifyListeners();

    try {
      DataSnapshot snapshot = await _database.get();
      if (snapshot.exists) {
        _data = snapshot.value as Map<dynamic, dynamic>;
      } else {
        print("No data available");
        _data = {};
      }
    } catch (e) {
      print("Error fetching data: $e");
      _data = {};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Write data to a specific path
  Future<void> writeData(String path, dynamic value) async {
    try {
      await _database.child(path).set(value);
      // Refresh data after write
      await fetchData();
    } catch (e) {
      print("Error writing data: $e");
    }
  }

  // Update specific data
  Future<void> updateData(String path, Map<String, dynamic> updates) async {
    try {
      await _database.child(path).update(updates);
      // Refresh data after update
      await fetchData();
    } catch (e) {
      print("Error updating data: $e");
    }
  }

  // Delete data at a specific path
  Future<void> deleteData(String path) async {
    try {
      await _database.child(path).remove();
      // Refresh data after delete
      await fetchData();
    } catch (e) {
      print("Error deleting data: $e");
    }
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = LoginPage();
      case 1:
        page = Placeholder();
      default:
        throw UnimplementedError('no widget for selected index $selectedIndex');
    }

    return Stack(
      children: [
        Container(color: Theme.of(context).colorScheme.primary),
        Scaffold(backgroundColor: Colors.transparent, body: page),
      ],
    );
  }
}
