import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'package:pdh_recommendation/navigation_controller.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final Color fitCrimson = const Color.fromARGB(255, 119, 0, 0);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MyAppState(),
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'PDH Recommendation',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: fitCrimson,
            dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
          ),
        ),
        // Use AuthWrapper as the home; it will display the appropriate screen.
        home: const AuthWrapper(),
      ),
    );
  }
}

/// AuthWrapper listens to the FirebaseAuth state and returns
/// either the NavigationController (if logged in) or a Scaffold containing LoginPage.
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // When the connection is active, determine which page to show.
        if (snapshot.connectionState == ConnectionState.active) {
          final User? user = snapshot.data;
          if (user == null) {
            // Wrap the LoginPage in a Scaffold to provide Material context.
            return Scaffold(
              body: LoginPage(),
              backgroundColor: Theme.of(context).colorScheme.primary,
            );
          } else {
            // Assume NavigationController already includes its own Scaffold.
            return Scaffold(body: NavigationController());
          }
        }
        // While waiting for authentication state, show a loading indicator.
        return Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}

/// MyAppState remains unchanged and provides global database state.
class MyAppState extends ChangeNotifier {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  Map<dynamic, dynamic>? _data;
  bool _isLoading = true;

  // track nav bar index
  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;

  void setSelectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  // Getter for data
  Map<dynamic, dynamic>? get data => _data;

  // Getter for loading state
  bool get isLoading => _isLoading;

  MyAppState() {
    // Fetch data when state is initialized.
    fetchData();
  }

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

  Future<void> writeData(String path, dynamic value) async {
    try {
      await _database.child(path).set(value);
      await fetchData();
    } catch (e) {
      print("Error writing data: $e");
    }
  }

  Future<void> updateData(String path, Map<String, dynamic> updates) async {
    try {
      await _database.child(path).update(updates);
      await fetchData();
    } catch (e) {
      print("Error updating data: $e");
    }
  }

  Future<void> deleteData(String path) async {
    try {
      await _database.child(path).remove();
      await fetchData();
    } catch (e) {
      print("Error deleting data: $e");
    }
  }
}
